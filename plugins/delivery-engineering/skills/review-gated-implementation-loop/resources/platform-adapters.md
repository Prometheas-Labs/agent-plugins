---
type: Reference
title: Platform adapters
description: Load only when mapping a review checkpoint to repository commands, CI, a Git host, or a reviewer CLI.
tags: [process, platform, adapters]
timestamp: 2026-08-15T00:00:00Z
---

# Platform adapters

The loop is vendor-neutral. Its steps name abstract actions. This file maps each
abstract action to a real tool. The loop rules do not change. Only the mapping
changes. Fill this in for your environment.

Keep process invariants separate from platform choices. An invariant holds
everywhere. A platform choice is one way to satisfy it here.

## Invariant → adapter

| Invariant (always true) | Adapter (your choice) |
|---|---|
| Open a plan as a draft before work is reviewable. | A draft pull request. Or a local plan file if you cannot open a pull request yet. |
| A gate runs a check and records a verdict. | Your CI system and your review tool. |
| The workspace check runs with the cache bypassed. | The command that forces a clean build and test in your build tool. |
| An independent reviewer reads the diff. | Your cross-vendor model, run as a command-line tool or an API call. |
| Findings are tracked and resolved. | Your review tool's threads, or issues. |
| History is linear and readable at merge. | Your host's merge style, such as squash merge. |
| The automated reviewer runs only when work is ready. | Your host's draft state, plus a command to pause or resume the reviewer. |

## When you cannot open a pull request

An agent may lack repository access or permission to create external state. Do not
block. Keep the plan and the checklist in a local file. Move it to a draft pull
request when creation is authorized.

## Reviewer command-line notes

These notes apply when the reviewer is a command-line model.

- Feed the diff inline. Do not point the reviewer at the repository.
- Tell the reviewer not to run tests or builds. Tool runs cause hangs.
- Retry once on a transient failure.
- Record which model and tier ran. See [reviewer-independence](./reviewer-independence.md).

## Automated-reviewer notes

- A "pass" status can mean the reviewer reviewed nothing. Confirm a review body
  exists, dated after your last push.
- Enumerate review threads from the API. A summary count can undercount.
- A draft pull request may not trigger the automated reviewer. Mark it ready to
  start the review.

## Related

- The steps these adapters serve: [the-shape](./the-shape.md).
- Verifying that a check really ran: [dispatcher-orchestration](./dispatcher-orchestration.md).
