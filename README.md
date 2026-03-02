# Product Development Lifecycle Skill

A skill that guides AI coding agents through a structured product development lifecycle, from initial idea through to implementation planning.

## What it does

This skill orchestrates the creation of product artifacts in a deliberate sequence, with human review gates between each phase:

```
[Init]  →  Idea  →  Design  →  PRD  →  TRD  →  User Stories  →  BDD Scenarios  →  Implementation Plan
                     [G1]       [G2a]   [G2]      [G3]             [G4]
```

Each arrow is a gate where you review and approve before the agent proceeds. No phase runs without your sign-off.

## Getting started

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

### Start building

Tell your agent what you want to build. The skill activates on phrases like "create a feature", "write a PRD", "plan a feature", etc.

You don't need to start at the beginning. If you already have a PRD, say "write user stories for the analytics feature" and the agent enters at Phase 3.

### During a phase

The agent will either:
- **Collaborate with you** in the main conversation (for smaller features or when you want to shape the artifact interactively)
- **Delegate to a sub-agent** that writes a draft, then present it to you for review (for larger features, to keep the conversation focused)

### At each gate

The agent pauses and presents the artifacts for your review. If you've configured automated review passes (see Configuration), those run first and findings are included.

You can:
- **Approve** — the agent proceeds to the next phase
- **Request changes** — the agent iterates on the current phase
- **Reject** — the agent stops and discusses the concern

## Artifacts produced

| Phase | Artifact | Location |
|-------|----------|----------|
| 0 | Documentation structure | `docs/product/README.md`, `docs/product/AGENTS.md` |
| 1 | Design document | `docs/plans/YYYY-MM-DD-<topic>-design.md` |
| 2 | PRD | `docs/product/features/{feature}/PRD.md` |
| 2 | TRD | `docs/product/features/{feature}/TRD.md` |
| 3 | User stories | `docs/product/features/{feature}/stories/*.md` |
| 4 | Platform scenarios | `docs/product/features/{feature}/scenarios/*.feature` |
| 4 | Surface scenarios | `apps/{surface}/docs/features/{feature}/scenarios/*.feature` |
| 5 | Implementation plan | `docs/plans/YYYY-MM-DD-<topic>.md` |

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
[gates.G2]
reviews = ["constitution-check"]

[gates.G3]
reviews = ["traceability-audit"]

[gates.G4]
reviews = ["traceability-audit", "coderabbit:review"]

[phases]
use_subagents = true      # Prefer sub-agents for heavy writing phases
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

## Phase 2 Notes
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
│   ├── phase-2-requirements.md            ← PRD + TRD structure and conventions
│   ├── phase-3-user-stories.md            ← story format and acceptance criteria
│   └── phase-4-scenarios.md               ← Gherkin conventions and boundary rules
├── scripts/
│   └── init.sh                            ← project initialization script
├── templates/
│   ├── README.md.tmpl                     ← documentation hierarchy template
│   └── AGENTS.md.tmpl                     ← agent guidance template
└── tests/
    └── init.bats                          ← BATS tests for init.sh
```

Reference files are loaded by the agent only when it enters the corresponding phase, keeping context focused.

## Installation

This skill is designed to be installed via [skills.sh](https://skills.sh):

```bash
npx skills add product-development
```

It lands in `.agents/skills/` and works with any compatible agent harness.

For development or local testing with Claude Code, the skill can also live at `.claude/skills/product-development/` in your project.
