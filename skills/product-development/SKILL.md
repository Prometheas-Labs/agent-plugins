---
name: product-development
description: "Use when the user asks to create feature specs, write or revise a PRD/TRD, add user stories or scenarios, initialize product docs, or move a feature through any gate of the product development lifecycle."
---

# Product Development Lifecycle

Guide features through the product development lifecycle from idea to implementation plan. Each phase produces specific artifacts that feed into the next. Phase transitions are gated by human review. Red-team review passes are strongly recommended from G1 onward and should be treated as the default automated review mode for serious spec work.

## Phase Sequence

```
[Initialize project]                          ←  one-time setup (scripts/init.sh)
  ↓
Idea
  ↓  (brainstorming skill)
Design
  ↓  [G1: human approves design]       →  red-team design review
PRD
  ↓  [G2a: human approves PRD]        →  red-team PRD review
TRD
  ↓  [G2: human approves PRD + TRD]   →  red-team TRD review
User Stories
  ↓  [G3: human approves stories]     →  red-team story review
BDD Scenarios
  ↓  [G4: human approves scenarios]   →  red-team scenario review + full-chain review
Implementation Plan
```

## Phase Overview

### Phase 0: Project Initialization

**Trigger:** The project does not yet have a `docs/product/` directory, or the user asks to "initialize product docs" or "set up product documentation."

**Process:** Run the initialization script (`scripts/init.sh`) to scaffold the documentation structure. The script uses templates with placeholders, auto-detects project context (name, surfaces), and prompts the user for domain-specific values. Consult `references/initialization.md` for the full workflow.

**Output:**
- `docs/product/README.md` — documentation hierarchy and boundary rules
- `docs/product/AGENTS.md` — agent guidance for organizing product docs
- `docs/product/features/` — empty directory ready for the first feature

**This phase runs once per project.** Skip if `docs/product/README.md` already exists.

### Phase 1: Idea to Design

**Trigger:** An idea, feature request, or problem statement arrives.

**Process:** Invoke the `brainstorming` skill. It handles collaborative exploration, approach proposals, and design approval.

**Output:** Approved design document at `docs/plans/YYYY-MM-DD-<topic>-design.md`.

**Gate G1:** Do not proceed to Phase 2 until the design is approved.

### Phase 2: Requirements (PRD + TRD)

**Trigger:** Design document is approved.

**Process:** Create product and technical requirements documents. Consult `references/phase-2-requirements.md` for structure, conventions, and the constitution alignment check.

**Gate G2a:** The PRD defines *what*; the TRD defines *how*. Present the PRD for human approval before writing the TRD. This prevents wasted architectural work if the requirements shift.

**Output:**
- `docs/product/features/{feature}/PRD.md`
- `docs/product/features/{feature}/TRD.md`

**Gate G2:** Both documents reviewed and approved before proceeding. Run configured review passes (see Configuration). The default recommendation is a PRD red-team at G2a and a TRD red-team at G2.

**Artifacts live at platform level** — requirements describe what the product does regardless of surface.

### Phase 3: User Stories

**Trigger:** PRD and TRD are reviewed and stable.

**Process:** Decompose PRD requirements into user-facing narratives. Consult `references/phase-3-user-stories.md` for format, sizing guidance, and acceptance criteria conventions.

**Output:** Story files at `docs/product/features/{feature}/stories/`.

**Gate G3:** Stories reviewed and approved. Run configured review passes. The default recommendation is a story red-team plus a traceability audit.

**Stories are platform-level** — they describe user intent, not surface-specific interactions.

### Phase 4: BDD Scenarios

**Trigger:** User stories have acceptance criteria defined.

**Process:** Express acceptance criteria as Gherkin scenarios. Consult `references/phase-4-scenarios.md` for the boundary rule, file placement, and writing conventions.

**Output:**
- Platform-level scenarios: `docs/product/features/{feature}/scenarios/*.feature`
- Surface-specific scenarios: `apps/{surface}/docs/features/{feature}/scenarios/*.feature`

**Gate G4:** Scenarios reviewed and approved. Run configured review passes. The default recommendation is a scenario red-team, a traceability audit, and a late-gate full-chain review across PRD → TRD → stories → scenarios before Phase 5.

**Boundary rule:** If the Given/When/Then language is surface-neutral, the scenario is platform-level. If it references a specific interaction model (swipe, D-pad, gaze), it is surface-specific.

### Phase 5: Implementation Planning

**Trigger:** Scenarios are reviewed and cover the acceptance criteria.

**Process:** Invoke the `writing-plans` skill. It creates a detailed, task-by-task implementation plan with TDD steps, file paths, and verification criteria.

**Output:** Implementation plan at `docs/plans/YYYY-MM-DD-<topic>.md`.

## Gates and Review Passes

### Gate behavior

At each gate:
1. The agent presents artifacts to the human for review
2. If review passes are configured for this gate, they run first and findings are included in the presentation
3. The human approves, requests changes, or rejects
4. On approval, proceed to next phase. On changes, iterate and re-present.

### Configurable review passes

Review passes are automated checks that run at gates before human review. Human approval still decides the gate, but the default stance for meaningful spec work should be adversarial review rather than a human-only read-through. See `references/review-passes.md` for gate-by-gate criteria, shielded sub-agent review, and third-party CLI review patterns. Examples:

- **Red-team review** — adversarial review for contradictions, missing coverage, unverifiable claims, and hidden implementation traps
- **Constitution alignment check** — verify PRD satisfies all governance principles
- **Traceability audit** — verify every FR-* is covered by a story, every story by a scenario
- **Code review agent** — run a review skill (e.g., `coderabbit:review`) against the artifacts
- **Custom review prompt** — project-specific review instructions from `AGENTS.md`

If no review passes are configured for a gate, the gate is human-only. That is acceptable for lightweight work, but it is a quality risk for complex, privacy-sensitive, or multi-artifact features.

## Configuration

Configuration lives in two locations, with project-level overriding user-level:

- **User-level:** `~/.config/prometheas-product-development-skill/`
- **Project-level:** `$PROJECT_ROOT/.config/prometheas-product-development-skill/`

### settings.toml

Declarative, structured configuration for what runs where:

```toml
[gates.G1]
reviews = ["red-team:design"]

[gates.G2a]
reviews = ["red-team:prd"]

[gates.G2]
reviews = ["constitution-check", "red-team:trd"]

[gates.G3]
reviews = ["traceability-audit", "red-team:stories"]

[gates.G4]
reviews = ["traceability-audit", "red-team:scenarios", "red-team:full-chain"]

[reviews.red-team]
backend = "subagent"      # Or: claude-cli, codex-cli, copilot-cli
shielded = true           # Do not fork the writer's full session context
structured_output = true  # Findings grouped by severity with file references

[phases]
use_subagents = true      # Delegate heavy writing to sub-agents
prd_before_trd = true     # G2a gate: human approves PRD before TRD
```

### AGENTS.md

Natural language instructions that review agents receive as context. Use this for nuanced, project-specific guidance that doesn't fit structured config:

```markdown
## Review Context
When reviewing PRDs, ensure constitution alignment with particular
attention to Principle II (Privacy).

## Phase 2 Notes
All TRDs must follow the vendor-agnostic facade pattern.
```

### Merge behavior

Project-level `settings.toml` overrides user-level per-key. Project-level `AGENTS.md` is appended after user-level `AGENTS.md`, so project-specific instructions take precedence in context.

### No configuration

If neither config location exists, the skill runs with defaults: human-only gates, no automated review passes, sub-agents used at the agent's discretion based on context size. For projects where spec quality matters, add review configuration early instead of treating it as cleanup.

## Context Management

Phases 2-4 involve substantial writing. To keep the main context focused on orchestration and human collaboration, delegate heavy writing to sub-agents. The lifecycle is sequential — never run phases in parallel.

### Sub-agent dispatch pattern

For each writing phase, dispatch a sub-agent with only the inputs it needs:

| Phase | Sub-agent receives | Sub-agent returns |
|-------|-------------------|-------------------|
| 2 (PRD) | Design doc, constitution, vision, `references/phase-2-requirements.md`, example features | PRD written to disk |
| 2 (TRD) | Approved PRD, `references/phase-2-requirements.md`, example features | TRD written to disk |
| 3 | Approved PRD, `references/phase-3-user-stories.md` | Story files written to disk |
| 4 | User stories, TRD, `references/phase-4-scenarios.md` | `.feature` files written to disk |

The main context reviews sub-agent output with the human and iterates if needed.

### Shielded red-team dispatch pattern

When a sub-agent is used for review, isolate it from the writing context. Do not fork the full session history into the reviewer. The reviewer should receive only:

- The artifacts under review
- The gate-specific rubric
- Neighboring product docs required to catch contradictions
- Any unresolved prior findings that still need verification
- The required output format and severity rubric

Do not pass the writer's chain-of-thought, preferred fixes, or prior "this looks good" judgments into the reviewer. The point of the review pass is to surface issues the main context may be biased to miss.

### When to stay in main context

Not every phase needs a sub-agent. Stay in the main context when:
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

## Phase Selection

Not every feature starts at Phase 1. Match the entry point to the current state:

| Starting point | Enter at |
|---------------|----------|
| No `docs/product/` directory | Phase 0 (initialization) |
| Vague idea, no clarity on approach | Phase 1 (brainstorming) |
| Clear requirements, needs documentation | Phase 2 (PRD + TRD) |
| PRD exists, needs decomposition | Phase 3 (user stories) |
| Stories exist, needs testable criteria | Phase 4 (scenarios) |
| Scenarios exist, needs implementation | Phase 5 (writing-plans) |

## Skill Delegation

This skill orchestrates the lifecycle but delegates to specialized skills for bookend phases:

- **Phase 1:** Delegate to `brainstorming` skill
- **Phases 2-4:** Follow the reference files in this skill
- **Phase 5:** Delegate to `writing-plans` skill

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

Detailed guidance for each phase lives in reference files to keep context targeted. Load only the reference for the current phase:

- **`references/initialization.md`** — Project initialization workflow, placeholders, post-init steps
- **`references/phase-2-requirements.md`** — PRD and TRD structure, conventions, constitution check
- **`references/phase-3-user-stories.md`** — Story format, acceptance criteria, sizing
- **`references/phase-4-scenarios.md`** — Gherkin conventions, boundary rule, file placement
- **`references/review-passes.md`** — Gate-by-gate red-team strategy, shielded review pattern, external CLI backends
- **`docs/METHODOLOGY.md`** — Specification evolution strategies, changelog conventions, supersession rules

## Scripts

- **`scripts/init.sh`** — Project initialization script. Scaffolds `docs/product/` from templates with placeholder substitution. Supports interactive prompts, CLI arguments, and `--dry-run`.

## Templates

- **`templates/README.md.tmpl`** — Documentation hierarchy template
- **`templates/AGENTS.md.tmpl`** — Agent guidance template
