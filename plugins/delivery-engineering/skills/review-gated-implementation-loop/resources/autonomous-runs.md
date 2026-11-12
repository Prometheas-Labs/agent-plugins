---
type: Playbook
title: Autonomous runs
description: Load when the owner hands over a run to continue without them, such as overnight or across sessions.
tags: [process, autonomy, ledger, escalation]
timestamp: 2026-11-11T00:00:00Z
---

# Autonomous runs

An autonomous run continues while the owner is away. The owner reviews it later
from the ledger. Keep the ledger where it lasts. See
[ledger-schema](./templates/ledger-schema.md#where-the-ledger-lives).

## Turn approval gates into ledger entries

A gate that normally waits for the owner becomes a ledger entry. Do not stop at
it. For each gate, record:

- **Decision** — what you chose, the options you rejected, and why.
- **Revisit if** — the fact that would change the decision.
- **Verification** — the commands you ran and their results, or what you saw.
  Say what you did not verify.

## Stop at decisions that are hard to undo

Stop at any decision that is hard or impossible to undo, or that requires the
reversal of a project invariant or an accepted architecture decision record (ADR).

Check reversibility before each outward or destructive step. Do not assume it.

1. Name the action that undoes the step.
2. Name the cost of that action, and who else it affects.
3. Verify the answer. For example, confirm that a backup or a ref exists, or
   that a revert does not force other branches to rebase.

Treat these steps as hard to undo until you verify otherwise:

- Delete data, branches, or records.
- Publish or send content outside the repository.
- Deploy or release.
- Force-push a branch that someone else uses.
- Migrate shared data.
- Spend money, including paid CI minutes.
- Change shared infrastructure.
- Merge outside a delegated merge authority. See
  [dispatcher-orchestration](./dispatcher-orchestration.md#intervene-rarely-escalate-one-decision).

If you are not sure, treat the step as irreversible.

Also stop at any step that the owner named as a stop point when they handed over
the run.

Check each decision against the project's invariants and ADRs. A decision that
requires the reversal of one is the owner's call, even when the code change is
easy to undo.

## When you stop

1. Record the decision in the ledger: the facts, the options, and why it is hard
   to undo or which invariant or ADR it reverses.
2. Continue the work that does not depend on it. One open decision must not stop
   the whole run.
3. Put the open decisions first in the final report.

## Related

- Merge authority and its delegation: [dispatcher-orchestration](./dispatcher-orchestration.md).
- The ledger, and where it lives: [ledger-schema](./templates/ledger-schema.md).
- Escalation during review: [stopping-the-loop](./stopping-the-loop.md).
