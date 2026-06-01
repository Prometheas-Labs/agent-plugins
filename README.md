# Product Development Plugin

A plugin package for AI coding agents that guides product work through a
structured lifecycle, from project setup through implementation planning.

The canonical methodology lives in `skills/product-development/`. Plugin
manifests, command wrappers, and agent wrappers route to that skill tree rather
than duplicating lifecycle rules. Runtime hooks are intentionally deferred for
V1; no hook configuration, hook scripts, or manifest hook declarations ship with
this package.

For detailed harness compatibility, see
`docs/compatibility/harness-matrix.md`. For development setup and local checkout
installs, see `docs/development.md`.

## Getting Started

Install this package through your agent harness. Plugin installation is the
preferred path for Codex, Claude Code, and GitHub Copilot CLI. Plain Agent Skill
installation via `skills.sh` remains available as a secondary compatibility
path.

| Harness | Recommended install path | Notes |
| --- | --- | --- |
| Codex | Repository marketplace | Uses repository marketplace metadata. |
| Claude Code | Repository marketplace | Uses the `.claude-plugin/marketplace.json` marketplace metadata. |
| GitHub Copilot CLI | Repository marketplace | Uses `.github/plugin/marketplace.json`; direct repository installs work but are deprecated by the CLI. |
| Plain Agent Skill | `skills.sh` | Installs only the canonical skill, not plugin marketplace metadata. |

<details>
<summary>Codex</summary>

Register this repository as a marketplace, then install the plugin:

```bash
codex plugin marketplace add https://github.com/Prometheas-Labs/agent-skill-product-development.git --ref main
codex plugin add product-development@prometheas-product-development
```

For private forks, pinned mirrors, or development from a local checkout, see
`docs/development.md#installing-from-a-local-checkout`.

</details>

<details>
<summary>Claude Code</summary>

Register this repository as a marketplace, then install the plugin:

```bash
claude plugin marketplace add --scope user https://github.com/Prometheas-Labs/agent-skill-product-development.git#main
claude plugin install product-development@prometheas-product-development
```

For private forks, pinned mirrors, or development from a local checkout, see
`docs/development.md#installing-from-a-local-checkout`.

</details>

<details>
<summary>GitHub Copilot CLI</summary>

Register this repository as a marketplace, then install the plugin:

```bash
copilot plugin marketplace add Prometheas-Labs/agent-skill-product-development
copilot plugin install product-development@prometheas-product-development
```

Copilot CLI also supports direct repository installs:

```bash
copilot plugin install Prometheas-Labs/agent-skill-product-development
```

The CLI currently warns that direct plugin installs are deprecated. Prefer the
marketplace commands above for public setup instructions.

For private forks, pinned mirrors, or development from a local checkout, see
`docs/development.md#installing-from-a-local-checkout`.

</details>

<details>
<summary>Plain Agent Skill</summary>

Install the canonical skill via [skills.sh](https://skills.sh):

```bash
npx skills add product-development
```

It lands in `.agents/skills/` and works with compatible skill-based harnesses.
This path does not install plugin marketplace metadata, shared command wrappers,
or shared agent wrappers.

</details>

Gemini/Antigravity, Pi, and OMP manifests are included so the package is ready
for adapter-specific work. See `docs/compatibility/harness-matrix.md` before
claiming runtime support for those harnesses.

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
writing files; see `docs/development.md#initialization-script`.

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

## Package Contents

The repository includes plugin-package manifests:

- `plugin.json`
- `.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `.codex-plugin/plugin.json`
- `.github/plugin/marketplace.json`
- `gemini-extension.json`
- `package.json`

Manifests that declare component paths route back to
`skills/product-development/`. Metadata-only manifests are documented in the
compatibility matrix and are not treated as proven runtime routing. Shared
command and agent adapters under `commands/shared/` and `agents/shared/` are
thin entrypoints only; the skill tree remains the source of truth.

Local marketplace install smoke tests have passed for Codex, Claude Code, and
GitHub Copilot CLI at the skill-package level. Those tests prove the package can
be registered and installed through those harnesses; they do not prove runtime
loading for shared command wrappers, shared agent wrappers, or hooks.

## Developing This Plugin

Development setup, local checkout installation, test commands, and repository
structure are documented in `docs/development.md`.
