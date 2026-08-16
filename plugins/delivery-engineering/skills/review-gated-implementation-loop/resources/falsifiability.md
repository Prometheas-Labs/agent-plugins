---
type: Playbook
title: Falsifiability — prove a test can fail
description: Load before validating an added or changed test, or when test effectiveness is disputed.
tags: [process, testing, verification]
timestamp: 2026-08-15T00:00:00Z
---

# Falsifiability — prove a test can fail

A test that cannot fail proves nothing. Reading a test does not show whether it
can fail. Reverting the behavior does. This practice is worth more than an extra
review round. For the evidence behind that claim, see [rationale](./rationale.md).

## Core rule

For every test you add or change, state the breaking change that turns it red.
Then verify the important tests. Revert the behavior and watch the test.

## Two reverts, opposite expectations

Do not confuse these two reverts.

- **Revert the behavior under test. Keep the test.** The test must go **red**.
  This proves the test observes the behavior.
- **Revert the mechanism you added. Keep the test and a live offender.** The suite
  must go **green**. This proves your mechanism detects the offender, and not
  something else.

Reverting the test itself proves nothing.

A test can survive a revert that does not remove the behavior it names. Reason
about it. Do not delete a good test.

## Supporting checks

- **Positive control.** When you measure, include an input whose answer is known.
  A probe that reports the same value for every input is broken. A known-good
  input exposes it.
- **Calibration assertion.** Assert that the setup varies what it claims to vary.
- **Reject vacuous passes.** "No offenders found" is meaningless if the finder
  could never find one. Supply a synthetic offender. Watch red. Then remove it.
- **Assert the right property at the right moment.** Common traps: assert presence
  where visibility matters; assert a value the test hard-coded; await nothing;
  place an expectation inside an un-awaited promise.

## Why this belongs in the loop

A reviewer reasons only over what the diff shows. Falsifiability gives the
reviewer ground truth it cannot fake. A test with a proven red condition is a
claim the reviewer can trust. It is the per-test form of the rule in
[reviewer-independence](./reviewer-independence.md): do not let a thing certify
itself.

## Related

- The gate where you write these tests: [the-shape](./the-shape.md).
- A finding is a lead to verify, not a ruling to obey: [reviewer-independence](./reviewer-independence.md).
