---
type: Template
title: Draft pull-request body
description: Load to start a draft pull request body — a plan overview plus a live commit checklist.
tags: [template, pull-request, plan]
timestamp: 2026-08-15T00:00:00Z
---

# Draft pull-request body template

Copy the block below into a new draft pull request. Fill the placeholders. Tick
each box as its commit lands. Record the commit id next to the box.

```markdown
## Delivery overview

<One paragraph. What this pull request delivers and why.>

## Governing decisions (do not weaken)

- <Decision 1, with its reason.>
- <Decision 2, with its reason.>

## Rejected alternatives

- <Alternative, and why it was rejected.>

## Commit checklist

- [ ] <Commit 1: short description> — `<sha>`
- [ ] <Commit 2: short description> — `<sha>`
- [ ] <Commit 3: short description> — `<sha>`

## Deferred (tracked, not dropped)

- <Deferred item> → issue #<n>, owner <name>
```

## Rules

- Open this as a draft before any work is reviewable.
- Keep the checklist current. Push each commit, then tick its box.
- Mark the pull request ready only at final delivery.

See [the-shape](../the-shape.md).
