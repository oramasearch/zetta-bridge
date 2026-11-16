# Zetta Bridge Repo

## What is Orama Zetta

**Orama Zetta turns a question into running, deployed intelligence.** Describe a data or AI problem in plain language — or hand over an artifact you already have (an n8n workflow, a SQL script, a notebook) — and Orama Zetta architects a correct data + AI pipeline, deploys it onto infrastructure *you* control (your k8s / AWS / Azure / GCP / on-prem), and runs it — **training models natively on the node rather than prompting a rented one**. (**"Customer training" means the customer training a model on their own data — their data, their model.** That is core. It does *not* mean forking and retraining our base agent per customer, and it does not mean training the customer. Board clarification 2026-08-17, correcting an earlier note here that wrongly recorded the capability as off the roadmap.) *"The data engineer, the AI engineer, and the platform engineer — in a bottle."* It compresses the time from **intent → deployed, correct intelligence** from quarters to hours: **Intelligence Velocity for Big Thinkers.** Full framing: [`docs/projects/orama-platform-2/one-pager.md`](https://github.com/oramasearch/amaro-bridge/blob/main/docs/projects/orama-platform-2/one-pager.md).

**How it works — one flow:** *Ingest* (plain language + the artifacts you already have) → *Architect* (compile a correct execution graph, validated before it runs) → *Deploy* (one button onto your target; your data never leaves) → *Run*. Why it's different: it **trains models natively** on your infrastructure rather than running inference over a rented model, is **correct by construction** (every graph passes a correctness gate before deploy), runs **compute-near-data** with hot→cold→re-warm tiered storage, and is **governed self-serve** (in your environment, identity-scoped, audited).

**Orama Zetta is the platform. Orama Studio is the UI that sits on it.** The platform is the product — storage, indexes, native training, execution, clustering, deploy. Studio is the human surface over it, and is the rebrand and rebuild of what was Amaro Desktop (announced to a customer on 2026-07-27). `oramasearch/zetta` is the platform repo; the older name *"ZettaDB"* is **retired** and `zetta` is the repo/binary codename.

**What runs today** (verified against a running node, 2026-07-25/26 — see [`motive-delivery/demo-script.md`](https://github.com/oramasearch/orama-bridge/blob/main/docs/projects/motive-delivery/demo-script.md)): the whole path **intent → Pipeline → Verify → Deploy → Run → ranked scores + drivers → act**, with lineage, trace and audit on every step · a churn model at **AUC 0.880 / accuracy 0.828** on 500 accounts with native TreeSHAP drivers · entity resolution correct at division level · n8n import and compile · native synthetic data generation · distributed search · **native GPU training measured on an A100** · and the **read surface across the web app live, not fixtures**.

**Still in flight:** the **learning loop**, tiered storage, Auto-Suggest, and Experiences. The claims split that governs what may be repeated to a customer is [`product-claims.md`](https://github.com/oramasearch/orama-bridge/blob/main/docs/projects/motive-fde-engagement/product-claims.md); the product definition of record is [`roles/cpo/product-definition.md`](https://github.com/oramasearch/orama-business-model/blob/main/roles/cpo/product-definition.md).

This **zetta-bridge** repo is **not** the product — it's just a way to **group all the GitHub repos that make up the Orama Zetta project** (the product code, its technical docs, websites, …) as git submodules, so Claude Code (or a human) can work across them at once. It is **deliberately separate from `amaro-bridge`** and is **not** a submodule of it.

## Bridge repo purpose

A bridge has **no build, no runtime, no tests** of its own. The real code lives in the submodules under `modules/`. On top of the submodule manifest, the bridge holds cross-module docs and the conventions below. Read each module's own `CLAUDE.md` before working inside it.

## Modules

Each module has (or will have) its own `CLAUDE.md` / `README.md` — **read those first** before editing inside a module.

### `modules/zetta` — Orama Zetta (the platform; Studio is the UI on it)

Private, **C++26**. The **platform** repo — product docs in `docs/product/`, the Studio UI docs in `docs/gui/`. **Under the hood today:** an equal-peer, **CRDT-replicated** store (from-scratch C++ Automerge, ~90M ops/sec on 30 cores), JSONL on-disk storage + large objects, a Postgres-SQL **subset** parser on a dialect-neutral AST, coroutine-native networking (Corosio), and **headed** (SDL3 + Dear ImGui — the desktop is itself a cluster member) + **headless** modes. `CMakeLists.txt` build; has its own `CLAUDE.md`. **In flight (not yet built):** tiered storage, compute-near-data (embedded Lua/Orly + DDF API), and the Postgres wire protocol. The GUI/control plane, indexing, distributed search and k8s deploy have since landed — see the verified list above. Imported from `homer6/zetta`.

### `modules/zetta-docs` — the blueprint docs website

Private, **MkDocs Material** (markdown + pre-rendered Graphviz SVGs), Railway-hosted via `Dockerfile` + `railway.toml`. The browsable rendering of the **Orama Zetta blueprint** — strategy, architecture/ADRs, domain model, data, security, UX, delivery, backlog, testing, risks, governance, glossary, diagrams. **Generated, not hand-edited.** The `.sync/` generators live here: `create_issues.py` (wtm → keyed GitHub issues) and `render.py` (wtm → docs pages + diagrams). Run: `mkdocs serve`. Don't edit `docs/*.md` by hand — re-run the sync.

### `modules/solutions-designs` — enterprise AI solution designs

Private, docs-only (no build/runtime/tests). A working space where a real-world **enterprise AI problem** is taken end-to-end into a concrete **Orama Zetta solution design**. Worked in **strict stages — evidence & ideas → analysis → design** (we don't jump ahead). One folder per solution under `solutions/<slug>/`; `templates/solution/` is the scaffold. Has its own `CLAUDE.md`. The governing rule for the current stage: **collect, don't conclude** — gather raw evidence + loose ideas, no analysis/ranking/design until explicitly moved on.

### `modules/agent-*` — the Python agent scaffold

Private, **Python + uv** (never pip), one repo per agent, **sibling to `zetta`**. The bootstrap
direction set 2026-08-07: build the agents in Python with frontier models, record the traces, and
only then re-implement in C++ with our own models — comparing eval scores between the two.
The lake-facing agents are modules here too: `agent-runtime`, `agent-ask-orama` and
`agent-creator` (see *Agents in lake* below). Four data modules exist — `agent-eval-generator` (eval profiles), `agent-autosuggest-corpus` and
`agent-project-corpus` (SFT data) — alongside two **runtime** agents, `agent-autosuggest` (a profile
in, a project profile out) and `agent-project` (builds and changes Pipelines by calling tools).

**The runtime agents have no model attached yet** — a frontier model plus few-shot examples
retrieved from the corpora. Two rules they both hold to: retrieval matches on the **situation and
never the answer** (matching the answer shows the model what it is supposed to conclude), and the
solutions catalogue is **injected as context, not exposed as a tool** (a tool anchors every run on
whatever it returned first, and without the catalogue the model invents ids like `S-31` against a
catalogue whose highest is `S-23`).

**Training data and eval data must never overlap.** The eval profiles are the *test set* for
Auto-Suggest, so `agent-autosuggest-corpus` generates its own situations and refuses to start if it
cannot load the eval set to check against — contamination would make every eval score a measurement
of memory rather than reading.

**Read [`docs/agents/scaffold.md`](docs/agents/scaffold.md) before touching any of them.** It owns
the load-bearing definitions: what a **profile** is (a *situation* — role, responsibilities, the
data they can reach — **plus the materialized data itself**, not a task or an intent), the
**discovery vs capture** distinction that decides whether a task is supportable, and the five rules
that make this a bootstrap rather than a demo (live node not mocks · tool surface derived from the
node's OpenAPI · every run recorded as a trace including failures · grading by Zetta's
deterministic graders, never a rubric or an LLM judge · evals generated, never hand-written).

Sibling to `zetta` rather than inside `zetta/modules/`, which holds vendored third-party
dependencies — the agents are first-party products that *call* the engine over `/v1`.

**Creating an eval profile: use the [`new-eval-profile`](.claude/skills/new-eval-profile/SKILL.md)
skill.** Give it a seed — an industry, a role, a pain point — and it researches the rest, writes
the situation, generates real records, and publishes to `OramaSearch/agent-eval-profiles`. Schema
and field rules: [`modules/zetta/docs/agent/eval-profiles.md`](modules/zetta/docs/agent/eval-profiles.md).

**Every agent repo has a private Docker Hub repository of the same name** (`oramasearch/agent-<name>`),
created private **before** its first image push, with the anonymous 404 check after (Steve,
2026-09-26; the org rule in the umbrella `CLAUDE.md`). A first push otherwise creates it **public**.

**Agents in lake (the Agents epic, https://github.com/oramasearch/lake/issues/228).** Exposed the way
the Zetta web UI (Studio, orama-design `src/studio/`) designs it, with two families that must not
be conflated:

- **Specialized Orama agents**, each its own repo and private image. **Ask Orama**
  (`agent-ask-orama`, https://github.com/oramasearch/zetta/issues/1018) is the **general agent for
  all of lake**: a panel on every page that acts as the signed-in person and can **delegate to any
  agent as a subagent, including user-created ones**. `agent-project` (builds and changes
  Pipelines: *Create a Solution*) and `agent-autosuggest` (Workspace Profile → *Discover
  Opportunities*) are the others. They are **not** run on `agent-runtime`.
- **Custom agents**, which people build in lake's **Train → Agents** (Studio's shape: purpose, work
  area, manifesto, goal, skills, model, trigger), by form or with the **Agent Factory**
  (**AgentCreator**, `agent-creator`, OpenAI SDK). They are native (the Orama base model in Zetta,
  on GPU or CPU) or Python on **one blank image, `agent-runtime`**, which loads their instructions
  and code from Zetta or a lake repository. So a new custom agent is a definition, never a repo or an
  image.

Conversation happens in Ask Orama; Train → Agents is for building agents and reading what the
unattended ones did. Every agent reaches a workspace's Zetta **through lake**, never with the admin
token, and can call **approved Pipelines as tools**
(https://github.com/oramasearch/lake/issues/238). Python agents use **one general Orama OpenAI
key**.

**Making a solution or methodology actually run: use the
[`add-solution-module`](.claude/skills/add-solution-module/SKILL.md) skill.** The engine trains M-1
(GBDT) and part of M-10 today; every other methodology is an issue under
[zetta#984](https://github.com/oramasearch/zetta/issues/984) (zetta#1041-#1060, the registry
zetta#1061, featurization zetta#1062). The skill carries the whole path: Zetta trainer, registry,
compiler shape, run path, gate checks, lake, and every agent that designs or teaches pipelines.

**Creating an agent: use the [`new-agent`](.claude/skills/new-agent/SKILL.md) skill.** It carries the
procedure — private repo verified before pushing, uv not pip, the tool surface derived from the
node's OpenAPI, traces recorded including failures, grading by deterministic graders — and the
definition of done, which is eval scores rather than the agent existing.

## The blueprint + sync model

Orama Zetta is designed **blueprint-first**. The single source of truth is the **worktree-manager (wtm) project `ORAMA-ZETTA`** — 278 artifacts across 14 domains + their traceability relations. The blueprint is projected onto two **regenerable** surfaces:

1. **GitHub issues** on [`oramasearch/zetta`](https://github.com/oramasearch/zetta/issues) — one keyed, cross-linked, agent-ready issue per artifact (`[FEAT-3]`-style title, `#number` traceability links, Definition of Done, code-repo + docs + source-of-truth references). Driven by [`modules/zetta-docs/.sync/create_issues.py`](modules/zetta-docs/.sync/create_issues.py).
2. **Docs site** — [`modules/zetta-docs`](modules/zetta-docs/) renders one page per domain + 3 Graphviz diagrams. Driven by [`modules/zetta-docs/.sync/render.py`](modules/zetta-docs/.sync/render.py).

**Hard rule — the sync is non-destructive to wtm.** It only **reads** wtm (`list_projects`, `list_artifacts`, `list_relations`, `list_artifact_types`, `list_relation_types`, `blueprint_status`) and **writes** issues + docs. **Never** call a wtm write tool (`create_artifact(s)`, `set_artifact_body`, `update_artifact`, `create_relation(s)`, `generate_blueprint`, `create_project`) from the sync. To change the design, edit the wtm artifact, then re-run the generators.

The orchestrating **`zetta-sync` skill** currently lives in `amaro-bridge/.claude/skills/zetta-sync/` (with the runbook at `amaro-bridge/docs/plans/orama-zetta-sync-plan.md`). The generator scripts themselves travel with this bridge inside `modules/zetta-docs/.sync/`. Migrating the skill into this repo's own `.claude/skills/` is a reasonable follow-up.

## Use cases + the catalog

Orama Zetta is built **use-case-first**: each use case is a *generic AI-project type* (the central item is the **AI project** — most AI projects fail, so the product's job is **data-project management**). **Churn (UC-1)** is the first, built via a **wtm worktree plan** over its issues (`create_worktree_plan` → `generate_worktree_plan` → `launch_plan_layer` — an execution graph that launches parallel worktrees). **Grow the catalog** with the **`add-use-case`** skill + the [`adding-a-use-case`](https://github.com/oramasearch/amaro-bridge/blob/main/docs/runbooks/adding-a-use-case.md) runbook (both in `amaro-bridge`): generate a **Perplexity Deep Research** prompt for the use case → land it in the blueprint as `UC-N` + its dependency closure → sync → worktree plan. Framing detail: [`modules/zetta/docs/orama-zetta.md`](modules/zetta/docs/orama-zetta.md).

## Conventions (repo-wide)

### No AI attribution in commits or PRs

**Never** add `Co-Authored-By: Claude`, `🤖 Generated with…`, or any mention of "Claude", "Codex", or "AI" in commit messages, PR titles/bodies, tag annotations, or release notes. Strip the trailer. This matches org policy across every `oramasearch` repo.

### Full cross-repo URLs; no auto-close

Reference issues/PRs in other repos by **full URL** (`https://github.com/oramasearch/zetta/issues/42`), never bare `#42`. **Never** use `fixes #N` / `closes #N` auto-close keywords; use `Related to <full URL>`. But **once you ship an issue's code (landed/pushed to its PR), manually close that issue** with a closing comment on what changed, and **keep the PR open for review** — solved work must not clutter the tracker (umbrella `CLAUDE.md` → "Close shipped tickets"). Priority labels are `p1`–`p4`.

### Submodules have their own commit flow

Commit + push **inside** the module first (its own CI/review conventions apply), **then** bump the gitlink here:

```sh
git add modules/<name> && git commit -m "<name>: bump pointer to <what landed>" && git push origin main
```

Never edit a submodule's history from the bridge. The bridge only records which commit each submodule is pinned to.

### Documentation discipline

When you touch files in a folder, update that folder's `README.md` (create it on first edit if missing). When a change affects repo-level navigation (new module, new convention), also update the root [`README.md`](README.md) and this `CLAUDE.md`. Keep this `CLAUDE.md` small — it's the jump-table; detail lives in folder READMEs.

### Memory system — DISABLED

Do not use the auto-memory system in this project. Memory lives on the local machine, not in git, so it isn't reproducible across contributors / agents / fresh checkouts. Durable rules go in this `CLAUDE.md` (repo-wide), a skill's `SKILL.md` (workflow), or the relevant folder's `README.md` (folder-scoped). When asked to "remember X", update the right reproducible doc and say what changed.

## Docs — the fuller explanations

This file is the jump-table and stays short. Anything needing more than a paragraph lives in
[`docs/`](docs/), one folder per topic.

| Topic | Read when |
|---|---|
| [`docs/solutions/`](docs/solutions/) | **What we can build and who wants it.** [`buildable-models.md`](docs/solutions/buildable-models.md) — the twelve Band-A modules S-1…S-12 (the catalogue itself now runs to S-23: S-13…S-23 were added 2026-10-09 and are not yet reconciled on that page), eight Band-B sketches, the 21 methods behind them, and what the engine actually trains today. [`buyers-and-roi.md`](docs/solutions/buyers-and-roi.md) — the customer thesis, the industry map by ROI fit, and per module the buyer, metrics and measurement design. ⚠️ Internal-confidential |
| [`docs/agents/`](docs/agents/) | The Python agent scaffold — profiles, discovery vs capture, traces, evals, the bootstrap sequence |
| [`docs/blueprint/`](docs/blueprint/) | The wtm blueprint export the docs site and GitHub issues are generated from |

**The through-line worth knowing:** the solutions catalogue prices every module on **measured**
ROI — incremental effect against a holdout, in the buyer's ledger units, never raw response. That
is the same sentence as the company's own value event in
[`orama-business-model`](https://github.com/oramasearch/orama-business-model). The product thesis
and the company objective are one idea stated twice.

**And the standing caution:** the catalogue is a *plan*. Its S-n modules specify uplift, bandits,
graph, vision and document models the engine does not have.
[`buildable-models.md`](docs/solutions/buildable-models.md) §3 is the reconciliation — read it
before quoting a capability. Reading a design statement as an engine statement is the failure that
has recurred most often in this repo's documentation, including in this file.

## Layout

- `modules/<name>/` — git submodules (the Orama Zetta platform repo + the docs site). See **Modules** above.
- `docs/` — cross-module bridge docs, one folder per topic (see [`docs/README.md`](docs/README.md)).

## Related

- [`oramasearch/zetta`](https://github.com/oramasearch/zetta) — Orama Zetta, the **platform** + the blueprint's tracking issues.
- [`oramasearch/zetta-docs`](https://github.com/oramasearch/zetta-docs) — the docs site source.
- `amaro-bridge` — the sibling bridge where the `zetta-sync` skill + the originating product/blueprint context (`docs/projects/orama-platform-2/`) currently live. Kept separate by design.
