# Phase 2: Requirements (PRD + TRD)

## Inputs

- Approved design document from Phase 1 (brainstorming)
- `docs/product/constitution.md` — governance principles every feature must satisfy
- `docs/product/vision.md` — product north-star for alignment

## Output Location

```
docs/product/features/{feature}/
├── PRD.md
└── TRD.md
```

## PRD Structure

The Product Requirements Document describes **what** and **why**.

### Required sections

1. **Header** — feature name, status, created date, implementation service
2. **Problem** — what problem this solves, why it matters now
3. **Goal** — one-sentence summary of the desired outcome
4. **User Stories** — numbered (US-1, US-2, ...) with acceptance criteria per story
5. **Requirements** — functional (FR-*) and non-functional (NFR-*) in table format with priority (Must/Should/Could)
6. **Privacy Model** — what data is collected, what is never collected, consent model
7. **Success Metrics** — measurable criteria with pass/fail or target values
8. **Constitution Alignment** — table checking each of the five constitutional principles (see below)
9. **Open Questions** — unresolved decisions to address during implementation

### Constitution alignment check

Every PRD must include a table validating against all five constitutional principles:

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Safety Is Non-Negotiable | PASS/RISK/FAIL | ... |
| II. Privacy By Default, Minimal Data Always | PASS/RISK/FAIL | ... |
| III. Local-First Core, Account-Optional Network Features | PASS/RISK/FAIL | ... |
| IV. Sharing and Discovery Without Lock-In | PASS/RISK/FAIL | ... |
| V. One Domain Model, Many Surfaces | PASS/RISK/FAIL | ... |

Any RISK or FAIL status must include a mitigation plan or a decision to not proceed.

## TRD Structure

The Technical Requirements Document describes **how**, architecturally.

### Required sections

1. **Header** — feature name, status, created date, implementation service/library
2. **Architecture Overview** — ASCII diagram showing component relationships and data flow
3. **Directory Structure** — exact file tree showing where new code lives
4. **Design Rationale** — why this architecture (vendor-agnostic facades, shared instances, etc.)
5. **Dependencies** — packages to add and remove, with versions and purpose
6. **Files** — tables for Create, Modify, and Remove with file paths and purpose/change description
7. **Public API** — TypeScript signatures for the feature's public interface, with usage examples
8. **Data Storage** — database keys, schemas, defaults (if applicable)
9. **Vendor Configuration** — SDK configuration, API keys, options (if applicable)
10. **Testing Strategy** — unit tests (with specific test cases) and manual verification steps
11. **Risks and Mitigations** — table with likelihood, impact, and mitigation per risk

### Design principles

- **Vendor-agnostic facades** — app code imports from `lib/services/{feature}/`, never from vendor modules directly
- **Vendor wiring behind facades** — all vendor-specific code lives under `lib/services/vendor/{vendor}/`
- **Explicit file paths** — every file to create, modify, or remove is listed with its exact path
- **Testable** — every behavior has a corresponding test case listed

## Quality Criteria

A PRD is ready for Phase 3 when:
- All constitutional principles are PASS (or RISK with documented mitigation)
- User stories have clear acceptance criteria
- Functional requirements are prioritized
- Privacy model is explicit about what is and isn't collected

A TRD is ready for Phase 3 when:
- Architecture diagram is clear and matches the file structure
- Public API signatures are defined
- Dependencies are listed
- Testing strategy covers the acceptance criteria

## Evolution Strategy

PRDs and TRDs are **living documents**. When requirements evolve, update the document in place and append to the changelog. See `docs/METHODOLOGY.md` for full conventions.

### Changelog section

Every PRD and TRD ends with a changelog:

```markdown
## Changelog

| Date | Change | Rationale |
|------|--------|-----------|
| 2026-03-15 | Added `session_paused` event | User research showed pause frequency is a key engagement signal |
| 2026-03-01 | Initial version | — |
```

- Record date, brief description, and **rationale** (git diff shows *what* changed, the changelog captures *why*)
- The initial version entry has no rationale (self-evident)
- Minor corrections (typos, formatting) do not need changelog entries
- Changes to requirements, architecture, or acceptance criteria always get entries

### When to supersede instead

Supersede with a new document (rather than editing) when:
- Replacing the underlying technology (e.g., migrating analytics vendors)
- Fundamentally changing the privacy or consent model
- Rearchitecting a feature to the point where the original PRD/TRD is unrecognizable

The threshold is judgment-based: if the volume of changes would confuse someone reading the document relative to its original intent, create a new version.

## Existing Examples

Reference these existing PRD/TRD pairs as templates:
- `docs/product/features/analytics/`
- `docs/product/features/error-tracking/`
- `docs/product/features/feature-flags/`
