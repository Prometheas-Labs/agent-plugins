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

## Test reachability first

Apply this test before you assign a level. A finding enters the scale only when
you can name all four parts:

- **Actor** — who causes the harm.
- **Entry point** — where the actor's input or action enters the system.
- **Required access** — what the actor must already have.
- **Harm** — the concrete damage: data exposed or lost, access gained, a wrong
  result, a broken build or step, or a false claim that a reader acts on.

Then decide who can reach it:

- **An untrusted actor or an ordinary failure can reach it.** Untrusted actors
  include a network peer, a server or relay operator, another user, and a
  stolen device. Ordinary failures include a crash, a restart, and a concurrent
  write. Classify the finding with the scale below.
- **It needs changed trusted source code, or code that already runs inside the
  trusted process.** Record it as optional hardening. Do not fix it in this
  review. Do not start another round for it. Exception: when the task itself
  covers plugin or supply-chain security, classify it with the scale.

Judge reachability against the finished change, not the current commit. A path
that a later commit in the same change connects is reachable.

A reviewer's level is not evidence. Reject a false or unreachable finding with
evidence from the source.

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

Every "Fix" row is mandatory, including at a round cap or when a reviewer will
not converge. Critical and High findings always block delivery. The three
never-defer classes also require fixes at every level. If a required fix cannot
be completed, escalate and stop delivery; do not park or defer it.

| Finding | Action |
|---|---|
| **Critical or High** | Fix every such finding in this review. Re-review. Then commit. |
| **Medium or Low** | You may log it and commit — EXCEPT the never-defer rows below. |
| **Any reachable security finding** | Fix now, at any level. See never-defer class 1. |
| **Anything that blocks a named person's critical path** | Fix now, at any level. See never-defer class 2. |
| **A false claim in docs, a comment, or a PR description** | Fix now, at any level. See never-defer class 3. |

## Never-defer class 1 — security, at any level

Fix these now when they pass the reachability test, whatever the level says:

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

## Never-defer class 3: false claims

Fix a false claim in documentation, a code comment, or a pull-request
description before delivery. Its severity does not make it safe to leave a
reader with incorrect instructions or evidence.

## Classify every finding into one bucket

A reviewer's finding is a lead. Verify it against the code first. Then sort it:

- **Must-fix** — real correctness or safety. Apply the decision table.
- **Deferred** — real, but the decision table permits deferral. Open a tracked
  issue with an owner. Record it. Never drop it silently. See
  [dispatcher-orchestration](./dispatcher-orchestration.md).
- **Accepted design** — a conscious trade-off. Record it in the pull request or a
  decision record, so the next reviewer does not raise it again.
- **Over-strict** — trivial or wrong. Push back with a reason. Repeated
  unsatisfiable findings mean you should [stop the loop](./stopping-the-loop.md).

## Related

- Which gate uses this classification: [the-shape](./the-shape.md).
- What to do when findings never stop: [stopping-the-loop](./stopping-the-loop.md).
