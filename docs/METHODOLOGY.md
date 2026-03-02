# Specification Evolution Methodology

Product specifications are living artifacts that evolve alongside the product. Different artifact types evolve at different rates and in different ways. This document defines the evolution strategy for each artifact in the product development lifecycle.

## Core Principle

**Traceability over format.** Whether a specification is updated in place or superseded by a new document, the requirement is that any current specification can be traced back to the decision that created it. Git history provides this for living documents. Explicit supersession headers provide this for immutable documents.

## Evolution Strategies

### Immutable + Supersede

The document is never modified after approval. When the specification must change, a new version is created. The old version is marked as superseded.

**Mechanism:** The new document includes a header indicating what it supersedes. The old document receives a header indicating what supersedes it. Both remain in the repository for historical reference.

```markdown
**Supersedes:** constitution-v1.0.0.md
```

```markdown
**Superseded by:** constitution-v2.0.0.md
**Status:** Archived
```

**Use for:** Governance documents where changes are rare, consequential, and require deliberate review. A quiet edit to the constitution undermines its authority.

### Living Document

The document is updated in place. A changelog section at the bottom records significant changes with date, description, and rationale.

**Mechanism:** Edit the document directly. Append to the changelog. Git history provides the full diff.

```markdown
## Changelog

| Date | Change | Rationale |
|------|--------|-----------|
| 2026-03-15 | Added `session_paused` event | User research showed pause frequency is a key engagement signal |
| 2026-03-01 | Initial version | — |
```

**Use for:** Specifications that evolve incrementally. Adding a new analytics event, refining acceptance criteria, updating a dependency version.

**When to supersede instead:** If the changes are so extensive that the document is no longer recognizable from its original form — a major pivot, a complete rearchitecture, or a fundamental change in approach — create a new document and supersede the old one rather than editing it beyond recognition.

### Living + Self-Verifying

The specification is tied to automated tests. When behavior changes, the specification is updated, and the test suite validates that the specification matches reality. Stale specs fail the build.

**Mechanism:** Gherkin `.feature` files are executable. Step definitions run as tests. A failing scenario means the specification and the implementation have diverged.

**Use for:** Behavioral contracts expressed as BDD scenarios. These are the only artifacts that can be mechanically verified for staleness.

## Strategy by Artifact Type

| Artifact | Strategy | Location | Rationale |
|----------|----------|----------|-----------|
| Constitution | Immutable + supersede (semver) | `docs/product/` | Governance changes are rare and consequential |
| Vision | Immutable + supersede (semver) | `docs/product/` | Strategic direction changes are deliberate |
| PRD | Living document with changelog | `docs/product/features/{feature}/` | Requirements evolve incrementally |
| TRD | Living document with changelog | `docs/product/features/{feature}/` | Architecture tracks requirements |
| User Stories | Living — add, complete, archive | `docs/product/features/{feature}/stories/` | Stories are transient work items |
| Platform Scenarios | Living + self-verifying | `docs/product/features/{feature}/scenarios/` | Executable behavioral contracts |
| Surface Scenarios | Living + self-verifying | `apps/{surface}/docs/features/{feature}/scenarios/` | Surface-specific executable contracts |

## User Story Lifecycle

Stories have a status field that tracks their progress:

- **Draft** — story is being written, acceptance criteria may be incomplete
- **Ready** — story is approved and ready for scenario writing or implementation
- **In Progress** — story is being implemented
- **Done** — story is implemented, scenarios pass
- **Archived** — story has been superseded or is no longer relevant

Done and archived stories remain in the `stories/` directory for traceability. If the directory becomes noisy, completed stories may be moved to `stories/archive/`.

## Changelog Conventions

For living documents (PRDs, TRDs), the changelog section is the last section in the document.

- Record the date, a brief description of the change, and the rationale
- The rationale matters more than the description — git diff shows *what* changed, but not *why*
- The initial version entry has no rationale (it's self-evident)
- Minor corrections (typos, formatting) do not need changelog entries
- Changes to requirements, architecture, or acceptance criteria always get entries

## When to Supersede vs. Update

Update in place when:
- Adding a new requirement or event to an existing feature
- Refining acceptance criteria based on implementation learnings
- Updating dependency versions or technical details
- Correcting errors discovered during implementation

Supersede with a new document when:
- Replacing the underlying technology (e.g., migrating from PostHog to another vendor)
- Fundamentally changing the privacy or consent model
- Rearchitecting a feature to the point where the original PRD/TRD is unrecognizable
- Changing governance principles (constitution, vision)

The threshold is judgment-based: if someone reading the document would be confused by the volume of changes relative to the original intent, it's time for a new version.
