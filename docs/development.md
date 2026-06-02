# Development

This document covers local development and local checkout installation for the
Product Development plugin package. The public README is focused on plugin
consumers.

## Development Environment

This repository includes a pinned Nix dev shell for local validation. The shell
uses a fixed Nixpkgs commit and provides `python313`, `bats`, and `node`.
`python313` gives the tests stdlib `tomllib` support without adding a PyPI TOML
parser dependency.

With direnv:

```bash
direnv allow
```

Without direnv:

```bash
nix develop
```

## Installing From A Local Checkout

Use local checkout installs for development, private forks, pinned internal
mirrors, or testing changes before publishing them.

Start from the project where you want the plugin available:

```bash
cd /path/to/your/project
mkdir -p plugins
git clone https://github.com/Prometheas-Labs/agent-plugin-product-development.git plugins/product-development
export PROJECT_ROOT="$PWD"
```

If you vendor or submodule dependencies differently, keep the same final layout:
the plugin package should live at `plugins/product-development/` relative to the
project root.

### Codex

Create `.agents/plugins/marketplace.json` in your project:

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

Then register the project root and install from that local marketplace:

```bash
codex plugin marketplace add "$PROJECT_ROOT"
codex plugin add product-development@local-product-development
```

### Claude Code

Create `.claude-plugin/marketplace.json` in your project:

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

Then validate, register, and install from that local marketplace:

```bash
claude plugin validate "$PROJECT_ROOT"
claude plugin marketplace add --scope project "$PROJECT_ROOT"
claude plugin install --scope project product-development@local-product-development
```

### GitHub Copilot CLI

Create `.github/plugin/marketplace.json` in your project:

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

Then register and install from that local marketplace:

```bash
copilot plugin marketplace add "$PROJECT_ROOT"
copilot plugin install product-development@local-product-development
```

## Initialization Script

The init script scaffolds `docs/product/` from templates:

| Generated file | Contents |
| --- | --- |
| `docs/product/README.md` | Three-tier documentation hierarchy, artifact flow diagram, boundary rule for scenario placement, directory structure reference |
| `docs/product/AGENTS.md` | Agent guidance for organizing product docs, feature workflow checklist, specification evolution conventions |
| `docs/product/features/` | Empty directory ready for the first feature |

Files that already exist are never overwritten.

The script inspects the target project before prompting:

| Value | Detection | Fallback |
| --- | --- | --- |
| Project name | `name` field from `package.json` | Directory name |
| Surfaces | Subdirectories under `apps/` | `mobile` |
| Existing features | Subdirectories under `docs/product/features/` | omitted from output |

Surface names are humanized in documentation prose, such as `mobile` becoming
"a phone", `tv` becoming "a TV", and `web` becoming "a browser".

Script options:

```text
./skills/product-development/scripts/init.sh <project-root> [options]

Options:
  --project-name NAME                  Project name for headings
  --surfaces "mobile,web,tv"           Comma-separated app surfaces
  --platform-scenario-example TEXT     Example platform-level scenario
  --surface-scenario-example TEXT      Example surface-specific scenario
  --non-interactive                    Use defaults without prompting
  --dry-run                            Preview without writing files
```

When run without options, the script prompts interactively for values it cannot
auto-detect. The scenario examples appear in the boundary rule section and
should reflect the target project's domain.

## Running Tests

Run plugin package validation:

```bash
nix develop -c bats tests/plugin-package.bats
```

Run init script coverage:

```bash
nix develop -c bats skills/product-development/tests/init.bats
```

Check whitespace:

```bash
git diff --check
```

## Repository Structure

```text
product-development/
├── README.md                              <- public consumer documentation
├── plugin.json                            <- GitHub Copilot CLI plugin manifest
├── .claude-plugin/
│   ├── plugin.json                        <- Claude-compatible plugin manifest
│   └── marketplace.json                   <- repository marketplace metadata
├── .codex-plugin/
│   └── plugin.json                        <- Codex plugin manifest
├── .github/plugin/
│   └── marketplace.json                   <- Copilot marketplace metadata
├── gemini-extension.json                  <- Gemini/Antigravity metadata
├── package.json                           <- Pi/npm metadata
├── agents/shared/                         <- thin shared agent wrappers
├── commands/shared/                       <- thin shared command wrappers
├── docs/
│   ├── compatibility/                     <- harness support and hook policy
│   └── development.md                     <- this file
├── skills/product-development/
│   ├── SKILL.md                           <- canonical agent instructions
│   ├── docs/METHODOLOGY.md                <- specification evolution strategies
│   ├── references/                        <- workflow reference material
│   ├── scripts/init.sh                    <- project initialization script
│   ├── templates/                         <- generated product-doc templates
│   └── tests/init.bats                    <- init script tests
└── tests/plugin-package.bats              <- package and adapter validation
```

Reference files are loaded by the agent only when it enters the corresponding
workflow, keeping context focused. The `phase-*` reference filenames remain for
compatibility.
