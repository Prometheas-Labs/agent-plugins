# Product Constitution Workflow Integration Implementation Plan

## Overview

Integrate the Product Constitution Guide into the `product-development` skill using the approved design in:

`docs/superpowers/specs/2026-05-26-product-constitution-workflow-design.md`

This plan keeps the current Product Vision workflow as the model:

- source archive under `references/source/`
- concise operational reference under `references/`
- `grill-with-docs` preferred, fallback only after notice/user choice
- current pointer plus immutable archive versioning
- Foundation Gate before the first PRD
- later PRDs check alignment

Do not add `docs/product/INDEX.md`.
Do not add a runtime gate script.
Do not add a full constitution skeleton template.
Keep existing `phase-*` filenames as compatibility paths.

## Pre-Execution Gate

Before implementation, dispatch an adversarial review subagent against this plan and the approved design spec. Do not edit implementation files until that review is resolved.

Review prompt:

```text
Adversarially review the implementation plan at docs/superpowers/plans/2026-05-26-product-constitution-workflow-integration.md against the approved design spec at docs/superpowers/specs/2026-05-26-product-constitution-workflow-design.md.

Look for missing tasks, wrong file ownership, contradictions with the current Product Vision workflow, bad test ordering, source fidelity gaps, Foundation Gate ambiguity, and implementation traps.

Do not edit files. Return findings first, ordered by severity, with file/line references.
```

## Source Archive Fidelity

The attached source file is:

`/Users/yanni/Downloads/Product Constitution Guide.md`

Expected source properties:

```text
sha256: cc34e8b2794ade47bb516394755561e60683150124ad214b7dc552c603f21326
bytes: 45385
```

The implementation must preserve this guide substantially as-is at:

`skills/product-development/references/source/product-constitution-guide.md`

Do not summarize the source archive. The operational summary belongs in `references/product-constitution.md`.

## Task 1: Add Tests For Foundation Gate And Init Output

**Files:**

- Modify: `skills/product-development/tests/init.bats`

**Goal:**

Add tests that fail against current generated docs, proving templates and init output need constitution workflow updates.

**Steps:**

1. Update `@test "README contains foundation gate section"` to assert both foundation docs need version metadata.

Expected test assertions:

```bash
grep -q "## Foundation gate" "$TEST_PROJECT/docs/product/README.md"
grep -q "Foundation Gate" "$TEST_PROJECT/docs/product/README.md"
grep -q "approved, versioned product constitution" "$TEST_PROJECT/docs/product/README.md"
grep -q "approved, versioned north-star product vision" "$TEST_PROJECT/docs/product/README.md"
```

2. Rename `@test "AGENTS.md contains vision gate and context-map guidance"` to:

```bash
@test "AGENTS.md contains foundation gate and context-map guidance" {
```

3. In that test, assert Constitution and Vision are both versioned and that Constitution Grill is referenced.

Expected assertions:

```bash
grep -q "Before creating the first feature PRD" "$TEST_PROJECT/docs/product/AGENTS.md"
grep -q "constitution.md" "$TEST_PROJECT/docs/product/AGENTS.md"
grep -q "vision.md" "$TEST_PROJECT/docs/product/AGENTS.md"
grep -q "approved, and has version metadata" "$TEST_PROJECT/docs/product/AGENTS.md"
grep -q "Constitution Grill" "$TEST_PROJECT/docs/product/AGENTS.md"
grep -q "CONTEXT-MAP.md" "$TEST_PROJECT/docs/product/AGENTS.md"
grep -q "docs/product/CONTEXT.md" "$TEST_PROJECT/docs/product/AGENTS.md"
```

4. Update `@test "init output directs users through foundation gate"` to assert Constitution workflow comes before Vision workflow.

Expected assertions:

```bash
grep -q "Foundation Gate" <<< "$output"
grep -q "Run the Product Constitution workflow" <<< "$output"
grep -q "approved, versioned docs/product/constitution.md" <<< "$output"
grep -q "Run the Product Vision workflow" <<< "$output"
grep -q "approved, versioned docs/product/vision.md" <<< "$output"
! grep -q "Start your first feature with: docs/product/features/{feature}/PRD.md" <<< "$output"
```

**Verification:**

Run the targeted tests and confirm they fail before implementation updates:

```bash
bats skills/product-development/tests/init.bats
```

Expected before implementation: at least the updated foundation gate/init output assertions fail.

Do not commit the intentionally failing test-only state. Carry these test changes into Task 4 and commit them only after the templates and init output pass the tests.

## Task 2: Add Constitution Source Archive And Operational Reference

**Files:**

- Add: `skills/product-development/references/source/product-constitution-guide.md`
- Add: `skills/product-development/references/product-constitution.md`

**Goal:**

Add progressive-disclosure resources matching the Product Vision resource shape.

**Steps:**

1. Add `skills/product-development/references/source/product-constitution-guide.md`.

Use the full content of `/Users/yanni/Downloads/Product Constitution Guide.md` without summarizing. Do not alter headings or major sections.

2. Add `skills/product-development/references/product-constitution.md`.

Use this structure:

```md
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

1. Gather repo evidence before asking the user: existing product docs, README/AGENTS files, ADRs, prior PRDs/TRDs, design docs, codebase conventions, tickets, incidents, and review history when available.
2. Ask one question at a time.
3. Extract candidate non-negotiables.
4. Separate constitution content from vision, strategy, specifications, plans, ADRs, and glossary/domain context.
5. Apply the immutability test.
6. Draft `docs/product/constitution.md`.
7. Run adversarial review before approval.
8. Ask the user to ratify the constitution explicitly.
9. Archive the approved immutable version under `docs/product/constitutions/constitution-vX.Y.Z.md`.

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
```

**Verification:**

Run:

```bash
shasum -a 256 /Users/yanni/Downloads/Product\ Constitution\ Guide.md skills/product-development/references/source/product-constitution-guide.md
rg -n "Source guide|grill-with-docs|Sync Impact Report|FAIL against the constitution" skills/product-development/references/product-constitution.md
```

Expected output:

- both hashes are `cc34e8b2794ade47bb516394755561e60683150124ad214b7dc552c603f21326`
- `rg` finds all listed phrases in `product-constitution.md`

**Commit:**

```bash
git add skills/product-development/references/product-constitution.md skills/product-development/references/source/product-constitution-guide.md
git commit -m "docs: add product constitution reference"
```

## Task 3: Wire Constitution Workflow Into Skill Map

**Files:**

- Modify: `skills/product-development/SKILL.md`
- Modify: `skills/product-development/references/product-vision.md`

**Goal:**

Make Constitution workflow first-class and remove stale future-work language.

**Steps:**

1. Update the YAML frontmatter description to include Product Constitution and Constitution Grill trigger phrases. Keep the description concise but ensure requests to create, approve, amend, or validate a product constitution trigger the skill.

Example description shape:

```yaml
description: "This skill should be used when the user asks to 'create a feature', 'write a PRD', 'write a TRD', 'add user stories', 'write scenarios', 'create acceptance criteria', 'plan a feature', 'initialize product docs', 'set up product documentation', create or update a Product Constitution, create or update a Product Vision, run the Constitution Grill or Vision Grill, or mentions any phase of product development from idea through implementation planning. Guides the full product development lifecycle: Project Setup -> Foundation Stage -> Discovery and Design -> Requirements -> User Stories -> BDD Scenarios -> Implementation Planning."
```

2. In `SKILL.md`, update Lifecycle Map Foundation Gate line:

```md
  └─ Foundation Gate: approved, versioned constitution + approved, versioned vision before first PRD
```

3. In `SKILL.md`, update Foundation Stage process:

```md
1. Product Constitution workflow: create, ratify, or amend approved, versioned `docs/product/constitution.md`. Consult `references/product-constitution.md` for `grill-with-docs` dependency behavior, Constitution Grill workflow, versioning, amendment behavior, and constitution alignment checks.
2. Product Vision workflow: run the Vision Grill after Constitution approval. Consult `references/product-vision.md` for `grill-with-docs` dependency behavior, context/ADR coordination, and vision versioning.
3. Additional product-anchor workflows: planned extension point for product-anchor documents when approved.
4. Foundation Gate: complete only when approved, versioned `docs/product/constitution.md` and approved, versioned `docs/product/vision.md` exist.
```

4. In `SKILL.md`, update Foundation Stage output:

```md
**Output:** Approved, versioned `docs/product/constitution.md`; approved, versioned `docs/product/vision.md`; optional `CONTEXT-MAP.md`, `docs/product/CONTEXT.md`, and ADRs when approved and used.
```

5. In `SKILL.md`, update Foundation Gate:

```md
**Foundation Gate:** Do not create the first PRD until the user approves `docs/product/constitution.md`, it has version metadata, and approved, versioned `docs/product/vision.md` exists.
```

6. In `SKILL.md`, update Requirements required inputs:

```md
**Required inputs:** Approved design document, approved, versioned `docs/product/constitution.md`, and approved, versioned `docs/product/vision.md`. Missing foundation documents block first-PRD requirements work.
```

7. In `SKILL.md`, update Workflow Selection table/routing so first-PRD Foundation Stage routing treats missing, unapproved, or unversioned constitution the same as missing, unapproved, or unversioned vision.

Expected wording:

```md
| Missing, unapproved, or unversioned constitution or vision before first PRD | Foundation Stage |
```

And:

```md
Clear requirements may skip brainstorming only after Foundation Gate passes. If this is the first PRD and `docs/product/constitution.md` or `docs/product/vision.md` is missing, unapproved, or unversioned, run Foundation Stage before Requirements.
```

8. In `SKILL.md`, update Reference Files list:

```md
- **`references/product-constitution.md`** - Product Constitution workflow, Foundation Gate, Constitution Grill, versioning, amendment behavior, and alignment checks
- **`references/product-vision.md`** - Product Vision workflow, Foundation Gate, Vision Grill, versioning, and context/ADR coordination
```

9. In `SKILL.md`, update source-loading guidance:

```md
Load `references/source/product-constitution-guide.md` only through `references/product-constitution.md` when exact source detail is needed. Load `references/source/vision-document-guide.md` only through `references/product-vision.md` when exact source detail is needed.
```

10. In `references/product-vision.md`, update Foundation Gate wording so constitution also has approval and version metadata:

```md
- `docs/product/constitution.md` - approved product governance principles with version metadata.
- `docs/product/vision.md` - approved, versioned product north star.
```

11. In `references/product-vision.md`, add a sentence to the Vision workflow context:

```md
Run the Vision workflow after Product Constitution approval. The vision must reconcile against the approved constitution and cannot weaken constitutional principles.
```

**Verification:**

Run:

```bash
rg -n "constitution-grill|future work" skills/product-development/SKILL.md skills/product-development/references/product-vision.md
rg -n "Product Constitution|Constitution Grill|product-constitution.md|approved, versioned `docs/product/constitution.md`|version metadata|unapproved, or unversioned" skills/product-development/SKILL.md skills/product-development/references/product-vision.md
```

Expected output:

- first command returns no stale future-work references
- second command finds frontmatter trigger wording, product-constitution reference, version metadata wording, and unversioned routing language

**Commit:**

```bash
git add skills/product-development/SKILL.md skills/product-development/references/product-vision.md
git commit -m "docs: wire constitution workflow into foundation stage"
```

## Task 4: Update Initialization Docs, Templates, And Init Output

**Files:**

- Modify: `skills/product-development/references/initialization.md`
- Modify: `skills/product-development/templates/README.md.tmpl`
- Modify: `skills/product-development/templates/AGENTS.md.tmpl`
- Modify: `skills/product-development/scripts/init.sh`

**Goal:**

Generated product docs and init output should direct users through Constitution Grill before Vision Grill, with version metadata required for both foundation documents.

**Steps:**

1. In `references/initialization.md`, replace post-initialization steps with:

```md
1. Review the generated files and adjust wording if needed
2. Run the Product Constitution workflow before the Product Vision workflow
3. Create and approve versioned `docs/product/constitution.md` through the Constitution Grill (use the immutable + supersede evolution strategy)
4. Run the Product Vision workflow before the first PRD
5. Create approved, versioned `docs/product/vision.md` through the Vision Grill (use the immutable + supersede evolution strategy)
6. Proceed to the first PRD only after the Foundation Gate passes
```

2. In `references/initialization.md`, add dependency wording:

```md
When running the Constitution Grill or Vision Grill, prefer `grill-with-docs` if it is installed. If it is missing, notify the user up front, recommend installing it for doc-aware interrogation, and continue with the built-in fallback only if the user declines installation or asks to proceed.
```

3. In `references/initialization.md`, update the final gate sentence:

```md
Discovery and design exploration may happen before the Foundation Gate, but the first Requirements PRD cannot start until `docs/product/constitution.md` is approved with version metadata and approved, versioned `docs/product/vision.md` exists.
```

4. In `templates/README.md.tmpl`, update platform artifact descriptions:

```md
- `constitution.md` - approved, versioned product constitution required before the first PRD
- `vision.md` - approved, versioned north-star product vision required before the first PRD
```

5. In `templates/README.md.tmpl`, update Foundation gate paragraph:

```md
Before the first feature PRD, `docs/product/constitution.md` and `docs/product/vision.md` must exist, be approved, and carry explicit version metadata. If either foundation document is missing, unapproved, or unversioned, complete the Foundation Gate before starting feature requirements.
```

6. In `templates/AGENTS.md.tmpl`, update key rules:

```md
- Before creating the first feature PRD, confirm `docs/product/constitution.md` exists, is approved, and has version metadata.
- Before creating the first feature PRD, confirm `docs/product/vision.md` exists, is approved, and has version metadata.
- If either foundation document is missing, unapproved, or unversioned, complete the Foundation Gate before Requirements.
- Use the Constitution Grill before the Vision Grill when creating foundation documents.
```

7. In `templates/AGENTS.md.tmpl`, update PRD rule:

```md
- Every PRD must include a constitution alignment check against every current principle or standard in `./constitution.md`.
```

8. In `scripts/init.sh`, update final output:

```bash
echo "  2. Run the Product Constitution workflow to create approved, versioned docs/product/constitution.md"
echo "  3. Run the Product Vision workflow to create approved, versioned docs/product/vision.md"
echo "  4. Start the first PRD only after the Foundation Gate passes"
```

**Verification:**

Run:

```bash
bats skills/product-development/tests/init.bats
```

Expected output:

```text
... all tests pass ...
```

Exact Bats output may include the number of tests; there should be zero failures.

**Commit:**

```bash
git add skills/product-development/references/initialization.md skills/product-development/templates/README.md.tmpl skills/product-development/templates/AGENTS.md.tmpl skills/product-development/scripts/init.sh skills/product-development/tests/init.bats
git commit -m "docs: update initialization foundation guidance"
```

## Task 5: Update Requirements Constitution Alignment Guidance

**Files:**

- Modify: `skills/product-development/references/phase-2-requirements.md`

**Goal:**

Remove hard-coded five-principle guidance. PRDs should check the actual approved constitution dynamically.

**Steps:**

1. Update Inputs:

```md
- `docs/product/constitution.md` - approved governance principles with version metadata. Required before the first PRD.
- `docs/product/vision.md` - approved, versioned product north star. Required before the first PRD.
```

2. Update PRD required section 8:

```md
8. **Constitution Alignment** - table checking every current constitutional principle or standard with PASS/RISK/FAIL/N/A
```

3. Replace the existing "Constitution alignment check" section with:

```md
### Constitution alignment check

Every PRD must validate against the actual approved `docs/product/constitution.md`.

Use this table shape:

| Principle or Standard | Status | Notes |
|-----------------------|--------|-------|
| [Current constitution item] | PASS/RISK/FAIL/N/A | Evidence, mitigation, or N/A justification |

Rules:

- Evaluate every current constitutional principle or standard.
- Use N/A only when the item truly does not apply; include a short justification.
- RISK requires mitigation, amendment discussion, or decision not to proceed.
- FAIL against the constitution blocks the PRD until explicit constitution amendment, supersession approval, or decision not to proceed.
- Do not mitigate a constitutional FAIL inside the PRD.
- If `docs/product/constitution.md` is missing and this is the first PRD, stop for Foundation Gate.
- If `docs/product/constitution.md` exists but lacks approval or version metadata, ask the user whether to ratify or migrate it before proceeding.
```

4. Update the first-PRD stop rule so the constitution and vision both require approval and version metadata.

Expected wording:

```md
If this is the first PRD and either foundation document is missing, unapproved, or unversioned, stop and run Foundation Stage before drafting requirements. Later PRDs must still load the approved, versioned constitution and approved, versioned vision for alignment checks.
```

5. Update Quality Criteria:

```md
- Every current constitutional principle or standard is PASS or N/A with justification; RISK has documented mitigation or amendment discussion; FAIL is not present
```

6. Keep Vision Alignment quality criteria intact, but ensure it still references approved `docs/product/vision.md`.

**Verification:**

Run:

```bash
rg -n "five constitutional principles|Safety Is Non-Negotiable|Privacy By Default|Local-First Core" skills/product-development/references/phase-2-requirements.md
rg -n "PASS/RISK/FAIL/N/A|FAIL against the constitution|version metadata" skills/product-development/references/phase-2-requirements.md
```

Expected output:

- first command returns no hard-coded principle text
- second command finds the new dynamic alignment rules

**Commit:**

```bash
git add skills/product-development/references/phase-2-requirements.md
git commit -m "docs: make constitution alignment dynamic"
```

## Task 6: Final Validation And Packaging Checks

**Files:**

- Modify only if validation exposes a real issue:
  - `skills/product-development/SKILL.md`
  - `skills/product-development/references/product-constitution.md`
  - `skills/product-development/references/product-vision.md`
  - `skills/product-development/references/initialization.md`
  - `skills/product-development/references/phase-2-requirements.md`
  - `skills/product-development/templates/README.md.tmpl`
  - `skills/product-development/templates/AGENTS.md.tmpl`
  - `skills/product-development/scripts/init.sh`
  - `skills/product-development/tests/init.bats`

**Goal:**

Confirm tests, source fidelity, progressive disclosure, and skill packaging.

**Steps:**

1. Run init tests:

```bash
bats skills/product-development/tests/init.bats
```

Expected output: all tests pass.

2. Run source archive fidelity check:

```bash
shasum -a 256 /Users/yanni/Downloads/Product\ Constitution\ Guide.md skills/product-development/references/source/product-constitution-guide.md
```

Expected output: both hashes are `cc34e8b2794ade47bb516394755561e60683150124ad214b7dc552c603f21326`.

3. Run static progressive-disclosure checks:

```bash
rg -n "references/product-constitution.md|source/product-constitution-guide.md|product-constitution-guide.md" skills/product-development/SKILL.md skills/product-development/references/product-constitution.md
rg -n "constitution-grill|future work|five constitutional principles|Safety Is Non-Negotiable" skills/product-development/SKILL.md skills/product-development/references/phase-2-requirements.md
```

Expected output:

- first command finds the operational reference and source archive routing
- second command finds no stale future-work or hard-coded principle text

4. Run skill quick validator if available:

```bash
quick_validate="$(find "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator" -path "*/scripts/quick_validate.py" -print -quit)"
if [ -n "$quick_validate" ]; then
  python3 "$quick_validate" skills/product-development
else
  echo "skill quick validator unavailable"
fi
```

Expected output: validator passes. If the validator path is empty, document that the validator was unavailable and continue with the other checks.

5. Inspect git status for unrelated dirt:

```bash
git status --short
```

Expected output: only files intentionally changed by this implementation before the final commit. If unrelated files are dirty, leave them unstaged and report them.

**Commit:**

If fixes were needed, stage exact files only:

```bash
git add \
  skills/product-development/SKILL.md \
  skills/product-development/references/product-constitution.md \
  skills/product-development/references/source/product-constitution-guide.md \
  skills/product-development/references/product-vision.md \
  skills/product-development/references/initialization.md \
  skills/product-development/references/phase-2-requirements.md \
  skills/product-development/templates/README.md.tmpl \
  skills/product-development/templates/AGENTS.md.tmpl \
  skills/product-development/scripts/init.sh \
  skills/product-development/tests/init.bats
git commit -m "docs: validate product constitution workflow"
```

If no fixes were needed, do not create an empty commit.

## Task 7: Request Final Review

**Files:**

- No direct edits expected.

**Goal:**

Run adversarial review on the implemented change before reporting completion.

**Steps:**

1. Dispatch a review subagent with this scope:

```text
Review the implemented Product Constitution workflow integration. Check the diff against the approved design spec and implementation plan. Focus on Foundation Gate consistency, progressive disclosure, source archive fidelity, dynamic PRD constitution checks, tests, and stale wording. Do not edit files. Return findings ordered by severity with file/line references.
```

2. Address valid findings one at a time.

3. Re-run relevant validation after each fix.

4. Commit fixes with conventional commits.

## Execution Notes

- Use `apply_patch` or native edit tools for file writes. Do not use shell redirection or heredocs to write files.
- Use context-mode tools for large reads and searches.
- Preserve unrelated user changes.
- Stage exact files only. Do not use broad `git add skills/product-development` or `git add .`.
- Keep commits focused and conventional.
- Do not push or open a PR unless the user asks.
