---
type: Playbook
title: Severity and never-defer classes
description: Load when you classify a review finding or decide whether it blocks a commit.
tags: [process, review, severity, security]
timestamp: 2026-08-15T00:00:00Z
---

# Severity and never-defer classes

This file is the one place that classifies a finding. Other files link here. Do
not restate these categories elsewhere.

## The severity scale

The author or the reviewer assigns one level to each finding. If they disagree,
use the higher level.

| Level | Meaning |
|---|---|
| **Critical** | Breaks correctness or safety now. |
| **High** | Breaks correctness or safety under a likely condition. |
| **Medium** | A real defect with a narrow or unlikely trigger. |
| **Low** | A minor defect, a style issue, or a small risk. |

## The decision table

| Finding | Action |
|---|---|
| **Critical or High** | Fix every such finding in this review. Re-review. Then commit. |
| **Medium or Low** | You may log it and commit — EXCEPT the two never-defer classes below. |
| **Any security finding** | Fix now, at any level. See never-defer class 1. |
| **Anything that blocks a named person's critical path** | Fix now, at any level. See never-defer class 2. |
| **A false claim in docs, a comment, or a PR description** | Fix now, at any level. |

## Never-defer class 1 — security, at any level

Fix these now, whatever the level says:

- A credential leaks.
- A token reaches storage, a URL, or a log.
- A request goes off-origin.
- A sign-out is forced.
- An authorization decision moves to the client.
- A denial becomes distinguishable from an invisible read.

The level lies here. The level tracks exploitability under the CURRENT wiring. A
large change alters the wiring. A finding marked "Medium, not reachable" becomes
critical the moment a later commit connects it.

## Never-defer class 2 — a named person's critical path

Write the path as a concrete sequence a real person performs. Example: clone, run
one command, sign in, see X, do Y, then follow only the README to build Z. Fix
anything that breaks a link in that chain now.

This clause aims the loop at outcomes. It is not a level. It is a named person
doing a named thing. Use it to settle disputes: do not ask "how bad is this"; ask
"which link in the chain does it break." If it breaks no link, it can wait.

## Classify every finding into one bucket

A reviewer's finding is a lead. Verify it against the code first. Then sort it:

- **Must-fix** — real correctness or safety. Apply the decision table.
- **Deferred** — real, but out of scope now. Open a tracked issue with an owner.
  Record it. Never drop it silently. See [dispatcher-orchestration](./dispatcher-orchestration.md).
- **Accepted design** — a conscious trade-off. Record it in the pull request or a
  decision record, so the next reviewer does not raise it again.
- **Over-strict** — trivial or wrong. Push back with a reason. Repeated
  unsatisfiable findings mean you should [stop the loop](./stopping-the-loop.md).

## Related

- Which gate uses this classification: [the-shape](./the-shape.md).
- What to do when findings never stop: [stopping-the-loop](./stopping-the-loop.md).
