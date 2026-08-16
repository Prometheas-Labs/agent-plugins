# Development

This document covers marketplace maintenance at the repository root and plugin
package development under `plugins/`. The public README is focused on plugin
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

## Marketplace Maintenance

Root marketplace files identify the Prometheas Labs marketplace and expose
plugin packages. They should stay metadata-only:

- `.agents/plugins/marketplace.json`
- `.claude-plugin/marketplace.json`
- `.github/plugin/marketplace.json`
- `tests/marketplace-package.bats`

Do not duplicate Product Development methodology in marketplace metadata or
root docs. Methodology belongs in
`plugins/product-development/skills/product-development/`.

## Plugin Package Development

Each plugin package lives under `plugins/<name>/`. Plugin manifests, any command
or agent wrappers, the canonical skill tree, and plugin package tests are
developed from that directory.

The Product Development plugin package lives under
`plugins/product-development/`. It ships shared command wrappers, shared agent
wrappers, and the canonical `product-development` skill tree.

The Delivery Engineering plugin package lives under
`plugins/delivery-engineering/`. It ships the `review-gated-implementation-loop`
skill tree, whose `resources/` directory is an Open Knowledge Format bundle.

When plugin behavior changes, update the canonical skill tree first. Shared
command and agent wrappers should remain thin routing entrypoints.

## Installing From A Local Checkout

Use local checkout installs for development. Register the checkout root as the
marketplace, then install `product-development@prometheas-labs`.

### Codex

```bash
codex plugin marketplace add "$PWD"
codex plugin add product-development@prometheas-labs
```

### Claude Code

```bash
claude plugin validate "$PWD"
claude plugin marketplace add --scope project "$PWD"
claude plugin install --scope project product-development@prometheas-labs
```

### GitHub Copilot CLI

```bash
copilot plugin marketplace add "$PWD"
copilot plugin install product-development@prometheas-labs
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
./plugins/product-development/skills/product-development/scripts/init.sh <project-root> [options]

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

```bash
nix develop -c bats tests/marketplace-package.bats
nix develop -c bats plugins/product-development/tests/plugin-package.bats
nix develop -c bats plugins/product-development/skills/product-development/tests/init.bats
nix develop -c bats plugins/delivery-engineering/tests/plugin-package.bats
git diff --check
```

## Repository Structure

```text
agent-plugins/
├── README.md
├── .agents/plugins/marketplace.json
├── .claude-plugin/marketplace.json
├── .github/plugin/marketplace.json
├── docs/
├── tests/marketplace-package.bats
└── plugins/
    ├── product-development/
    │   ├── plugin.json
    │   ├── package.json
    │   ├── gemini-extension.json
    │   ├── .codex-plugin/plugin.json
    │   ├── .claude-plugin/plugin.json
    │   ├── README.md
    │   ├── agents/shared/
    │   ├── commands/shared/
    │   ├── skills/product-development/
    │   └── tests/plugin-package.bats
    └── delivery-engineering/
        ├── plugin.json
        ├── package.json
        ├── gemini-extension.json
        ├── .codex-plugin/plugin.json
        ├── .claude-plugin/plugin.json
        ├── README.md
        ├── skills/review-gated-implementation-loop/
        └── tests/plugin-package.bats
```

Reference files are loaded by the agent only when it enters the corresponding
workflow, keeping context focused. The `phase-*` reference filenames remain for
compatibility.
