# Attested computations

An `Attested Computation` concept holds the one sanctioned way to compute a value, so a consumer can confirm a number came from running it. OKF records the contract; it runs nothing itself.

Write one concept per computation, once you have both its query and its `runtime`. Concepts that need the value link to it and leave the query out.

````markdown
---
type: Attested Computation
title: Revenue for fiscal year
description: Recognized revenue for a fiscal year, per Finance's definition.
status: draft
runtime: bigquery
parameters:
  - { name: year, type: integer, required: true }
executor:
  resource: references/skills/run-on-bq.md
  receipt: [job_id, executed_sql, result]
attester:
  resource: references/attesters/revenue.py
generated:
  by: claude-code/claude-opus-5-5
  at: 2026-06-20T22:53:05Z
sources:
  - id: rev-policy
    resource: https://example.com/finance/revenue-recognition
    title: Revenue recognition policy
---

# Computation

```sql
SELECT SUM(amount) AS revenue
FROM finance.recognized_revenue
WHERE fiscal_year = @year
```

The computation follows the recognition policy.[^rev-policy]

[^rev-policy]: Revenue recognition policy
````

| Field | Meaning |
| --- | --- |
| `runtime` | Required for this type. How to run the computation, which also defines what `parameters` mean. |
| `parameters` | Typed holes a consumer may fill: `{ name, type, required }`. |
| `computation` | URL or path to a file holding the computation, used instead of the body block. |
| `executor.resource` | Run instructions or code. |
| `executor.receipt` | Fields a run must return as evidence. |
| `attester.resource` | Deterministic code, with no LLM, that checks a receipt and returns a verdict. |

- Put the computation in exactly one place: a single fenced code block under `# Computation`, or the `computation` path.
- Take the query from an owner's approved source. A query you drafted isn't sanctioned.
- If the query or `runtime` is unavailable, skip this concept. In the concept that needs the value, say who owns the computation and where it lives, then report what's missing.
- Point `executor` and `attester` at files that exist or that the user has agreed to provide, and report any that are still missing.
- Keep receipts and verdicts out of the bundle, because they belong to each run.
