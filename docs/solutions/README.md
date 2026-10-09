# solutions/ — what we can build, and who wants it

The two halves of the same question, drawn from
[`modules/solutions-designs/docs/plan/`](../../modules/solutions-designs/docs/plan/) — the
portfolio plan authored by the combined executive team. ⚠️ **Internal-confidential.**

| Doc | Answers |
|---|---|
| [`buildable-models.md`](buildable-models.md) | **What** — the twelve Band-A modules (S-1…S-12), eight Band-B sketches, the 21 methods in six families behind them, and what the engine actually trains today. The catalogue now runs to **S-23** (S-13…S-23 added 2026-10-09 — two Band A, nine Band B); this page has not yet been re-derived for them |
| [`buyers-and-roi.md`](buyers-and-roi.md) | **Who and why** — the three-condition customer thesis, the buying group, the industry map by ROI fit, and per module the buyer, value lever, metrics and the measurement design that turns a metric into an ROI number |

## The one thing to carry away

The catalogue's own discipline, and it governs both docs:

> **ROI must be measured, not asserted.** Every module's readout reports the *incremental* effect
> — treated minus holdout, challenger versus champion, phased versus baseline — converted into
> the economic buyer's ledger units. Never raw response.

That is the same sentence as the company's own value event in
[`orama-business-model`](https://github.com/oramasearch/orama-business-model/blob/main/world_model/objectives.md):
an artifact in production driving **measured** ROI on the customer's most important initiative.
The product thesis and the company objective are the same thing stated twice.

## Reading them honestly

Both are **snapshots of a plan**, not of the engine. `buildable-models.md` §3 is the reconciliation
— what the C++ engine actually trains today (histogram GBDT, calibration, TreeSHAP, scoring, a
lag-feature forecaster) versus what the catalogue specifies. Everything needing uplift, bandits,
graph, vision, speech or document models is catalogue, not code.

Re-derive from the plan docs before quoting either externally. The plan moves; these do not.
