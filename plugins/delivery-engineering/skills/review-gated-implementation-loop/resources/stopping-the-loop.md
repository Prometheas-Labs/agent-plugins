---
type: Playbook
title: Stopping the loop
description: Load when review rounds repeat, reopen settled decisions, or fail to converge.
tags: [process, review, escalation]
timestamp: 2026-08-15T00:00:00Z
---

# Stopping the loop

A reviewer at high effort can find one more thing forever. Without limits, the
loop stops converging and starts gold-plating. These rules keep it finite.

This file owns round limits and escalation. For reviewer setup and prompt rules,
see [reviewer-independence](./reviewer-independence.md). For how to classify a
finding, see [severity-and-never-defer](./severity-and-never-defer.md).

## Bound the rounds

- **Set a fixed cap of fix-rounds per task.** Five is a good default.
- **At the cap, adjudicate.** Escalate if any surviving finding is load-bearing.
  Otherwise park it with a written ruling and move on.

## Break the pattern, do not add effort

- **Escalate to fresh eyes.** A task that survives several resumes usually means
  the author cannot see its own problem. Hand the report to a fresh implementer.
  Tell it: "a prior attempt tried this N times; you own it now."
- **State the model tier.** If the author is already at the top tier, say so.
  Do not imply that a bigger model is coming.

## Recognize an unconverging reviewer

The reviewer will not converge when it does one of these:

- It demands a proof that no artifact can give.
- It raises a stricter bar each round. Round N asks for "non-empty." Round N+1
  asks for "exhaustive."

When you see this, make a judgment call. Do not chase the verdict.

1. Fix the findings that are genuinely real.
2. Record the accepted-design stance for the rest.
3. Defer the remainder to tracked issues.
4. Ship.

The reviewer informs the decision. It does not own the decision.

## Shape the prompt to close questions

- **Carry a do-not-relitigate list** in every re-review prompt. List the settled
  decisions and the findings you already ruled on.
- **Ask for rulings, not assessments.** "Rule on X, and say what changes if it is
  wrong" closes a question. "Assess X" reopens it.

## Route judgment calls to the human at once

- A product trade-off, a scope boundary, or a plan contradiction is the human's
  call. Do not let two agents trade opinions on it.
- **A finding that contradicts the plan is an escalation.** Show the finding next
  to the plan text. Ask which one governs. Do not implement against the plan in
  silence.
- **Escalate one decision at a time.** Give the facts, the options, and the
  trade-offs. Do not act on an outward or irreversible action while you wait.

## Related

- What "load-bearing" is judged against: [severity-and-never-defer](./severity-and-never-defer.md).
- Verify a finding instead of trusting it: [falsifiability](./falsifiability.md).
