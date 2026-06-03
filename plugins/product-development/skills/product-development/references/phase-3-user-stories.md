# User Stories

This file keeps its `phase-3-user-stories.md` name as a legacy compatibility path. The public workflow name is User Stories.

## Inputs

- Approved PRD at `docs/product/features/{feature}/PRD.md`
- TRD at `docs/product/features/{feature}/TRD.md` (for technical feasibility context)
- Approved, versioned product constitution at `docs/product/constitution.md`
- Approved, versioned product vision at `docs/product/vision.md`

## Output Location

```
docs/product/features/{feature}/stories/
├── US-001-<short-name>.md
├── US-002-<short-name>.md
└── ...
```

## Story Format

Each story is a separate markdown file. Stories are **living artifacts** that progress through a lifecycle (see `docs/METHODOLOGY.md`).

```markdown
# US-{NNN}: {Short title}

**Status:** Draft | Ready | In Progress | Done | Archived
**PRD Requirement:** FR-{N}, NFR-{N}

## Story

As a {persona},
I want {capability},
so that {benefit}.

## Acceptance Criteria

- [ ] {Criterion 1 — testable, specific}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

## Notes

{Any context, constraints, or open questions not captured above.}
```

## Writing Conventions

### Personas

Use personas from the PRD's user stories section. Common Eirene personas:

- **Practitioner** — the person using the app for breathwork
- **Developer** — the team building and maintaining the app

### Acceptance criteria

Each criterion must be:
- **Testable** — can be verified as true or false
- **Specific** — no ambiguity about what "done" means
- **Independent** — doesn't depend on other criteria being checked first

Write criteria in plain language, not Gherkin. Gherkin comes in BDD Scenarios.

**Good:** "Error reports for opted-out users contain no persistent identifier"
**Bad:** "Error reports work correctly" (not testable — what does "correctly" mean?)

### Story sizing

Stories should be small enough to implement in a single focused session. If a story has more than 5-6 acceptance criteria, consider splitting it.

### Traceability

Every story references one or more PRD requirements by ID (FR-1, NFR-2, etc.). Every functional requirement in the PRD should be covered by at least one story.

Stories also preserve foundation alignment:

- Constitutional constraints from the PRD/TRD remain visible in acceptance criteria or notes.
- User intent, personas, and benefits stay aligned with the approved vision.
- If a story would weaken a constitutional principle or conflict with the approved vision, stop and resolve the foundation artifact before writing scenarios.

## Platform-Level Artifacts

User stories describe **user intent**, not surface-specific interactions. A story like "As a practitioner, I want my breathwork errors reported automatically" applies to every surface. The surface-specific details (how errors manifest on mobile vs TV) are captured in BDD Scenarios.

If a story can only apply to one surface, note the surface in the story's metadata but keep the file at platform level. This makes it visible in cross-surface planning.

## Story Lifecycle

Stories progress through statuses:

- **Draft** — story is being written, acceptance criteria may be incomplete
- **Ready** — story is approved and ready for scenario writing or implementation
- **In Progress** — story is being implemented
- **Done** — story is implemented, scenarios pass
- **Archived** — story has been superseded or is no longer relevant

Done and archived stories remain in `stories/` for traceability. If the directory becomes noisy, completed stories may be moved to `stories/archive/`.

## Quality Criteria

Stories are ready for BDD Scenarios when:
- Every PRD functional requirement is covered by at least one story
- Acceptance criteria are testable and specific
- Stories are small enough to implement individually
- Personas match those defined in the PRD
- Constitutional constraints and approved vision intent are preserved
