---
type: Playbook
title: The loop for one pull request
description: Load after you classify work as Substantial or Campaign, to run the full review loop for one pull request.
tags: [process, review, pull-request]
timestamp: 2026-08-15T00:00:00Z
---

# The loop for one pull request

Run this loop when [planning-altitude](./planning-altitude.md) sets the change to
Substantial or Campaign. For a Campaign, run this loop inside each pull request
and coordinate the pull requests with [dispatcher-orchestration](./dispatcher-orchestration.md).

## The steps

1. **Open one pull request as a draft.** Do this before any work is reviewable.
   The pull request body is the plan. Put a delivery overview and a checklist of
   the expected commits in it. Use the [draft-PR template](./templates/draft-pr-body.md).
2. **Plan each phase up front.** Write the decisions and the rejected
   alternatives. A settled decision is out of scope for review.
3. **Per task, write the failing test first.** Run it. See it fail.
4. **Implement to green.** Run the workspace check and the end-to-end check.
5. **Review the staged diff.** Use an independent reviewer. See
   [reviewer-independence](./reviewer-independence.md). This review gates the
   commit, not the merge.
6. **Apply the severity gate.** See [severity-and-never-defer](./severity-and-never-defer.md).
   Fix now, or log to the ledger.
7. **Commit and push one commit.** Tick its checklist item. Record the commit id.
8. **Review the whole phase as one composed diff.** Some defects live only in the
   combination of correct commits. This gate finds them.
9. **Run the automated review.** Work every finding to closure. Reply, resolve,
   push.
10. **At final delivery, mark the pull request ready.** Verify each completion
    criterion, one at a time.
11. **Merge.** Then triage every deferred item into a tracked issue. Never drop
    one silently.

## Define each gate the same way

A gate is not prose. Define each gate by four parts. See
[platform-adapters](./platform-adapters.md) for how each part maps to your tools.

- **Input** — the exact diff or artifact under review.
- **Check** — the command or the review prompt that runs.
- **Pass condition** — the exact result that lets you proceed.
- **Recorded output** — where you write the verdict.

## Three rules carry most of the value

- **The draft pull request is a channel, not a final report.** Open it early. Its
  body is the live plan and the progress tracker. Tick the checklist as commits
  land. Mark it ready only at final delivery.
- **Review gates the commit, not the merge.** A finding is cheapest to fix while
  the diff is staged and the author's context is fresh.
- **The composed-diff gate is not a formality.** It finds defects that no single
  task's diff holds. See [rationale](./rationale.md) for the evidence.

## Settle open questions before you execute

- Write each decision with its reasoning and its rejected alternatives.
- A reviewer that proposes a rejected alternative is answered by the document, not
  by another round.
- Name the settled decisions in every review prompt. A finding that reopens one is
  an escalation, not a fix. See [stopping-the-loop](./stopping-the-loop.md).

## Related

- Who reviews, and why they must differ from the author: [reviewer-independence](./reviewer-independence.md).
- Prove the tests can fail: [falsifiability](./falsifiability.md).
- Run this across many pull requests: [dispatcher-orchestration](./dispatcher-orchestration.md).
