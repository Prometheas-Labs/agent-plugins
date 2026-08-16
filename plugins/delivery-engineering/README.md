# delivery-engineering

Engineering delivery workflows: turning an **approved implementation plan** into
**merged, shipped, and coordinated** work.

## Scope

This plugin owns the **execution half** of the software delivery lifecycle. It
begins where a plan is settled and ends when the work is merged, verified, and
its coordination state is recorded. It hosts a family of skills:

- **`review-gated-implementation-loop`** — plan and execute a large or high-risk
  change with an independent reviewer gating each step. *(available)*
- **campaign orchestration** — coordinate many work items: issue metadata for
  starting work, documented pivots, and project-board state. *(planned)*
- **pull-request shepherding** — drive an open pull request to green and merge;
  "babysit" checks, reviews, and threads. *(planned)*

## Scope boundary

This plugin does **not** decide *what* to build or *why*. Product definition —
product constitution and vision, PRDs and TRDs, user stories, scenarios,
acceptance criteria, and implementation *planning* — belongs to the
[`product-development`](../product-development) plugin.

The two plugins meet at one hand-off:

```
product-development                         delivery-engineering
  idea → constitution → vision           →    approved plan → implementation
  → PRD → TRD → stories → scenarios            → review-gated delivery
  → acceptance criteria → PLAN          ─┐    → merge → coordinate → ship
                                         └──►  (starts here)
```

`product-development` ends at an approved implementation plan.
`delivery-engineering` starts there.

Also out of scope:

- **Runtime operations** — deployment runbooks, incident response, and
  production monitoring are operational concerns, not delivery workflows.
- **Product strategy and design** — owned upstream by `product-development`.

## Skills

| Skill | Status | Purpose |
|-------|--------|---------|
| [`review-gated-implementation-loop`](./skills/review-gated-implementation-loop) | available | Execute a large or high-risk change under independent, staged review gates. |
| campaign orchestration | planned | Coordinate many work items, issue metadata, pivots, and board state. |
| pull-request shepherding | planned | Drive an open pull request to green and merge. |

## Conventions

Each skill is portable and vendor-neutral. A skill's `resources/` directory is an
[Open Knowledge Format](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
bundle: plain Markdown, readable without tooling, usable by any agent.
