# Zetta Bridge Repo

## What is Orama Zetta

**Orama Zetta** is a desktop GUI **control plane** for the **ZettaDB** engine — *"the data engineer, the AI engineer, and the platform engineer in a bottle."* Tagline: **Intelligence Velocity for Big Thinkers.**

You give it a plain-language problem — or an artifact you already have, like an n8n workflow — and it produces a correct, professionally-architected data + AI **execution graph**, then provisions ZettaDB nodes and deploys the workflows onto infrastructure you control (local → private k8s → AWS/Azure/GCP/on-prem) and runs them. The desktop app is itself a **cluster node** and an **orchestrator**: it talks to cloud provisioning APIs through a **Cloud Interface** abstraction (local CLI impls *or* direct HTTP), reconciles desired→actual, and self-heals. Data stays where it sits — no egress. It also **learns from your data** (native, cluster-parallel model training/inference reimplemented in C++/CUDA), rather than running inference over a rented model.

This **zetta-bridge** repo is a bridge — it ties the Orama Zetta modules together as git submodules so Claude Code (or a human) can work across the whole system at once, or inside any single module. It is **deliberately separate from `amaro-bridge`** and is **not** a submodule of it.

## Bridge repo purpose

A bridge has **no build, no runtime, no tests** of its own. The real code lives in the submodules under `modules/`. On top of the submodule manifest, the bridge holds cross-module docs and the conventions below. Read each module's own `CLAUDE.md` before working inside it.

## Modules

Each module has (or will have) its own `CLAUDE.md` / `README.md` — **read those first** before editing inside a module.

### `modules/zetta` — the ZettaDB engine

Private, **C++26**. An equal-peer, **CRDT-replicated** database (from-scratch C++ Automerge, ~90M ops/sec on 30 cores), JSONL on-disk storage + large objects, a Postgres-SQL **subset** parser on a dialect-neutral AST, coroutine-native networking (Corosio), and **headed** (SDL3 + Dear ImGui — *the desktop is a cluster node*) + headless modes. `CMakeLists.txt` build; has its own `CLAUDE.md`. **Planned (not yet built):** tiered storage, compute-near-data (embedded Lua/Orly + DDF API), indexing, k8s/cloud deploy, Postgres wire protocol, auth/RBAC. Imported from `homer6/zetta`. The substrate Orama Zetta wraps.

### `modules/zetta-docs` — the blueprint docs website

Private, **MkDocs Material** (markdown + pre-rendered Graphviz SVGs), Railway-hosted via `Dockerfile` + `railway.toml`. The browsable rendering of the **Orama Zetta blueprint** — strategy, architecture/ADRs, domain model, data, security, UX, delivery, backlog, testing, risks, governance, glossary, diagrams. **Generated, not hand-edited.** The `.sync/` generators live here: `create_issues.py` (wtm → keyed GitHub issues) and `render.py` (wtm → docs pages + diagrams). Run: `mkdocs serve`. Don't edit `docs/*.md` by hand — re-run the sync.

## The blueprint + sync model

Orama Zetta is designed **blueprint-first**. The single source of truth is the **worktree-manager (wtm) project `ORAMA-ZETTA`** — 278 artifacts across 14 domains + their traceability relations. The blueprint is projected onto two **regenerable** surfaces:

1. **GitHub issues** on [`oramasearch/zetta`](https://github.com/oramasearch/zetta/issues) — one keyed, cross-linked, agent-ready issue per artifact (`[FEAT-3]`-style title, `#number` traceability links, Definition of Done, engine-repo + docs + source-of-truth references). Driven by [`modules/zetta-docs/.sync/create_issues.py`](modules/zetta-docs/.sync/create_issues.py).
2. **Docs site** — [`modules/zetta-docs`](modules/zetta-docs/) renders one page per domain + 3 Graphviz diagrams. Driven by [`modules/zetta-docs/.sync/render.py`](modules/zetta-docs/.sync/render.py).

**Hard rule — the sync is non-destructive to wtm.** It only **reads** wtm (`list_projects`, `list_artifacts`, `list_relations`, `list_artifact_types`, `list_relation_types`, `blueprint_status`) and **writes** issues + docs. **Never** call a wtm write tool (`create_artifact(s)`, `set_artifact_body`, `update_artifact`, `create_relation(s)`, `generate_blueprint`, `create_project`) from the sync. To change the design, edit the wtm artifact, then re-run the generators.

The orchestrating **`zetta-sync` skill** currently lives in `amaro-bridge/.claude/skills/zetta-sync/` (with the runbook at `amaro-bridge/docs/plans/orama-zetta-sync-plan.md`). The generator scripts themselves travel with this bridge inside `modules/zetta-docs/.sync/`. Migrating the skill into this repo's own `.claude/skills/` is a reasonable follow-up.

## Conventions (repo-wide)

### No AI attribution in commits or PRs

**Never** add `Co-Authored-By: Claude`, `🤖 Generated with…`, or any mention of "Claude", "Codex", or "AI" in commit messages, PR titles/bodies, tag annotations, or release notes. Strip the trailer. This matches org policy across every `oramasearch` repo.

### Full cross-repo URLs; no auto-close

Reference issues/PRs in other repos by **full URL** (`https://github.com/oramasearch/zetta/issues/42`), never bare `#42`. **Never** use `fixes #N` / `closes #N` — issues stay open through validation; use `Related to <full URL>`. Priority labels are `p1`–`p4`.

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

- `modules/<name>/` — git submodules (the engine + the docs site). See **Modules** above.
- `docs/` — cross-module bridge docs (see [`docs/README.md`](docs/README.md)).

## Related

- [`oramasearch/zetta`](https://github.com/oramasearch/zetta) — the engine + the blueprint's tracking issues.
- [`oramasearch/zetta-docs`](https://github.com/oramasearch/zetta-docs) — the docs site source.
- `amaro-bridge` — the sibling bridge where the `zetta-sync` skill + the originating product/blueprint context (`docs/projects/orama-platform-2/`) currently live. Kept separate by design.
