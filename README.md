# Zetta Bridge

Bridge repo for **Orama Zetta** — pulls the project's repos together as git submodules so one Claude Code session (or one human) can work across the whole system with full cross-reference. The bridge itself holds no application code; the product code and the docs site live in the submodules under `modules/`.

**Orama Zetta turns a question into running, deployed intelligence.** Describe a data or AI problem in plain language — or hand over an artifact you already have (an n8n workflow, a SQL script, a notebook) — and Orama Zetta architects a correct data + AI pipeline, deploys it onto infrastructure *you* control, runs it, and **learns from your data**. *The data engineer, the AI engineer, and the platform engineer — in a bottle.* Tagline: **Intelligence Velocity for Big Thinkers.** Full framing: [`docs/projects/orama-platform-2/one-pager.md`](https://github.com/oramasearch/amaro-bridge/blob/main/docs/projects/orama-platform-2/one-pager.md) (in `amaro-bridge`).

See [`CLAUDE.md`](CLAUDE.md) for full navigation, conventions, and the blueprint/sync model.

## Getting started

The bridge is **empty without its submodules** — the product code and the docs site live in `modules/*` as git submodules. Clone recursively:

```bash
git clone --recursive git@github.com:oramasearch/zetta-bridge.git
cd zetta-bridge
```

If you already cloned without `--recursive`, initialize them in place:

```bash
git submodule update --init --recursive
```

Keep the pinned commits up to date after a `git pull`:

```bash
git submodule update --init --recursive
```

Both submodules are **private** (`oramasearch/zetta`, `oramasearch/zetta-docs`) — you need `git@github.com:`-style SSH access with a key registered to the `oramasearch` org.

## Modules

| Module | What it is |
|---|---|
| [`modules/zetta`](modules/zetta/) | **Orama Zetta** — the product. Turns a plain-language problem (or an artifact you already have) into a correct, deployed, running data + AI system on infrastructure you control, and learns from your data. *Under the hood today:* a C++26 equal-peer CRDT-replicated store with clustering, JSONL storage + large objects, a Postgres-SQL subset, headed (SDL3 + Dear ImGui) + headless modes. GUI control plane, one-button deploy, tiered storage, compute-near-data + the learning loop are in flight. Has its own `CLAUDE.md`; build with CMake. |
| [`modules/zetta-docs`](modules/zetta-docs/) | The **Orama Zetta blueprint docs website** — MkDocs Material, Railway-hosted via `Dockerfile` + `railway.toml`. Generated, not hand-edited: projected from the wtm `ORAMA-ZETTA` blueprint. The `.sync/` generators (`create_issues.py`, `render.py`) live here. |

## The blueprint

Orama Zetta is designed blueprint-first. The single source of truth is the **worktree-manager (wtm) project `ORAMA-ZETTA`** (278 artifacts across strategy / requirements / architecture / domain model / data / APIs / security / UX / delivery / backlog / testing / risks / governance / glossary, plus their traceability relations). That blueprint is projected onto two surfaces, both reachable from this bridge:

- **Docs site** — [`modules/zetta-docs`](modules/zetta-docs/) renders one page per domain + Graphviz diagrams (Railway-hosted).
- **GitHub issues** — one keyed, cross-linked, agent-ready issue per artifact on [`oramasearch/zetta`](https://github.com/oramasearch/zetta/issues) (e.g. `[FEAT-3]`).

Both are **regenerable projections** — edit the wtm artifact, then re-run the sync. Never hand-edit the generated docs or issues. See [`CLAUDE.md`](CLAUDE.md) for the sync workflow.

## Conventions

This is a bridge: **no build, no runtime, no tests** at this level. Verification happens per-module. Key rules (full detail in [`CLAUDE.md`](CLAUDE.md)):

- **No AI attribution** in commits, PRs, or tags.
- **Full cross-repo URLs** — never bare `#N` across repos; no `fixes #N` / no auto-close.
- **Submodules have their own commit flow** — commit + push inside the module first, then bump the gitlink here.
- **Update the folder `README.md` when you touch a folder** — documentation discipline.
