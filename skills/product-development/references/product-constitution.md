# Product Constitution

## Purpose

Use this reference to create, approve, version, maintain, and apply `docs/product/constitution.md` as the product governance authority for the product-development lifecycle.

The constitution defines durable principles, standards, and constraints. It sits above Product Vision, PRDs, TRDs, plans, and implementation work.

## When to use this reference

- `docs/product/constitution.md` is missing before the first PRD.
- An existing constitution lacks approval or version metadata.
- The user asks to create, ratify, amend, or supersede product governance principles.
- A proposed product change appears to violate a constitutional principle or standard.
- A PRD, TRD, story, scenario, implementation plan, or delivery result needs constitution alignment review.

## Foundation Gate before first PRD

First feature PRD work is blocked until both foundation documents exist and are approved:

- `docs/product/constitution.md` - approved product constitution with version metadata.
- `docs/product/vision.md` - approved, versioned product north star.

Do not create the first feature PRD while either document is missing, unapproved, or unversioned. Brainstorming and design exploration may continue before Foundation Gate passes.

## Preferred dependency: grill-with-docs

Use `grill-with-docs` when it is installed. It is the preferred dependency for interview discipline, repo-aware questioning, context coordination, and ADR awareness.

Keep the user interview in the main context because it is one-question-at-a-time and requires tight collaboration. Answer from repo evidence instead of asking the user when the answer is discoverable from project files, source artifacts, existing docs, tickets, linked research, or code conventions.

The product-development skill still owns the product artifact rules:

- Product constitution lives at `docs/product/constitution.md`.
- Approved immutable versions live under `docs/product/constitutions/`.
- Product vision lives at `docs/product/vision.md`.
- Product glossary/domain context, when needed, lives at `docs/product/CONTEXT.md`.
- ADRs default to `docs/adr/` unless the repository already uses another ADR convention.

## If grill-with-docs is missing

Notify the user up front that `grill-with-docs` is not installed and recommend installing it before continuing. Explain that it improves interrogation discipline and keeps context/ADR updates compatible with repo docs.

Continue with the fallback workflow only if the user declines installation or explicitly asks to proceed without it. In fallback mode, preserve the same rules: one question at a time, repo evidence first, source-labeled synthesis, adversarial review, and explicit user ratification before approval.

## Constitution Grill workflow

1. Check whether `grill-with-docs` is installed. If it is missing, notify the user and recommend installation before fallback.
2. Gather repo evidence before asking the user: existing product docs, README/AGENTS files, ADRs, prior PRDs/TRDs, design docs, codebase conventions, tickets, incidents, and review history when available.
3. Ask one question at a time.
4. Extract candidate non-negotiables.
5. Separate constitution content from vision, strategy, specifications, plans, ADRs, and glossary/domain context.
6. Apply the immutability test.
7. Draft candidate constitution material without overwriting `docs/product/constitution.md`.
8. Run adversarial review before approval.
9. Present the candidate constitution, review findings, and proposed version for user ratification.
10. Write or update `docs/product/constitution.md` only after explicit user approval.
11. Archive the approved immutable version under `docs/product/constitutions/constitution-vX.Y.Z.md`.

## Immutability test

For every candidate principle or standard, ask:

- Identity: would violating this change what the product is?
- Stability: should this still be true years from now?
- Cost: would changing this require major refactoring, retraining, or process change?
- Decision utility: does this resolve real tradeoffs?
- Enforcement: can agents or humans review against it?

If a candidate fails the test, move it to the correct artifact: vision, strategy, PRD/TRD, plan, ADR, or `docs/product/CONTEXT.md`.

## Constitution anatomy

Use these prompts to structure `docs/product/constitution.md`. Consult the source guide for exact worksheets and deeper explanation.

- Metadata: version, status, approval date, supersession, archived copy link.
- Purpose and authority: what the constitution governs and what it overrides.
- Core principles: durable product values and non-negotiables.
- Technical standards: stable architectural and engineering constraints.
- Design standards: durable brand, interaction, accessibility, and UX constraints.
- Operational standards: required development, review, release, and documentation practices.
- Domain-specific rules: invariant product/business rules.
- AI agent guidance: what to do when generating, reviewing, or uncertain.
- Amendment process: who approves, what evidence is needed, and when supersession applies.
- Sync Impact Report and changelog behavior: what changed and what downstream artifacts need review.

Keep these as prompts. Do not paste long guide explanations into normal constitution drafts.

## Versioning and approval

Use explicit metadata at the top of every approved `docs/product/constitution.md`:

```md
# Product Constitution

Version: 1.0.0
Status: Approved
Approved: YYYY-MM-DD
Supersedes: None
```

Version rules:

- Initial approved constitution is `1.0.0`.
- Patch versions are for wording or example fixes with no governance meaning change.
- Minor versions are for material clarifications that preserve existing principles.
- Major versions are for new principles, removed principles, changed principle meaning, authority shifts, or governance pivots.
- Approved governance meaning is immutable.
- Governance changes supersede prior approved versions; they do not silently rewrite history.
- Immutable approved copies live under `docs/product/constitutions/constitution-vX.Y.Z.md`.
- `docs/product/constitution.md` is the current pointer containing the latest approved version and a link to the archived immutable copy.

## Amendment behavior

Constitution amendments require explicit user approval and a short top HTML Sync Impact Report:

```md
<!--
Sync Impact Report:
- Version change: 1.0.0 -> 1.1.0
- Changed principles: None
- Added sections: Operational Standards
- Removed sections: None
- Project artifacts reviewed: docs/product/vision.md, active PRDs, ADRs
- Deferred items: None
-->
```

Product constitution amendments must check project artifacts that consume the approved constitution:

- current `docs/product/vision.md`, if it already exists
- immutable vision and constitution archives
- active PRDs, TRDs, user stories, scenarios, and implementation plans affected by the changed principle
- `docs/product/README.md` and `docs/product/AGENTS.md` if they contain project-specific foundation guidance
- `docs/product/CONTEXT.md` if terminology or domain language changed
- ADRs that recorded decisions now affected by the amendment
- PR templates, issue templates, review checklists, or CI checks that reference constitutional rules, if present in the project

Skill-maintenance propagation is separate. Normal amendments to a user's `docs/product/constitution.md` must not mutate the installed skill docs.

## Context and ADR coordination

Artifact boundaries:

- `docs/product/constitution.md`: invariant product governance principles, durable standards, and constraints.
- `docs/product/vision.md`: product direction, target users, value proposition, platform principles, surface vision, success metrics, assumptions, and open questions.
- `docs/product/CONTEXT.md`: glossary and domain language only.
- `CONTEXT-MAP.md`: root routing file when product context is not root-level and `grill-with-docs` needs to discover it.
- ADRs: durable decision records for consequential technical/product tradeoffs, defaulting to `docs/adr/` unless the repository already uses another convention.

Do not silently write `CONTEXT-MAP.md`, `docs/product/CONTEXT.md`, or ADRs during the interview. User approval is required before writing side-effect docs unless the user explicitly asks for inline updates.

Before presenting a constitution for approval, reconcile terminology and decisions across constitution, existing vision if present, context, and ADRs. If they conflict, ask the user to choose. In greenfield projects where vision does not exist yet, the later Vision workflow must reconcile against the approved constitution.

## Ongoing use during planning and delivery

Reference the approved constitution during:

- PRD creation: evaluate every current principle or standard with PASS/RISK/FAIL/N/A and justify N/A.
- TRD creation: confirm implementation architecture does not violate technical or operational standards.
- User story writing: preserve constitutional constraints in acceptance criteria.
- BDD scenario writing: add scenario coverage for constitutional behaviors when relevant.
- Implementation planning: stop if the plan violates `MUST NOT` language, weakens a principle, conflicts with strategic vision, or exceeds clear authority.
- Delivery validation: check whether shipped behavior matches the constitution and whether any amendment is needed.

FAIL against the constitution blocks the PRD or delivery until explicit amendment, supersession approval, or decision not to proceed. FAIL is not mitigated inside the PRD.

## Source guide

The full source archive is preserved at [source/product-constitution-guide.md](source/product-constitution-guide.md).

Consult it when exact worksheet language, detailed anatomy guidance, examples, maintenance guidance, or source fidelity is needed. Normal product-development work should start with this operational reference and load the source guide only for deeper detail.

This operational reference overrides source-guide path examples. In this skill, the current constitution lives at `docs/product/constitution.md`, immutable archives live under `docs/product/constitutions/`, and side-effect docs require user approval before writing.
