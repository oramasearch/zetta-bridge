# Zetta Bridge Repo

## What is Orama Zetta

**Orama Zetta turns a question into running, deployed intelligence.** Describe a data or AI problem in plain language — or hand over an artifact you already have (an n8n workflow, a SQL script, a notebook) — and Orama Zetta architects a correct data + AI pipeline, deploys it onto infrastructure *you* control (your k8s / AWS / Azure / GCP / on-prem), runs it, and **learns from your data**. *"The data engineer, the AI engineer, and the platform engineer — in a bottle."* It compresses the time from **intent → deployed, correct intelligence** from quarters to hours: **Intelligence Velocity for Big Thinkers.** Full framing: [`docs/projects/orama-platform-2/one-pager.md`](https://github.com/oramasearch/amaro-bridge/blob/main/docs/projects/orama-platform-2/one-pager.md).

**How it works — one flow:** *Ingest* (plain language + the artifacts you already have) → *Architect* (compile a correct execution graph, validated before it runs) → *Deploy* (one button onto your target; your data never leaves) → *Run + learn* (it gets sharper the more it sees). Why it's different: it **learns from your data** (trains on *your* data, not inference over a rented model), is **correct by construction** (every graph passes a correctness gate before deploy), runs **compute-near-data** with hot→cold→re-warm tiered storage, and is **governed self-serve** (in your environment, identity-scoped, audited).

`oramasearch/zetta` **is** Orama Zetta — the product. The older name *"ZettaDB"* is **retired**; `zetta` is just the repo/binary codename. The full product surface (GUI control plane, one-button deploy, the learning loop, tiered storage) is **in flight**; the core runs today (a CRDT-replicated store with clustering + a Postgres-SQL subset).

This **zetta-bridge** repo is **not** the product — it's just a way to **group all the GitHub repos that make up the Orama Zetta project** (the product code, its technical docs, websites, …) as git submodules, so Claude Code (or a human) can work across them at once. It is **deliberately separate from `amaro-bridge`** and is **not** a submodule of it.

## Bridge repo purpose

A bridge has **no build, no runtime, no tests** of its own. The real code lives in the submodules under `modules/`. On top of the submodule manifest, the bridge holds cross-module docs and the conventions below. Read each module's own `CLAUDE.md` before working inside it.

## Modules

Each module has (or will have) its own `CLAUDE.md` / `README.md` — **read those first** before editing inside a module.

### `modules/zetta` — Orama Zetta (the product)

Private, **C++26**. **Orama Zetta itself** — the product repo. **Under the hood today:** an equal-peer, **CRDT-replicated** store (from-scratch C++ Automerge, ~90M ops/sec on 30 cores), JSONL on-disk storage + large objects, a Postgres-SQL **subset** parser on a dialect-neutral AST, coroutine-native networking (Corosio), and **headed** (SDL3 + Dear ImGui — the desktop is itself a cluster member) + **headless** modes. `CMakeLists.txt` build; has its own `CLAUDE.md`. **In flight (not yet built):** the GUI control plane, tiered storage, compute-near-data (embedded Lua/Orly + DDF API), indexing, k8s/cloud deploy, Postgres wire protocol, auth/RBAC, the learning loop. Imported from `homer6/zetta`.

### `modules/zetta-docs` — the blueprint docs website

Private, **MkDocs Material** (markdown + pre-rendered Graphviz SVGs), Railway-hosted via `Dockerfile` + `railway.toml`. The browsable rendering of the **Orama Zetta blueprint** — strategy, architecture/ADRs, domain model, data, security, UX, delivery, backlog, testing, risks, governance, glossary, diagrams. **Generated, not hand-edited.** The `.sync/` generators live here: `create_issues.py` (wtm → keyed GitHub issues) and `render.py` (wtm → docs pages + diagrams). Run: `mkdocs serve`. Don't edit `docs/*.md` by hand — re-run the sync.

### `modules/solutions-designs` — enterprise AI solution designs

Private, docs-only (no build/runtime/tests). A working space where a real-world **enterprise AI problem** is taken end-to-end into a concrete **Orama Zetta solution design**. Worked in **strict stages — evidence & ideas → analysis → design** (we don't jump ahead). One folder per solution under `solutions/<slug>/`; `templates/solution/` is the scaffold. Has its own `CLAUDE.md`. The governing rule for the current stage: **collect, don't conclude** — gather raw evidence + loose ideas, no analysis/ranking/design until explicitly moved on.

### `modules/orama-design` — Orama visual design

Private, the **Orama design / visual** repo (Daniel's design workspace, upstream
`nisttahuz/orama-website`). Pinned as a **branch-following submodule** on `main`, which
carries the merged July 23 state: the live **Orama Studio** prototype (`src/studio/`),
the design system (`packages/design-system/`, Storybook = source of truth), the Zetta
baseline (`apps/zetta-studio/`), the marketing clone + skins (`src/`), and the Orama
Project Hub (`src/workspace/`). Read its `CLAUDE.md` + `HANDOFF.md` before editing. A
deep inventory (screens, flows, personas, components, decisions) lives in the umbrella
bridge at `docs/projects/orama-studio-marketplace/design-index.md`
(https://github.com/oramasearch/orama-bridge). Because it tracks a branch,
`git submodule update --remote modules/orama-design` pulls the latest on `main` (plain
`--init` still checks out the pinned commit).

### `modules/orama-perfcost` — benchmarking + cost/performance

Private, docs/data + harnesses. **Performance benchmarking** and **cost analysis** of
Orama products vs third-party products (e.g. Turbopuffer — vendor-published numbers
harvested with full provenance). Canonical output: `data/latest.json` (spec in
`spec/dataset-spec.md`), built/validated by stdlib-only Python scripts; refreshes are
driven by the module's own **`perfcost-refresh` skill** (`.claude/skills/perfcost-refresh/`,
runbook at `docs/runbook.md`). First-party Zetta harness is stubbed — blocked on the
Zetta API. Pinned as a **branch-following** submodule on `main` (`git submodule
update --remote modules/orama-perfcost` pulls the latest; plain `--init` checks out the
pinned commit). Read its own `README.md` before editing.

### `modules/orama-website-v2` — the Orama marketing website

Private, **Vite + React + shadcn/ui**, prerendered/SSG (custom scripts, not a
meta-framework); content lives as TS modules under `src/content/` with build-time
content gates under `src/content/validation/` + `content/registry/` (routes, claims,
product-truth, forbidden-content). **Currently enforces a price-free / no-numbers
posture** — any currency token or metric fails the build. Future consumer of the
`orama-perfcost` dataset via the vendored-copy publish path
([`modules/orama-perfcost/docs/architecture.md`](modules/orama-perfcost/docs/architecture.md));
wiring that up requires lifting the posture + a net-new compare surface. Pinned as a
**branch-following** submodule on `main` (`git submodule update --remote
modules/orama-website-v2` pulls the latest; plain `--init` checks out the pinned
commit). Read its own docs before editing.

### `modules/agent-*` — the Python agent scaffold

Private, **Python + uv** (never pip), one repo per agent, **sibling to `zetta`**. The bootstrap
direction set 2026-08-07: build the agents in Python with frontier models, record the traces, and
only then re-implement in C++ with our own models — comparing eval scores between the two.
`agent-eval-generator` (eval profiles) and `agent-autosuggest-corpus` (Auto-Suggest SFT data)
exist; the rest are planned.

**Training data and eval data must never overlap.** The eval profiles are the *test set* for
Auto-Suggest, so `agent-autosuggest-corpus` generates its own situations and refuses to start if it
cannot load the eval set to check against — contamination would make every eval score a measurement
of memory rather than reading.

**Read [`docs/agent-scaffold.md`](docs/agent-scaffold.md) before touching any of them.** It owns
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

## Layout

- `modules/<name>/` — git submodules (the Orama Zetta product repo + the docs site). See **Modules** above.
- `docs/` — cross-module bridge docs (see [`docs/README.md`](docs/README.md)).

## Related

- [`oramasearch/zetta`](https://github.com/oramasearch/zetta) — Orama Zetta (the product) + the blueprint's tracking issues.
- [`oramasearch/zetta-docs`](https://github.com/oramasearch/zetta-docs) — the docs site source.
- `amaro-bridge` — the sibling bridge where the `zetta-sync` skill + the originating product/blueprint context (`docs/projects/orama-platform-2/`) currently live. Kept separate by design.
