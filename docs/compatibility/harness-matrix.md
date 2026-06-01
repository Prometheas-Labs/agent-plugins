# Harness Compatibility Matrix

V1 keeps `skills/product-development/` as the canonical package surface. Plugin
manifests route supported harnesses to that skill tree and do not duplicate the
methodology.

V1 includes shared Markdown command wrappers under `commands/shared/` and shared
agent wrappers under `agents/shared/`. Harness-specific command and agent support
remains adapter- and validation-tiered. Each harness load path still requires
proof before a runtime support claim.

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
| Plain Agent Skill | supported | skills/product-development/SKILL.md | supported | shared wrappers | documented adapter only | bats skills/product-development/tests/init.bats | Canonical skill layout remains installable without plugin manifests; shared command wrappers are optional entrypoints. |
| Claude Code | supported | .claude-plugin/plugin.json | install validated | shared wrappers | documented adapter only | bats tests/plugin-package.bats + Claude project marketplace smoke test | Project marketplace install succeeded for the canonical skill. Shared command wrappers currently validate with Claude frontmatter warnings; runtime command loading is not claimed. |
| Codex | supported | .codex-plugin/plugin.json | install validated | shared wrappers | documented adapter only | bats tests/plugin-package.bats + Codex local marketplace smoke test | Home personal and project marketplace installs succeeded. Codex manifest keeps `skills` as `./skills/`; no hooks, MCP servers, apps, or command declarations are declared. |
| GitHub Copilot CLI | supported | plugin.json | install validated | shared wrappers | documented adapter only | bats tests/plugin-package.bats + Copilot local marketplace smoke test | Marketplace install succeeded and registered one skill. Direct local path installs still work but are deprecated by the CLI; runtime command loading is not claimed. |
| Gemini/Antigravity | manifest prepared | gemini-extension.json | manifest prepared | documented adapter only | documented adapter only | bats tests/plugin-package.bats | Extension manifest uses metadata only; no context file, TOML commands, MCP servers, hooks, or agents are declared. |
| Pi | manifest prepared | package.json | manifest prepared | shared wrappers | documented adapter only | bats tests/plugin-package.bats | `pi.skills` points to the canonical skill directory; shared command wrappers exist outside package metadata and no npm lifecycle scripts are allowed. |
| OMP | smoke-test-required | .claude-plugin/plugin.json / package.json | smoke-test-required | smoke-test-required | smoke-test-required | manual OMP install/link smoke test | OMP compatibility remains provisional until a live install/link smoke test proves current runtime behavior. |

## Local Marketplace Layouts

These layouts were smoke-tested in ephemeral projects. They validate marketplace
registration and skill installation only; they do not validate automatic
project-local discovery or runtime execution of command, agent, or hook surfaces.

| harness | marketplace manifest | plugin directory | source path form | notes |
| --- | --- | --- | --- | --- |
| Codex | `.agents/plugins/marketplace.json` | `plugins/product-development/` | `{"source":"local","path":"./plugins/product-development"}` | Pass the project root to `codex plugin marketplace add`; the source path resolves from that root. |
| Claude Code | `.claude-plugin/marketplace.json` | `plugins/product-development/` | `"./plugins/product-development"` | `claude plugin validate` passes with warnings for shared command wrappers that lack Claude command frontmatter. |
| GitHub Copilot CLI | `.github/plugin/marketplace.json` | `plugins/product-development/` | `"./plugins/product-development"` | Marketplace install is preferred; direct local path installs are currently accepted but deprecated by the CLI. |
