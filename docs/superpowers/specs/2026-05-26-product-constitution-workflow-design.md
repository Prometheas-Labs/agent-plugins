# Product Constitution Workflow Integration Design

## Goal

Integrate the attached Product Constitution Guide into the `product-development` skill using the same progressive-disclosure model as the Product Vision workflow.

The change must add a documentation resource and operational workflow for creating, approving, maintaining, and referencing a product constitution while preserving the existing Foundation Stage model:

- Product Constitution approval happens before Product Vision workflow.
- Foundation Gate requires approved `docs/product/constitution.md` and approved, versioned `docs/product/vision.md`.
- Foundation Stage does not block brainstorming or design exploration.
- The first PRD remains blocked until Foundation Gate passes.
- Later PRDs must check constitution and vision alignment.

## Current Context

The skill already exposes this lifecycle:

```text
Project Setup
Foundation Stage
Discovery and Design
Requirements
User Stories
BDD Scenarios
Implementation Planning
```

The current Vision workflow already uses this shape:

- Preserve source guide under `references/source/`.
- Add concise operational reference under `references/`.
- Prefer Matt Pocock's `grill-with-docs` when installed.
- Notify the user up front when `grill-with-docs` is missing and recommend installing it before fallback.
- Keep product-development responsible for artifact placement, approval, versioning, and gate behavior.
- Treat `docs/product/vision.md` as the current approved pointer and archive immutable versions under `docs/product/visions/`.

This constitution integration should mirror that pattern.

## Selected Approach

Use the "Mirror Vision Flow, Plus Spec Kit Amendment Controls" approach.

Add:

- `skills/product-development/references/source/product-constitution-guide.md` as the source archive.
- `skills/product-development/references/product-constitution.md` as the concise operational reference.
- Foundation Stage wiring for an active Constitution workflow.
- Initialization, template, and requirements guidance updates.
- Tests that protect Foundation Gate wording and generated product-doc guidance.

Borrow only targeted external patterns:

- From GitHub Spec Kit: semver amendment rules, compliance review, template propagation, and Sync Impact Report.
- From SpecDD: stop rules for `MUST NOT`, weakened inherited principles, unclear authority, and stricter-parent-constraint behavior.
- From BMAD: PASS/RISK/FAIL-style gate language.
- From Anchored Development: documentation should have a clear consumer and enforcement/check mechanism.
- From OpenSpec: archive/delta thinking as inspiration, not the gate model.

Exclude `docs/product/INDEX.md` from this change. Existing `README.md`, `AGENTS.md`, `CONTEXT-MAP.md`, `CONTEXT.md`, and ADR conventions already cover routing needs.

Do not add a runtime gate script in this change.

Do not add a full constitution skeleton template. The operational reference should use prompts and rules, matching the Vision workflow.

## Product Constitution Workflow

`references/product-constitution.md` should define this workflow:

1. Check whether `grill-with-docs` is installed.
   - If installed, use it as the preferred interrogation dependency.
   - If missing, notify the user up front, recommend installation, and use fallback only if the user declines or explicitly asks to proceed.
2. Gather repo evidence before asking the user:
   - existing product docs
   - `README.md` and `AGENTS.md`
   - ADRs
   - prior PRDs/TRDs
   - design docs
   - codebase conventions
   - tickets, incidents, or review history when available
3. Grill one question at a time.
   - Extract candidate non-negotiables.
   - Separate constitution content from vision, strategy, specifications, plans, ADRs, and glossary/domain context.
4. Apply the immutability test to each candidate:
   - Identity: would violating this change what the product is?
   - Stability: should this still be true years from now?
   - Cost: would changing this require major refactoring, retraining, or process change?
   - Decision utility: does this resolve real tradeoffs?
   - Enforcement: can agents or humans review against it?
5. Draft `docs/product/constitution.md`.
   - Use section prompts, not boilerplate.
   - Include concrete AI agent guidance per principle or standard.
6. Run adversarial review before approval.
   - Find vague principles.
   - Find strategy masquerading as constitution.
   - Find conflicts with existing docs or code.
   - Find unenforceable "nice to have" rules.
7. Get explicit user ratification.
   - Only approved constitution content passes Foundation Gate.
   - Archive immutable approved versions.

## Constitution Anatomy

The operational reference should define prompts for these sections:

1. Metadata.
2. Purpose and authority.
3. Core principles.
4. Technical standards.
5. Design standards.
6. Operational standards.
7. Domain-specific rules.
8. AI agent guidance.
9. Amendment process.
10. Sync Impact Report and changelog behavior.

Each principle or standard should be written so an agent can apply it in planning, implementation, review, and delivery validation.

## Versioning and Approval

Use the same current-pointer plus immutable-archive model as Vision:

- Current approved pointer: `docs/product/constitution.md`.
- Immutable approved archives: `docs/product/constitutions/constitution-vX.Y.Z.md`.
- Initial approved constitution: `1.0.0`.
- Patch version: wording or example fixes with no governance meaning change.
- Minor version: material clarification that preserves existing principles.
- Major version: new principle, removed principle, changed principle meaning, authority shift, or governance pivot.

Approved governance meaning is immutable. Changes happen through supersession, not silent rewrite.

Required approved metadata:

```md
# Product Constitution

Version: 1.0.0
Status: Approved
Approved: YYYY-MM-DD
Supersedes: None
```

## Amendment Behavior

Constitution amendments require explicit user approval and a short top HTML `Sync Impact Report` in `docs/product/constitution.md`.

The report should include:

- Version change: old -> new.
- Changed principles, including renames.
- Added sections.
- Removed sections.
- Dependent docs, templates, references, and checks updated or pending.
- Deferred TODOs, if any.

The amendment workflow must include a propagation checklist for:

- `SKILL.md` Foundation Stage wording.
- `references/product-constitution.md`.
- `references/product-vision.md` when constitutional hierarchy or gate behavior changes.
- `references/initialization.md`.
- `references/phase-2-requirements.md`.
- `templates/README.md.tmpl`.
- `templates/AGENTS.md.tmpl`.
- generated docs expectations covered by tests.

## Foundation Gate Behavior

Brainstorming and design exploration are allowed before Foundation Gate passes.

The first feature PRD is blocked until:

- `docs/product/constitution.md` exists and is approved.
- `docs/product/vision.md` exists, is approved, and has version metadata.

Later PRDs must:

- load current constitution and vision;
- include PASS/RISK/FAIL alignment checks;
- stop or escalate when the proposed feature violates `MUST NOT` language, weakens a principle, conflicts with strategic vision, or exceeds clear authority.

## Requirements Guidance

`references/phase-2-requirements.md` currently includes a hard-coded five-principle constitution table. This should become dynamic.

Every PRD should validate against the actual approved `docs/product/constitution.md`:

- Each constitutional principle or standard relevant to the feature gets a PASS/RISK/FAIL entry.
- Any RISK or FAIL requires mitigation, amendment discussion, or decision not to proceed.
- If no approved constitution exists and this is the first PRD, stop for Foundation Gate.
- If the constitution exists but lacks approval/version metadata, treat it as not passing Foundation Gate and ask the user how to ratify or migrate it.

Examples may be kept only if clearly labeled as examples, not normative fixed principles.

## Context, ADR, and Vision Coordination

Artifact boundaries:

- `docs/product/constitution.md`: invariant product governance principles, durable standards, and constraints.
- `docs/product/vision.md`: product direction, target users, value proposition, platform principles, surface vision, success metrics, assumptions, and open questions.
- `docs/product/CONTEXT.md`: glossary and domain language only.
- `CONTEXT-MAP.md`: root routing file when product context is not root-level and `grill-with-docs` needs to discover it.
- ADRs: durable decision records for consequential technical/product tradeoffs, defaulting to `docs/adr/` unless the repository already uses another convention.

The Constitution workflow must not silently write `CONTEXT-MAP.md`, `docs/product/CONTEXT.md`, or ADRs during the interview. Those side-effect docs require user approval unless the user explicitly asks for inline updates.

Before presenting a constitution for approval, reconcile terminology and decisions across constitution, vision, context, and ADRs. If they conflict, ask the user to choose.

## Files Likely Changed During Implementation

- `skills/product-development/SKILL.md`
- `skills/product-development/references/product-constitution.md`
- `skills/product-development/references/source/product-constitution-guide.md`
- `skills/product-development/references/product-vision.md`
- `skills/product-development/references/initialization.md`
- `skills/product-development/references/phase-2-requirements.md`
- `skills/product-development/templates/README.md.tmpl`
- `skills/product-development/templates/AGENTS.md.tmpl`
- `skills/product-development/tests/init.bats`

Keep existing `phase-*` filenames as compatibility paths.

## Validation Plan

Run:

```bash
bats skills/product-development/tests/init.bats
```

Run skill validation if the local quick validator exists:

```bash
quick_validate="$(find "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator" -path "*/scripts/quick_validate.py" -print -quit)"
python3 "$quick_validate" skills/product-development
```

Static checks:

- `SKILL.md` references `references/product-constitution.md`.
- `references/product-constitution.md` references `source/product-constitution-guide.md`.
- `references/source/product-constitution-guide.md` exists.
- No stale language says the Constitution Grill remains future work.
- `references/phase-2-requirements.md` no longer presents hard-coded five principles as normative.
- Foundation Gate wording stays consistent across `SKILL.md`, initialization reference, generated README, generated AGENTS, and requirements reference.
- Source archive remains separate from operational reference.

Manual review:

- Progressive disclosure stays intact.
- Constitution workflow mirrors Vision workflow.
- External framework borrowings do not override Constitution-before-Vision ordering.
- No `docs/product/INDEX.md` or runtime gate script was added.

## Risks and Edge Cases

- `grill-with-docs` may be missing. The workflow must recommend installation before fallback.
- Existing projects may already have unversioned `docs/product/constitution.md`. The skill should treat it as needing ratification or migration, not silently approved.
- Constitution content can drift into product strategy. The immutability test and adversarial review should push strategy into Vision or ADRs.
- Hard-coded principle examples can become accidental defaults. Examples must be labeled clearly or removed.
- Side-effect docs like ADRs and `CONTEXT.md` can surprise users. Require approval before writing them.
- Strong stop rules can block useful exploration if applied too early. Apply hard blocking only at PRD creation and later delivery gates, not brainstorming/design exploration.

## External Research Notes

Primary sources checked:

- GitHub Spec Kit: <https://github.com/github/spec-kit>
- GitHub Spec Kit constitution command: <https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/constitution.md>
- OpenSpec getting started: <https://github.com/Fission-AI/OpenSpec/blob/main/docs/getting-started.md>
- BMAD workflow map: <https://docs.bmad-method.org/reference/workflow-map/>
- SpecDD: <https://specdd.ai/>
- Anchored Development: <https://anchored-dev.org/>

Research conclusion: GitHub Spec Kit has the strongest constitution mechanics, but lacks a separate Vision layer. This skill should borrow amendment controls while preserving its own hierarchy: Constitution -> Vision -> Foundation Gate -> PRD.
