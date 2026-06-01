# Product Development Lifecycle Skill

A skill that guides AI coding agents through a structured product development lifecycle, from project setup through implementation planning.

This repository remains installable as a plain Agent Skill. It also contains
plugin-package manifests for harnesses that can load packaged skills. The
canonical methodology lives in `skills/product-development/`; shared command
and agent wrappers route there, while metadata-only manifests are documented in
the compatibility matrix. Adapters do not own separate lifecycle rules.

Support levels for each harness are documented in
`docs/compatibility/harness-matrix.md`. Runtime hooks are intentionally deferred
for V1; no hook configuration, hook scripts, or manifest hook declarations ship
with this package.

## What it does

This skill orchestrates the creation of product artifacts in a deliberate sequence, with human review gates between each workflow:

```
Project Setup  →  Foundation Stage  →  Discovery and Design  →  Requirements  →  User Stories  →  BDD Scenarios  →  Implementation Planning
                         ↓                       ↓                    ↓                ↓                ↓
                  Foundation Gate          Design Approval       PRD/TRD Approval  Story Approval  Scenario Approval
```

Foundation Stage contains Product Constitution approval and the Product Vision workflow. Foundation Gate blocks the first PRD until constitution is approved and versioned, and vision is approved and versioned. Discovery and Design can still happen before the gate passes. Each approval point pauses for your review before the agent proceeds.

## Getting started

### Development environment

This repository includes a pinned Nix dev shell for local validation. The shell
uses a fixed Nixpkgs commit and provides `python313`, `bats`, and `node`.
`python313` gives the tests stdlib `tomllib` support without adding a PyPI TOML
parser dependency.

```bash
direnv allow
```

Without direnv, enter the same environment directly:

```bash
nix develop
```

### New project — initialize first

If your project doesn't have a `docs/product/` directory yet, initialize it:

```bash
# Run the init script directly
./scripts/init.sh /path/to/your/project

# Or ask your agent
> "Initialize product documentation for this project"
```

The script scaffolds `docs/product/` with a README, agent guidance, and feature directory. It auto-detects your project name and app surfaces, then asks for a couple of domain-specific examples to customize the boundary rule documentation.

Use `--dry-run` to preview what would be created without writing files.

### What init does

The script scaffolds `docs/product/` from templates:

| Generated file | Contents |
|----------------|----------|
| `docs/product/README.md` | Three-tier documentation hierarchy, artifact flow diagram, boundary rule for scenario placement, directory structure reference |
| `docs/product/AGENTS.md` | Agent guidance for organizing product docs, feature workflow checklist, specification evolution conventions |
| `docs/product/features/` | Empty directory ready for the first feature |

Files that already exist are never overwritten.

### Auto-detection

The script inspects your project before prompting:

| Value | Detection | Fallback |
|-------|-----------|----------|
| Project name | `name` field from `package.json` | Directory name |
| Surfaces | Subdirectories under `apps/` | `mobile` |
| Existing features | Subdirectories under `docs/product/features/` | (omitted from output) |

Surface names are humanized in documentation prose (`mobile` → "a phone", `tv` → "a TV", `web` → "a browser").

### Script options

```
./scripts/init.sh <project-root> [options]

Options:
  --project-name NAME                  Project name for headings
  --surfaces "mobile,web,tv"           Comma-separated app surfaces
  --platform-scenario-example TEXT     Example platform-level scenario
  --surface-scenario-example TEXT      Example surface-specific scenario
  --non-interactive                    Use defaults without prompting
  --dry-run                            Preview without writing files
```

When run without options, the script prompts interactively for any values it can't auto-detect. The two values that genuinely need human input are the **scenario examples** — they appear in the boundary rule section and should reflect your project's domain.

### Running tests

The script has BATS test coverage:

```bash
bats tests/init.bats
```

From the repository root, run the same init script coverage with:

```bash
bats skills/product-development/tests/init.bats
```

Plugin package validation is covered separately:

```bash
bats tests/plugin-package.bats
```

### Start building

Tell your agent what you want to build. The skill activates on phrases like "create a feature", "write a PRD", "plan a feature", etc.

You don't need to start at the beginning. If you already have a PRD, say "write user stories for the analytics feature" and the agent enters the User Stories workflow.

### During a workflow

The agent will either:
- **Collaborate with you** in the main conversation (for smaller features or when you want to shape the artifact interactively)
- **Delegate to a sub-agent** that writes a draft, then present it to you for review (for larger features, to keep the conversation focused)

### At each gate

The agent pauses and presents the artifacts for your review. If you've configured automated review passes (see Configuration), those run first and findings are included.

You can:
- **Approve** — the agent proceeds to the next workflow
- **Request changes** — the agent iterates on the current workflow
- **Reject** — the agent stops and discusses the concern

## Artifacts produced

| Workflow | Artifact | Location |
|----------|----------|----------|
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

Platform-level artifacts describe what the product does regardless of which app surface (mobile, web, TV) delivers it. Surface-specific artifacts capture behaviors tied to a particular interaction model (touch gestures, remote control, etc.).

## Configuration

Configuration is optional. Without it, the skill runs with human-only gates and no automated review passes.

### Config locations

- **User-level:** `~/.config/prometheas-product-development-skill/`
- **Project-level:** `$PROJECT_ROOT/.config/prometheas-product-development-skill/`

Project-level settings override user-level.

### settings.toml

Controls what automated review passes run at each gate:

```toml
[review_gates.requirements]
reviews = ["constitution-check"]

[review_gates.user_stories]
reviews = ["traceability-audit"]

[review_gates.bdd_scenarios]
reviews = ["traceability-audit", "coderabbit:review"]

[workflows]
use_subagents = true      # Prefer sub-agents for heavy writing workflows
prd_before_trd = true     # Require PRD approval before TRD is written
```

#### Available review types

| Review | What it checks |
|--------|---------------|
| `constitution-check` | PRD/TRD alignment with project governance principles |
| `traceability-audit` | Every requirement is covered by a story; every story by a scenario |
| `coderabbit:review` | General document quality via CodeRabbit |
| Any skill name | Runs the named skill as a review pass |

### AGENTS.md

Natural language instructions that review agents receive as context. Use this for project-specific guidance:

```markdown
## Review Context
When reviewing PRDs, pay attention to privacy implications.
Our default stance is zero tracking unless explicitly justified.

## Requirements Notes
All TRDs must follow the vendor-agnostic facade pattern.
```

## Specification evolution

Product specs are living artifacts — they evolve over time. The methodology (`docs/METHODOLOGY.md`) defines how each artifact type evolves:

- **PRDs and TRDs** are updated in place with a changelog at the bottom recording date, change, and rationale
- **User stories** progress through a lifecycle (Draft → Ready → In Progress → Done → Archived) and may be moved to `stories/archive/` when the directory gets noisy
- **BDD scenarios** are living and self-verifying — when behavior changes, scenarios update and the test suite validates the spec matches reality
- **Governance docs** (constitution, vision) are never edited after approval; a new version supersedes the old one

When incremental updates are insufficient (e.g., a major pivot or rearchitecture), supersede with a new document instead of editing beyond recognition.

## Skill files

```
product-development/
├── README.md                              ← this file (for humans)
├── SKILL.md                               ← agent instructions (loaded by the harness)
├── docs/
│   └── METHODOLOGY.md                     ← specification evolution strategies
├── references/
│   ├── initialization.md                  ← project initialization workflow
│   ├── product-constitution.md            ← Product Constitution workflow and Foundation Gate
│   ├── product-vision.md                  ← Product Vision workflow and Foundation Gate
│   ├── source/
│   │   ├── product-constitution-guide.md  ← archived constitution source guide
│   │   └── vision-document-guide.md       ← archived vision source guide
│   ├── phase-2-requirements.md            ← Requirements workflow; legacy compatibility path
│   ├── phase-3-user-stories.md            ← User Stories workflow; legacy compatibility path
│   └── phase-4-scenarios.md               ← BDD Scenarios workflow; legacy compatibility path
├── scripts/
│   └── init.sh                            ← project initialization script
├── templates/
│   ├── README.md.tmpl                     ← documentation hierarchy template
│   └── AGENTS.md.tmpl                     ← agent guidance template
└── tests/
    └── init.bats                          ← BATS tests for init.sh
```

Reference files are loaded by the agent only when it enters the corresponding workflow, keeping context focused. The `phase-*` filenames remain for compatibility.

## Installation

Choose the path that matches your harness.

### Plain Agent Skill

Install the canonical skill via [skills.sh](https://skills.sh):

```bash
npx skills add product-development
```

It lands in `.agents/skills/` and works with any compatible agent harness.

For development or local testing with Claude Code, the skill can also live at
`.claude/skills/product-development/` in your project.

### Plugin Marketplaces From A Local Checkout

The Codex, Claude Code, and GitHub Copilot CLI examples below install this
package from a project-local marketplace. Start from the project where you want
the plugin available:

```bash
cd /path/to/your/project
mkdir -p plugins
git clone https://github.com/Prometheas-Labs/agent-skill-product-development.git plugins/product-development
export PROJECT_ROOT="$PWD"
```

If you vendor or submodule dependencies differently, keep the same final layout:
the plugin package should live at `plugins/product-development/` relative to the
project root.

### Codex

Create `.agents/plugins/marketplace.json`:

```json
{
  "name": "local-product-development",
  "plugins": [
    {
      "name": "product-development",
      "source": {
        "source": "local",
        "path": "./plugins/product-development"
      }
    }
  ]
}
```

Then register the project root and install the plugin:

```bash
codex plugin marketplace add "$PROJECT_ROOT"
codex plugin add product-development@local-product-development
```

### Claude Code

Create `.claude-plugin/marketplace.json`:

```json
{
  "name": "local-product-development",
  "owner": {
    "name": "Your Team"
  },
  "plugins": [
    {
      "name": "product-development",
      "source": "./plugins/product-development"
    }
  ]
}
```

Then validate, register, and install:

```bash
claude plugin validate "$PROJECT_ROOT"
claude plugin marketplace add --scope project "$PROJECT_ROOT"
claude plugin install --scope project product-development@local-product-development
```

### GitHub Copilot CLI

Create `.github/plugin/marketplace.json`:

```json
{
  "name": "local-product-development",
  "owner": {
    "name": "Your Team"
  },
  "plugins": [
    {
      "name": "product-development",
      "source": "./plugins/product-development"
    }
  ]
}
```

Then register and install:

```bash
copilot plugin marketplace add "$PROJECT_ROOT"
copilot plugin install product-development@local-product-development
```

### Other Harnesses

Gemini/Antigravity, Pi, and OMP manifests are included so the package is ready
for adapter-specific work. See `docs/compatibility/harness-matrix.md` before
claiming runtime support for those harnesses.

## Plugin package

The repository also includes plugin-package manifests:

- `plugin.json`
- `.claude-plugin/plugin.json`
- `.codex-plugin/plugin.json`
- `gemini-extension.json`
- `package.json`

These files keep the repository package-shaped for supported harnesses.
Manifests that declare component paths route back to `skills/product-development/`.
Metadata-only manifests are documented in the compatibility matrix and are not treated as proven runtime routing. Shared command and agent adapters under
`commands/shared/` and `agents/shared/` are thin entrypoints only; the skill tree
remains the source of truth for Product Constitution, Product Vision,
requirements, user stories, scenarios, and implementation planning methodology.

Local marketplace install smoke tests have passed for Codex, Claude Code, and
GitHub Copilot CLI at the skill-package level. Those tests prove the package can
be registered and installed through those harnesses; they do not prove runtime
loading for shared command wrappers, shared agent wrappers, or hooks.

See `docs/compatibility/harness-matrix.md` for support tiers, local marketplace
layouts, and validation status. See `docs/compatibility/hooks.md` for the V1
hook policy: hooks are intentionally deferred until a separate design, security
review, and per-harness schema validation are approved.
