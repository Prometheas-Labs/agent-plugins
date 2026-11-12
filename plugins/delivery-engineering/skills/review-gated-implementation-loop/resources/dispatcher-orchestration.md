---
type: Playbook
title: Dispatcher orchestration
description: Load only when you coordinate several related pull requests or several agent owners.
tags: [process, orchestration, subagents, campaign]
timestamp: 2026-08-15T00:00:00Z
---

# Dispatcher orchestration

The loop in [the-shape](./the-shape.md) governs one pull request. A campaign is
many issues that must land together, with more than one owner. A campaign needs a
coordinator. The coordinator is the **dispatcher**. The dispatcher assigns work,
verifies it, and holds the whole together. It does not do every task itself.

## Assign work to owners

- Give each owner one independent work packet. Record any issue that spans several
  packets.
- Give each owner a branch, a written plan, and the gate sequence it must clear.
  Use the templates in [templates/index.md](./templates/index.md).
- Let each owner run to the ready state without per-commit sign-off. The gates
  supervise the work.
- **Quote code facts in a brief.** When a brief states how code behaves, such as
  a schema, a signature, or a query shape, quote the source lines and name the
  file. Do not paraphrase from memory. Tell the owner that the code governs when
  the brief and the code disagree.
- Read each owner's progress from its draft pull request checklist.

## Never trust a report. Verify it.

This is the load-bearing rule. "CI is green" and "all fixed" are claims to
verify, not facts. Run every item in the
[verification checklist](./templates/verification-checklist.md) before you accept
a report. Run the independent review yourself; do not trust the owner's report of
it (see [reviewer-independence](./reviewer-independence.md)). When a finding and a
report disagree, the code decides.

## Keep a ledger

Keep one running document. Use the [ledger schema](./templates/ledger-schema.md).
Record:

- Each packet's status.
- The merge order. Note which pull request must merge before another can rebase.
- Each decision and each escalation.
- The current base commit and which pull requests merged.

The ledger is the memory you reason from. Do not rely on chat history. Keep it
where it lasts; see [where the ledger lives](./templates/ledger-schema.md#where-the-ledger-lives).
When the owner hands over the run, see [autonomous-runs](./autonomous-runs.md).

## Intervene rarely. Escalate one decision.

- Act on an escalation. Verify the facts. Then adjudicate or escalate.
- **Adjudicate** when you can settle it with facts. Relay the facts to the owners.
- **Escalate** when a genuine decision is needed. Give the human one decision:
  the facts, the options, the trade-offs.
- **Merges are the human's call by default.** The owner can delegate merge
  authority by direction: for a named class of pull requests, or for one
  campaign. Record each delegation in the ledger: its scope, its conditions
  (for example, the gates that must pass), who granted it, and when. A
  delegation never covers a step that [autonomous-runs](./autonomous-runs.md)
  says to stop at.
- **Gate other outward and irreversible actions to the human.** These include
  deletions, deploys, releases, and content published outside the project. Do
  not gate the loop's own steps: reading the hosted pull request and CI, the
  pushes and pull-request updates in [the-shape](./the-shape.md), and diffs sent
  to the reviewer that the project approved. Prepare a ready-to-run result. Let
  the human run it. Do not act while you wait. In an autonomous run, apply
  [autonomous-runs](./autonomous-runs.md) instead.
- **Defer non-blocking work into a tracked issue with an owner.** Record it in the
  pull request and the ledger. Classify it with [severity-and-never-defer](./severity-and-never-defer.md).

## Related

- The per-pull-request loop each owner runs: [the-shape](./the-shape.md).
- How to classify what an owner or a reviewer finds: [severity-and-never-defer](./severity-and-never-defer.md).
