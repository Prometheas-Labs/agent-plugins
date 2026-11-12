---
type: Playbook
title: Reviewer independence
description: Load when you select, configure, or brief an independent reviewer for a diff.
tags: [process, review, models, independence]
timestamp: 2026-08-15T00:00:00Z
---

# Reviewer independence

The reviewer's job is to catch what the author cannot see. A model that reviews
its own work shares its own blind spots. So the reviewer must be independent of
the model that did the work. Independence has two axes. Pick the strongest axis
the environment gives you. Record which tier you used.

## Choose the reviewer

Use the highest available tier.

| Tier | Reviewer | What it gives |
|---|---|---|
| **1 — best** | A different vendor's model than the author's model. | Different training and different alignment. The reviewer is blind to different things than the author. |
| **2 — partial** | The same vendor, a different model or size, in a clean context. | Some behavior diversity. Less blind-spot diversity. |
| **3 — fallback** | The same model, in a fresh isolated context. | No model diversity. It still removes author bias, such as sunk cost and "I already settled this." |

Automate the choice. Detect which foreign models are reachable. Pick the highest
tier. Fall back if none is reachable. Stamp the verdict with the tier you used, so
a reader knows how much rigor the review had.

Tier 3 is a real downgrade. Correlated blind spots survive it. Name it as a
fallback, not an equal.

## Brief the reviewer the same way every time

- **Give it the diff, the settled decisions, and the do-not-relitigate list.**
- **Tell it to refute, not to confirm.** Ask "find the case that breaks this," not
  "does this look correct."
- **Forbid it from editing.** The reviewer rules on the work. It does not change
  the work.
- **Limit it to reading.** Feed the diff inline. A command-line reviewer can
  also read the repository, for example to find the callers of a changed
  function. Run it in a read-only sandbox when the tool has one. Forbid builds
  and test runs. They cause hangs and waste rounds.
- **Give the scope and the rulings. Do not cap findings.** The prompt can state
  the threat scope and the owner's earlier rulings. Tell the reviewer to report
  a finding in a ruled class, and to label it with that ruling. Do not tell the
  reviewer to skip an area. Do not cap the level of a finding that no ruling
  covers. Correct: "The owner ruled on 2026-09-25 that X is optional hardening.
  Report X, and label it hardening." Incorrect: "Do not flag X" or "at most Low."
- **Say that a clean verdict is useful.** A reviewer told only to be thorough
  invents a finding to justify the round.

## Do not obey the reviewer blindly

A finding is a lead, not a ruling. Verify each finding against the code. Then
classify it with [severity-and-never-defer](./severity-and-never-defer.md). A
reviewer that keeps returning "do not ship" on unsatisfiable grounds is a signal
to [stop the loop](./stopping-the-loop.md), not to chase its approval.

## Related

- The gate the reviewer performs: [the-shape](./the-shape.md).
- What to do when the review will not converge: [stopping-the-loop](./stopping-the-loop.md).
- In a campaign, the dispatcher runs this review itself: [dispatcher-orchestration](./dispatcher-orchestration.md).
