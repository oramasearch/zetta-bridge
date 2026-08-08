---
name: new-agent
description: "Create a new scaffolded agent module for the Zetta bootstrap - a private repo under oramasearch, Python + uv, added as a submodule sibling to zetta. Use when adding one of the five agents (autosuggest profile/tasks, project profile/build, eval generator) or any new agent that calls the Zetta platform over /v1. Covers the repo layout, deriving the tool surface from the node's OpenAPI rather than hand-writing it, trace recording as the deliverable, grading by deterministic graders instead of a rubric, and the definition of done. Triggers - 'create an agent', 'new agent module', 'scaffold an agent', 'add agent-*', 'build the autosuggest agent', 'build the project agent'."
---

# new-agent — scaffold an agent for the Zetta bootstrap

Read [`docs/agent-scaffold.md`](../../docs/agent-scaffold.md) first — it owns the definitions
(what a profile is, discovery vs capture, the bootstrap sequence). This skill is the procedure.

Tracking: [zetta#986](https://github.com/oramasearch/zetta/issues/986).

## Two kinds of agent, and they differ more than they look

**A doing-agent** performs a task against a live node — `agent-eval-generator` invents profiles by
calling `/v1`. Its tools come from the node's OpenAPI and its failure mode is a tool surface that
lies.

**A corpus-agent** generates training data — `agent-autosuggest-corpus`,
`agent-project-corpus`. It calls **no node**: it invents situations and the correct answers to
them. Its failure mode is producing examples that look right and teach nothing, so it lives or dies
on its **defect checks** (§3b).

Both record traces, both are private repos with uv, both publish to the private HF org. Everything
below applies to both unless it says otherwise.

## Before you start

**The agents are built in Python with frontier models first**, then ported to C++ only once eval
scores prove the solutions work. Building one in C++ because the engine is C++ is the mistake this
sequence exists to prevent — the previous attempt did exactly that and produced four checkpoints
with no broad gain.

## 1 · Create the repo

**Private, always.** A fork or a public repo publishes org and product context and cannot be made
private afterwards.

```sh
gh repo create oramasearch/agent-<name> --private \
  --description "<Agent N> — <one line> (zetta#986)"
gh repo view oramasearch/agent-<name> --json visibility   # verify BEFORE pushing anything
```

## 2 · Scaffold with uv — never pip

```sh
uv init --name agent-<name> --package --python 3.12
uv add openai httpx pydantic
```

```
agent-<name>/
  CLAUDE.md            points at docs/agent-scaffold.md; only agent-specific rules here
  README.md            what it does, its eval scores, its KNOWN FAILURES
  pyproject.toml       [project.scripts] entry point
  src/agent_<name>/
    agent.py           the loop: prompt -> tool calls -> observation -> next call
    tools.py           ZettaClient + derive_tool_specs
    trace.py           the recorder
    prompts/vN.md      versioned - a prompt change is a model change
  traces/              COMMITTED. The deliverable, not logs.
  evals/               generated cases + the grader that scores them
  reports/             dated eval reports
```

## 3 · The five rules — each learned by getting it wrong

**1. Tool calls go to a live node.** No mock transport, no `if testing:` branch. If the node is
down the agent fails rather than pretending. An agent scaffolded against mocks proves nothing about
whether the platform supports the job, which is the question the bootstrap exists to answer.

**2. Derive the tool surface from the node's OpenAPI.** Never hand-write it. `derive_tool_specs`
reads `/v1/openapi.json`; keep a static table only as the no-node fallback.

> The eval generator's first run failed because a hand-written spec said the parameter was `name`
> when the capability required `dataset` — the exact failure the repo's "render from source, never
> retype" rule exists to prevent, made on the first attempt.

**3. Record every run as a trace, including failed tool calls.** The traces become SFT and RLVR
data, so a run that was not recorded did not happen — and an agent that never sees its own failures
cannot learn to avoid them.

> Recording the failure is how we caught the model responding to a 400 with *"Since the list of
> datasets indicates its availability, I can still provide an eval case based on the description"*
> and then **inventing the schema**. That would have looked like a successful run.

**4. Grade with Zetta's deterministic graders over `/v1`** — never a rubric, never an LLM judge,
and put the grade **in the trace**. A trace that passes a grader is training data; one that merely
looks plausible is not. A trace with no grade cannot become training data without someone deciding
after the fact whether it was good, which is the judgement call graders exist to remove.

**5. Version the prompts.** `prompts/v1.md`, and the trace records which version it ran under.
Traces from different prompt versions are not comparable.

## 3b · A corpus-agent lives on its defect checks

Nobody reviews 10,000 training examples. The checks are the review, and every one should exist
because something weak got through without it. From the two corpus agents built so far:

- **Structural**: a tool-calling trajectory needs ≥2 calls, and every call after the first must
  name the **observation** that justified it. *"Because the user asked for churn"* is a scripted
  step; *"because `get_dataset` reported 11.4% null ids"* is a read.
- **Vocabulary**: an id where an id belongs. `solution` must be `S-1`, not *"Predict high-value
  purchase likelihood"* — the id is what lets a downstream agent look up the correctness profile.
- **Non-restatement**: a field that justifies against a constraint must not repeat the constraint.
  *"Provides actionable insights"* against *"must provide actionable insights"* says nothing.
- **Substance**: a constraint must **narrow** what a good answer is — a number, a prohibition, an
  ordering. *"Must be data-driven"* is decoration.
- **Domain**: the methodology's required and forbidden fields, mirroring zetta's correctness cores.
  A forecast that carries `calibrated` is the churn recipe misapplied.
- **Coverage**: something must be declined, and the reason must match the answer.
  *Discovered-but-not-captured* → **"capture it first"**; a missing label is **not** fixed by
  capturing.
- **Balance**: alternate the example kinds rather than hoping for a mix. `agent-project-corpus`
  alternates create/mutate because mutation is the harder half and the easier half to
  under-represent.

### When a check rejects almost everything, teach the prompt — never loosen the check

This has now happened three times and gone the same way each time:

| Corpus | First run | After teaching the prompt |
|---|---|---|
| Auto-Suggest constraints | **0 of 6** kept | 50%, every rejection genuine |
| Project trajectories | 1 of 4 | 50% |
| Project methodology fields | 50% | **18 of 40**, rejections now catching real domain errors |

What worked each time was **a worked example in the prompt** — a good `because` chain beside four
bad ones, a table of decoration-vs-real constraints, the exact required/forbidden fields per
methodology. Not softer thresholds.

## 4 · Wire it into the bridge

**Sibling to `zetta`**, not inside `zetta/modules/` — that holds vendored third-party dependencies,
and an agent placed there would make the engine appear to depend on something that depends on it.

```sh
cd zetta-bridge
git submodule add git@github.com:oramasearch/agent-<name>.git modules/agent-<name>
```

Then add it to the bridge's `CLAUDE.md` module list. **Check `git status` before committing** — a
`git add -A` here sweeps unrelated submodule pointer bumps into the commit, and git's
embedded-repo warning is easy to scroll past (it happened; a clone would have had an empty
directory with no way to fetch it).

## 4b · Training data and eval data must never overlap

If the agent generates **training** data for a model that is **evaluated** on another dataset, the
two must be disjoint — otherwise every eval score measures memory rather than reading, and nothing
downstream can tell the difference.

**Enforce it, do not document it.** `agent-autosuggest-corpus` refuses to start if it cannot load
the eval set to check against; generating blind risks silent contamination. Near-misses count
(>60% overlap of industry and table names), and the off-limits list goes to the model **up front**
rather than rejecting after the call — 12 of 40 generations were wasted before that change.

## 5 · Definition of done

Not "the agent exists".

- [ ] Completes its task against a **live node**, not mocks.
- [ ] Traces recorded in a form step 2 can consume, failures included.
- [ ] **Eval scores from generated cases, graded by Zetta's graders**, in a dated report.
- [ ] README states its **known failures**, not only its wins.

That last one is not politeness. A README listing intentions as achievements is what the model-card
rule exists to prevent, and step 4's port comparison needs a real number to beat.

## Never

- ❌ pip. Use uv.
- ❌ A public repo, or a fork of one.
- ❌ A hand-written tool surface.
- ❌ Swallowing a failed tool call.
- ❌ Grading by rubric or LLM judge.
- ❌ Annotating generated data as awkward. Awkwardness lives **in the data**; whether the agent
  notices is what the eval tests. The bar: perturb one fact and the right answer must change.
- ❌ Claiming eval scores that have not been run.

## Related

- [`docs/agent-scaffold.md`](../../docs/agent-scaffold.md) — the definitions.
- **rlvr-training-data**, **use-case-corpus** (in `modules/zetta`) — what the traces become.
- **github-ops** — issue and PR conventions.

## Version History
- v1.1.0 (2026-08-07) — Split doing-agents from corpus-agents; added the defect-check catalogue
  and the rule that a check rejecting everything means teaching the prompt rather than loosening
  the check (measured three times); added the training/eval disjointness requirement and that it
  must be enforced rather than documented.
- v1.0.0 (2026-08-07) — Initial, distilled from building `agent-eval-generator`: the OpenAPI-derived
  tool surface, trace-recording including failures, grading by deterministic graders, and the
  sibling-not-nested module placement.
