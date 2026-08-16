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

The ledger is the memory you reason from. Do not rely on chat history.

## Intervene rarely. Escalate one decision.

- Act on an escalation. Verify the facts. Then adjudicate or escalate.
- **Adjudicate** when you can settle it with facts. Relay the facts to the owners.
- **Escalate** when a genuine decision is needed. Give the human one decision:
  the facts, the options, the trade-offs.
- **Gate outward and irreversible actions to the human.** These include merges,
  deletions, deploys, and anything sent to an external service. Prepare a
  ready-to-run result. Let the human run it. Do not act while you wait.
- **Defer non-blocking work into a tracked issue with an owner.** Record it in the
  pull request and the ledger. Classify it with [severity-and-never-defer](./severity-and-never-defer.md).

## Related

- The per-pull-request loop each owner runs: [the-shape](./the-shape.md).
- How to classify what an owner or a reviewer finds: [severity-and-never-defer](./severity-and-never-defer.md).
