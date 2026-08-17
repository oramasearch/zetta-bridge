# What we can build in the Zetta solutions catalogue

> **Status:** captured 2026-08-17 · spans [`modules/solutions-designs`](../modules/solutions-designs/)
> (the catalogue) and [`modules/zetta`](../modules/zetta/) (the engine that has to run it).
> ⚠️ Inherits the **internal-confidential** classification of the plan docs it summarises.
>
> **Sources:** [`solutions-designs/docs/plan/04-solutions-catalog.md`](../modules/solutions-designs/docs/plan/04-solutions-catalog.md)
> · [`solutions-designs/docs/plan/03-methodology-portfolio.md`](../modules/solutions-designs/docs/plan/03-methodology-portfolio.md)
> · [`zetta/src/core/ml/`](../modules/zetta/src/core/ml/) + [`zetta/docs/ml/README.md`](../modules/zetta/docs/ml/README.md)
> · [`zetta/docs/product/catalog.md`](../modules/zetta/docs/product/catalog.md).
> Those files are the truth; this page is a snapshot and goes stale — re-derive before quoting it.

Two different things get called "models" here, so both, from the catalogue itself.

## 1. The sellable modules — `04-solutions-catalog.md`

**Twelve Band-A specs** (S-n ≈ 1:1 with UC-n), each a full 12-field spec with an ROI contract, agent operating definition, and data plan:

| ID | Module | Methodology | Latency | Primary ROI lever |
|---|---|---|---|---|
| S-1 | Churn & Retention *(reference impl.)* | M-1+M-2+M-3 (+M-6,7,8) | L1 | Revenue lift (retained margin) |
| S-2 | Lead & Opportunity Scoring | M-1+M-2+M-3 (+M-7) | L1 | Conversion per rep-hour |
| S-3 | Customer Lifetime Value | M-1+M-2+M-3 (+M-6,7) | L1 | Spend reallocation |
| S-4 | Collections Prioritization | M-1+M-2+M-3 (+M-7) | L1 | Working-capital release |
| S-5 | Demand Forecasting | M-4+M-2+M-3 (+M-5) | L1/L2 | Working capital + availability |
| S-6 | Replenishment & Inventory Action | M-4+M-11 (+M-5) | L1 | Working capital + cost |
| S-7 | KPI Anomaly & Driver Analysis | M-1+M-3+M-5 (+M-4,9) | L1/L2 | Decision quality |
| S-8 | Predictive Maintenance | M-5+M-1+M-2 (+M-6) | L3+L1 | Downtime avoidance |
| S-9 | Automated Outbound | M-1+M-3+M-2 (+M-7,8,9) | L1 | Incremental pipeline |
| S-10 | Fraud & Financial-Crime Decisioning | M-1+M-2+graph (+M-5) | **L4** | Loss avoidance + false-decline recovery |
| S-11 | Next-Best-Action | M-8+M-1+M-7+M-2 (bandits) | **L4** | Long-horizon customer value |
| S-12 | Claims Triage & Fraud Referral | M-1+M-2+M-9 (+M-3) | L3+L1 | Cycle time + leakage |

**Eight Band-B sketches** (strong ROI, higher variance — each carries the named condition that promotes it to a full spec): B-1 Dynamic Pricing & Discount Governance · B-2 Employee Attrition (aggregate-only) · B-3 Ticket Triage & Service Automation · B-4 Document & Workflow Automation (AP/contracts/KYC) · B-5 Supplier Risk & Procurement Intelligence · B-6 Healthcare Operations (no-show & denials) · B-7 Credit Underwriting & Limit Management · B-8 IT & Security Operations.

## 2. The model/method types behind them — `03-methodology-portfolio.md`

21 methods in six families, the agent's toolbox:

- **I · Tabular decision core** — M-1 tabular supervised · M-5 survival/time-to-event · M-17 Bayesian/UQ · M-18 ensembling
- **II · Identity & structure** — M-2 entity resolution · M-3 segmentation/clustering · M-12 graph ML
- **III · Time & vigilance** — M-4 forecasting · M-7 anomaly detection · M-21 online/streaming
- **IV · Action & decision** — M-6 causal/uplift · M-8 recommendation/NBA · M-9 learning-to-rank · M-15 bandits/sequential · M-16 optimization/OR
- **V · Language, documents, perception** — M-10 NLP/embeddings/RAG/fine-tuning · M-11 document intelligence · M-13 vision · M-14 speech
- **VI · Data supply chain** — M-19 label efficiency · M-20 privacy-preserving/synthetic

Note the numbering differs between doc 03's headers and the composition column in doc 04's overview table (doc 04 calls survival M-6 and causal/uplift M-7 in the S-1 prose; doc 03 has M-5 survival, M-6 causal). Worth reconciling if you're going to quote IDs externally.

## 3. What the engine actually trains today

The catalogue above is spec. In `modules/zetta/src/core/ml/` the native trainer is a **histogram GBDT (binary logistic)**, distributed via allreduced histograms, plus Platt/isotonic **calibration**, exact **TreeSHAP** explanation, batch **scoring/rank-at-risk**, held-out metrics, temporal split/backtest, and a lag-feature **forecaster**. `docs/product/catalog.md` states it plainly — GBDT today, RL and LLM fine-tuning behind the same interfaces — and UC-1 churn is the one worked end-to-end. So S-1 is buildable now; S-5/S-6 lean on the forecast path; anything needing uplift, bandits, graph, vision, speech, or document models is catalogue, not code.
