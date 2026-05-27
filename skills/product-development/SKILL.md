---
name: product-development
description: "Use when the user asks to create a feature, write a PRD or TRD, add user stories, write scenarios, create acceptance criteria, plan implementation, initialize product docs, set up product documentation, create, approve, amend, or validate a Product Constitution, run the Constitution Grill, create or maintain Product Vision, run a Vision Grill, or work anywhere in the product development lifecycle from project setup through implementation planning."
---

# Product Development Lifecycle

Guide features through the product development lifecycle from idea to implementation plan. Each workflow produces specific artifacts that feed into the next. Workflow transitions are gated by human review, with optional automated review passes.

## Lifecycle Map

```
[Project Setup]                              ← one-time setup (scripts/init.sh)
  ↓
Foundation Stage
  ├─ Product Constitution approval
  ├─ Product Vision workflow (Vision Grill)
  ├─ additional product-anchor workflows (planned extension point)
  └─ Foundation Gate: approved, versioned constitution + approved, versioned vision before first PRD
  ↓
Discovery and Design
  ↓  [human approves design]
Requirements
  ├─ PRD  [human approves before TRD]
  └─ TRD  [human approves PRD + TRD]  → optional review pass
  ↓
User Stories
  ↓  [human approves stories]         → optional review pass
BDD Scenarios
  ↓  [human approves scenarios]       → optional review pass
Implementation Planning
```

Foundation Stage does not block brainstorming or design exploration. Foundation Gate blocks creation of the first PRD. Later PRDs must check constitution and vision alignment before proceeding.

## Workflows

### Project Setup

**Trigger:** The project does not yet have a `docs/product/` directory, or the user asks to "initialize product docs" or "set up product documentation."

**Process:** Run the initialization script (`scripts/init.sh`) to scaffold the documentation structure. The script uses templates with placeholders, auto-detects project context (name, surfaces), and prompts the user for domain-specific values. Consult `references/initialization.md` for the full workflow.

**Output:**
- `docs/product/README.md` — documentation hierarchy and boundary rules
- `docs/product/AGENTS.md` — agent guidance for organizing product docs
- `docs/product/features/` — empty directory ready for the first feature

**This workflow runs once per project.** Skip if `docs/product/README.md` already exists.

### Foundation Stage

**Trigger:** `docs/product/constitution.md` or `docs/product/vision.md` is missing, the user asks to create or update product-anchor docs, or the agent is preparing to start the first feature PRD and must verify Foundation Gate before drafting.

**Process:** Establish product-anchor docs in this hierarchy:

1. Product Constitution workflow: create, ratify, or amend approved, versioned `docs/product/constitution.md`. Consult `references/product-constitution.md` for `grill-with-docs` dependency behavior, Constitution Grill workflow, versioning, amendment behavior, and constitution alignment checks.
2. Product Vision workflow: run the Vision Grill after Constitution approval. Consult `references/product-vision.md` for `grill-with-docs` dependency behavior, context/ADR coordination, and vision versioning.
3. Additional product-anchor workflows: planned extension point for product-anchor documents when approved.
4. Foundation Gate: complete only when approved, versioned `docs/product/constitution.md` and approved, versioned `docs/product/vision.md` exist.

**Output:** Approved, versioned `docs/product/constitution.md`; approved, versioned `docs/product/vision.md`; optional `CONTEXT-MAP.md`, `docs/product/CONTEXT.md`, and ADRs when approved and used.

**Foundation Gate:** Do not create the first PRD until the user approves `docs/product/constitution.md`, it has version metadata, and approved, versioned `docs/product/vision.md` exists.

### Discovery and Design

**Trigger:** An idea, feature request, or problem statement arrives.

**Process:** Invoke the `brainstorming` skill. It handles collaborative exploration, approach proposals, and design approval.

**Output:** Approved design document at `docs/plans/YYYY-MM-DD-<topic>-design.md`.

**Gate:** Do not proceed to Requirements until the design is approved.

### Requirements

**Trigger:** Design document is approved.

**Required inputs:** Approved design document, approved, versioned `docs/product/constitution.md`, and approved, versioned `docs/product/vision.md`. Missing, unapproved, or unversioned foundation documents block first-PRD requirements work.

**Process:** Create product and technical requirements documents. Consult `references/phase-2-requirements.md` for structure, conventions, constitution alignment, and vision alignment.

**Gate:** The PRD defines *what*; the TRD defines *how*. Present the PRD for human approval before writing the TRD. This prevents wasted architectural work if the requirements shift.

**Output:**
- `docs/product/features/{feature}/PRD.md`
- `docs/product/features/{feature}/TRD.md`

**Gate:** Both documents reviewed and approved before proceeding. Run configured review passes (see Configuration).

**Artifacts live at platform level** — requirements describe what the product does regardless of surface.

### User Stories

**Trigger:** PRD and TRD are reviewed and stable.

**Process:** Decompose PRD requirements into user-facing narratives. Consult `references/phase-3-user-stories.md` for format, sizing guidance, and acceptance criteria conventions.

**Output:** Story files at `docs/product/features/{feature}/stories/`.

**Gate:** Stories reviewed and approved. Run configured review passes.

**Stories are platform-level** — they describe user intent, not surface-specific interactions.

### BDD Scenarios

**Trigger:** User stories have acceptance criteria defined.

**Process:** Express acceptance criteria as Gherkin scenarios. Consult `references/phase-4-scenarios.md` for the boundary rule, file placement, and writing conventions.

**Output:**
- Platform-level scenarios: `docs/product/features/{feature}/scenarios/*.feature`
- Surface-specific scenarios: `apps/{surface}/docs/features/{feature}/scenarios/*.feature`

**Gate:** Scenarios reviewed and approved. Run configured review passes.

**Boundary rule:** If the Given/When/Then language is surface-neutral, the scenario is platform-level. If it references a specific interaction model (swipe, D-pad, gaze), it is surface-specific.

### Implementation Planning

**Trigger:** Scenarios are reviewed and cover the acceptance criteria.

**Process:** Load the approved constitution and approved vision with the reviewed scenarios, then invoke the `writing-plans` skill. It creates a detailed, task-by-task implementation plan with TDD steps, file paths, and verification criteria. Stop before planning if the plan would violate `MUST NOT` language, weaken a constitutional principle, conflict with the approved vision, or exceed clear authority.

**Output:** Implementation plan at `docs/plans/YYYY-MM-DD-<topic>.md`.

## Gates and Review Passes

### Gate behavior

At each gate:
1. The agent presents artifacts to the human for review
2. If review passes are configured for this gate, they run first and findings are included in the presentation
3. The human approves, requests changes, or rejects
4. On approval, proceed to next workflow. On changes, iterate and re-present.

### Configurable review passes

Review passes are optional automated checks that run at gates before human review. They are configured per-project or per-user (see Configuration). Examples:

- **Constitution alignment check** — verify PRD satisfies all governance principles
- **Traceability audit** — verify every FR-* is covered by a story, every story by a scenario
- **Code review agent** — run a review skill (e.g., `coderabbit:review`) against the artifacts
- **Custom review prompt** — project-specific review instructions from `AGENTS.md`

If no review passes are configured for a gate, the gate is human-only.

## Configuration

Configuration lives in two locations, with project-level overriding user-level:

- **User-level:** `~/.config/prometheas-product-development-skill/`
- **Project-level:** `$PROJECT_ROOT/.config/prometheas-product-development-skill/`

### settings.toml

Declarative, structured configuration for what runs where:

```toml
[review_gates.requirements]
reviews = ["constitution-check"]

[review_gates.user_stories]
reviews = ["traceability-audit"]

[review_gates.bdd_scenarios]
reviews = ["traceability-audit", "coderabbit:review"]

[workflows]
use_subagents = true      # Delegate heavy writing to sub-agents
prd_before_trd = true     # Human approves PRD before TRD
```

### AGENTS.md

Natural language instructions that review agents receive as context. Use this for nuanced, project-specific guidance that doesn't fit structured config:

```markdown
## Review Context
When reviewing PRDs, ensure constitution alignment with particular
attention to Principle II (Privacy).

## Requirements Notes
All TRDs must follow the vendor-agnostic facade pattern.
```

### Merge behavior

Project-level `settings.toml` overrides user-level per-key. Project-level `AGENTS.md` is appended after user-level `AGENTS.md`, so project-specific instructions take precedence in context.

### No configuration

If neither config location exists, the skill runs with defaults: human-only gates, no automated review passes, sub-agents used at the agent's discretion based on context size.

## Context Management

Requirements, User Stories, and BDD Scenarios involve substantial writing. To keep the main context focused on orchestration and human collaboration, delegate heavy writing to sub-agents. The lifecycle is sequential — never run workflows in parallel.

### Sub-agent dispatch pattern

For each writing workflow, dispatch a sub-agent with only the inputs it needs:

| Workflow | Sub-agent receives | Sub-agent returns |
|----------|-------------------|-------------------|
| Requirements PRD | Design doc, constitution, vision, `references/phase-2-requirements.md`, example features | PRD written to disk |
| Requirements TRD | Approved PRD, constitution, vision, `references/phase-2-requirements.md`, example features | TRD written to disk |
| User Stories | Approved PRD, TRD, constitution, vision, `references/phase-3-user-stories.md` | Story files written to disk |
| BDD Scenarios | User stories, TRD, constitution, vision, `references/phase-4-scenarios.md` | `.feature` files written to disk |

The main context reviews sub-agent output with the human and iterates if needed.

### When to stay in main context

Not every workflow needs a sub-agent. Stay in the main context when:
- The human wants to collaborate interactively on the artifact
- The feature is small enough that writing fits comfortably in context
- The human explicitly asks to work through it together

## Documentation Hierarchy

All product documentation follows a three-tier hierarchy. See `docs/product/README.md` for the full specification.

| Tier | Location | Contains |
|------|----------|----------|
| Platform | `docs/product/` | PRDs, TRDs, user stories, platform-level scenarios |
| App | `apps/{surface}/docs/` | Surface-specific scenarios |
| Code | `apps/{surface}/tests/` | Step definitions (test automation) |

## Workflow Selection

Not every feature starts at the beginning. Match the entry point to the current state:

| Starting point | Enter at |
|---------------|----------|
| No `docs/product/` directory | Project Setup |
| Missing, unapproved, or unversioned constitution or vision before first PRD | Foundation Stage |
| Vague idea, no clarity on approach | Discovery and Design |
| Clear requirements, needs documentation | Requirements after Foundation Gate |
| PRD exists, needs decomposition | User Stories |
| Stories exist, needs testable criteria | BDD Scenarios |
| Scenarios exist, needs implementation | Implementation Planning |

Clear requirements may skip brainstorming only after Foundation Gate passes. If this is the first PRD and `docs/product/constitution.md` or `docs/product/vision.md` is missing, unapproved, or unversioned, run Foundation Stage before Requirements.

## Skill Delegation

This skill orchestrates the lifecycle but delegates to specialized skills for bookend workflows:

- **Discovery and Design:** Delegate to `brainstorming` skill
- **Requirements, User Stories, BDD Scenarios:** Follow the reference files in this skill
- **Implementation Planning:** Delegate to `writing-plans` skill

## Specification Evolution

Product specifications are living artifacts. Different artifact types evolve at different rates. Consult `docs/METHODOLOGY.md` for the full methodology. Summary:

| Artifact | Strategy |
|----------|----------|
| Constitution, Vision | Immutable + supersede (semver) |
| PRD, TRD | Living document with changelog |
| User Stories | Living — add, complete, archive |
| Platform Scenarios | Living + self-verifying |
| Surface Scenarios | Living + self-verifying |

When updating an existing spec, append to its changelog with date, change, and rationale. When changes are so extensive the document is unrecognizable from its original form, supersede with a new document instead.

## Reference Files

Detailed guidance for each workflow lives in reference files to keep context targeted. The `phase-*` filenames are legacy compatibility paths; load them by the workflow names below:

- **`references/initialization.md`** — Project initialization workflow, placeholders, post-init steps
- **`references/product-constitution.md`** — Product Constitution workflow, Foundation Gate, Constitution Grill, versioning, amendment behavior, and alignment checks
- **`references/product-vision.md`** — Product Vision workflow, Foundation Gate, Vision Grill, versioning, and context/ADR coordination
- **`references/phase-2-requirements.md`** — PRD and TRD structure, conventions, constitution and vision checks
- **`references/phase-3-user-stories.md`** — Story format, acceptance criteria, sizing
- **`references/phase-4-scenarios.md`** — Gherkin conventions, boundary rule, file placement
- **`docs/METHODOLOGY.md`** — Specification evolution strategies, changelog conventions, supersession rules

Load `references/source/product-constitution-guide.md` only through `references/product-constitution.md` when exact source detail is needed. Load `references/source/vision-document-guide.md` only through `references/product-vision.md` when exact source detail is needed.

## Scripts

- **`scripts/init.sh`** — Project initialization script. Scaffolds `docs/product/` from templates with placeholder substitution. Supports interactive prompts, CLI arguments, and `--dry-run`.

## Templates

- **`templates/README.md.tmpl`** — Documentation hierarchy template
- **`templates/AGENTS.md.tmpl`** — Agent guidance template
