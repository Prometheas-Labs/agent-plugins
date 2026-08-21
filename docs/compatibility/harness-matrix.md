# Harness Compatibility Matrix

This repository is the Prometheas Labs agent plugin marketplace. The root
marketplace exposes `product-development@prometheas-labs` from
`plugins/product-development/`.

Marketplace manifests expose the plugin package. Plugin manifests inside
`plugins/product-development/` route supported harnesses to the canonical skill
tree and do not duplicate the methodology.

V1 includes shared Markdown command wrappers under
`plugins/product-development/commands/shared/` and shared agent wrappers under
`plugins/product-development/agents/shared/`. Harness-specific command and agent
support remains adapter- and validation-tiered. Each harness load path still
requires proof before a runtime support claim.

## Support Tiers

- `supported`: local load, validation, or local marketplace install passes for the harness.
- `manifest prepared`: manifest exists and declared paths validate, but no runtime load was proven.
- `documented adapter only`: docs explain future adapter work, with no runtime support claim.
- `smoke-test-required`: likely support, but the target is too unstable to claim without a live test.

## Capability States

- `shared wrappers`: thin shared Markdown wrappers exist, but harness-specific command or agent loading was not proven.
- `install validated`: local marketplace install accepted the package and registered the canonical skill; runtime invocation beyond skill loading was not proven.

## V1 Contract

| harness | V1 support tier | manifest file | skills support | commands support | agents support | validation command | notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Plain Agent Skill | supported | `plugins/product-development/skills/product-development/SKILL.md` | supported | shared wrappers | documented adapter only | `bats plugins/product-development/skills/product-development/tests/init.bats` | Canonical skill layout remains installable without plugin manifests; shared command wrappers are optional entrypoints. |
| Claude Code | supported | `.claude-plugin/marketplace.json` + `plugins/product-development/.claude-plugin/plugin.json` | install validated | shared wrappers | documented adapter only | `bats tests/marketplace-package.bats` + Claude marketplace smoke test | Marketplace install validates the canonical skill package. Shared command wrappers currently validate with Claude frontmatter warnings; runtime command loading is not claimed. |
| Codex | supported | `.agents/plugins/marketplace.json` + `plugins/product-development/.codex-plugin/plugin.json` | install validated | shared wrappers | documented adapter only | `bats tests/marketplace-package.bats` + Codex marketplace smoke test | Codex marketplace metadata exposes `product-development@prometheas-labs`; no hooks, MCP servers, apps, or command declarations are declared. |
| GitHub Copilot CLI | supported | `.github/plugin/marketplace.json` + `plugins/product-development/plugin.json` | install validated | shared wrappers | documented adapter only | `bats tests/marketplace-package.bats` + Copilot marketplace smoke test | Marketplace install is preferred; direct local path installs are currently accepted but deprecated by the CLI. |
| Gemini/Antigravity | manifest prepared | `plugins/product-development/gemini-extension.json` | manifest prepared | documented adapter only | documented adapter only | `bats plugins/product-development/tests/plugin-package.bats` | Extension manifest uses metadata only; no context file, TOML commands, MCP servers, hooks, or agents are declared. |
| Pi | manifest prepared | `plugins/product-development/package.json` | manifest prepared | shared wrappers | documented adapter only | `bats plugins/product-development/tests/plugin-package.bats` | `pi.skills` points to the canonical skill directory; shared command wrappers exist outside package metadata and no npm lifecycle scripts are allowed. |
| OMP | smoke-test-required | `plugins/product-development/.claude-plugin/plugin.json` / `plugins/product-development/package.json` | smoke-test-required | smoke-test-required | smoke-test-required | manual OMP install/link smoke test | OMP compatibility remains provisional until a live install/link smoke test proves current runtime behavior. |

## branch-guard

`branch-guard` (`plugins/branch-guard/`) ships hook wiring for three
harnesses, implemented as POSIX `sh` scripts. It is an MVP-scoped
best-practices nudge, not a security boundary. Each row starts at
`smoke-test-required` and moves to `supported` only once a live smoke test
proves the hook is discovered, trusted, and fires against the currently
installed CLI version.

| harness | V1 support tier | manifest file | notes |
| --- | --- | --- | --- |
| Claude Code | smoke-test-required | `plugins/branch-guard/.claude-plugin/plugin.json` + `plugins/branch-guard/hooks/hooks.json` | `PreToolUse` hook, matcher on a short mutating-tool list. |
| Codex | smoke-test-required | `plugins/branch-guard/.codex-plugin/plugin.json` + `plugins/branch-guard/.codex-plugin/hooks.json` | Uses `$PLUGIN_ROOT` and an explicit `hooks` manifest field, since Codex also auto-discovers `hooks/hooks.json` (the same relative path Claude Code uses) and reads `$CLAUDE_PLUGIN_ROOT` for compatibility. Codex's `PreToolUse` does not yet implement an `ask` decision, so this adapter never sets `permissionDecision`; on a protected branch it adds a model-visible reminder via `additionalContext` and lets the action proceed, rather than blocking. |
| GitHub Copilot CLI | smoke-test-required | `plugins/branch-guard/plugin.json` + `plugins/branch-guard/copilot-hooks/preToolUse.json` | Hook config is not marketplace-installed automatically; requires manual placement under `.github/hooks/` or `~/.copilot/hooks/`, documented in the plugin README. |
| GitHub Copilot Cloud Agent | documented adapter only | none | No hook runtime attempted in V1. |
| Gemini/Antigravity | documented adapter only | `plugins/branch-guard/gemini-extension.json` | Metadata only, matching this repo's existing convention for this harness. |

## Local Marketplace Layouts

These layouts validate marketplace registration and skill installation only;
they do not validate automatic project-local discovery or runtime execution of
command, agent, or hook surfaces.

Validation notes distinguish marketplace registration, plugin installation, and
runtime component loading. Current smoke tests validate marketplace
registration and plugin installation only unless this document explicitly says
otherwise.

| harness | marketplace manifest | plugin directory | source path form | notes |
| --- | --- | --- | --- | --- |
| Codex | `.agents/plugins/marketplace.json` | `plugins/product-development/` | `{"source":"local","path":"./plugins/product-development"}` | Pass the checkout root to `codex plugin marketplace add`; the source path resolves from that root. |
| Claude Code | `.claude-plugin/marketplace.json` | `plugins/product-development/` | `"./plugins/product-development"` | `claude plugin validate` passes with warnings for shared command wrappers that lack Claude command frontmatter. |
| GitHub Copilot CLI | `.github/plugin/marketplace.json` | `plugins/product-development/` | `"./plugins/product-development"` | Marketplace install is preferred; direct local path installs are currently accepted but deprecated by the CLI. |
