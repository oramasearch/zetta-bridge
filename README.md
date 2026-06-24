# Zetta Bridge

Bridge repo for **Orama Zetta** — pulls the Zetta module repos together as git submodules so one Claude Code session (or one human) can work across the whole system with full cross-reference. The bridge itself holds no application code; the engine and the docs site live in the submodules under `modules/`.

**Orama Zetta** is a desktop GUI control plane for the **ZettaDB** engine: turn a plain-language problem — or an artifact you already have, like an n8n workflow — into a correct, professionally-architected data + AI **execution graph**, then deploy ZettaDB nodes and the workflows onto infrastructure you control and run them. *The data engineer, the AI engineer, and the platform engineer — in a bottle.* Tagline: **Intelligence Velocity for Big Thinkers.**

See [`CLAUDE.md`](CLAUDE.md) for full navigation, conventions, and the blueprint/sync model.

## Getting started

The bridge is **empty without its submodules** — the engine code and the docs site live in `modules/*` as git submodules. Clone recursively:

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
| [`modules/zetta`](modules/zetta/) | The **ZettaDB engine** (the database/compute substrate — *not* the product). C++26, equal-peer CRDT-replicated database (from-scratch C++ Automerge), JSONL on-disk storage + large objects, a Postgres-SQL subset parser, coroutine-native networking (Corosio), and headed (SDL3 + Dear ImGui) + headless modes — any node runs either way. Has its own `CLAUDE.md`; build with CMake. |
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
