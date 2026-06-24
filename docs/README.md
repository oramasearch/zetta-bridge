# docs/

Cross-module, bridge-level documentation for Orama Zetta — anything that spans both the engine ([`modules/zetta`](../modules/zetta/)) and the docs site ([`modules/zetta-docs`](../modules/zetta-docs/)) and therefore doesn't belong inside either submodule.

This is intentionally thin to start. Most reference content is **generated** and lives in [`modules/zetta-docs/docs/`](../modules/zetta-docs/docs/) (the blueprint pages) — see the root [`CLAUDE.md`](../CLAUDE.md) for the blueprint/sync model. Add bridge-level docs here only when they genuinely span modules (e.g. a release plan that touches the engine and the docs site together).

Per the documentation-discipline rule in [`CLAUDE.md`](../CLAUDE.md): when you add a subfolder here, give it its own `README.md`.
