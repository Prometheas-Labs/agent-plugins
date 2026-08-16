---
type: Playbook
title: Planning altitude — classify the change
description: Load first whenever this skill activates. Classify the change and select the next resource.
tags: [process, planning, routing]
timestamp: 2026-08-15T00:00:00Z
---

# Planning altitude

"Altitude" means the amount of review that a change requires. Use only this file
to assign the altitude. Every other file refers to the altitude you set here.

An incorrect altitude causes problems. Too many review steps can cause an agent
to omit required steps later. Too few review steps can miss defects that occur
across several commits.

## Rule: pick the highest matching altitude

Read the rows from top to bottom. Select the FIRST row whose trigger is true.
Each trigger is independent. You do not need every condition in a row.

| Altitude | Trigger (any one is enough) | Process |
|---|---|---|
| **Question** | The work exists to learn something, not to change behavior. | Run a spike. Do not run the loop. |
| **Campaign** | Several pull requests must land together, or more than one owner works in parallel. | Run [dispatcher-orchestration](./dispatcher-orchestration.md). Each pull request runs [the-shape](./the-shape.md). |
| **Substantial** | The change alters security, alters a shared contract, spans many commits or files, or requires several agent steps. | Run the full loop: [the-shape](./the-shape.md). |
| **Bounded** | The change is one contained fix in one area, and its failure mode is local and obvious. | Write the failing test. Implement to green. Get one ordinary review. |
| **Trivial** | The change is a copy edit, a config change, a version bump, or one obvious line. | Use the standard pull-request process. Do not run the loop. |

## How to classify honestly

- Risk sets the floor, not size. A three-line change to an authorization check is
  **Substantial**. A 400-line copy change is **Trivial**.
- Reversibility matters. If a wrong result is silent, data-shaped, or hard to
  undo, move up one altitude.
- Blast radius matters. A change to a shared package's public interface is rarely
  **Trivial**. Move it up.
- Delivery model matters. Work that an agent executes across many steps gains
  from the loop's gates. A human may do the same work in one pass.
- When you are unsure, run the higher altitude for the first slice. Learn the real
  risk. Then drop down. This is cheaper than finding the floor after merge.

## Related

- The Question altitude produces a spike, not a merge. Keep exploratory code out
  of operational directories; a separate change carries the decision.
- Once you set the altitude, load only the resources that altitude names.
