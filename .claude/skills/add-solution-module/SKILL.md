---
name: add-solution-module
description: "Add a supported solution module or methodology to Orama Zetta and lake, end to end: the native trainer in Zetta, its entry in the methodology registry, its own pipeline shape in the compiler, its run path and report, its correctness gate checks, featurization for it, the control surface, lake (projects created with it, pages that say what runs), and every agent that designs, recommends, proposes or teaches pipelines (Project Agent, Auto-Suggest, Ask Orama, AgentCreator, the eval and corpus generators). Use when making a catalogue solution (S-n) or a portfolio methodology (M-n) actually run, e.g. 'support segmentation', 'add forecasting', 'make S-5 work', 'add a new model type', 'add a solution to the catalogue and make it run'. Tracking: zetta#984 (one issue per methodology, zetta#1041-#1060), the registry zetta#1061, featurization zetta#1062."
---

# add-solution-module — make a solution or methodology actually run

A catalogue solution (`S-n`) is sold on a methodology (`M-n`). It is **supported** only when a
person can create a project for it in lake, get that methodology's own pipeline, run it on their
data, read an honest report, and ask any agent about it and hear the truth. Anything less is a
design statement, and treating a design statement as an engine statement is the failure this repo
has repeated most (zetta-bridge `CLAUDE.md`, *the standing caution*). Live example, 2026-09-27: a
segmentation project got the generic skeleton, trained nothing, and Ask Orama proposed renaming its
steps (zetta#1042).

## 0. Before you start

- **Read, in this order:** zetta-bridge `docs/solutions/buildable-models.md` (§3 and §9: what runs
  today; §8: the catalogue and the portfolio number methodologies differently — the engine uses the
  **portfolio's** M-numbers), the methodology's section in
  `modules/solutions-designs/docs/plan/03-methodology-portfolio.md` §4 (⚠️ internal-confidential:
  link it, never paste it outside private repos), the solution's section in `04-solutions-catalog.md`,
  and zetta's `docs/ml/`, `docs/pipeline/execution.md`, `docs/data/query.md`.
- **Find its issue:** one per methodology under zetta#984 (M-2 zetta#1041 … M-21 zetta#1060). A new
  methodology or solution gets its issue first, in that shape, linked from the epic.
- **The foundations must exist:** the methodology registry (zetta#1061: `list_methodologies`,
  compile/run routed by it) and data-first featurization (zetta#1062). If they do not yet, build the
  part you need in the same change rather than route around them.
- **Work on branches:** Zetta PRs target `dev`, never `main`; a feature branch per repo; the bridge's
  own zetta checkout may belong to another session — use a worktree (`codex-work/wt/zetta/<name>`).

## 1. Zetta: the engine runs it

Every item lands in one PR to `dev`, with its tests and docs.

1. **The trainer / runner** under `src/core/ml/`: native C++, distributed the way GBDT is
   (gradient-histogram allreduce is the bar), no embedded Python, no foreign runtime (ADR-17). Own
   `model_kind` string.
2. **The registry entry** (`list_methodologies`, zetta#1061): `id`, `name`, `model_kinds`,
   `runnable: true`, the inputs it needs (label / time / treatment / group column), its outputs, its
   metrics, the solutions it serves. One table in `src/core/ml/`, generated into `docs/ml/README.md`.
3. **Its pipeline shape** in `src/core/pipeline/intent_compiler.cpp`: `compile_intent` with
   `solution: S-n` or `methodology: M-n` builds this shape (the keyword heuristic is only the
   fallback). The shape is the methodology's, not the churn skeleton renamed.
4. **Its run path** in `handle_run` (`src/core/api/capabilities.cpp`): a graph of this shape trains on
   the pipeline's own table (zetta#1040: the connect step's `source`/`table`, the model step's
   attributes), writes its outputs as tables, records lineage, and never runs structurally.
5. **Its report**: `get_run_report` carries its metrics and what it read and excluded.
6. **Featurization for it** (zetta#1062): the plan's per-methodology rules (scaling, lags, no
   post-treatment features, …) and the *transform required* answers it needs.
7. **Its correctness profile as gate checks** (`pipeline/graph_checks.hpp`, the `Check` interface):
   what a person must never get from it (a calibrated forecast, clustering on the label, uplift with
   post-treatment features).
8. **The control surface in the same change**: registry, REST, MCP, the agent allow-list,
   `ZETTA_WRITE_SCHEMAS=1 ./build/tests/zetta-tests` for `schemas/openapi.json`, the capability-count
   assertion, `docs/ml/<model_kind>.md`.
9. **Tests**: a landed table in, a trained model and its outputs out, through the registry as an agent
   calls it (see `Uc1Journey.ARunWithoutADatasetReadsItsPipelinesTable` in
   `tests/api/test_action_journeys.cpp`), plus each gate check refusing the wrong case. Wait for the
   run to finish before the test ends (a background worker outliving the node crashes teardown).
   Run the full suite; name any load-sensitive failure you re-ran alone.

## 2. lake: people can create and run it

In the lake worktree, on its PR branch (liquid-bridge `/liquid-dev` for build and deploy):

- A project made from an Opportunity, and *Build a Pipeline*, pass the solution / methodology to
  `compile_intent` (lake#289); `settle_build` applies the Project Agent's design with its
  methodology.
- Pages say what runs: the Opportunity card (*runs today* / *needs M-n, not supported yet*), the
  project, the pipeline page (and *this pipeline trains nothing yet* for a structural run), the
  run page with the new report fields.
- `workspace_reads` / `workspace_actions` allow the new capabilities; `docs/api/*.md` and the guide
  (`docs/guide/`) say which methodologies run.
- Tests: `ctest` (memory and Postgres), `tools/ui/test-token-gates.sh`, and the live suite
  `tools/e2e/agents.py` after the roll.

## 3. Every agent learns it

The agents read `list_methodologies` at each turn, so a newly runnable methodology is picked up
without a prompt change. Still check, and extend the evals, for each:

| Agent | What it must do with the new methodology |
|---|---|
| `agent-project` | design with it (naming `methodology` and `model_kind`), and **edit** a pipeline into its shape when asked (agent-project#7) |
| `agent-autosuggest` | recommend it when the data supports it; decline with *transform first* when the data's shape is the gap (agent-autosuggest#5) |
| `agent-ask-orama` | answer "can Orama do X" from the registry; never propose an edit naming an unrunnable methodology (agent-ask-orama#4) |
| `agent-creator` | build agents on it only once it runs (agent-creator#3) |
| `agent-eval-generator` | profiles name the methodology they need (agent-eval-generator#1) |
| `agent-autosuggest-corpus`, `agent-project-corpus` | teach its shape only once it runs; examples replayed against a run of it (their #1) |

Each agent repo: its tests, its README, a new image (private Docker Hub repository of the same
name; a new repo is created private **before** its first push, and an anonymous read must answer
404), and a roll.

## 4. Ship and prove it

1. Build Zetta from the PR branch (or an integration branch when several PRs must ship together) on
   the cluster BuildKit; roll `Lake/prod` `spec.services.zettaImage` and `spec.zetta.image`.
2. Build and roll lake and the changed agents (liquid-bridge `/liquid-dev`).
3. **Live proof, as a person:** scan a workspace whose data suits the solution, create a project from
   the Opportunity, watch the Project Agent design it, run it, read the report; ask Ask Orama about
   it; ask for an edit that switches a pipeline to it. Record the times and results on the issue.
4. **Close the issue** with a comment: what changed, the PRs, what is deployed (image tags), the live
   proof. Keep the PRs open for review (org rule). Tick it on zetta#984. Update
   `docs/solutions/buildable-models.md` §9 (what the engine trains today) in the same stretch.

## Rules that do not bend

- Never ship a shape that names a methodology the engine cannot run; refuse it with the issue.
- No AI attribution in commits or PRs; merge commits only; commit means push.
- Confidential portfolio and catalogue text stays in private repos; issues link it.
- No time estimates; report what runs.
