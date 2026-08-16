# product-development

The Product Development methodology as a portable agent plugin. It guides
features through the product development lifecycle from idea to implementation
plan, producing artifacts that feed the next workflow.

The canonical methodology lives in
`skills/product-development/`. Marketplace manifests and adapter wrappers expose
the plugin; they do not duplicate methodology.

Install it from the marketplace as described in the
[repository README](../../README.md#getting-started).

## What It Does

This plugin guides agents through product artifacts in a deliberate sequence,
with human review gates between each workflow:

```text
Project Setup  ->  Foundation Stage  ->  Discovery and Design  ->  Requirements  ->  User Stories  ->  BDD Scenarios  ->  Implementation Planning
                         |                       |                    |                |                |
                  Foundation Gate          Design Approval       PRD/TRD Approval  Story Approval  Scenario Approval
```

Foundation Stage contains Product Constitution approval and the Product Vision
workflow. Foundation Gate blocks the first PRD until constitution is approved
and versioned, and vision is approved and versioned. Discovery and Design can
still happen before the gate passes. Each approval point pauses for review
before the agent proceeds.

## Start A Product Workflow

After installing the plugin, ask your agent to initialize product docs in the
project you want to work on:

```text
Initialize product documentation for this project
```

The script scaffolds `docs/product/` with a README, agent guidance, and feature
directory. It auto-detects your project name and app surfaces, then asks for
domain-specific examples to customize the boundary rule documentation. Use
`--dry-run` from a local checkout to preview what would be created without
writing files; see `../../docs/development.md#initialization-script`.

After initialization, tell your agent what you want to build. The skill
activates on phrases like "create a feature", "write a PRD", "write user
stories", or "plan a feature".

## Workflow Behavior

During a workflow, the agent will either collaborate in the main conversation or
delegate heavier drafting work to a sub-agent and return the draft for review.

At each gate, you can:

- **Approve**: the agent proceeds to the next workflow.
- **Request changes**: the agent iterates on the current artifact.
- **Reject**: the agent stops and discusses the concern.

## Artifacts Produced

| Workflow | Artifact | Location |
| --- | --- | --- |
| Project Setup | Documentation structure | `docs/product/README.md`, `docs/product/AGENTS.md` |
| Foundation Stage | Constitution | `docs/product/constitution.md`, `docs/product/constitutions/constitution-vX.Y.Z.md` |
| Foundation Stage | Product vision | `docs/product/vision.md`, `docs/product/visions/vision-vX.Y.Z.md` |
| Discovery and Design | Design document | `docs/plans/YYYY-MM-DD-<topic>-design.md` |
| Requirements | PRD | `docs/product/features/{feature}/PRD.md` |
| Requirements | TRD | `docs/product/features/{feature}/TRD.md` |
| User Stories | User stories | `docs/product/features/{feature}/stories/*.md` |
| BDD Scenarios | Platform scenarios | `docs/product/features/{feature}/scenarios/*.feature` |
| BDD Scenarios | Surface scenarios | `apps/{surface}/docs/features/{feature}/scenarios/*.feature` |
| Implementation Planning | Implementation plan | `docs/plans/YYYY-MM-DD-<topic>.md` |

Platform-level artifacts describe what the product does regardless of which app
surface delivers it. Surface-specific artifacts capture behavior tied to a
particular interaction model, such as touch gestures, browser interaction, or
remote control.

## Configuration

Configuration is optional. Without it, the skill runs with human-only gates and
no automated review passes.

Config locations:

- User-level: `~/.config/prometheas-product-development-skill/`
- Project-level: `$PROJECT_ROOT/.config/prometheas-product-development-skill/`

Project-level settings override user-level settings.

Example `settings.toml`:

```toml
[review_gates.requirements]
reviews = ["constitution-check"]

[review_gates.user_stories]
reviews = ["traceability-audit"]

[review_gates.bdd_scenarios]
reviews = ["traceability-audit", "coderabbit:review"]

[workflows]
use_subagents = true
prd_before_trd = true
```

Available review types:

| Review | What it checks |
| --- | --- |
| `constitution-check` | PRD/TRD alignment with project governance principles |
| `traceability-audit` | Every requirement is covered by a story; every story by a scenario |
| `coderabbit:review` | General document quality via CodeRabbit |
| Any skill name | Runs the named skill as a review pass |

Project-specific `AGENTS.md` guidance can add review context:

```markdown
## Review Context
When reviewing PRDs, pay attention to privacy implications.
Our default stance is zero tracking unless explicitly justified.

## Requirements Notes
All TRDs must follow the vendor-agnostic facade pattern.
```

## Specification Evolution

Product specs are living artifacts:

- PRDs and TRDs are updated in place with a changelog recording date, change,
  and rationale.
- User stories progress through a lifecycle from Draft to Ready to In Progress
  to Done to Archived.
- BDD scenarios are living and self-verifying; when behavior changes, scenarios
  update and the test suite validates the spec.
- Governance docs such as constitution and vision are never edited after
  approval; a new version supersedes the old one.

When incremental updates are insufficient, supersede with a new document instead
of editing beyond recognition.
