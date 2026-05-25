# Product Vision Resource Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

## Overview

Implement the approved design in `docs/superpowers/specs/2026-05-25-product-vision-resource-design.md`.

This is a docs and skill-resource change. No runtime feature code is expected. The implementation must keep `SKILL.md` concise and place detailed guidance in references.

## File Structure

- Create `skills/product-development/references/product-vision.md`
  - Operational workflow for creating, maintaining, and applying `docs/product/vision.md`.
  - Primary reference loaded by the skill.
- Create `skills/product-development/references/source/vision-document-guide.md`
  - Source archive copied from `/Users/yanni/Downloads/Vision Document Guide.md`.
  - Loaded only when exact guide detail, worksheets, or source fidelity is needed.
- Modify `skills/product-development/SKILL.md`
  - Add Phase 0.5 and Foundation Gate before first PRD.
  - Update phase-selection guidance so Phase 2 cannot bypass the Foundation Gate.
  - Point to `references/product-vision.md`.
- Modify `skills/product-development/references/initialization.md`
  - Explain post-init foundation-doc requirement.
- Modify `skills/product-development/references/phase-2-requirements.md`
  - Make approved `docs/product/constitution.md` and approved, versioned `docs/product/vision.md` required before the first PRD.
  - Add PRD vision alignment checks.
- Modify `skills/product-development/templates/README.md.tmpl`
  - Document first-PRD vision gate, versioning, optional product context, and ADR conventions.
- Modify `skills/product-development/templates/AGENTS.md.tmpl`
  - Tell agents to enforce vision gate and Matt-compatible context placement.
- Modify `skills/product-development/scripts/init.sh`
  - Update generated next-step stdout so it does not direct users to start the first PRD before the Foundation Gate.
- Modify `skills/product-development/tests/init.bats`
  - Add template-output and init-script-output assertions for new guidance.

## Task 1: Add Vision Reference Resources

**Files:**

- Create: `skills/product-development/references/product-vision.md`
- Create: `skills/product-development/references/source/vision-document-guide.md`

**Steps:**

- [ ] **Step 1: Add source guide archive**

  Copy `/Users/yanni/Downloads/Vision Document Guide.md` into `skills/product-development/references/source/vision-document-guide.md`.

  Keep the guide substantially as-is. Do not rewrite the source archive except for path-safe markdown normalization if needed.

- [ ] **Step 2: Add operational product vision reference**

  Create `skills/product-development/references/product-vision.md` with these sections:

  ```md
  # Product Vision

  ## Purpose
  ## When to use this reference
  ## Hard gate before first PRD
  ## Preferred dependency: grill-with-docs
  ## If grill-with-docs is missing
  ## Vision Grill workflow
  ## Vision document anatomy
  ## Versioning and approval
  ## Context and ADR coordination
  ## Ongoing use during planning and delivery
  ## Maintenance and maturity
  ## Source guide
  ```

  Required content:

  - State that first feature PRD work is blocked until approved `docs/product/constitution.md` and approved, versioned `docs/product/vision.md` exist.
  - State that `grill-with-docs` is recommended when installed.
  - If `grill-with-docs` is missing, instruct the agent to notify the user up front, recommend installation, and continue only if the user declines install or asks to proceed.
  - Keep the user interview in the main context because it is one-question-at-a-time.
  - Instruct the agent to answer from repo evidence instead of asking when the answer is discoverable.
  - Include research synthesis, source-evidence labeling, red-team review, and user ratification as part of the workflow. If source evidence is thin, instruct the agent to label assumptions rather than invent certainty.
  - Include the vision anatomy from the guide as concise prompts, not pasted long explanations.
  - Define `vision.md`, `CONTEXT.md`, and ADR boundaries.
  - Define root `CONTEXT-MAP.md` plus `docs/product/CONTEXT.md` when product context is not root-level.
  - Define ADR default as `docs/adr/` unless repo convention differs.
  - Require user approval before writing `CONTEXT-MAP.md`, `docs/product/CONTEXT.md`, or ADR side-effect docs unless the user explicitly asks for inline updates.
  - Define `docs/product/CONTEXT.md` as glossary/domain-language guidance only. Assumptions stay in the vision/research synthesis; decisions stay in ADRs.
  - Define version metadata:

    ```md
    # Product Vision

    Version: 1.0.0
    Status: Approved
    Approved: YYYY-MM-DD
    Supersedes: None
    ```

  - Define version rules:
    - initial approved vision is `1.0.0`
    - patch for non-strategic wording fixes
    - minor for material clarification preserving direction
    - major for strategic pivot
    - approved strategic meaning is immutable
    - pivots supersede prior versions
    - immutable approved copies live under `docs/product/visions/vision-vX.Y.Z.md`
    - `docs/product/vision.md` is the current pointer containing the latest approved version and a link to the archived immutable copy
  - Link to `references/source/vision-document-guide.md` for exact worksheets and source detail.
  - Add an explicit note that the skill's immutable-plus-supersede strategy overrides the source guide's "living document" language for approved strategic meaning.

- [ ] **Step 3: Self-check reference boundaries**

  Search the new operational reference for excessive pasted guide prose. It should summarize guide content and route to source archive for exact detail.

- [ ] **Step 4: Commit**

  ```bash
  git add skills/product-development/references/product-vision.md skills/product-development/references/source/vision-document-guide.md
  git commit -m "docs: add product vision reference resources"
  ```

## Task 2: Wire Vision Phase into Skill Lifecycle

**Files:**

- Modify: `skills/product-development/SKILL.md`
- Modify: `skills/product-development/references/initialization.md`
- Modify: `skills/product-development/references/phase-2-requirements.md`

**Steps:**

- [ ] **Step 1: Update lifecycle diagram in `SKILL.md`**

  Insert Foundation Docs after initialization and before first Phase 2 PRD work. Do not block idea brainstorming or design exploration on this phase; block Phase 2 PRD creation.

  ```text
  [Initialize project]
    ↓
  Foundation Docs
    ↓  [F1: human approves constitution + versioned vision]
  Idea
    ↓  (brainstorming skill)
  Design
    ↓  [G1: human approves design]
  PRD
  ```

- [ ] **Step 2: Add Phase 0.5 in `SKILL.md`**

  Add a short section:

  ```md
  ### Phase 0.5: Product Vision

  **Trigger:** `docs/product/vision.md` is missing, the user asks to create or update product vision, or the agent is about to create the first feature PRD.

  **Process:** Run the Vision Grill. Consult `references/product-vision.md` for the workflow, `grill-with-docs` dependency behavior, context/ADR coordination, and vision versioning.

  **Output:** Approved, versioned `docs/product/vision.md`; optional `CONTEXT-MAP.md`, `docs/product/CONTEXT.md`, and ADRs when `grill-with-docs` is used.

  **Gate F1:** Do not create the first PRD until the user approves `docs/product/constitution.md` and approved, versioned `docs/product/vision.md` exists.
  ```

- [ ] **Step 3: Update Phase 2 in `SKILL.md`**

  In Phase 2, state that approved `docs/product/constitution.md` and approved, versioned `docs/product/vision.md` are required inputs. Missing foundation docs block Phase 2.

- [ ] **Step 4: Update phase-selection guidance in `SKILL.md`**

  Find any phase-selection or shortcut guidance that lets agents proceed directly to Phase 2 when requirements are clear. Add this constraint:

  ```md
  Clear requirements may skip brainstorming only after the Foundation Gate passes. If this is the first PRD and `docs/product/constitution.md` or approved, versioned `docs/product/vision.md` is missing, run the foundation phase before Phase 2.
  ```

- [ ] **Step 5: Update reference list in `SKILL.md`**

  Add `references/product-vision.md` to the reference files section. Mention that `references/source/vision-document-guide.md` is loaded only from `product-vision.md` when exact source detail is needed.

- [ ] **Step 6: Update `references/initialization.md`**

  In post-initialization, replace the current combined instruction to create constitution and vision with explicit sequence:

  ```md
  1. Create and approve `docs/product/constitution.md` — governance principles.
  2. Run Phase 0.5 Product Vision before the first PRD.
  3. Create approved, versioned `docs/product/vision.md` through the Vision Grill.
  4. Proceed to the first PRD only after the Foundation Gate passes.
  ```

  Clarify that vision is not scaffolded because it requires project-specific interrogation.

- [ ] **Step 7: Update `references/phase-2-requirements.md`**

  Required input list must include:

  ```md
  - `docs/product/constitution.md` — approved governance principles. Required before the first PRD.
  - `docs/product/vision.md` — approved, versioned product north star. Required before the first PRD.
  ```

  Add PRD readiness criteria:

  ```md
  - Vision alignment is explicit: target users, value proposition, platform principles, and relevant surface vision are consistent with `docs/product/vision.md`.
  - If the PRD would change strategic direction, stop and supersede the vision before writing the PRD.
  ```

- [ ] **Step 8: Commit**

  ```bash
  git add skills/product-development/SKILL.md skills/product-development/references/initialization.md skills/product-development/references/phase-2-requirements.md
  git commit -m "docs: require foundation docs before first PRD"
  ```

## Task 3: Update Generated Product Docs Templates

**Files:**

- Modify: `skills/product-development/templates/README.md.tmpl`
- Modify: `skills/product-development/templates/AGENTS.md.tmpl`
- Modify: `skills/product-development/scripts/init.sh`
- Modify: `skills/product-development/tests/init.bats`

**Steps:**

- [ ] **Step 1: Update README template hierarchy**

  In `templates/README.md.tmpl`, keep `vision.md` in platform-level docs but clarify it is approved and versioned:

  ```md
  - `vision.md` — approved, versioned north-star product vision required before the first PRD
  ```

- [ ] **Step 2: Add foundation-gate section to README template**

  Add a concise section near artifact flow:

  ```md
  ## Foundation gate

  Before the first feature PRD, `docs/product/constitution.md` and `docs/product/vision.md` must exist and be approved. `vision.md` must carry explicit version metadata. If either foundation document is missing, complete the Foundation Gate before starting feature requirements.

  When `grill-with-docs` is used, product-domain context may live in `docs/product/CONTEXT.md`; if so, root `CONTEXT-MAP.md` should point to it. `CONTEXT.md` is for glossary and domain language, not requirements. ADRs default to `docs/adr/` unless this repository already uses another ADR convention.
  ```

- [ ] **Step 3: Update directory structure in README template**

  Add optional context and ADR lines without implying init creates them:

  ```text
  ├── vision.md                 ← approved, versioned product vision
  ├── CONTEXT.md                ← optional product-domain context for grill-with-docs
  ```

  Mention `docs/adr/` outside the `docs/product/` tree if the template already shows broader repo structure. If it does not, keep ADR text in the foundation-gate prose only.

- [ ] **Step 4: Update AGENTS template key rules**

  Add rules:

  ```md
  - Before creating the first feature PRD, confirm `docs/product/constitution.md` exists and is approved.
  - Before creating the first feature PRD, confirm `docs/product/vision.md` exists, is approved, and has version metadata.
  - If either foundation document is missing, complete the Foundation Gate before Phase 2 requirements.
  - If product context lives at `docs/product/CONTEXT.md`, ensure root `CONTEXT-MAP.md` points to it so Matt-style `grill-with-docs` agents can discover it.
  - Keep `docs/product/CONTEXT.md` limited to glossary and domain language. Put assumptions in vision/research synthesis and decisions in ADRs.
  - ADRs default to `docs/adr/` unless the repository already has an ADR convention.
  ```

- [ ] **Step 5: Update init script next-step output**

  In `scripts/init.sh`, update the final `Next steps` output so it says:

  ```text
  1. Review docs/product/README.md and docs/product/AGENTS.md
  2. Create and approve docs/product/constitution.md
  3. Run Phase 0.5 Product Vision to create approved, versioned docs/product/vision.md
  4. Start the first PRD only after the Foundation Gate passes
  ```

  Remove or replace wording that says users can start `docs/product/features/{feature}/PRD.md` immediately after init.

- [ ] **Step 6: Add init test assertions**

  In `tests/init.bats`, add tests that generated docs contain new guidance:

  ```bash
  @test "README contains foundation gate section" {
    run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
    grep -q "## Foundation gate" "$TEST_PROJECT/docs/product/README.md"
    grep -q "Foundation Gate" "$TEST_PROJECT/docs/product/README.md"
  }

  @test "AGENTS.md contains vision gate guidance" {
    run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
    grep -q "Before creating the first feature PRD" "$TEST_PROJECT/docs/product/AGENTS.md"
    grep -q "CONTEXT-MAP.md" "$TEST_PROJECT/docs/product/AGENTS.md"
  }

  @test "init output directs users through foundation gate" {
    run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
    grep -q "Foundation Gate" <<< "$output"
    ! grep -q "Start your first feature with: docs/product/features/{feature}/PRD.md" <<< "$output"
  }
  ```

- [ ] **Step 7: Run focused tests**

  ```bash
  bats skills/product-development/tests/init.bats
  ```

  If `bats` is unavailable, record that validation gap and run a dry-run smoke test:

  ```bash
  tmpdir="$(mktemp -d)"
  skills/product-development/scripts/init.sh "$tmpdir" --non-interactive --project-name "SmokeTest"
  grep -q "## Foundation gate" "$tmpdir/docs/product/README.md"
  grep -q "Before creating the first feature PRD" "$tmpdir/docs/product/AGENTS.md"
  output="$(skills/product-development/scripts/init.sh "$tmpdir-2" --non-interactive --project-name "SmokeTest" 2>&1)"
  grep -q "Foundation Gate" <<< "$output"
  ```

- [ ] **Step 8: Commit**

  ```bash
  git add skills/product-development/templates/README.md.tmpl skills/product-development/templates/AGENTS.md.tmpl skills/product-development/scripts/init.sh skills/product-development/tests/init.bats
  git commit -m "docs: surface vision gate in product templates"
  ```

## Task 4: Validate Skill Packaging and Progressive Disclosure

**Files:**

- Modify if needed: `skills/product-development/SKILL.md`
- Modify if needed: `skills/product-development/references/product-vision.md`
- Modify if needed: `skills/product-development/references/source/vision-document-guide.md`
- Modify if needed: `skills/product-development/scripts/init.sh`

**Steps:**

- [ ] **Step 1: Run skill validation**

  Locate the skill-creator validation script and run it against the skill folder:

  ```bash
  /Users/yanni/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/product-development
  ```

  If that exact path is unavailable, find `quick_validate.py` under `/Users/yanni/.codex/skills/.system/skill-creator` and run it.

- [ ] **Step 2: Check progressive disclosure**

  Confirm:

  - `SKILL.md` references `product-vision.md` but does not paste the full guide.
  - `product-vision.md` references `source/vision-document-guide.md`.
  - `source/vision-document-guide.md` is not directly referenced as the normal entry point from `SKILL.md`.
  - `product-vision.md` says when to consult the source guide.

- [ ] **Step 3: Check Matt convention compatibility**

  Confirm docs state:

  - existing repo convention wins
  - root `CONTEXT-MAP.md` points to `docs/product/CONTEXT.md` when product context is non-root
  - ADRs default to `docs/adr/`
  - `grill-with-docs` can propose context/ADRs, but side-effect docs require user approval unless explicitly requested inline
  - `docs/product/CONTEXT.md` is glossary/domain-language guidance only
  - product-development owns `docs/product/vision.md`

- [ ] **Step 4: Check hard-gate wording**

  Search for contradictory first-PRD guidance:

  ```bash
  rg -n "first PRD|first feature PRD|vision.md|constitution.md|Foundation Gate|Product Vision|Phase 0.5|Phase 2|Start your first feature" skills/product-development
  ```

  Confirm no file says the first PRD may proceed before approved constitution and approved, versioned vision exist.

- [ ] **Step 5: Check version strategy**

  Search for versioning language:

  ```bash
  rg -n "visions/vision-v|current pointer|Supersedes|Version: 1.0.0|living document|immutable" skills/product-development
  ```

  Confirm the operational reference says source-guide "living document" language is overridden by immutable-plus-supersede rules after approval.

- [ ] **Step 6: Check downstream alignment**

  Confirm docs require vision alignment during:

  - PRD creation
  - implementation planning or delivery validation

- [ ] **Step 7: Final status**

  ```bash
  git status --short
  ```

  If clean, implementation is complete. If files remain modified, review and commit them.

- [ ] **Step 8: Commit any validation fixes**

  ```bash
  git add skills/product-development
  git commit -m "docs: validate product vision skill integration"
  ```

## Self-Review Checklist

- [ ] The raw guide is preserved under `references/source/`.
- [ ] The operational workflow is in `references/product-vision.md`.
- [ ] `SKILL.md` stays concise.
- [ ] First PRD is blocked until approved `docs/product/constitution.md` and approved, versioned `docs/product/vision.md` exist.
- [ ] `grill-with-docs` missing behavior recommends install before fallback.
- [ ] `CONTEXT-MAP.md`, `docs/product/CONTEXT.md`, and `docs/adr/` placement rules are explicit.
- [ ] `docs/product/CONTEXT.md` is scoped to glossary/domain language only.
- [ ] Matt side-effect docs require user approval unless explicitly requested inline.
- [ ] Vision versioning uses `1.0.0` initial approval and supersede rules for pivots.
- [ ] Immutable approved vision copies live under `docs/product/visions/`.
- [ ] `docs/product/vision.md` is defined as current pointer/latest approved version.
- [ ] Init templates include user-facing guidance.
- [ ] Init script stdout does not direct users to start the first PRD before the Foundation Gate.
- [ ] Tests cover generated README, AGENTS guidance, and init stdout.
- [ ] Validation commands have been run or unavailable tooling is reported.
