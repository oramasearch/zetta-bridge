# docs/

Cross-module, bridge-level documentation for Orama Zetta — anything that spans both the engine ([`modules/zetta`](../modules/zetta/)) and the docs site ([`modules/zetta-docs`](../modules/zetta-docs/)) and therefore doesn't belong inside either submodule.

This is intentionally thin to start. Most reference content is **generated** and lives in [`modules/zetta-docs/docs/`](../modules/zetta-docs/docs/) (the blueprint pages) — see the root [`CLAUDE.md`](../CLAUDE.md) for the blueprint/sync model. Add bridge-level docs here only when they genuinely span modules (e.g. a release plan that touches the engine and the docs site together).

Per the documentation-discipline rule in [`CLAUDE.md`](../CLAUDE.md): when you add a subfolder here, give it its own `README.md`.

**Explain jargon before use.** Bridge docs are read by people outside the plan-writing loop, so every page opens with a "Terms used on this page" section that defines the plan vocabulary (E[ROI], p(success), Band A/B, holdout, decision pool, data exhaust …), the buyer-side acronyms it relies on (DSO, LAE, OEE, SAIDI …), and any regulatory shorthand (SR 11-7, NAIC AIS, NERC CIP …) — *before* the body uses them. Inline, first use of a load-bearing term also gets a one-line gloss or a `(§0.n)` pointer. A reader should never have to leave the page to decode a term.

- [`buildable-models.md`](buildable-models.md) — **what we can build in the solutions catalogue**:
  the twelve Band-A modules (S-1…S-12) + eight Band-B sketches from
  [`solutions-designs`](../modules/solutions-designs/docs/plan/04-solutions-catalog.md), the 21
  methods in six families that back them, and — the reason this is a bridge doc — what
  [`zetta`](../modules/zetta/src/core/ml/) actually trains today (histogram GBDT + calibration +
  TreeSHAP + scoring + a lag-feature forecaster), i.e. which modules are code and which are still
  spec. ⚠️ Internal-confidential.
- [`buyers-and-roi.md`](buyers-and-roi.md) — **who wants those models and why**: the
  three-condition customer thesis, the buying group (economic buyer · champion · outcome owner ·
  validator), the industry map by ROI fit (dominant modules, champions, triggers, governance
  regime as advantage, proof metric), segmentation by decision pool, the anti-customer, and — per
  module S-1…S-12 — the buyer, value lever, the metrics they watch, guardrails, and the
  measurement design that turns the metric into the ROI number; closes with the D1/D6/D8
  arithmetic (pool → E[R] → p(success) → share-of-return price → true-up → renewal). Summarised
  from `solutions-designs/docs/plan/` 04/05/06. ⚠️ Internal-confidential.
- [`agent-scaffold.md`](agent-scaffold.md) — **the Python agent scaffold** (zetta#986): the
  bootstrap sequence (Python + frontier models → record traces → then port to C++ and compare eval
  scores), the five agent modules and why each is a sibling of `zetta` rather than inside it, what
  a **profile** is (a situation *plus its materialized data*), the **discovery vs capture**
  distinction, and the five rules that keep it a bootstrap rather than a demo.
