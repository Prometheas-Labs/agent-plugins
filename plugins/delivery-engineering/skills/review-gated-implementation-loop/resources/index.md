---
okf_version: "0.1"
---

# Adversarial review loop — knowledge bundle

## Route

- [planning-altitude](./planning-altitude.md) - Classify the change first.
- [the-shape](./the-shape.md) - Run the loop for one pull request.
- [dispatcher-orchestration](./dispatcher-orchestration.md) - Coordinate many pull requests.
- [autonomous-runs](./autonomous-runs.md) - Continue without the owner.

## Concepts

- [planning-altitude](./planning-altitude.md) - Load first to classify a change and set its review level.
- [the-shape](./the-shape.md) - Load to run the full review loop for one pull request.
- [reviewer-independence](./reviewer-independence.md) - Load to select and brief an independent reviewer for a diff.
- [severity-and-never-defer](./severity-and-never-defer.md) - Load to classify a finding and decide if it blocks a commit.
- [stopping-the-loop](./stopping-the-loop.md) - Load to bound the rounds and stop a review that will not converge.
- [falsifiability](./falsifiability.md) - Load to prove a test can fail.
- [dispatcher-orchestration](./dispatcher-orchestration.md) - Load to coordinate many pull requests and owners.
- [autonomous-runs](./autonomous-runs.md) - Load when the owner hands over a run to continue without them.
- [platform-adapters](./platform-adapters.md) - Load to map the abstract gates onto real tools.
- [rationale](./rationale.md) - Load only to see the evidence behind a rule. Optional.
- [templates/index](./templates/index.md) - Load to copy a starting artifact.
