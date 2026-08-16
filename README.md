# Prometheas Labs Agent Plugins

This repository is the Prometheas Labs agent plugin marketplace. It hosts a
growing set of portable, vendor-neutral agent plugins and is structured to add
more over time. Each plugin owns its own methodology; marketplace manifests and
adapter wrappers expose plugins without duplicating their content.

`branch-guard` is the marketplace's first hook-bearing plugin; see
`docs/compatibility/hooks.md` for the policy governing hook-bearing plugins.
`product-development` and `delivery-engineering` remain hook-free.

For detailed harness compatibility, see
`docs/compatibility/harness-matrix.md`. For development setup and local checkout
installs, see `docs/development.md`.

## Plugins

| Plugin | Scope | Docs |
| --- | --- | --- |
| `product-development` | Product definition: from constitution and vision through PRD/TRD, user stories, scenarios, and the implementation plan. | [`plugins/product-development/README.md`](plugins/product-development/README.md) |
| `delivery-engineering` | Engineering delivery: turning an approved plan into merged, shipped, and coordinated work. | [`plugins/delivery-engineering/README.md`](plugins/delivery-engineering/README.md) |
| `branch-guard` | Nudges agents away from directly editing a repository's protected branch. | [`plugins/branch-guard/README.md`](plugins/branch-guard/README.md) |

`product-development` and `delivery-engineering` meet at one hand-off: `product-development` ends at an approved
implementation plan; `delivery-engineering` starts there.

## Getting Started

Register the marketplace once, then install the plugins you want.

<details>
<summary>Codex</summary>

```bash
codex plugin marketplace add Prometheas-Labs/agent-plugins --ref main
codex plugin add product-development@prometheas-labs
codex plugin add branch-guard@prometheas-labs
codex plugin add delivery-engineering@prometheas-labs
```

For private forks, pinned mirrors, or development from a local checkout, see
`docs/development.md#installing-from-a-local-checkout`.

</details>

<details>
<summary>Claude Code</summary>

```bash
claude plugin marketplace add --scope user Prometheas-Labs/agent-plugins@main
claude plugin install product-development@prometheas-labs
claude plugin install branch-guard@prometheas-labs
claude plugin install delivery-engineering@prometheas-labs
```

For private forks, pinned mirrors, or development from a local checkout, see
`docs/development.md#installing-from-a-local-checkout`.

</details>

<details>
<summary>GitHub Copilot CLI</summary>

```bash
copilot plugin marketplace add Prometheas-Labs/agent-plugins
copilot plugin install product-development@prometheas-labs
copilot plugin install branch-guard@prometheas-labs
copilot plugin install delivery-engineering@prometheas-labs
```

`branch-guard`'s hooks require an extra manual step for Copilot CLI; see
`plugins/branch-guard/README.md`.

For private forks, pinned mirrors, or development from a local checkout, see
`docs/development.md#installing-from-a-local-checkout`.

</details>

<details>
<summary>Plain Agent Skill</summary>

Each plugin's skills are portable and can be installed on their own via
[skills.sh](https://skills.sh):

```bash
npx skills add product-development
```

Skills land in `.agents/skills/` and work with compatible skill-based harnesses.
This path does not install plugin marketplace metadata, shared command wrappers,
or shared agent wrappers.

</details>

Plain Agent Skill installation via `skills.sh` remains available as a secondary
compatibility path for canonical skills only; it does not install marketplace
metadata or adapter wrappers. Gemini/Antigravity, Pi, and OMP manifests are
included so packages are ready for adapter-specific work. See
`docs/compatibility/harness-matrix.md` before claiming runtime support for those
harnesses.

## Marketplace Contents

The marketplace exposes each plugin through three metadata files and one package
directory per plugin.

- `.agents/plugins/marketplace.json` - Codex marketplace metadata.
- `.claude-plugin/marketplace.json` - Claude Code marketplace metadata.
- `.github/plugin/marketplace.json` - GitHub Copilot CLI marketplace metadata.
- `plugins/product-development/` - Product Development plugin package.
- `plugins/branch-guard/` - branch-guard plugin package.
- `plugins/delivery-engineering/` - Delivery Engineering plugin package.

Each plugin package contains its own plugin manifests and skill tree. Manifests
that declare component paths route back into that plugin's `skills/` tree, which
remains the source of truth. Metadata-only manifests are documented in the
compatibility matrix and are not treated as proven runtime routing.

The `branch-guard` plugin package (see `plugins/branch-guard/README.md`)
directs agents away from directly editing a repository's protected branch:
Claude Code and Copilot CLI show the harness's own approval prompt, while
Codex adds a model-visible reminder and lets the action proceed. It is an
MVP-scoped best-practices nudge, not a security boundary, implemented in
POSIX `sh` with no runtime dependency beyond `git`.

Local marketplace install smoke tests have passed for Codex, Claude Code, and
GitHub Copilot CLI at the skill-package level. Those tests prove a package can be
registered and installed through those harnesses; they do not prove runtime
loading for shared command wrappers, shared agent wrappers, or hooks.

## Developing These Plugins

Development setup, local checkout installation, test commands, and repository
structure are documented in `docs/development.md`.
