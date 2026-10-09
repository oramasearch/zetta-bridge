# The agent scaffold — bootstrapping in Python before porting to C++

Tracking: [zetta#986](https://github.com/oramasearch/zetta/issues/986).
Direction set 2026-08-07 (*Zetta Evals and Model Development*), superseding the C++-first
sequencing that [zetta#983](https://github.com/oramasearch/zetta/issues/983) was planned against.

## The sequence

1. Build the agents **in Python with frontier models** (OpenAI tooling) and standard ML libraries.
   Tool calls go to a live Zetta node over `/v1`.
2. **Record every run as a trace.** Traces become the starting point for SFT and RLVR.
3. Build the **solutions** in Python too, with known ML libraries — industry-standard tooling,
   focused on producing results that actually work.
4. **Only then** re-implement in C++ / Zetta with our own models, and **compare eval scores**
   between the Python + frontier scaffold and the custom implementation.

The point is doing less at once: solve the simpler problem with known tools before the
exceptional implementation.

**Why, from measured evidence.** The C++-first attempt produced a clean split: the engine work
went well (forecast executable, gate checks, Monitor/Improve capabilities, 2009 tests green) while
four rounds of hand-authored corpus produced four narrow fixes and no broad gain — **v13, trained
before any of it, still had the best turn-1 behaviour.** Recording what a frontier model actually
does removes the guessing that failed four times.

## The agents — one module each

Each agent is its own **private repo**, added as a submodule under `zetta-bridge/modules/`,
**sibling to `zetta`**.

| Module | Agent |
|---|---|
| `agent-eval-generator` | 5 — eval profiles (the **test set**) |
| `agent-autosuggest-corpus` | the **training set** for Auto-Suggest: profile → project profile |
| `agent-project-corpus` | the training set for **the main agent**: project profile + intent → a Pipeline, built by **tool calls**, and mutated on request |
| `agent-autosuggest` | 1+2 — the **runtime** Auto-Suggest agent: a profile in, a project profile out |
| `agent-project` | 3+4 — the **runtime** main agent: builds and changes Pipelines by calling tools |
| `agent-runtime` | the **blank Python agent** that runs every user-created agent in lake: loads its definition from Zetta or a lake repository, tools derived from lake's filtered OpenAPI and its skills ([zetta#1016](https://github.com/oramasearch/zetta/issues/1016)) |
| `agent-ask-orama` | **Ask Orama**, the general agent for all of lake: reads as the person, proposes every change, delegates to any agent ([zetta#1018](https://github.com/oramasearch/zetta/issues/1018)) |
| `agent-creator` | **AgentCreator**, the Agent Factory's agent: a definition on `agent-runtime` that proposes new agents and creates nothing ([zetta#1017](https://github.com/oramasearch/zetta/issues/1017)) |

**The runtime agents have no model attached yet.** They run a frontier model with few-shot examples
retrieved from the corpus modules above, which is the bootstrap the whole document describes: get a
scaffold producing production-grade results first, then replace the frontier model with a trained
one and compare. It also means the corpora are continuously exercised rather than sitting unread
until a training run — a corpus nothing consumes is a corpus nobody notices is wrong.

**Retrieval is over the SITUATION, never the answer.** Both agents match on industry, table names,
column names, capture state, the intent and (for a change) the pipeline being changed — all things
they are handed. Retrieving by the answer would show the model what it is supposed to conclude,
which is leakage in the shape of a helpful prompt.

**The solutions catalogue is injected as context, not exposed as a tool.** Reached through a tool it
anchors every run on whatever came back first — the failure that made three eval-generator runs
produce the same domain. It is also the vocabulary: without it the model invents plausible ids
(`S-31` against a catalogue whose highest is `S-23`). A catalogue that cannot be built raises rather
than returning empty, because an empty one makes the id check vacuously pass and the validator then
reports an answer with invented ids as clean.

**Sibling, not inside `zetta/modules/`.** That directory holds vendored third-party dependencies
(`capy`, `corosio`, `automerge-cpp`, `beast2`, `libpqxx`, `oramacore-cpp`). The agents are
first-party products that *call* the engine over `/v1`; putting them there would make the engine
appear to depend on things that depend on it.

**A module each, not one repo with five packages.** Each agent has its own eval scores, its own
trace corpus, and its own port decision at step 4 — those are the units being compared. Bundling
them means one agent's regression hides inside an aggregate, which is the same shape as the catalog
defect where 30 solutions hid behind the one that worked.

## What a profile is

**A profile is a situation**: who someone is, what they are responsible for, and what data they
can reach. It is **not** a task, an intent, or an RL environment — those are later layers.

A first draft that named the traps and pre-decided the correct answers had to be discarded: every
downstream eval built on it would have been a memory test rather than a reading-the-data test.

### A profile has three parts

**1. The person and their situation.** Role, tenure, what they are measured on, what they can
actually act on. These constraints are load-bearing: a fleet director who can dispatch 40
preventive jobs a month, an insurance VP required to explain any individual decision, a supply
chain lead whose roasting orders lock every Tuesday. The **same data** has different correct
answers under different constraints, and only the role encodes that.

**2. Connections and their capture state.** Two distinct states, and conflating them produces
ungradeable cases:

- **Discovery** — connect to a source and introspect it: tables, columns, types, null rates. Tells
  you what *could* be used.
- **Capture** — fully download the source into Zetta **parquet partitions**. After capture the
  connection is no longer needed to train.

**A pipeline that trains needs captured data, not a live connection.** So a task can be
unsupportable for two reasons with *different answers*: the data genuinely cannot support it
(no label, no timestamp, a null rate that biases every aggregate) → decline and name what is
missing; or it is **discovered but not captured** → **"capture it first"**, not "cannot be done".
An agent that never declines builds something worthless when asked; one that declines when the
answer is *capture it first* is just as wrong.

**3. Data, schemas and records.** A profile is not a description of data — it **comes with the
data**: real schemas and real records, generated alongside the situation.

**Profiles are an eval dataset, published to HuggingFace.** They are a *tool for evaluating models
and agents*, not a fixture to be loaded into an engine. Loading a profile into Zetta is something
we may do later; it is not what a profile is for, and building the loader first was a wrong turn
taken on 2026-08-07.

## What a profile is FOR — the evaluation chain

```
profile  ──►  Auto-Suggest model   ──►  a set of candidate TASKS
                                             │
profile + chosen intent  ──►  Project-creation agent  ──►  a Pipeline / Project
```

Two models are scored against the same profile, at different points:

1. **Auto-Suggest** reads the profile and proposes the tasks worth doing. It is scored on whether
   the set it proposes is the right set for *that* situation — which is why the role and its
   constraints are part of the profile, and why the awkwardness has to live in the data rather than
   in an annotation.
2. **Project creation** takes the profile plus a chosen intent and builds the Pipeline. It is
   scored on whether the Pipeline is correct and production-grade for that data.

A profile therefore has to be **self-contained and portable**: situation, schemas, and records
together, in a form a model can be evaluated against without a running Zetta node. That is what
makes HuggingFace the right home for it — the same discipline as the corpora
(`OramaSearch/base-agent-interaction-corpus`): private, versioned, and carrying a card that states
its limitations rather than only its size.

### Describe the data neutrally

Awkwardness lives in the data, not in the prose. A `closed_at` that is null on 31% of rows, a
`total_paid` populated only at close, a subscription table that makes demand largely
deterministic — the profile states these as facts and **does not say they are traps**. Whether the
agent notices is exactly what the later layers test.

The test for a good profile: **perturb one fact and the right answer should change.** If it does
not, the case measures recall of the ask rather than reading of the data.

## Training data and eval data must never overlap

The eval profiles are the **test set** for Auto-Suggest. A training corpus that overlaps them makes
every eval score a measurement of **memory rather than reading**, and nothing downstream can tell
the difference — the model looks fine right up until it meets data nobody wrote an answer key for.

So the two are generated **independently**, by different agents, into different datasets:

| Dataset | Purpose | Generated by |
|---|---|---|
| `OramaSearch/agent-eval-profiles` | **test set** — score Auto-Suggest and project creation | `agent-eval-generator` |
| `OramaSearch/autosuggest-sft-corpus` | **training set** — teach Auto-Suggest | `agent-autosuggest-corpus` |

**Enforced, not documented.** `agent-autosuggest-corpus` refuses to start if it cannot load the
eval set to check against — generating blind risks silent contamination. Near-misses count: a
candidate sharing more than 60% of its industry and table names with an eval profile is rejected,
and the off-limits industries are given to the model up front rather than rejected after the call.

### The output shape is a contract between two models

An Auto-Suggest training example is `(profile → project profile)`, and that **project profile is
the same shape the project-creation agent consumes**. Auto-Suggest proposes the approach; the
project agent turns it into a Pipeline and chats about it. One shape means the two compose instead
of needing a translation layer that can drift out of sync.

## The main agent is tool-calling, so its corpus is trajectories

`agent-project-corpus` trains the agent that builds and changes Pipelines. An example is a
**trajectory** — `ask → call → observation → next call decided by that observation → Pipeline` —
and every call after the first must name the observation that justified it. A call justified by the
user's ask is a scripted step, and a scripted trajectory is a lookup with extra steps.

**Mutations are half the corpus by construction.** Changing a Pipeline is the harder half of the
product and the easier half to under-represent: *"add calibration to that"*, *"actually use the
last 90 days"*, *"that ran too long"*. A mutation carries the pipeline **before**, because what
must not change is as much of the lesson as what must — a mutation that silently rebuilds has lost
the user's work.

### SFT then RLVR, and the order is measured

RLVR sharpens what a policy **already sometimes does**; it cannot originate a capability. A
campaign against a policy that never emits a pipeline returns a uniformly zero reward, and a group
with equal rewards has **zero advantage** — GRPO takes a null step and the run cannot learn however
long it goes. That was measured
([zetta#859](https://github.com/oramasearch/zetta/issues/859)), not assumed.

So the corpus has one job: get the policy to *sometimes* build a correct pipeline. The loop takes
it from there, and it works — reward rose 0.52 → 1.00 over 16 steps against the deterministic
graders.

## What makes it a bootstrap rather than a demo

1. **Tool calls go to a live node over `/v1`.** No mock transport, no `if testing:` branch — if the
   node is down the agent fails rather than pretending. An agent scaffolded against mocks proves
   nothing about whether the platform supports the job.
2. **The tool surface is derived from the node's own OpenAPI**, never hand-written. The first run
   of the eval generator failed because a hand-written spec said the parameter was `name` when the
   capability required `dataset` — the exact failure the "render from source, never retype" rule
   exists to prevent, made on the first attempt.
3. **Every run is recorded as a trace, including failed tool calls.** Step 2 turns these into SFT
   and RLVR data, so a run that was not recorded did not happen — and an agent that never sees its
   own failures cannot learn to avoid them.
4. **The grade is part of the trace**, and grading is by **Zetta's deterministic graders over
   `/v1`** — never a rubric, never an LLM judge. A trace that passes a grader is training data; one
   that merely looks plausible is not. This is what makes a recorded trace *verifiable rather than
   imitated*.
5. **Evals are generated, never hand-written.** Hand-written evals inherit the author's blind
   spots — measured twice: an acceptance test asserting only that consecutive replies differ passed
   a model that answered *"create me a churn project"* with a description and then fabricated; a
   campaign test asserting `best_reward > 0` passed a policy that had collapsed to zero. Both were
   caught by reading outputs, not by the tests.

## Definition of done

Not "the agents exist in Python". Done is **eval scores from the Python + frontier scaffold,
recorded**, so step 4's comparison has a baseline to beat. Without that number the port has nothing
to be measured against — which is the failure this sequence exists to avoid, and the one the
C++-first attempt walked into.

Per agent: it completes its task against a live node · its traces are recorded in a form step 2 can
consume · it has eval scores from generated cases graded by Zetta's graders, in a dated report ·
its README states its known failures, not only its wins.

## What carries over from the C++ work

- **The deterministic graders and the admission gate** — what make a trace verifiable. The RLVR
  loop already learns against them (reward 0.52 → 1.00 over 16 steps, zetta#859).
- **The seven correctness profiles** — `supervised_core`, `forecast_core`, `unsupervised_core`,
  `retrieval_core`, `decisioning_core`, `perception_core`, `uncertainty_core`. They encode what
  production-grade means per methodology and are language-independent, so Python solutions get
  graded against the same bar.
- **`model_health` and `propose_improvement`** — the Monitor and Improve verbs, callable from any
  scaffold.

## What is ahead of proof

`train_forecast` beats a mean baseline on **synthetic seasonal data**. That is not evidence it
works on a customer's data. If the Python scaffold finds a different pipeline shape wins on real
data, the cores and gate checks encode assumptions that need revisiting — better known before the
step-4 comparison than after.
