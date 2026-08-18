# docs/

Cross-module documentation for Orama Zetta — anything spanning the engine, the docs site and the
solution work, and therefore belonging in none of them.

One folder per topic; a topic that fits in a paragraph belongs in [`../CLAUDE.md`](../CLAUDE.md)
instead.

| Topic | Read when |
|---|---|
| [`solutions/`](solutions/) | Asking what we can build, who buys it, or how a module's ROI is measured. ⚠️ Internal-confidential |
| [`agents/`](agents/) | Working on the Python agent scaffold — profiles, traces, evals, the bootstrap sequence |
| [`blueprint/`](blueprint/) | The wtm blueprint export (`artifacts.json`, `relations.json`) that the docs site and GitHub issues are generated from |

Most *reference* content is **generated** and lives in
[`modules/zetta-docs/docs/`](../modules/zetta-docs/) — see [`../CLAUDE.md`](../CLAUDE.md) for the
blueprint/sync model. Add here only when it genuinely spans modules.

## Conventions

**Link from `CLAUDE.md`.** A doc nothing points at is a doc nobody finds.

**Say what is plan and what is built.** The recurring failure in this repo's documentation has been
a true statement about the *design* read as a statement about the *engine* — it reached the bridge
jump-table and understated the shipped capability list for weeks. Where a doc describes intent,
mark it.
