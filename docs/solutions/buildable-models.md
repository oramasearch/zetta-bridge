# What we can build in the Zetta solutions catalogue

> **Status:** captured 2026-08-17 · spans [`modules/solutions-designs`](../../modules/solutions-designs/)
> (the catalogue) and [`modules/zetta`](../../modules/zetta/) (the engine that has to run it).
> ⚠️ Inherits the **internal-confidential** classification of the plan docs it summarises.
>
> **Sources:** [`solutions-designs/docs/plan/04-solutions-catalog.md`](../../modules/solutions-designs/docs/plan/04-solutions-catalog.md)
> · [`solutions-designs/docs/plan/03-methodology-portfolio.md`](../../modules/solutions-designs/docs/plan/03-methodology-portfolio.md)
> · [`zetta/src/core/ml/`](../../modules/zetta/src/core/ml/) + [`zetta/docs/ml/README.md`](../../modules/zetta/docs/ml/README.md)
> · [`zetta/docs/product/catalog.md`](../../modules/zetta/docs/product/catalog.md).
> Those files are the truth; this page is a snapshot and goes stale — re-derive before quoting it.

## 0. Terms used on this page — read this first

> **Revised 2026-08-17** after reading the full catalogue rather than its first third. The
> additions that matter: **§4 the eight shared components** (the actual product), **§5 the bundles
> the field sells**, **§6 connector reuse**, and the correction that there are **three** M-numbering
> schemes, not two.

| Term | Meaning |
|---|---|
| **Use case (UC-n) · methodology (M-n) · solution / module (S-n) · sketch (B-n)** | The *problem* (churn) · the *arranged AI methods* (extract → features → GBDT → SHAP → report) · the methodology *applied correctly for the real conditions and wired to the business action that realizes the value*, sold as a priced module · a solution specified only at sketch level. Cardinality: many use cases ≈ many solutions ≫ few methodologies (methods are reused across use cases) |
| **Band A / B** | The plan's ROI tiers for use cases: **A** = largest risk-adjusted ROI, full 12-field spec · **B** = strong ROI, higher variance, sketched until a named condition justifies promotion |
| **ROI contract · agent operating definition · data plan** | The three stages every module spec carries: the return named up front with the measurement design that proves it · what the customer's trained agent does autonomously vs with approval · the supply chain that turns operations into training data |
| **Latency classes L1–L4** | **L1** batch (daily/weekly) · **L2** intraday · **L3** event-triggered, seconds · **L4** request-time, tens of ms, in the transaction path |
| **Value lever** | One of five return classes: revenue lift · cost reduction · loss avoidance · working-capital release · risk reduction |
| **GBDT · histogram GBDT** | Gradient-boosted decision trees — the workhorse model for tabular business data. "Histogram" = features are bucketed so training can be split across nodes and the per-node histograms summed (allreduce), giving single-node == multi-node results |
| **Calibration (Platt / isotonic)** | Post-fitting so a predicted 20% really happens 20% of the time; two standard methods |
| **TreeSHAP · reason codes** | Exact per-row attribution of a tree model's score to its features ("why is *this* account at risk"); surfaced to users as reason codes |
| **Rank-at-risk / batch scoring** | Scoring every entity and sorting into an at-risk list |
| **Held-out metrics · temporal split · backtest** | Measuring the model on rows it never trained on · splitting by *time* rather than randomly, so the model can't train on the future of its own test set · re-running the pipeline as-of past dates |
| **Lag-feature forecaster** | A time-series model whose features are earlier values of the same series (yesterday, last week, rolling window) |
| **Uplift · bandits · graph ML** | Modelling who *changes behaviour because of* a treatment · online algorithms that balance trying options vs exploiting the best one · models over relationships between entities (accounts↔devices↔merchants) |
| **Correctness gate** | The product's pre-deploy check that a pipeline is leakage-free, point-in-time correct, and entity-resolved |

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

## 4. The shared foundation — the part that actually is the product

**This is the most load-bearing section of the catalogue and the easiest to miss**, because it
sits at the back (§17.3). The S-n modules are not twelve products. They are twelve configurations
over **eight shared components**, and those eight are the thing being built:

| # | Component | What it is |
|---|---|---|
| 1 | **Snapshot / feature layer with time-travel** | As-of joins — the point-in-time substrate every correctness claim rests on |
| 2 | **Entity / identity resolution** | The gate's entity test, and the identity backbone S-11 arbitrates on |
| 3 | **The decision-policy engine** | Thresholds, caps, eligibility, approvals, kill-switches as **versioned auditable config** — changeable without retraining |
| 4 | **The holdout / experiment manager** | Holdouts, cells, exploration slices, below-the-line samples. **The measurement engine and the reward-data engine are the same object** |
| 5 | **Drift + guardrail monitor** | Inputs, scores, calibration, guardrail panels |
| 6 | **The audit ledger** | score → action → outcome, with model, policy and agent versions |
| 7 | **The ROI readout generator** | §2.3 — and it is the billing instrument |
| 8 | **The agent** | One per customer, post-trained on their data, operating every module through the other seven |

Everything above them is **configuration, connectors and domain policy.**

### Why this changes how the catalogue reads

**The first module pays for the foundation.** Connectors, identity graph, snapshot history, and
the agent's fluency in the customer's systems. Every subsequent module reuses all of it, so the
marginal module's customer investment falls while its return holds — which is why the plan says
expansion pricing is *designed to be obvious*.

**The data compounds along the same path.** S-1's treatment cells train S-9's send/hold policy;
S-2's routing outcomes feed S-11's arbitration; S-5's forecast-value-added ledger tunes S-6's
release policy; S-10's exploration slice sharpens the whole risk family. **One agent, one reward
ledger, many modules** — and the agent's cross-module view of this customer's caps, consent state
and guardrails is itself a contradiction-prevention layer no per-module point solution has.

Per-customer weights stay the customer's. The generalised patterns — feature templates, playbook
priors, threshold-economics benchmarks, condition libraries — raise every future agent's starting
point.

## 5. The bundles the field actually sells

One wiring, several heads. This is the commercial shape of §17.3:

| Bundle | Modules | Note |
|---|---|---|
| **Revenue Intelligence** | S-1 + S-2 + S-3 | One CRM/warehouse wiring, three heads. **The B2B SaaS default** |
| **Financial-services risk family** | S-4 + S-10 (+ B-7) + S-1 as deposit attrition | Under one SR 11-7-legible governance surface |
| **Insurance family** | S-12 + S-1 as lapse/retention | Under one NAIC governance programme |
| **Operational family** | S-8 + S-5/S-6 (+ B-8) | Sensor and ERP wiring shared |
| **Customer-decisioning capstone** | S-11 over any customer-family bundle | The arbitration layer on top |
| **Exec surface** | S-7 attached to anything | The wholesale layer as its own SKU |

## 6. Connector reuse — build once, attach everywhere

The catalogue's own observation (§17.2) is that **component reuse is denser than methodology
reuse.** The connectors that recur:

| Connector | Serves |
|---|---|
| **Warehouse / CDP** (Snowflake, BigQuery, Databricks, Postgres) | **All twelve** |
| **BI layer** | Every report layer |
| **CRM** (Salesforce, HubSpot, Dynamics) | S-1 S-2 S-3 S-9 S-11 (+B-3) |
| Marketing automation / ESP | S-1 S-3 S-9 S-11 |
| Billing / AR / core banking | S-1 S-3 S-4 B-7 |
| ERP / planning | S-5 S-6 B-4 B-5 |
| Ticketing / support | S-1 S-7 B-3 |
| CMMS/EAM + historian · dialer · payment auth stream · claims + SIU · ad platforms · EHR/RCM | One module family each |

## 7. Three structural facts worth carrying

From §17.1, and each one changes what you would build first:

1. **Four action patterns cover all twelve modules** — report→forum · task-in-system-of-work ·
   policy engine · bounded closed-loop. And **most modules run two at once**: an action layer
   harvesting today's value, and a report layer changing tomorrow's business.
2. **The autonomy frontier is a governance configuration, not a maturity clock.** Every module
   declares which action classes sit at A0/A1/A2/A3 and what evidence moves one. The customer
   chooses the position; the agent supplies the evidence.
3. **Latency follows decision physics.** Ten of twelve modules are batch-first because enterprise
   decisions are mostly batch decisions. L4 appears exactly twice — S-10 at authorisation, S-11 at
   the touchpoint — where the decision window demands it.


## 8. The model/method types behind them — `03-methodology-portfolio.md`

21 methods in six families, the agent's toolbox:

- **I · Tabular decision core** — M-1 tabular supervised · M-5 survival/time-to-event · M-17 Bayesian/UQ · M-18 ensembling
- **II · Identity & structure** — M-2 entity resolution · M-3 segmentation/clustering · M-12 graph ML
- **III · Time & vigilance** — M-4 forecasting · M-7 anomaly detection · M-21 online/streaming
- **IV · Action & decision** — M-6 causal/uplift · M-8 recommendation/NBA · M-9 learning-to-rank · M-15 bandits/sequential · M-16 optimization/OR
- **V · Language, documents, perception** — M-10 NLP/embeddings/RAG/fine-tuning · M-11 document intelligence · M-13 vision · M-14 speech
- **VI · Data supply chain** — M-19 label efficiency · M-20 privacy-preserving/synthetic

### ⚠️ There are three M-numbering schemes, not two

| Where | Scheme |
|---|---|
| Doc 03 headers | 21 methods, M-1…M-21. Survival is **M-5**, causal/uplift **M-6** |
| Doc 04 §3 overview | Survival **M-6**, causal/uplift **M-7** |
| Doc 04 §17.4 fan-out | An **11-method** scheme: M-5 anomaly, M-6 survival, M-7 uplift, M-9 documents/NLP, M-10 the agent, M-11 optimisation |

**Do not quote an M-id externally without saying which table it came from.** The families are
stable; the numbers are not.

### What the fan-out matrix actually says

Reading §17.4 rather than just noting it exists:

- **Tabular supervised + entity resolution + the policy engine underpin ten of twelve modules.**
  The tabular methodology is the workhorse, exactly as the prevalence evidence predicts.
- **Uplift/causal is the highest-leverage single component.** It upgrades six modules from
  propensity to persuadability — and every deployment's holdout design accumulates its training
  data as a by-product. **The data plan pays for the methodology.**
- **The agent has no column of its own because it is the row under all of them.** It is what turns
  the other ten from a toolbox into an operated solution.

## 9. What the engine actually trains today

The catalogue above is spec. In `modules/zetta/src/core/ml/` the native trainer is a **histogram GBDT (binary logistic)**, distributed via allreduced histograms, plus Platt/isotonic **calibration**, exact **TreeSHAP** explanation, batch **scoring/rank-at-risk**, held-out metrics, temporal split/backtest, and a lag-feature **forecaster**. `docs/product/catalog.md` states it plainly — GBDT today, RL and LLM fine-tuning behind the same interfaces — and UC-1 churn is the one worked end-to-end. So S-1 is buildable now; S-5/S-6 lean on the forecast path; anything needing uplift, bandits, graph, vision, speech, or document models is catalogue, not code.
