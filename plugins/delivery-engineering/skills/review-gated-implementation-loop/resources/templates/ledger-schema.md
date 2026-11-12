---
type: Template
title: Dispatcher ledger schema
description: Load to start or structure the dispatcher's campaign ledger.
tags: [template, ledger, campaign]
timestamp: 2026-08-15T00:00:00Z
---

# Dispatcher ledger schema

Keep one ledger per campaign. Update it as state changes. Reason from the ledger,
not from chat history. See [dispatcher-orchestration](../dispatcher-orchestration.md).

```markdown
# Campaign ledger: <name>

## Ground state
- Base commit: <sha>
- Updated: <timestamp>

## Packets
| Issue | Owner | PR | Status | Blocks / blocked by |
|-------|-------|----|--------|--------------------|
| #<n>  | <name>| #<n> | planning / in-progress / green / merged | <ids> |

## Merge order
1. <PR that must merge first>
2. <next>

## Decisions and escalations
- <date> — <decision or escalation, and the outcome>

## Deferred (tracked)
- <item> → issue #<n>, owner <name>
```

## Where the ledger lives

- Keep the ledger where it survives a restart and where the owner can find it
  later. For example, commit it on the work branch, or put it in a folder that
  the repository already uses for plans or ledgers.
- Never keep it in an operating-system temporary directory, such as `/tmp` or
  `$TMPDIR`. The operating system deletes those, sometimes during a run. The
  same rule applies to worktrees, briefs, and handoff notes.
- Write to it as you go. A run that stops early must still leave a readable
  ledger.
- Name the ledger's location at the start of the run and in the final report.

## Status values

- **planning** — plan not yet accepted.
- **in-progress** — commits landing.
- **green** — all checks pass and all threads resolved; verified directly.
- **merged** — merged to the base branch.
