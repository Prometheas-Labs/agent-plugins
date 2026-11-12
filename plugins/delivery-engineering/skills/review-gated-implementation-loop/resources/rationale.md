---
type: Reference
title: Rationale — evidence behind the rules
description: Load only to see the evidence behind a rule. You do not need this file to run the loop.
tags: [rationale, evidence]
timestamp: 2026-08-15T00:00:00Z
---

# Rationale — evidence behind the rules

This file holds the evidence for the loop's rules. You do not need it to run the
loop. Read it to understand why a rule exists, or to defend a rule to a skeptic.
Each rule below earned its place from a real delivery.

## The composed-diff gate finds real defects

The whole-phase gate found a defect in each of three phases. Each defect existed
only in the combination of individually-correct commits. The sharpest case: a
security cleanup lived in a file that a later task deleted. The delete took the
only test with it. No single task's diff held both halves. See
[the-shape](./the-shape.md).

## Tests can pass without being able to fail

One delivery had seventeen tests that could not fail. Reading them caught none.
Reverting the behavior caught all of them. This is why falsifiability outranks an
extra review round. See [falsifiability](./falsifiability.md).

## A round cap prevents wasted effort

One task used all five fix-rounds. The last finding was a specification defect. No
further round would have found it. A fresh implementer wrote a needed regression
test at once, after five rounds had failed to. This is why you escalate to fresh
eyes, not more effort. See [stopping-the-loop](./stopping-the-loop.md).

## Severity lies when wiring changes

A forced-sign-out primitive arrived labeled Medium. Its level tracked
exploitability under the wiring at that moment. A large change alters the wiring.
This is why security is a never-defer class at any level. See
[severity-and-never-defer](./severity-and-never-defer.md).

## A green check can be empty

In one campaign, three security-critical test suites ran in no check at all. Both
required checks passed because the suites never ran. Only direct verification
found it. This is why the dispatcher verifies every claim. See
[dispatcher-orchestration](./dispatcher-orchestration.md).

## False documentation is the most common defect

Across three phases, a false claim in documentation was the single most persistent
defect class. It outranked any logic defect. This is why you fix false docs at any
level. See [severity-and-never-defer](./severity-and-never-defer.md).
