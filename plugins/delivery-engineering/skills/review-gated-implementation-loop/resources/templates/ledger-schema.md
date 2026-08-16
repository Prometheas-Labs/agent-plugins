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

## Status values

- **planning** — plan not yet accepted.
- **in-progress** — commits landing.
- **green** — all checks pass and all threads resolved; verified directly.
- **merged** — merged to the base branch.
