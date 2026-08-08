---
name: new-eval-profile
description: "Generate an eval profile - a situation plus its data - from whatever the user gives you (an industry, a role, a company shape, a pain point), researching the rest. Produces situation.md, profile.json and real records, then publishes to the private OramaSearch/agent-eval-profiles dataset. Use when asked to make a new eval, add a profile, build a test situation for Auto-Suggest or project creation, or evaluate an agent against a realistic business. Triggers - 'create an eval', 'new profile', 'generate a profile', 'make an eval for <industry>', 'I want a profile where...', 'add a test situation'."
---

# new-eval-profile — turn a hint into a scoreable situation

Read [`modules/zetta/docs/agent/eval-profiles.md`](../../modules/zetta/docs/agent/eval-profiles.md)
for the schema and the rules. This skill is the procedure for producing one.

Tracking: [zetta#987](https://github.com/oramasearch/zetta/issues/987).

## What you are making

A **profile is a situation plus its data**: who someone is, what they are responsible for, what
data they can reach, and the actual schemas and records. It scores two things:

```
profile  ──►  Auto-Suggest  ──►  a set of candidate TASKS
profile + chosen intent  ──►  project creation  ──►  a Pipeline
```

**It is not a task, an intent, or an RL environment.** A draft that named the traps and
pre-decided the correct answers was thrown away — every eval built on it would have measured
recall of an annotation rather than reading of the data.

## 1 · Take what you were given, then research the rest

The user supplies a seed — an industry, a role, a company shape, a pain point, sometimes just
*"something in logistics"*. Everything else you research:

- **The solutions catalogue** (`modules/solutions-designs/docs/plan/04-solutions-catalog.md`) for
  what a business like this plausibly wants: S-1 churn · S-5 demand forecasting · S-8 predictive
  maintenance · S-10 fraud · S-12 claims triage, and the rest.
- **Perplexity** (the `perplexity` skill) for what the systems and schemas actually look like in
  that industry — real system names (Guidewire, NetSuite, Samsara), real table and column
  conventions, real null-rate and data-quality patterns. **Invented schemas produce shallow
  profiles**; a model can pattern-match `customer_table.churn_flag` and learn nothing.
- If deep research would help more than a quick lookup, **write the user a Perplexity deep-research
  prompt** and let them run it rather than guessing.

**Ask before inventing** anything that changes the answer — the person's authority, what they can
act on, the regulatory posture. Those are the fields that decide what a good task set looks like.

## 1b · Be curious. A cross-product is not diversity.

Generating profiles by multiplying a few templates produces **one shape wearing many names** — the
exact defect that made a 14,889-case corpus teach two pipeline shapes. **Every profile should
surprise someone who read the last one.**

Vary what changes the answer: the **industry** (a grain elevator co-op, a dialysis network, a
municipal water utility — not B2B SaaS with different nouns) · **the shape of the mess** (three
systems disagreeing about identity; clean data and nobody who can act on it; a column that
silently changed meaning after a migration) · **the number of sources** (two tables, or fifteen
across six systems where the question becomes *which things and in what order*, because one
project's output is another's input) · **the person's authority** · and **whether a good answer
exists at all** — a generator that always produces a solvable situation teaches that a solution
always exists.

If you produce a profile whose structure you have already produced, **stop and pick something
further away.**

## 2 · Write the situation

Role, tenure, what they are measured on, and **what they can actually act on**. Then connections
with capture state, then tables.

**`persona.constraints` must narrow the space of correct answers.** *"Runs a small team"* does not.
*"Can dispatch about 40 preventive jobs a month"* does — it makes a model that proposes scoring
every asset wrong for this situation and right for another.

**`connections[].state`** — `discovered` (introspected only) or `captured` (in parquet). A pipeline
that trains needs captured data, so a task blocked on an uncaptured source has the answer
**"capture it first"**, not "cannot be done". Include at least one of each; the distinction is
worth testing.

## 3 · Generate the records — this is the part that matters

`records.py` in `modules/agent-eval-generator`. Two rules, and getting either wrong makes the
profile worthless:

**Awkwardness is GENERATED, never annotated.** If the schema says `cancelled_at` is null for active
subscriptions, the records really are like that. Never write *"note: mostly null"* — an annotation
turns the eval into a reading-comprehension test. State the null fraction as a fact and stop.

**The structure has to reward reading it.** Random noise shaped like a schema teaches nothing. Put
something real in there: subscriptions that largely *determine* daily orders, a `total_paid` that
is only populated after close, a timestamp that is the pipeline load date rather than the source
change date. A model that reads the tables should beat one that pattern-matches the ask.

### The quality bar, as a test you run

> **Perturb one fact and the correct answer must change.**

Remove the label column, drop the null rate to 0.05%, take away the cutoff. If the right answer
survives unchanged, the profile is testing recall of the ask rather than reading of the data —
rewrite it.

## 4 · Package, view, publish

```sh
cd modules/agent-eval-generator
uv run python -c "..."      # package(profile_id, situation, tables, Path('evals/profiles'))
```

```
<profile-id>/
  profile.json              persona · connections · tables
  situation.md              the same situation, readable
  records/<db>.<table>.jsonl
```

**Show the user before publishing.** They review the situation and the schema — that is the review
step the GUI profile viewer ([zetta#988](https://github.com/oramasearch/zetta/issues/988)) exists
to make easy, and an eval nobody reviews is one whose defects reach a model.

Then publish to **`OramaSearch/agent-eval-profiles`**, private, verified private *before* upload:

```sh
curl -s -H "Authorization: Bearer $HF_TOKEN" \
  https://huggingface.co/api/datasets/OramaSearch/agent-eval-profiles | grep -o '"private":[a-z]*'
hf upload OramaSearch/agent-eval-profiles evals/profiles --repo-type=dataset \
  --commit-message="<profile-id>: situation, schema and N records"
```

Update the dataset card with the new profile **and its limitations** — never only its size.

## Never

- ❌ Annotate the awkwardness. It lives in the data.
- ❌ Include tasks, intents, or correct answers. Later layers.
- ❌ Invent a schema when research would give you a real one.
- ❌ A constraint that does not narrow the answer space.
- ❌ Publish without verifying the repo is private.
- ❌ Claim a profile discriminates before a model has been scored against it. Until then it is a
  dataset, not a benchmark.

## Related

- `modules/zetta/docs/agent/eval-profiles.md` — the schema and field rules
- [zetta#988](https://github.com/oramasearch/zetta/issues/988) — the GUI viewer
- **perplexity** · **new-agent** · **hf-ops**

## Version History
- v1.0.0 (2026-08-07) — Initial, distilled from building the `coffee-subscription` profile: research
  before inventing, constraints that narrow the answer space, awkwardness generated rather than
  annotated, and the perturbation test as the quality bar.
