---
okf_version: "0.1"
---

# Adversarial review loop — knowledge bundle

This bundle defines a vendor-neutral process for large or high-risk
implementation work. An independent reviewer gates each step. A dispatcher can
run the process across many pull requests. Load a file only at its decision
point. The description in each file's frontmatter states when to load it.

## Route

1. Classify the change → [planning-altitude](./planning-altitude.md)
2. Run the loop for one pull request → [the-shape](./the-shape.md)
3. Coordinate many pull requests → [dispatcher-orchestration](./dispatcher-orchestration.md)

## Concepts

- [planning-altitude](./planning-altitude.md) - Load first to classify a change and set its review level.
- [the-shape](./the-shape.md) - Load to run the full review loop for one pull request.
- [reviewer-independence](./reviewer-independence.md) - Load to select and brief an independent reviewer for a diff.
- [severity-and-never-defer](./severity-and-never-defer.md) - Load to classify a finding and decide if it blocks a commit.
- [stopping-the-loop](./stopping-the-loop.md) - Load to bound the rounds and stop a review that will not converge.
- [falsifiability](./falsifiability.md) - Load to prove a test can fail.
- [dispatcher-orchestration](./dispatcher-orchestration.md) - Load to coordinate many pull requests and owners.
- [platform-adapters](./platform-adapters.md) - Load to map the abstract gates onto real tools.
- [rationale](./rationale.md) - Load only to see the evidence behind a rule. Optional.
- [templates/index](./templates/index.md) - Load to copy a starting artifact.

## One rule

Load only the resource that your current decision names. Start at the Route
above. [severity-and-never-defer](./severity-and-never-defer.md) is the one file
that classifies a finding; other files link to it.
