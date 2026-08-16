---
name: review-gated-implementation-loop
description: >-
  Use when implementation work changes security or a shared contract, spans
  multiple commits or files, or coordinates several agents or pull requests. Do
  not use for questions, copy edits, or contained one-file fixes.
---

# Adversarial review loop

This skill runs a plan-and-review process for large or high-risk changes. An
independent reviewer gates each step. A dispatcher can run the process across
many pull requests at the same time.

## Use this skill when

- A change spans many commits or many files.
- A change alters a security posture (authentication, secrets, isolation, data exposure).
- A change alters a shared contract (a public API, a schema, a cross-team interface).
- An agent executes the change across several steps.
- You coordinate several related pull requests or several agent owners.

## Do not use this skill when

- The work answers a question. Run a spike instead.
- The work is a copy edit, a config change, or a bounded one-file fix.

## First step, always

Classify the change before you load any other file. Read
[planning-altitude](resources/planning-altitude.md). Its table sets the altitude
and routes you to the next resource: [the-shape](resources/the-shape.md) for one
pull request, or [dispatcher-orchestration](resources/dispatcher-orchestration.md)
for many. Load each resource only at its decision point.

For the full resource map, load [resources/index.md](resources/index.md).
