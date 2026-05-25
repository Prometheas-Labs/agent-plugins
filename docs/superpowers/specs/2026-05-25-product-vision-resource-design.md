# Product Vision Resource Integration Design

Date: 2026-05-25

## Goal

Integrate the attached Vision Document Guide into the `product-development` skill so agents can create, maintain, and use a product vision document as part of the product-development workflow set.

The integration must preserve progressive disclosure:

- Keep `SKILL.md` small and procedural.
- Put detailed vision guidance in a reference file loaded only when needed.
- Require an approved, versioned `docs/product/vision.md` before the first feature PRD.
- Prefer Matt Pocock's `grill-with-docs` skill for the interview mechanics when installed, while keeping product-development responsible for product-doc artifact rules.

## Current Context

The skill should expose this public workflow map:

```text
Project Setup
Foundation Stage
Discovery and Design
Requirements
User Stories
BDD Scenarios
Implementation Planning
```

The current docs already expect foundation artifacts:

- `docs/product/vision.md` as product north star.
- `docs/product/constitution.md` as governance principles.
- Feature PRDs and TRDs under `docs/product/features/{feature}/`.

`references/initialization.md` says vision and constitution are not scaffolded because their contents are project-specific. This design keeps that principle: initialization may create the directory structure, but the product vision is produced through an interactive grilling workflow, not a generic template.

## Workflow Map Change

Add a `Foundation Stage` after Project Setup and before the first feature PRD.

```text
Project Setup
  |
Foundation Stage
  - Product Constitution approval
  - Product Vision workflow
  - future product-anchor workflows
  |
Foundation Gate: user approves constitution + versioned vision
  |
First PRD allowed
```

The Foundation Stage is required before the first Requirements PRD, not before brainstorming or design exploration. Agents may brainstorm and shape feature ideas before the foundation is complete, but the first Requirements PRD must block until the Foundation Gate passes.

The Foundation Gate requires:

- approved `docs/product/constitution.md`
- approved, versioned `docs/product/vision.md`

The agent should not create a first PRD and merely note missing foundation documents as a risk. Missing foundation documents are a hard gate for the Requirements workflow.

## Vision Grill Workflow

The vision workflow should:

1. Inspect project docs, source artifacts, and existing product docs.
2. Check whether `grill-with-docs` is installed.
3. If missing, notify the user up front, recommend installing it, and explain that it improves grilling against project language and docs.
4. If the user declines or wants to continue immediately, use the built-in fallback workflow.
5. Ask one question at a time.
6. Prefer answering from existing repo evidence instead of asking the user when the answer is discoverable.
7. Resolve terms, user segments, surfaces, value proposition, design principles, architecture direction, metrics, business goals, assumptions, and open questions.
8. Run a source-evidence pass: distinguish researched facts, user-stated assumptions, and unresolved gaps.
9. Run a red-team pass for contradictions, weak evidence, and over-commitment before presenting a draft.
10. Synthesize a draft `docs/product/vision.md`.
11. Present the vision draft and any proposed side-effect docs (`CONTEXT.md`, `CONTEXT-MAP.md`, ADRs) for user approval.
12. Only after approval, allow Requirements PRD work.

## Matt Pocock Skill Integration

Use `grill-with-docs` as a preferred soft dependency, not a hard dependency.

Known sources:

- `mattpocock/skills`, plugin entry `./skills/engineering/grill-with-docs`
- `grill-me` exists separately under `./skills/productivity/grill-me`

Expected behavior:

- If `grill-with-docs` is installed, use its interrogation and documentation discipline.
- If not installed, recommend installation and continue with fallback only when user chooses not to install or asks to proceed.
- Do not let `grill-with-docs` change the primary product-development output path. Product vision still belongs in `docs/product/vision.md`.

## Context and ADR Placement

If `grill-with-docs` is used, allow it to propose context docs and ADRs, with product-development placement rules:

- Existing repo convention wins.
- If no convention exists and product context is not root-level, create or update root `CONTEXT-MAP.md`.
- Put product-domain context in `docs/product/CONTEXT.md`.
- Put ADRs in `docs/adr/` by default.
- Do not silently write side-effect docs during the interview. Present proposed `CONTEXT.md`, `CONTEXT-MAP.md`, and ADR changes with the vision draft for user approval unless the user explicitly asks for inline updates.

Rationale:

- Matt's skill expects root `CONTEXT.md` for simple repos or root `CONTEXT-MAP.md` for multiple contexts.
- `docs/product/CONTEXT.md` is discoverable by Matt-style agents only if root `CONTEXT-MAP.md` advertises it.
- `docs/adr/` is the cleaner default for repository-level architectural/product decisions unless the repo already has another ADR convention.

Artifact boundaries:

- `docs/product/vision.md`: product north star, long-horizon direction, approved and versioned.
- `docs/product/CONTEXT.md`: product-domain language, glossary, and term-usage guidance discovered during grilling.
- `docs/adr/`: hard-to-reverse, surprising, real-tradeoff decisions.

The agent must reconcile terminology across these artifacts before presenting final drafts. If `vision.md` and `CONTEXT.md` would define conflicting terms, ask the user to choose.

## Vision Document Versioning

`docs/product/vision.md` must be explicitly versioned and treated as the current vision pointer.

Required metadata at the top:

```md
# Product Vision

Version: 1.0.0
Status: Approved
Approved: YYYY-MM-DD
Supersedes: None
```

Versioning rules:

- Initial approved vision is `1.0.0`.
- Minor wording fixes that do not change product direction may use patch versions.
- Material clarification that preserves direction may use minor versions.
- Strategic pivots use major versions and supersede the prior vision.
- Once approved, a vision version is treated as immutable for strategic meaning.
- New strategic direction should create a new version and mark the old one as superseded.
- Preserve immutable approved versions under `docs/product/visions/vision-vX.Y.Z.md`.
- Keep `docs/product/vision.md` as the current pointer containing the latest approved version and a link to its archived immutable copy.
- When superseding, archive the old approved version, update supersession metadata, then update `docs/product/vision.md` to the new approved version.

This should align with the existing methodology's immutable-plus-supersede strategy for vision documents.

The source guide describes the product vision as a living document. In this skill, the operational rule is stricter: strategic meaning is immutable after approval, and strategic changes supersede prior versions. The source guide remains useful for creation and maintenance prompts, but the skill methodology controls versioning.

## Reference Files

Add `skills/product-development/references/product-vision.md`.

It should include:

- When to use the reference.
- Required preconditions and hard gate behavior.
- `grill-with-docs` dependency check and fallback.
- Vision grill stages.
- Vision document anatomy from the guide:
  - executive vision statement
  - target users and customer segments
  - core problems and needs
  - value proposition and differentiation
  - platform principles
  - experience vision by surface
  - multi-surface design philosophy
  - architecture vision
  - success metrics and north star metric
  - business goals and constraints
  - open questions and assumptions
- Ongoing use:
  - when feature planning must reference vision
  - PRD alignment expectations
  - implementation-plan alignment expectations
  - delivery validation prompts
  - maturity model usage
  - supersede vs update rules
- Artifact coordination with `CONTEXT.md` and ADRs.

The reference should summarize and operationalize the guide rather than paste the guide wholesale.

Also add `skills/product-development/references/source/vision-document-guide.md` as the source document.

This source file should preserve the provided guide substantially as-is so agents can consult original wording, worksheets, and detailed rationale when needed. It should not be the primary entry point for normal product-development work.

Progressive disclosure rule:

- `SKILL.md` routes to `references/product-vision.md`.
- `references/product-vision.md` provides the concise operational workflow and points to `references/source/vision-document-guide.md` only for exact source detail.
- `references/source/vision-document-guide.md` is loaded only when the agent needs source fidelity, detailed worksheet language, or a deeper explanation from the original guide.

## Existing File Updates

Update `skills/product-development/SKILL.md`:

- Add Foundation Stage to the public workflow map.
- Mention `references/product-vision.md`.
- State that the first Requirements PRD is blocked until approved `docs/product/constitution.md` and approved, versioned `docs/product/vision.md` exist.
- Keep the body concise.

Update `skills/product-development/references/initialization.md`:

- After initialization, direct the agent to complete the Foundation Stage before the first PRD.
- Clarify that vision is produced by grilling, not scaffolding.
- Include the `grill-with-docs` recommendation behavior.

Update `skills/product-development/references/phase-2-requirements.md`:

- Treat this filename as a legacy compatibility path for the Requirements workflow.
- Make approved `docs/product/constitution.md` and approved, versioned `docs/product/vision.md` required inputs for the first PRD.
- Add vision alignment expectations to PRD readiness.
- Block first PRD if either foundation document is missing.

Update `skills/product-development/templates/README.md.tmpl`:

- Document the hard gate before first PRD.
- Mention vision versioning.
- Mention optional `CONTEXT.md`/ADR artifacts when `grill-with-docs` is used.
- Ensure generated docs do not imply users can immediately start a PRD after init without passing the Foundation Gate.

Update `skills/product-development/templates/AGENTS.md.tmpl`:

- Tell agents to check for approved `docs/product/vision.md` before adding feature PRDs.
- Tell agents to use `CONTEXT-MAP.md` if product context lives in `docs/product/CONTEXT.md`.
- Mention default ADR placement at `docs/adr/`.
- Tell agents to treat `docs/product/CONTEXT.md` as glossary/domain-language guidance, not as a requirements scratchpad.

Update `skills/product-development/scripts/init.sh`:

- Update the final next-step output so it directs users to complete the Foundation Stage before the first PRD.
- Remove any wording that says users can start the first feature PRD immediately after init when foundation documents are missing.

## Validation

After implementation:

1. Run the existing init test if Bats is available.
2. Run the skill validation script from `skill-creator` if available.
3. Inspect rendered docs for broken references and duplicated guide content.
4. Confirm no generated template contradicts Matt's `grill-with-docs` discovery model.
5. Confirm missing constitution or vision is described as a blocker before first PRD.
6. Confirm `scripts/init.sh` stdout matches the Foundation Gate.
7. Confirm `SKILL.md` workflow-selection guidance cannot bypass the Foundation Gate for the first Requirements PRD.

## Out of Scope

- Installing Matt Pocock's skills automatically.
- Creating a complete product vision template that can be filled without user interrogation.
- Replacing `brainstorming` or `writing-plans`.
- Changing PRD/TRD format beyond adding vision alignment expectations.
