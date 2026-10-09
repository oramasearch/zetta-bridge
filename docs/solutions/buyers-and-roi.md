# Who wants these models — buyers, motives, metrics, and the line back to ROI

> **Status:** captured 2026-08-17 · companion to [`buildable-models.md`](buildable-models.md)
> (which lists *what* is in the catalogue; this page is *who buys it and why*).
> ⚠️ Inherits the **internal-confidential** classification of the plan docs it summarises.
>
> **Revised 2026-08-17** after reading the full catalogue: added §7 (the three tensions that
> change what a buyer is told) and §8 (bundles, and why the expansion argument is structural).
>
> **Sources:** [`solutions-designs/docs/plan/05-industries-and-gtm.md`](../../modules/solutions-designs/docs/plan/05-industries-and-gtm.md)
> (customer thesis, buying group, industry map, segmentation, anti-customer, commercial motion)
> · [`04-solutions-catalog.md`](../../modules/solutions-designs/docs/plan/04-solutions-catalog.md)
> (per-module ROI contracts: levers, illustrative math, measurement design, buyer)
> · [`06-financial-plan.md`](../../modules/solutions-designs/docs/plan/06-financial-plan.md)
> (how measured ROI becomes the price) · [`00-strategy-kernel.md`](../../modules/solutions-designs/docs/plan/00-strategy-kernel.md)
> (the kernel's decisions D1/D3/D6/D8 — glossed in §0 below).
> Every dollar figure below is an **illustrative planning quantity** from those docs, not a
> commitment; engagement-specific models replace them at contract time. Snapshot — re-derive
> before quoting.

---

## 0. Terms used on this page — read this first

The plan docs have their own vocabulary and lean on buyer-side acronyms from nine
industries. Everything below is defined here before it is used; the body then uses the
terms freely. Skim it once, come back to it as needed.

### 0.1 Plan vocabulary

| Term | Meaning |
|---|---|
| **The kernel · D1…D10** | `00-strategy-kernel.md`, the binding decision list every plan doc elaborates. **D1** the ROI calculus (`score = E[ROI] × p(success)`) · **D2** solutions are agent-operated (Auto-RL) · **D3** who the customers are · **D4** which use cases (Bands A/B/C, the anti-portfolio) · **D5** methodologies · **D6** every solution carries an ROI contract · **D7** data strategy · **D8** ROI-based pricing · **D9** metrics · **D10** principles |
| **Use case (UC-n) · methodology (M-n) · solution / module (S-n) · sketch (B-n)** | The *problem* · the *arranged AI methods* · the methodology *applied correctly and wired to a business action*, sold as a priced module · a solution specified only at sketch level. See [`buildable-models.md`](buildable-models.md) for the lists |
| **Band A / B / C · anti-portfolio** | The plan's ROI tiers for use cases (D4): **A** = largest risk-adjusted ROI, full spec · **B** = strong ROI, higher variance, sketch until a named condition is met · **C** = below the line. The **anti-portfolio** is what we deliberately don't sell — autonomous high-stakes decisions without human gates, and returns that can't be measured |
| **E[ROI]** | Expected return on investment = expected return ÷ customer investment, where customer investment = module price + integration effort + data work + change cost (all four, not just our line) |
| **p(success)** | The ex-ante probability the deployed module actually delivers that return, scored on five drivers: data availability & label quality · actionability (is there a business action to wire to?) · measurability · organizational adoption (is there a named owner?) · governance fit |
| **The agent · Auto-RL** | The customer's own trained operator that *builds, runs, monitors, explains, improves* a module. **Auto-RL** = it is trained by reinforcement learning with the module's **measured ROI as the reward** (D7-2) |
| **Autonomy classes A0–A3** | Governance settings the customer chooses per action class: **A0** draft only (human executes) · **A1** approval-gated (agent executes after a named human approves) · **A2** autonomous-under-audit (executes inside the policy envelope) · **A3** self-tuning (also adjusts thresholds inside pre-approved bounds) |
| **Latency classes L1–L4** | **L1** batch (daily/weekly) · **L2** intraday · **L3** event-triggered, seconds · **L4** request-time, tens of ms, in the transaction path |
| **Value lever / return class** | The five ways a module can produce return: **revenue lift · cost reduction · loss avoidance · working-capital release · risk reduction** |
| **Decision pool** | The set of recurring decisions a module goes after, sized in dollars: frequency × value per decision. Example: "which customers do we try to save this month?" — 200k customers × 2%/month churn × $40 ARPU ≈ $21M/yr revenue at risk; that $21M is the churn pool. For a lender it's the delinquent receivables being worked; for a plant, the unplanned-downtime hours on covered assets; for a payments company, the transactions being approved or declined. Whoever owns the P&L of the pool is the **economic buyer** (§2); which pool dominates an account decides how it is segmented (§4.2) and what you land with |
| **ROI contract** | Per module, agreed up front: value levers · illustrative ROI math · the **measurement design** that will prove the return · p(success) drivers and named risks |
| **ROI readout** | The customer-visible dossier the module produces on a cadence — it simultaneously *proves* the return and *trues up* the price. Its sections are listed in §6.3 |
| **True-up** | The annual settlement of the success-linked part of the price against the return the readout measured; runs both ways |
| **Correctness gate** | The product's pre-deploy check that a pipeline is leakage-free, point-in-time correct, entity-resolved, calibrated, etc. Blocks with a stated reason |
| **Leakage** | A feature that secretly contains the answer — e.g. "support tickets in the last 90 days" pulled from a live table that already includes the tickets a customer opened *because* they were leaving. Produces a model that looks brilliant offline and useless in production |
| **Point-in-time** | Every feature computed only from data that existed as of the prediction date — never "latest value" |
| **Entity resolution** | Matching records across systems (billing, CRM, telemetry, tickets) to the one unit the business can act on — customer vs account vs household vs asset |
| **Reason codes** | The per-score, human-readable drivers shown next to a prediction ("usage −40% QoQ; 2 open P1 tickets") |
| **Guardrail metrics** | The panel proving the win wasn't bought invisibly — complaints, margin, contact fatigue, cap adherence, fairness |
| **System of record vs system of action** | Where the data *lives* (CRM, ERP, billing, claims, plant historian) vs where the acting team *works* and the module writes its scores/tasks/drafts (a CRM queue, a maintenance work order, a dialer, marketing automation) |
| **Data exhaust · owned data exhaust** | The records a company generates *as a by-product of operating* — every bill, ticket, claim, sensor reading, CRM edit — sitting in its own systems of record. "Decision-grade" when the **outcomes** are recorded too (not just the leads, but whether each converted), so a training label can be built from it. "**Owned**" = theirs to train on: not rented, not scraped, not held by a vendor |
| **Zero egress · in-environment · identity-scoped** | No customer data leaves the customer's infrastructure · the product runs on infrastructure the customer controls (cloud VPC, K8s, on-prem) · every user sees only what the customer's own SSO says they may |
| **Connector** | The read/write integration between the module and a system of record/action (Salesforce, SAP, Zendesk, a CMMS…) |

### 0.2 Measurement vocabulary

| Term | Meaning |
|---|---|
| **Holdout · treated − holdout · incrementality** | A randomly chosen slice that receives *no* model-driven treatment. The return is what happened to the treated group minus what happened to the holdout — the **incremental** effect — never raw response. **Global holdout** = the same at whole-program level |
| **Uplift · persuadables · sleeping dogs** | Modelling *who changes behaviour because of* a treatment. **Persuadables** respond only if treated; **sure things** were staying anyway; **sleeping dogs** are *harmed* by contact (reminded to cancel). Uplift targeting spends only on persuadables |
| **Champion / challenger** | The incumbent strategy (champion) keeps running on part of the traffic while a candidate (challenger) runs on a randomized slice; the winner is decided on live results |
| **Phased comparison · staggered starts** | Roll out by category / region / asset class at different times, so not-yet-started units act as controls when true randomization is impractical |
| **Side-by-side validation** | The model's output shown next to the incumbent process (CSM intuition, an existing health score) *without* driving action yet — both an accuracy check and the adoption mechanism |
| **FVA — forecast value added** | How much a forecast beats the incumbent process — a naive baseline, a statistical baseline, or planners' manual overrides. Can be negative |
| **Exploration slice / quota / rate floor** | A small share of low-scored or random cases deliberately worked / sent / approved anyway, so the model keeps learning about cases it would otherwise never see and selection bias stays measurable |
| **Below-the-line audit** | Sampling the cases the model *cleared* — auto-paid claims, un-alerted transactions — and re-checking them by hand to measure what it missed |
| **Calibration** | Whether a predicted 20% really happens 20% of the time. Needed whenever the number (not just the ranking) drives money |
| **Label · label window · blackout gap** | The outcome the model learns to predict; the time window after the prediction date in which the outcome counts; a buffer excluded so operational signals of the outcome (a non-renewal notice) don't leak into features |
| **Auto-pause** | A guardrail breach (e.g. spam-complaint rate) that halts the action automatically |

### 0.3 Buyer-side metrics and acronyms

| Domain | Terms |
|---|---|
| **Subscription / revenue** | **ARR / ACV** annual recurring revenue / annual contract value · **NRR / GRR** net / gross revenue retention (does the installed base grow or shrink net of churn and expansion) · **CLV** customer lifetime value · **CAC** customer acquisition cost · **ARPU** average revenue per user · **PQL** product-qualified lead · **NPS** net promoter score · **BTYD** "buy till you die" — probabilistic models of non-contractual customers |
| **Collections / finance** | **DSO** days sales outstanding (how long receivables take to become cash) · **roll rates** share of accounts sliding from one delinquency bucket to the next · **promises-kept / re-default** did the payment plan hold · **cost-to-collect** · **hardship detection** flagging vulnerable customers who must be treated differently · **charge-off** debt written off |
| **Supply chain** | **MAPE** mean absolute percentage error (forecast accuracy) · **service level** share of demand met from stock · **turns** inventory turnover · **stockout / overstock** · **expedite** rush shipping to cover a miss · **S&OP** sales & operations planning · **safety stock** |
| **Manufacturing / assets** | **OEE** overall equipment effectiveness · **PdM / PM** predictive / preventive maintenance · **catch rate** failures that were preceded by an alert · **historian** the plant's time-series sensor database · **MES / SCADA** manufacturing execution / supervisory control systems · **OT / IT** operational vs information-technology networks · **CMMS** the maintenance work-order system · **scrap / first-pass yield** · **run-to-failure** the no-PdM baseline |
| **Payments / fraud / AML** | **bps** basis points (1 bp = 0.01% of volume) · **false declines** good transactions wrongly refused · **chargeback** a disputed card transaction reversed to the merchant · **challenge rate** share of transactions stepped up for extra verification · **PSP** payment service provider · **AML** anti-money-laundering · **SAR** suspicious activity report; **SAR yield** share of alerts that become filings · **KYC** know-your-customer checks |
| **Insurance** | **LAE** loss adjustment expense (the cost of *handling* claims) · **STP** straight-through processing (auto-adjudicated, no human touch) · **leakage** (claims) money paid that shouldn't have been · **SIU** special investigations unit (the fraud team) · **indemnity** the claim payout itself · **FNOL** first notice of loss · **lapse** a policy not renewed · **loss ratio / combined ratio** claims (+ expenses) ÷ premium · **CAT** catastrophe events · **MGA** managing general agent · **CUO** chief underwriting officer |
| **Utilities** | **SAIDI / SAIFI** average outage duration / frequency per customer · **AMI** advanced metering infrastructure (smart meters) · **T&D** transmission & distribution · **O&M** operations & maintenance · **rate case / prudency review** the regulatory proceeding where a utility justifies costs and prices · **load** electricity demand |
| **Healthcare** | **RCM** revenue cycle management (a provider's billing + collections function) · **denials** payer refusals to pay claims · **prior auth** payer pre-approval for a procedure · **clean-claim rate** · **no-show** missed appointment · **PHI** protected health information · **HL7 / FHIR / X12** healthcare data-exchange standards · **CMIO** chief medical information officer |
| **Retail / marketing** | **sell-through · markdown · promo lift · elasticity · same-store comps** merchandising metrics · **CDP** customer data platform · **MAP / ESP** marketing-automation / email platform · **CPQ** configure-price-quote (B2B quoting tool) · **geo-experiment** A/B by region · **PSA** public-service-announcement control ads |
| **Sales / support** | **RevOps** revenue operations · **SDR / AE / CSM** sales development rep / account executive / customer success manager · **speed-to-lead** time to first response · **BANT** budget-authority-need-timeline qualification · **containment / deflection** support contacts resolved without a human — a vanity metric unless repeat-contact is measured |

### 0.4 Regulatory and governance terms

| Term | Meaning |
|---|---|
| **SR 11-7 · MRM · MRA** | US Fed/OCC model-risk guidance (model inventory, documentation, *independent validation / effective challenge*, ongoing monitoring) · the bank's Model Risk Management function that enforces it · "matter requiring attention", a formal examiner finding |
| **GLBA · ECOA / FCRA · fair lending** | US customer-data safeguards law · credit anti-discrimination / consumer-reporting law and its adjacency |
| **NAIC AI model bulletin · AIS program · DOI · market conduct** | US state insurance regulators' expectation of a written, auditable governance program for "AI systems"; adopted state-by-state · that program · a state Department of Insurance · the exam of how an insurer treats customers |
| **HIPAA · BAA · minimum necessary · CMS** | US health-privacy law · business associate agreement (the contract that lets a vendor touch PHI) · the access-limitation rule · the US Medicare/Medicaid agency, whose rules set the prior-auth clock |
| **NERC CIP** | Critical-infrastructure cybersecurity standards for utilities — a security perimeter operational data must stay inside |
| **FDCPA / Reg F · CAN-SPAM / CASL · TCPA** | US debt-collection conduct rules · US / Canadian marketing-consent law · US telephone-contact law |
| **GDPR / CCPA / PIPEDA · DPA · SOC 2 · FCA Consumer Duty · EU AI Act** | Privacy law (EU / California / Canada) · data processing agreement (contract terms about handling a customer's data, which flow down to *their* vendors) · a security-controls attestation · UK vulnerable-customer rules · the EU's risk-tiered AI regulation (employment decisions = high-risk) |
| **Data residency vs AI sovereignty** | Data stays in-country vs control over data *and* infrastructure *and* operations *and* the model lifecycle (IDC's definition) |
| **DPIA** | Data-protection impact assessment |

### 0.5 Sales vocabulary

| Term | Meaning |
|---|---|
| **Economic buyer · champion · outcome owner · validator** | Defined in §2 |
| **ICP · anti-customer** | Ideal customer profile · the profile we decline, argued on p(success) (§4.3) |
| **Landing module · attach · expansion map** | The first module sold · further modules on the same deployed foundation · the standing section of every readout proposing the next attach |
| **Proof metric** | The one readout number, in the economic buyer's ledger units, that wins the renewal |
| **Buying trigger** | The event that opens the conversation (an exam finding, an NRR miss, a downtime postmortem) |
| **Workload placement · repatriation** | Choosing where each workload runs — often onto owned infrastructure rather than public cloud; the plan frames it as placement, never anti-cloud |
| **The contraption · P1 archetype** | The champion's hand-built n8n / notebook / sidecar stack; the persona from the design-partner research (evidence 08) who owns it |
| **Goodhart pressure** | A metric gets gamed once it becomes the target — why holdout integrity is contractual |
| **Dual-audience readout** | The same ROI readout serving as renewal case *and* regulator-grade evidence |

---

## 1. The customer in one sentence

> Any enterprise where **recurring, high-value decisions** meet **owned data exhaust** and
> **a governance requirement** — the three conditions under which risk-adjusted ROI is
> largest (kernel D3; doc 05 §2.1).

In plain words: they make the same money-bearing decision over and over; the records of
those decisions *and their outcomes* pile up in systems they own; and someone — a regulator,
an auditor, a privacy office — constrains what may be done with that data. Each condition is a
term of the scoring calculus `score = E[ROI] × p(success)` (kernel D1; §0.1):

| Condition | What it looks like inside the account | Which term it drives | Why it is non-negotiable |
|---|---|---|---|
| **Recurring, high-value decisions** | The same decision made hundreds-to-millions of times per period with dollars attached: which account to save, which invoice to chase, which claim to route, which asset to service, which price to quote | **E[ROI] numerator** — frequency × per-decision value = the pool a module can address | One-off decisions can't repay an agent-operated system; a decision made continuously can be *measured* continuously — and measurement is the ROI readout, the price basis, and the agent's reward signal at once |
| **Owned data exhaust** (§0.1) | Systems of record producing decision-grade history as a by-product of operating — CRM, ERP, billing, telemetry, tickets, claims, sensors — with the *outcomes* recorded, not just the inputs | **p(success)** (data availability + label quality are its first two drivers) and the agent's training supply chain (D7) | An agent trained on the customer's own data *is* the product; no exhaust ⇒ nothing to train on ⇒ rented inference, which is the anti-portfolio |
| **A governance requirement** | A regulator, examiner, auditor, privacy office, or board policy that constrains where data may go, who may act on it, what must be evidenced | **p(success)** (governance fit) and **differentiation** | The harder the account's governance, the fewer alternatives survive procurement; identity-scoped, audited, in-environment, approval-gated reads as *the compliance posture itself* |

Two corollaries: **industry is a proxy, the conditions are the test** (a mid-market logistics
firm with rich telemetry and a named outcome owner outscores a money-center bank whose data is
inaccessible to its own teams); and **the conditions predict renewal, not just the sale**
(recurring decisions keep generating measurable return; exhaust keeps sharpening the agent;
governance keeps the switching cost of leaving high).

---

## 2. The buying group — three roles that must all exist (doc 05 §2.2)

| Role | Who they are | What they buy | Why the deal dies without them |
|---|---|---|---|
| **Economic buyer** — the P&L owner of the decision pool | Head of Consumer Banking (deposit attrition) · SVP Collections / CFO office (DSO) · Chief Underwriting or Claims Officer (lapse / triage) · VP Revenue Cycle (denials) · COO / VP Manufacturing (downtime, yield) · CRO (pipeline, churn) | **A measured return on a decision pool they already own.** Every proposal opens with the ROI model in *their ledger's units*; the price is a share of *their* return, not a seat count. Also the **renewal buyer** — the ROI readout is written for them | No pool owner ⇒ no ledger to measure into ⇒ nothing to price on |
| **Champion** — the prototype-to-production owner | Head of ML Platform · MLOps Lead · AI Platform Lead · VP Data Engineering · Director of DS Platform (*not the CDAO alone*). Archetype: CEO-sponsored mandate, fluent in the duct-tape stack, a small dev team, two years of "you're too slow" behind them | Leverage that ends their bottleneck without ending their control — architecture, access, and audit stay centrally owned; the agent does the plumbing, operating, and improving | The champion is the person whose queue is the reason the prototype is stuck |
| **Outcome owner** — the person who acts on the output | Save-desk lead · collections queue manager · maintenance planner · renewal underwriter · RCM appeals team | A queue / task / draft in the system they already work in, with reason codes | Kernel D3 verbatim: *no owner ⇒ p(success) → 0*. A proposal without a named outcome owner is a p(success) misestimate; we decline it on our own calculus |
| *Supporting:* **the validator** | Model Risk Management (banking) · AIS-program owner (insurance) · privacy office (healthcare) | The correctness gate, lineage, and audit trail were built to delight exactly this person | In regulated accounts they are the fastest route from vendor to system of record |
| *Supporting:* **CISO / security review** | Every enterprise | In-environment deploy, zero egress, identity via the customer's own SSO | Ours is designed to be the shortest such review in the category |

---

## 3. Why they choose us over the four alternatives (doc 05 §2.3)

| Alternative | What it actually delivers | Where it breaks on the buyer's conditions | The sentence to say |
|---|---|---|---|
| **Accelerators** (Databricks's 93 notebooks; Snowflake's industry catalogs) | A starting-point notebook + a platform to migrate data into; the customer staffs productionization, governance, operation | The prototype-to-production gap is retained by design; data moves to *their* platform, colliding with the governance condition | "An accelerator is the first 10% — you still own the 90% where projects fail. We deliver the deployed, governed, agent-operated solution in your environment, priced on its measured return." |
| **Copilots / rented inference** | Retrieval + prompting over a general model; plateaus at what the rented model knew | Never trains on the customer's data ⇒ no compounding, no explained drivers, no holdout-provable return | "A copilot borrows what a general model knew. Your agent is trained on your data, operates your solution, and gets sharper with every run — and you can measure the difference in dollars." |
| **Consultancies / SIs** | Hours; a bespoke build; knowledge that leaves when the engagement ends | Cost scales with effort, not return; nothing compounds; IP boundary murky | "You can rent effort or buy a return. Our price is set from your measured ROI, the agent keeps improving after the engagement would have ended, and your data and your weights stay yours." |
| **Internal build** | The platform team *could* build it — which is why it won't get to | Opportunity cost of the scarce team; every solution a quarter-long single-shot project with no shared foundation | "Your team keeps architecture, access, and audit. The agents do the plumbing and the operating. The second module rides the same foundation." |

The positive case in one line: **the customer's agents, trained on the customer's data,
operating the customer's solutions, in the customer's environment, priced on the customer's
measured return.**

---

## 4. Which companies — the industry map by ROI fit (doc 05 §3)

All industries are in-scope with **no ordering among them**; account selection within any
industry is D1 scoring on the three conditions. Each row: why the fit is structural, which
catalogue modules dominate, who champions and who signs, what triggers the conversation, and
the **proof metric** — the ROI readout that wins the renewal, stated in the economic buyer's
ledger.

| Industry | Why the ROI fit is structural | Dominant modules (S-n) | Champion → economic buyer | Buying triggers | Governance regime → our advantage | Proof metric (renewal instrument) |
|---|---|---|---|---|---|---|
| **Financial services / banking** | Densest intersection of the three conditions: millions of dollar-denominated recurring decisions, complete labeled ledgers, hardest private-sector governance regime — which maps ~1:1 onto our primitives | S-10 fraud & financial-crime · S-4 collections/DSO · S-1 deposit attrition · S-2/S-11 scoring & NBA · S-7 KPI drivers · (B-7 credit) | Head of ML Platform / VP Data Eng → retail-banking head, SVP Collections/CFO, CRO; **MRM as validator to court, never dodge** | Exam findings / MRAs on model documentation; an internal AI policy blocking DS from shipping; cloud-cost repatriation (framed as workload placement); a notebook model that failed MRM review | **SR 11-7 + GLBA**: inspectable graph = model inventory; correctness gate = effective challenge; audit + lineage = ongoing monitoring; zero egress + SSO scoping = safeguards. "SR 11-7 evidence as a by-product of operating the system" | Recovered $ per contact-hour + DSO reduction vs holdout (collections) · saved deposit balances treated-vs-holdout (attrition) · fraud losses avoided at equal false positives — each doubling as MRM ongoing-monitoring evidence |
| **Insurance** | Recurring priced decisions (renewals, claims, referrals) over decades of labeled loss history, under a tightening regime (NAIC AI bulletin, 24 states as of Mar 2025) | S-1 lapse/retention · S-12 claims triage & fraud referral · S-7 loss-ratio drivers · (B-4 doc automation) | Head of DS / Chief Actuary's modernization lead / VP Claims Analytics → CUO (lapse), Chief Claims Officer (triage/LAE) | A state DOI adopting the bulletin; an AI questionnaire from a reinsurer; a lapse spike in a book; a stuck actuarial prototype | **NAIC AIS program**: agent operating definitions = proportionate risk management; run history + lineage = market-conduct exam evidence; customer-owned weights = "the insurer's model is the insurer's" | Lapse-rate reduction on treated renewal cohort vs holdout **in retained premium dollars** · cycle-time + LAE reduction at equal-or-better leakage — doubling as the AIS ongoing-monitoring exhibit |
| **Healthcare / life sciences** | Administrative pools (denials, prior auth, no-shows, scheduling) are recurring dollar decisions; X12/HL7/FHIR exhaust is standardized; HIPAA makes in-environment the *only* comfortable posture. **Not clinical decisioning** (anti-portfolio) | B-6 denials + no-show · S-5 supply/staffing forecasting · S-7 service-line drivers · (B-4 doc intelligence) | VP Revenue Cycle (champion-adjacent *and* outcome owner) / Head of DS / Dir. Clinical Informatics → CFO; CMIO + privacy office as validators | Denial-rate escalation from specific payers; CMS prior-auth rule compliance clock; margin compression; payers automating denials (providers need symmetric intelligence) | **HIPAA**: "Data Behind Glass" (Mayo's own term) is literally our architecture — the compute visits the PHI; minimum-necessary via SSO-scoped views; native access audit | Denial-rate reduction + recovered reimbursement vs holdout · prior-auth turnaround vs the CMS clock · no-show fill-rate lift on treated clinics |
| **Manufacturing / industrial** | Purest data exhaust in the economy (sensors, MES/SCADA, quality) attached to decisions whose downside is halted lines; governance is operational (safety cases, change control, OT/IT separation) | S-8 predictive maintenance · S-5/S-6 forecasting + replenishment · S-7 OEE/scrap drivers · (B-5 supplier risk; quality/yield sketch) | VP Manufacturing Excellence / plant digital lead / Head of Industrial Data → plant P&L owner / COO; CFO via scrap + downtime dollars | An unplanned-downtime incident with a board postmortem; an OEE program stalled at the dashboard; scrap/energy escalation; a point-solution PdM pilot that never generalized past one asset class | **Operational trust**: every graph versioned + gated = change control; compute-near-data = historian data never leaves the plant network; approval gates on anything touching a physical process | Prevented-downtime hours + maintenance cost avoided vs run-to-failure baseline · MAPE reduction → inventory dollars released · scrap-% / OEE-point gain on one line, one plant |
| **Logistics / fleet** | Fleets are rolling sensor networks — telematics, routes, service records — attached to per-vehicle, per-route, per-day decisions | S-8 fleet PdM · S-5 volume forecasting · S-1 3PL/account churn · S-7 utilization drivers · (ETA sketch) | The P1 archetype — senior platform/AI lead with a CEO mandate and a hand-built n8n/notebook/sidecar contraption → COO/CEO directly at mid-market scale | The contraption becoming unmaintainable; rented-model scoring with no real predictive power; a vendor security review measured in months | **Safe self-service**: Okta-scoped access, no exfiltration ("it's not a service account, it's a tailored view"); driver-facing recommendations stay assistive | Saved-account ARR vs holdout · prevented-downtime hours per asset class · forecast-error reduction → positioning + labor dollars. Renewal narrative: *the contraption is gone, the devs run it themselves, here is the number* |
| **Telecom** | Largest B2C subscriber-churn pools, petabyte network exhaust, and **sovereignty pressure** as national policy — carriers building sovereign AI infrastructure need sovereign workloads | S-1 subscriber churn · S-7 network KPI anomaly · S-11 NBA · S-4 collections · S-5 capacity forecasting | Head of AI Platform → consumer-division P&L (churn/NBA), network ops (KPI); the **sovereign-AI program office** as structural sponsor | Sovereign-AI infrastructure needing workloads; churn spikes in competitive markets; residency commitments; hyperscaler-dependence reviews | **Sovereignty + privacy law**: in-carrier, zero-egress deployment; customer owns deployment, weights, and operating policy — sovereignty over the *model lifecycle*, which residency-only vendors can't offer | Churn saves vs holdout in subscriber dollars · incident/outage reduction on assisted network domains · plus the co-marketable public sovereignty story |
| **Retail / CPG** | Highest-frequency decisions in commerce (price, facings, replenishment, offers) over deep, labeled, continuous POS/e-com exhaust; governance is privacy law + commercial secrecy (margin data leaving the building is unthinkable) | S-5/S-6 forecasting + replenishment · S-11 personalization · S-1 loyalty/subscription churn · S-3 CLV · (B-1 pricing) | Head of Data/AI Platform / VP Merchandising Analytics → Chief Merchant (pricing), SVP Supply Chain (forecasting), CMO (personalization) | Margin-compression program; markdown-waste postmortems; personalization stack renewal (CDP fatigue); board-visible forecast misses | **Privacy + secrecy**: identity-scoped, purpose-limited access; in-environment training with customer-owned weights means elasticity models never leave; explainable pricing drivers | Forecast-error reduction → inventory $ released + stockout revenue recovered · margin per category vs control stores · incremental revenue per session vs A/B control — the format the merchant already trusts |
| **Energy / utilities** | Load forecasting (steering capital and market positions) + asset health over SCADA/AMI exhaust, under NERC CIP and rate-case scrutiny; audited efficiency gains are *regulatorily valuable* | S-5 load forecasting · S-8 grid asset care · S-7 SAIDI/SAIFI drivers · S-4 collections · (grid anomaly sketch) | Head of Grid Analytics / Dir. Asset Management → VP T&D Operations, trading/resource-planning desk, CFO via O&M | A reliability event with regulatory attention; AMI/sensor investments producing data nobody exploits; storm-cost postmortems; rate-case cycles seeking demonstrable efficiency | **NERC CIP perimeter**: in-environment, zero-egress is the shortest path to a CIP-compatible AI program; the ROI readout gains a **third audience — the rate case** | Load-forecast error reduction → market/capacity dollars · avoided outage-hours / O&M per asset class vs run-to-failure — formatted rate-case-ready |
| **B2B SaaS / technology** | Born with the conditions half-met: churn/expansion *are* the recurring decisions; telemetry + CRM + billing exhaust is clean; governance is contractual (DPA flow-down, tenant isolation). Also where the **anti-customer concentrates** | S-1 churn (native anchor) · S-2 lead scoring · S-11 expansion NBA · S-4 collections · S-7 "why did NRR move" · (B-3 ticket triage) | Head of Data / RevOps platform owner / VP Data Eng → CRO (churn/expansion/scoring), CFO (collections), VP Support (triage) | An NRR miss with board attention; a RevOps consolidation program; DPA/security-review friction blocking a SaaS-AI vendor they were about to buy | **Contractual**: in-environment + SSO scoping means customer-data promises survive the vendor's own AI program; customer-owned weights answer "are you training on our tenants' data?" cleanly | Saved ARR vs holdout · NRR movement attributable via treated-cohort design · win-rate + cycle-time lift on treated segments — an audited NRR instrument in a sector valued on NRR |

### 4.1 The firmographic profile (doc 05 §4.1)

D1 scoring inputs, not admission gates by size:

- **Scale:** enterprises large enough to own systems of record and a platform team — density
  center ~1,000–25,000 employees / ~$500M–$10B revenue, no ceiling. Below the band the
  outcome-owner and platform-owner roles usually don't exist ⇒ p(success) collapses.
- **Data estate (must see):** systems of record producing decision-grade, labeled history,
  *accessible* for the named use case.
- **Infrastructure (must see):** a deployment surface they control (cloud VPC, K8s, on-prem)
  and an identity provider.
- **Technographic strong-fit:** on-prem GPU investment; multi-cloud; a FinOps program; a live,
  stuck prototype (notebook / automation tool / LLM-only scorer) — a stuck prototype = a named
  problem + an educated champion + proof the internal path failed.
- **Organizational (must see):** named outcome owner, prototype-to-production champion,
  economic-buyer access.

### 4.2 Segment by dominant decision pool, not size band (doc 05 §4.2)

| Segment (dominant pool) | Typical industries | Economic buyer | Landing module family |
|---|---|---|---|
| Revenue-retention-dominant | SaaS, telecom, insurance (lapse), banking (deposits), subscription retail | CRO / consumer P&L | S-1 churn & retention + S-2/S-11 attach |
| Working-capital-dominant | Banking, utilities, SaaS, any AR-heavy enterprise | CFO office | S-4 collections/DSO + doc-automation attach |
| Loss-avoidance-dominant | Banking (fraud/AML), insurance (claims fraud), security-sensitive ops | CRO(risk) / CFO | S-10 fraud & financial-crime decisioning (assistive designs) |
| Asset-and-operations-dominant | Manufacturing, logistics, energy/utilities | COO / plant & network P&L | S-8 PdM + S-5/S-6 forecasting + quality/yield |
| Administrative-cost-dominant | Healthcare (denials/prior-auth), insurance (claims ops), doc-heavy back offices | CFO / VP Revenue Cycle / COO | B-6 healthcare ops + B-4 document automation + S-12 |
| Exec-intelligence-dominant (attach-first, rarely lands alone) | All | CEO/CFO staff | S-7 KPI driver analysis — the attach that makes every other module legible |

### 4.3 The anti-customer — argued on p(success) (doc 05 §4.3)

Each entry is a structural p(success) failure, priced at ~zero regardless of E[ROI]; sellers
decline by naming the failed driver.

| Anti-customer | The p(success) failure | The decline, said aloud |
|---|---|---|
| Wants an LLM copilot / RAG search, not a trained system | **Measurability fails** — no holdout-provable return for "answers feel better"; an unmeasured module cannot be ROI-priced | "For that, buy a copilot — honestly. We sell measured returns; a copilot's return can't be measured, so we can't price it." |
| Requires us to hold their raw data in our cloud | **Governance fit fails** — and the product thesis with it | "Never — structurally. The engine deploys to your infrastructure. That's not a policy; it's the architecture." |
| No named outcome owner (the innovation lab; the tool collector) | **Adoption fails** — predictions nobody acts on produce no return | "When a named owner will act on the output weekly, we're the right call. Until then a pilot would only measure our ability to be ignored." |
| No platform team / no controlled deployment surface | **Actionability & environment fail** | "We deploy into infrastructure you control. When that surface exists, so does this deal." |
| Wants autonomous high-stakes decisioning out of the gate | **Governance exposure caps p(success)** (anti-portfolio) | "Our agents act under declared autonomy policies with approval gates. If you want unsupervised high-stakes automation, we are deliberately the wrong vendor." |
| Buys projections, resists measurement (no holdout, "just deploy it") | **Measurability fails by refusal** — no readout, no true-up, no renewal instrument | "Our price is set from your measured return. Refusing measurement isn't a discount — it's a different product, and not ours." |

---

## 5. Per module: who buys it, what they watch, and how the metric becomes ROI (doc 04)

The pattern is identical across the catalogue: a **value lever** (one of five return
classes — revenue lift · cost reduction · loss avoidance · working-capital release · risk
reduction), the **operating metrics** the buyer already watches, a **measurement design**
whose output *is* the ROI number (never raw response — always incremental vs a holdout,
challenger, baseline, or phased control), and **guardrail metrics** proving the win wasn't
purchased invisibly. Illustrative E[ROI] is on the reference customer shape in the spec.

| Module | Primary buyer (economic / outcome) | Value lever(s) | The metrics they care about | Guardrails | Measurement design → the ROI number | Illustrative E[ROI] |
|---|---|---|---|---|---|---|
| **S-1 Churn & Retention** | CS/retention leader; CRO / CSMs, retention marketing | Revenue lift (retained recurring margin); cost reduction (budget concentrated on persuadables) | Churn rate; **incremental retention = treated − holdout**; saved revenue = incremental retention × CLV − offer cost; per-driver churn trends | Contact-fatigue complaints; discount budget vs plan; margin erosion; NPS treated-vs-holdout; action-execution rate | Permanent randomized holdout of 5–10% per risk tier; uplift-designed A/B per treatment; side-by-side vs incumbent process before routing. First complete readout matures ~2 quarters after treatments begin (90-day label window) | ≈ 2.5–4× at −1 pp annual churn on $96M ARR (≈ $960k/yr) vs $250–400k/yr all-in |
| **S-2 Lead & Opportunity Scoring** | RevOps / sales leader / SDR + AE teams | Revenue lift (conversion per rep-hour; win-rate mix); cost reduction (SDR capacity) | **Conversion per rep-hour**; win rate; cycle time; band-vs-realized conversion | Lead-response SLA; new-segment coverage; rep cherry-picking; speed-to-lead; exploration-slice size | Randomized routing experiment — score-ordered vs status-quo queues at matched capacity; permanent exploration quota as the selection-bias guard | ≈ 5–15× at +10% conversion on the worked slice ($2–6M ARR) vs $150–300k/yr |
| **S-3 Customer Lifetime Value** | Growth/performance marketing + **finance as named co-owner** | Revenue lift (reallocation to high-CLV); cost reduction (promo concentrated on incremental response); payback discipline | Blended payback; margin; spend-effectiveness; **CLV calibration curve** (predicted vs realized 12/24-month value) | Margin; discount-dependency share; new-vs-returning mix; consent state | Geo-experiments / platform conversion-lift studies for media; **permanent promo holdouts**; CLV backtests. Measurability is the hard part — priced as measurement-design risk | ≈ 3–6× at 3–5% spend-effectiveness on $30M spend |
| **S-4 Collections Prioritization** | Collections / finance ops (SVP Collections, CFO office) / strategy team, agents | Working-capital release (net recovery↑, roll rates↓); cost reduction (cost-to-collect↓); risk reduction (complaints↓ — the regulator-visible metric) | **Net recovery** (recovery − treatment cost); roll rates; promises-kept; re-default; DSO; cost-to-collect | Complaint rate; hardship-detection recall; **contact-cap adherence 100%-or-incident** | Champion/challenger strategy cells (collections ran randomized strategy tests before "A/B" was a phrase); silent side-by-side vs incumbent bucket rules; the cell readout doubles as regulator-legible evidence | ≈ 4–8× at +2% net recovery ($3–6M) + 10–20% cost-to-collect ($1.2–2.4M) on $500M receivables |
| **S-5 Demand Forecasting** | Supply chain / S&OP / planners | Working-capital release (inventory↓ at equal service); revenue lift (availability↑); cost reduction (waste, expedite, planner load) | Forecast error (MAPE) and **FVA vs incumbent process**; service level; stockout rate; inventory turns; waste | Bias by segment; promo-window misses; override rate | FVA is the model-quality loop; the business loop is a **phased comparison by category/region** (staggered starts create built-in controls; randomization impractical) | ≈ 3–8× — inventory −5% ≈ $4M one-time + waste −10% + $1–3M/yr availability on $400M COGS |
| **S-6 Replenishment & Inventory Action** | Supply chain ops + finance / buyers, planners | Working-capital release; cost reduction (expedite, waste); revenue (availability) | Service, stockouts, turns, waste, expedite; **draft-order acceptance rate + edit distance** (the trust metric); release-quality per segment | Release-quality evidence gates A2 eligibility — the autonomy policy's own guardrail | Phased rollout by category vs incumbent ordering; the action layer converts S-5's forecast into **1.5–2× the forecast-only value** | Combined S-5+S-6 ≈ $5–10M/yr on the reference shape; marginal investment above S-5 is small (shared connectors + data plan) |
| **S-7 KPI Anomaly & Driver Analysis** | CFO / COO / exec analytics / the decision forum | Risk reduction + cost avoidance (decision quality — bad big decisions avoided, good ones found earlier) | **Decision-adoption rate**; tracked outcomes vs predicted (the forecast-honesty score); experiments spawned per cycle; the driver KPIs themselves | A program that can't show decisions-and-outcomes within two quarters is a dashboard-graveyard candidate — and the contract says so | Value = Σ(tracked outcomes of adopted decisions vs predicted); the decision log computes it — this module's measurement loop *is* its product surface | ≈ 4–15× (widest variance in the catalogue) at 2 adopted decisions/yr × $0.5–2M vs $150–250k/yr; priced with lower fixed anchor, success-linked component |
| **S-8 Predictive Maintenance** | Reliability / maintenance (VP Manufacturing Excellence, plant P&L, COO) / planners, technicians | Cost reduction (maintenance cost, PM volume, expedited parts); loss avoidance (unplanned downtime, secondary damage, safety) | Downtime hours; maintenance cost; catch rate (failures preceded by alerts) vs false-alarm rate; **technician-confirmed alert precision** (the trust currency) | Alarm fatigue; **downtime baseline recorded at qualification — savings claims without before-measurement are unfundable** | Phased comparison by asset class vs run-to-failure baseline; alerts validated silently by reliability engineers before planners see the queue | ≈ 3–7× at 10–20% downtime reduction + 5–10% maintenance-cost reduction ($2–4.5M/yr) vs $400–700k/yr |
| **S-9 Automated Outbound** | Marketing / growth ops / SDR + marketing-ops | Revenue lift (incremental replies/meetings/pipeline per 1,000 sends); cost reduction (list burn avoided); risk reduction (zero-violation contact governance) | **Incremental pipeline per 1,000 sends** — never open rates | Unsubscribe rate; spam-complaint rate (hard thresholds — breach auto-pauses); deliverability; touches/contact/month; downstream NPS | Permanent randomized send/hold holdout per audience cell; message A/B within cells; the governance panel (zero cap breaches, zero suppressed-identity sends) is part of the true-up | ≈ 4–12× at 20–40% incremental response at 30–50% lower send volume ($1–3M/yr pipeline) vs $120–250k/yr |
| **S-10 Fraud & Financial-Crime Decisioning** | Fraud/AML strategy; CRO risk / fraud analysts, AML investigators | Loss avoidance (fraud bps↓); revenue lift (approval rate↑ / false declines↓ — frequently the *larger* lever); cost reduction (review + triage productivity) | **Reported jointly**: fraud bps, approval rate, challenge rate, review rate, chargeback rate; SAR yield + investigator productivity on the AML level | Growth-vs-fraud threshold wars — joint KPI reporting above the contending teams is the countermeasure | Continuous champion/challenger on live traffic + an exploration slice quantifying missed-good/missed-bad; below-the-line audits (AML). The champion/challenger ledger is the true-up instrument | ≈ 3–6× — fraud −25% ≈ $600k + false-decline recovery +0.3 pp ≈ $1.8–2.7M margin on $3B volume vs $500k–1M/yr |
| **S-11 Next-Best-Action** | CMO / CX decisioning owner / channel + offer owners | Revenue lift (long-horizon value per customer); cost reduction (offer spend concentrated); risk reduction (contradictory-contact harm eliminated) | **Long-horizon cohort value, never per-touch CTR**; net value per active customer; promo-spend efficiency | Unsubscribe/complaint volume; margin; offer-fairness distribution; exploration-rate floor | **Global holdout** (customers on the rule-based/random policy) for program-level incrementality; per-arm bandit statistics for local optimization | ≈ 4–8× at +1–2% net value per active customer ($6–12M) + 10% promo efficiency ($2.5M) on 2M customers vs $600k–1.2M/yr |
| **S-12 Claims Triage & Fraud Referral** | Claims operations; COO insurance (Chief Claims Officer) / adjusters, SIU | Cost reduction (cycle time, adjuster touches, LAE); loss avoidance (leakage↓, referrals that convert); retention-adjacent (claim NPS is the loyalty event) | Cycle time by path; LAE; **STP leakage audits**; referral hit rate vs SIU capacity; NPS by path | Overpayment rate on STP; false-referral burden on honest customers; regulator complaint rates; **denials never automated** | Phased comparison by line of business; re-adjudicating random samples of auto-paid claims (below-the-line sampling); leakage-audit + hit-rate readout is the true-up | ≈ 5–10× at LAE −8% ($7M) + leakage −0.5% of indemnity ($4.5M) on 500k claims vs $500–900k/yr |

**Band-B buyers, briefly** (doc 04 §27): B-1 pricing → Chief Merchant / revenue management
(retail, CPG, travel, B2B CPQ) with elasticity data or the license to create it; B-2 employee
attrition → CHRO at ≥5k employees with works-council sign-off, *aggregate-only*; B-3 ticket
triage → VP Support at ≥100k tickets/yr owning its taxonomy; B-4 document automation → CFO
office / AP, legal ops, KYC ops; B-5 supplier risk → CPO / procurement; B-6 healthcare ops →
VP Revenue Cycle / CFO; B-7 credit underwriting → Chief Credit Officer under fair-lending
overlay; B-8 IT & security ops → CIO / CISO, assistive-only.

---

## 6. How a metric becomes ROI — the arithmetic (kernel D1, D6, D8; doc 06 §2)

### 6.1 The calculus

```
score = E[ROI] × p(success)                         (kernel D1 — selection, pricing, reward)

E[ROI] = expected return ÷ customer investment
         customer investment = module price + integration effort + data work + change cost
                               (all four named — never just our line)
```

### 6.2 The ROI model — three steps, all contract artifacts (doc 06 §2.1)

| Step | Quantity | How it is produced |
|---|---|---|
| 1 | **Value pool `V`** | The customer-specific size of the problem, computed from *their* operating data during scoping: churn revenue at risk; DSO-days × daily cash; inventory-distortion cost. (E.g. each DSO day on $1B revenue ≈ $2.7M cash.) |
| 2 | **Expected annual return `E[R]`** | The intervention effect applied to the pool, net of action costs: `E[R] = V × effect size × margin − action cost`, always using the conservative end of documented effect-size ranges |
| 3 | **p(success) `p`** | The ex-ante probability the deployed solution delivers `E[R]`, scored on the five D1 drivers — data availability & label quality · actionability · measurability · organizational adoption · governance fit — with named risks and countermeasures |

### 6.3 The measurement design *is* the ROI number

The buyer's operating metric (churn rate, DSO, MAPE, downtime hours, fraud bps, LAE …) is
never reported raw. The ROI readout reports the **incremental effect** — treated vs
holdout, challenger vs champion, phased cohort vs baseline, FVA vs incumbent — converted
into **the economic buyer's ledger units** (saved balances, retained premium, recovered
reimbursement, prevented downtime-hours, released inventory dollars). Attributing natural
retention to a campaign, or open rates to outbound, or containment to support automation,
is the documented way programs overstate value; the contract's metric choice neutralizes it.

The readout — assembled by the agent, never hand-built — is the customer-visible artifact
(doc 04 §2.3):

| Section | Role |
|---|---|
| Correctness certificate | Eligibility to be believed (gate checks, entity-resolution test, leakage screens) |
| **Incrementality readout** | **The ROI numerator, measured** — with confidence interval |
| ROI statement | Measured return ÷ customer investment vs the agreed model; variance vs ex-ante E[ROI] |
| Guardrail panel | Proof the win wasn't purchased invisibly |
| Agent operations report | Actions by autonomy class; approval history; override rate; agent-improvement log |
| Audit extract | Every score→action→outcome, model + policy + agent versions; zero governance violations |
| **Price true-up statement** | The success-linked component computed from the incrementality readout |

In regulated verticals the same readout is **dual-audience by design**: renewal case *and*
regulator-grade evidence (MRM ongoing monitoring, AIS exhibit, rate-case prudency) — one
document, two rooms.

### 6.4 The price is a share of the measured return (doc 06 §2.2–2.4; planning assumptions)

- **Anchor:** target annual take = `s(p) × E[R]`, with `s(p)` spanning **10–20% of expected
  annual return, centered at 15%** — the customer keeps ~85% (≈ 5.7:1 on the module price
  alone; target **net customer ROI ≥ 3:1 on the first module**, rising on every attach).
- **Share rises with confidence; contingent weight rises as confidence falls:**

  | p(success) band | Target share of E[R] | Fixed / contingent |
  |---|---|---|
  | p ≥ 0.75 — high confidence | 17–20% | ~70 / 30 |
  | 0.60 ≤ p < 0.75 — standard Band-A | 14–17% | ~55–65 / 35–45 |
  | 0.45 ≤ p < 0.60 — higher variance | 11–14% | ~35–50 / 50–65 |
  | p < 0.45 | not sold as a priced module | — |

- **Structure:** `annual price = F + C(realized)`; `F = max(cost floor, fixed-weight × s(p) × E[R])`
  invoiced flat; `C = contingent-weight × s(p) × R_measured`, accrued quarterly from the
  readout, settled annually at true-up, capped at 1.5× target (overage carries to renewal
  repricing). Two consecutive true-ups below 50% realization trigger a joint review of the
  agent's improvement loop; if realization doesn't recover, either party may exit at renewal.
- **Renewal = the readout** (doc 05 §6.4). There is no separate renewal motion; the same
  document that opened the deal (the ROI model) is the one the renewal is judged by, and the
  expansion map — the next module's D1 score on the now-cheaper investment base — is a
  standing section of it.

### 6.5 Why the customer believes it

The measurement loop has teeth against us (true-up runs both ways), the p(success) markdown
is shared openly (we mark down our own price when confidence is lower), and the metric the
customer pays on is the metric the agent is trained on (kernel D7-2: reward = the module's
measured ROI signal) — so the readout should *trend*, not just hold. A flat readout is
treated as churn risk on our own book.

---

## 7. The seven open tensions the plan itself flags

Appendix A of the catalogue records frictions the authors could not resolve, with the
kernel-conservative reading applied until each is settled. **Three of them change what a buyer is
told**, so they belong here rather than buried:

| # | Tension | Why a seller needs to know |
|---|---|---|
| **T-3** | **Label physics vs true-up cadence.** For churn (90-day windows), collections and CLV (multi-cycle), and credit (vintages), the complete incrementality readout matures **one or more quarters after actions begin** | The contract's true-up cadence must **match its label cadence**. Leading indicators are reported but **never billed on**. Promising a quarterly true-up on a 90-day label is promising a number that cannot exist yet |
| **T-5** | **The measured-ROI reward can be gamed.** Training agents on the ROI signal risks Goodhart effects where the measurement design is weak — S-7's forecast honesty, ticket triage's deflection theatre | The convention: **the reward always carries the guardrail penalty inside it.** Collections' complaint-weighted reward is the pattern. And "measurement-design strength" becomes an explicit p(success) factor |
| **T-6** | **Risk-reduction value that never cashes.** Fraud-loss avoidance and exposure-day reduction are real returns the customer's P&L only ever shows as an **absence** | Measured against modelled counterfactual baselines. Champion/challenger makes this rigorous for fraud; it is weaker elsewhere. Do not promise a P&L line that will not appear |

The other four are internal: Band membership for CLV and replenishment (T-1), UC numbering (T-2),
autonomy-class defaults (T-4), and the re-admission of request-time latency (T-7).

### T-4's three cross-cutting autonomy rules

Proposed as company-wide defaults, and worth knowing because they cut across every module:

1. **Contact may be A2; concessions are A1.**
2. **Payment-direction automation may be A2; denial-direction decisions never are.**
3. **A3 exists only inside pre-approved bounds, with per-change ROI logging.**

Rule 2 is the sharpest — it is why claims triage can auto-pay a fast-track claim but can never
auto-deny one.

## 8. The commercial shape: bundles, not modules

Buyers do not buy S-4. They buy a family that shares one wiring — see
[`buildable-models.md`](buildable-models.md) §5. What matters for the buyer conversation:

**The first module pays for the foundation; every later one is cheaper while its return holds.**
That is the whole expansion argument, and it is a structural fact about the architecture rather
than a discount. The bundle a buyer lands in is set by which decision pool dominates them (§4.2),
and the attach path is already mapped in §6.3.

---

## 9. What this means for the engine today

Cross-reference [`buildable-models.md`](buildable-models.md) §3: the engine's native
trainer is a histogram GBDT + calibration + TreeSHAP + scoring + a lag-feature forecaster,
with UC-1 churn worked end-to-end. So the buyers we can *serve* now are the
revenue-retention-dominant segment (S-1: CS/retention leaders and CROs in SaaS, telecom,
insurance lapse, banking deposits, subscription retail) — the S-1 measurement design (permanent
holdout, treated − holdout, saved revenue = incremental retention × CLV − offer cost) is the
first ROI readout the product can produce — and, on the forecast path, the working-capital
buyers of S-5/S-6. Every other buyer above is catalogue, not code.
