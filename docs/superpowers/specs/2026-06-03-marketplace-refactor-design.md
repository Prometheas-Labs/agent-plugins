# Prometheas Labs Marketplace Refactor Design

## Goal

Refactor this repository from a single Product Development plugin package into the Prometheas Labs agent plugin marketplace.

The marketplace should initially expose one plugin, `product-development`, but the repository should be framed and structured so additional Prometheas Labs plugins can be added later without changing the consumer marketplace name.

## Decisions

- The canonical repository name is `Prometheas-Labs/agent-plugins`.
- The marketplace name is `prometheas-labs`.
- The plugin name remains `product-development`.
- Public install docs should use `product-development@prometheas-labs`.
- Root files describe and validate the marketplace.
- Plugin package metadata and implementation live under `plugins/product-development/`.
- Old root install paths should not be presented as supported consumer paths.
- The product-development methodology remains owned by the plugin skill tree.
- No lifecycle hooks are added in this refactor.

## Selected Approach

Use a one-PR mechanical marketplace refactor.

The root repository becomes the marketplace/catalog package:

```text
agent-plugins/
  README.md
  .agents/plugins/marketplace.json
  .claude-plugin/marketplace.json
  .github/plugin/marketplace.json
  docs/
  tests/marketplace-package.bats
  plugins/product-development/
```

The Product Development plugin becomes a complete package under `plugins/product-development/`:

```text
plugins/product-development/
  plugin.json
  package.json
  gemini-extension.json
  .codex-plugin/plugin.json
  .claude-plugin/plugin.json
  agents/
  commands/
  skills/product-development/
  tests/
```

This keeps marketplace concerns separate from plugin concerns while preserving existing methodology ownership.

## Alternatives Considered

### Keep Repo Root As Plugin Package

This is the smallest file move, but it preserves the current conceptual mismatch: one repo acts as both marketplace and plugin package. It also keeps awkward install names such as `product-development@prometheas-product-development`.

Rejected.

### Add Marketplace Metadata Without Moving Plugin Package

This would create root marketplace manifests that point back at the same root. It is less disruptive, but future plugins would force another structural migration and tests would have to distinguish root-as-marketplace from root-as-plugin.

Rejected.

### Move Product Development Under `plugins/product-development`

This matches the long-term marketplace model. It makes source paths explicit for Codex, Claude Code, and GitHub Copilot CLI. It also gives tests a clean boundary: root validates marketplace metadata; plugin package tests validate plugin metadata and methodology routing.

Selected.

## Source Of Truth Rule

Marketplace manifests and root documentation expose plugins. They must not duplicate Product Development methodology.

Canonical methodology remains under:

```text
plugins/product-development/skills/product-development/
```

Thin command wrappers and agent wrappers may route users to the canonical skill. They may not restate the full Foundation Gate, Constitution, Vision, PRD, TRD, user-story, scenario, or acceptance workflow.

If a methodology rule changes, the change belongs in the canonical skill tree or its references, not in marketplace metadata or adapter wrappers.

## Repository Changes

### Root Marketplace

Root README should present the repository as the Prometheas Labs agent plugin marketplace. It should lead with consumer install commands:

```bash
codex plugin marketplace add Prometheas-Labs/agent-plugins --ref main
codex plugin add product-development@prometheas-labs
```

```bash
claude plugin marketplace add --scope user Prometheas-Labs/agent-plugins@main
claude plugin install product-development@prometheas-labs
```

```bash
copilot plugin marketplace add Prometheas-Labs/agent-plugins
copilot plugin install product-development@prometheas-labs
```

Root marketplace manifests should all name `prometheas-labs` and expose `product-development` from `plugins/product-development` using each harness's expected source-path shape.

### Product Development Plugin Package

Move the current plugin files into `plugins/product-development/`:

- `plugin.json`
- `package.json`
- `gemini-extension.json`
- `.codex-plugin/plugin.json`
- `.claude-plugin/plugin.json`
- `agents/shared/`
- `commands/shared/`
- `skills/product-development/`

Update manifest paths so they remain relative to the plugin package root.

### Documentation

Update development docs to cover:

- marketplace maintenance at repo root
- plugin package development under `plugins/product-development/`
- local checkout marketplace installs
- harness-specific validation commands
- source-of-truth boundary between marketplace/adapters and canonical skill tree

Update compatibility docs to describe the marketplace repo framing and to avoid claiming runtime support that is not smoke-tested.

Update presentation or demo material if it remains in the repository.

### Tests

Replace or refactor `tests/plugin-package.bats` into marketplace-aware validation.

The root test should validate:

- root marketplace manifests exist
- marketplace names equal `prometheas-labs`
- each marketplace exposes `product-development`
- each marketplace source points to `plugins/product-development`
- root docs use `Prometheas-Labs/agent-plugins`
- root docs use `product-development@prometheas-labs`
- historical root install paths are not primary supported docs
- no lifecycle hook declarations are introduced

The plugin package test should validate:

- plugin manifests exist under `plugins/product-development/`
- plugin manifests name `product-development`
- manifest paths point to the moved skill tree
- shared commands and agents route to the canonical skill
- adapter files do not duplicate methodology headings

Existing init-script tests should run from:

```bash
plugins/product-development/skills/product-development/tests/init.bats
```

## Validation

Minimum local validation:

```bash
nix develop -c bats tests/marketplace-package.bats
nix develop -c bats plugins/product-development/skills/product-development/tests/init.bats
git diff --check
```

Harness smoke tests should use ephemeral config homes. Notes must distinguish marketplace registration, plugin install, and runtime component loading. Runtime support should not be claimed unless the harness actually loads the relevant component.

## Out Of Scope

- Implementing lifecycle hooks.
- Adding plugins beyond `product-development`.
- Rewriting Product Development methodology.
- Publishing to a curated third-party marketplace.
- Maintaining old root plugin install paths as supported public setup.
