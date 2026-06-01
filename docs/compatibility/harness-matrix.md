# Harness Compatibility Matrix

V1 keeps `skills/product-development/` as the canonical package surface. Plugin
manifests route supported harnesses to that skill tree and do not duplicate the
methodology.

V1 includes shared Markdown command wrappers under `commands/shared/` and shared
agent wrappers under `agents/shared/`. Harness-specific command and agent support
remains adapter- and validation-tiered. Each harness load path still requires
proof before a runtime support claim.

## Support Tiers

- `supported`: local load or validation passes for the harness.
- `manifest prepared`: manifest exists and declared paths validate, but no runtime load was proven.
- `shared wrappers`: thin shared Markdown wrappers exist, but harness-specific command loading was not proven.
- `documented adapter only`: docs explain future adapter work, with no runtime support claim.
- `smoke-test-required`: likely support, but the target is too unstable to claim without a live test.

## V1 Contract

| harness | V1 support tier | manifest file | skills support | commands support | agents support | validation command | notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Plain Agent Skill | supported | skills/product-development/SKILL.md | supported | shared wrappers | documented adapter only | bats skills/product-development/tests/init.bats | Canonical skill layout remains installable without plugin manifests; shared command wrappers are optional entrypoints. |
| Claude Code | manifest prepared | .claude-plugin/plugin.json | manifest prepared | shared wrappers | documented adapter only | bats tests/plugin-package.bats | Manifest points at the canonical skill; no Claude runtime plugin command load was proven in V1. |
| Codex | manifest prepared | .codex-plugin/plugin.json | manifest prepared | shared wrappers | documented adapter only | bats tests/plugin-package.bats | Codex manifest keeps `skills` as `./skills/`; no hooks, MCP servers, apps, or command declarations are declared. |
| GitHub Copilot CLI | manifest prepared | plugin.json | manifest prepared | shared wrappers | documented adapter only | bats tests/plugin-package.bats | Root manifest declares only current metadata and skill path; no live `copilot plugin` command validation was run. |
| Gemini/Antigravity | manifest prepared | gemini-extension.json | manifest prepared | documented adapter only | documented adapter only | bats tests/plugin-package.bats | Extension manifest uses metadata only; no context file, TOML commands, MCP servers, hooks, or agents are declared. |
| Pi | manifest prepared | package.json | manifest prepared | shared wrappers | documented adapter only | bats tests/plugin-package.bats | `pi.skills` points to the canonical skill directory; shared command wrappers exist outside package metadata and no npm lifecycle scripts are allowed. |
| OMP | smoke-test-required | .claude-plugin/plugin.json / package.json | smoke-test-required | smoke-test-required | smoke-test-required | manual OMP install/link smoke test | OMP compatibility remains provisional until a live install/link smoke test proves current runtime behavior. |
