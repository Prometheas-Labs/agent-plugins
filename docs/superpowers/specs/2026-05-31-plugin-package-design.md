# Product Development Plugin Package Design

## Goal

Refactor the product-development skill repository from a skills-only package into a canonical plugin package that can be installed or adapted across Claude Code, Codex, GitHub Copilot CLI, Gemini/Antigravity, Pi, and OMP.

The first implementation should optimize for one canonical package. It should also leave clear seams for per-harness adapters in later work without duplicating the product-development methodology.

Compatibility claims must be tiered. V1 should only claim "supported" for a harness when there is a reproducible local load or validation check. Otherwise, the harness should be marked as "manifest prepared" or "documented adapter only."

## Current Context

The repository currently ships one canonical skill:

- `skills/product-development/SKILL.md`
- `skills/product-development/references/`
- `skills/product-development/scripts/init.sh`
- `skills/product-development/templates/`
- `skills/product-development/tests/init.bats`

The current repo does not ship plugin manifests, custom agent definitions, slash-command wrappers, marketplace metadata, or lifecycle hooks. It should remain installable as a plain Agent Skill while the plugin package is added.

## Selected Approach

Use a canonical plugin package at the repository root.

The first refactor should add native manifests and thin adapter surfaces around the existing skill tree. It should not move the product-development workflow into harness-specific files.

This is sensible because current harness support converges most strongly around Agent Skills-style `SKILL.md` directories. Commands, custom agents, and hooks are less uniform:

- Skills are the most portable capability across the target harnesses.
- Slash commands are useful, but their file formats and runtime support differ.
- Custom agents are widely available, but frontmatter and security constraints differ.
- Lifecycle hooks are powerful and high-risk, but schemas and trust models differ substantially.

## Source Of Truth Rule

The whole `skills/product-development/` tree owns the product-development methodology.

This includes:

- `skills/product-development/SKILL.md`
- `skills/product-development/references/`
- `skills/product-development/docs/`
- `skills/product-development/templates/`
- `skills/product-development/scripts/`
- `skills/product-development/tests/`

The methodology includes:

- Foundation Gate behavior
- Product Constitution workflow
- Product Vision workflow
- PRD, TRD, user-story, scenario, and acceptance-criteria workflows
- approval gates
- artifact locations
- review and validation rules

Manifests, commands, agents, and harness adapters may only:

- declare package metadata
- point to canonical skill paths
- route users into a workflow
- summarize which entrypoint to use

They must not:

- redefine lifecycle stages
- duplicate Foundation Gate rules
- duplicate PRD, TRD, user-story, or scenario instructions
- create harness-specific versions of the methodology

For example, a `commands/write-prd.md` file may say:

```markdown
Use the product-development skill. Run the Requirements workflow for the current feature. Respect all approval gates from the skill.
```

It must not contain a full PRD process. If a product-development rule changes, the change should happen in the canonical skill or references, not in adapter files.

## Package Architecture

The v1 package should use this target shape:

```text
repo-root/
  plugin.json
  .claude-plugin/plugin.json
  .codex-plugin/plugin.json
  gemini-extension.json
  package.json
  .claude-plugin/marketplace.json
  marketplace.json

  skills/product-development/
    SKILL.md
    references/
    scripts/
    templates/
    tests/

  agents/
    shared/
      product-researcher.md
      spec-reviewer.md
      plan-reviewer.md
      implementation-auditor.md
    copilot/
      spec-reviewer.agent.md

  commands/
    shared/
      init-product-docs.md
      create-constitution.md
      create-vision.md
      write-prd.md
    gemini/
      write-prd.toml

  docs/compatibility/
    harness-matrix.md
    hooks.md
```

The exact file list can be trimmed during planning if a target harness requires less for v1. The architecture principle is stable: shared content first, native manifests second, per-harness adapters only when needed.

## V1 Support Matrix

V1 should distinguish support level from aspiration:

| Harness | V1 status | Manifest | Commands | Agents | Validation expectation |
| --- | --- | --- | --- | --- | --- |
| Claude Code | supported when locally load-tested | `.claude-plugin/plugin.json` | Markdown routing wrappers if accepted by Claude plugin command discovery, otherwise skill-only | shared Markdown agents | `claude --plugin-dir` or equivalent local plugin load succeeds |
| Codex | supported when plugin install/list is validated | `.codex-plugin/plugin.json` | skill-only unless Codex supports custom command import for the current build | documented adjacent config only | `codex plugin` local install/list detects the plugin and skill |
| GitHub Copilot CLI | supported only if root `plugin.json` validates | `plugin.json` | root plugin command format only if current CLI accepts it; otherwise documented adapter only | `.agent.md` wrappers when used | `copilot plugin` validation/install accepts the root package |
| Gemini/Antigravity | manifest prepared unless local extension validation runs | `gemini-extension.json` | TOML command files only | preview; shared agents only if current runtime loads them | `gemini extensions link/install` loads manifest and declared paths |
| Pi | manifest prepared | `package.json` `pi` metadata | prompt-template metadata only if current Pi docs match paths | not first-class in v1 | package metadata resolves skill paths |
| OMP | smoke-test-required | Claude-compatible marketplace/plugin files and/or `package.json` `omp` metadata | only if runtime smoke test passes | only if runtime smoke test passes | OMP install/link resolves the skill path |

If a validation command cannot be run during implementation, the harness must be documented as "manifest prepared" or "documented adapter only," not "supported."

## Components

### Canonical Skill

Keep `skills/product-development/` as the core package content.

Existing references, scripts, templates, and tests should stay under this skill unless a later implementation plan identifies a concrete packaging reason to move them.

### Manifests

Add root-level native manifests where current harnesses support them:

- `plugin.json` for GitHub Copilot CLI plugin installation.
- `.claude-plugin/plugin.json` for Claude Code and Claude-compatible marketplace consumers.
- `.codex-plugin/plugin.json` for Codex plugin installation.
- `gemini-extension.json` for Gemini/Antigravity extension loading.
- `package.json` for Pi package metadata and future npm distribution.
- `.claude-plugin/marketplace.json` only if Claude/OMP marketplace distribution is in scope for the implementation.
- `marketplace.json` only if Copilot marketplace distribution is in scope for the implementation.

Manifest paths should point at shared directories instead of copied harness-specific trees.

Marketplace catalogs are not plugin manifests. V1 may include marketplace catalog files only when their file locations and source paths are explicit for the target harness. Curated or public marketplace submission remains out of scope.

### Commands

Add thin command wrappers only where they improve ergonomics and where the target harness supports the file format.

Command wrappers should route to the canonical skill. They should not explain the full workflow. Candidate commands:

- `init-product-docs`
- `create-constitution`
- `create-vision`
- `write-prd`

Markdown command wrappers are not universal. Gemini/Antigravity command wrappers require TOML. Copilot and Claude command discovery should be validated against their current plugin behavior before command support is claimed.

If command validation cannot run in v1, ship skill-only support for that harness and document the command adapter as future work.

### Agents

Add focused custom agents only for bounded support tasks:

- `product-researcher`
- `spec-reviewer`
- `plan-reviewer`
- `implementation-auditor`

Agents should help gather information, review artifacts, or audit implementation plans. They should not own lifecycle rules or duplicate workflow steps from the skill.

Agent definitions should start as shared prompt bodies plus the thinnest harness wrappers needed for validated support. For example, Copilot may require `.agent.md` filenames while Claude may accept `agents/*.md`. Gemini subagents are preview and should not be claimed as supported without a runtime smoke test.

### Hooks

Do not ship runtime hooks in v1.

It is not too early to document hook intent, but it is too early to add executable hook placeholders. Empty hook files would create security review burden and false confidence.

V1 should include documentation only:

- `docs/compatibility/hooks.md`
- hook capability notes inside `docs/compatibility/harness-matrix.md`

V1 should not include:

- `hooks/hooks.json`
- `hooks.json`
- `hooks/scripts/*`
- manifest hook declarations
- any other default hook path that a target harness auto-loads

## Data Flow

Practical flow:

1. A user installs or links this repository as a plugin or extension.
2. The harness reads its native manifest.
3. The manifest points to shared `skills/`, agents, and commands paths where supported.
4. The user invokes the product-development skill directly or through a thin command wrapper.
5. The canonical skill loads its own references, scripts, and templates.

Adapters route users into the methodology. They do not own the methodology.

Future per-harness packages can be generated or hand-authored from this canonical tree if real divergence appears.

## Validation Plan

Add lightweight validation before adding complex runtime tests.

Automated checks should verify:

- JSON manifests parse.
- TOML manifests or commands parse if added.
- Manifest-declared paths exist.
- Adapter files stay thin and do not duplicate lifecycle content.
- Runtime hook files are absent in v1, including `hooks/hooks.json`, root `hooks.json`, hook scripts, and manifest hook declarations.
- Existing initialization tests still pass.

The source-of-truth guard should flag adapter drift with deterministic rules:

- Adapter files must stay below a documented line or word limit unless explicitly allowlisted.
- Adapter files must not contain lifecycle headings such as `Foundation Gate`, `Product Constitution`, `Product Vision`, `Requirements`, `User Stories`, `Scenarios`, or `TRD` as Markdown section headings.
- Adapter files must not contain numbered lifecycle procedures.
- Adapter files must not copy multi-line blocks from canonical files under `skills/product-development/`.
- Manifest path checks must ensure adapters point at canonical files instead of copied harness-specific methodology.

Manual smoke tests after implementation:

- Claude Code: local plugin loads and exposes the skill and agents.
- Codex: plugin install/list detects the plugin and skill.
- GitHub Copilot CLI: plugin manifest is accepted where available, with skill and agents discoverable where supported.
- Gemini/Antigravity: extension link/install loads the skill; command support requires TOML command validation.
- Pi: package metadata resolves the skill path.
- OMP: marketplace or package install resolves the skill path; custom agents and commands are smoke-tested because OMP is moving quickly.

## Risks and Edge Cases

- Harness support is not uniform. Skills are portable, but commands, agents, and hooks need per-harness care.
- Claude, Copilot, and OMP have overlapping plugin/marketplace formats, but behavior is not identical.
- Codex plugins support skills and hooks, but custom agents are currently better treated as adjacent configuration rather than core plugin manifest content.
- Gemini CLI support is active, but Google announced a transition for unpaid and Google One users to Antigravity CLI on June 18, 2026.
- Pi package support is strong for skills, prompts, extensions, and themes, but custom agents are not a core first-class primitive in the same way as Claude or OMP.
- OMP is promising but fast-moving. Treat OMP marketplace and runtime behavior as smoke-test-required.
- Hook behavior is security-sensitive. Deferring runtime hooks avoids shipping unreviewed executable lifecycle behavior.
- Root package and marketplace layouts differ by harness. The implementation must avoid implying that one `marketplace.json` location is universal.
- Manifest versions should be explicit once plugin manifests are introduced, because some harnesses cache or update plugins by manifest version rather than only by git SHA.

## External Research Notes

Primary sources reviewed:

- Claude Code plugins reference: https://code.claude.com/docs/en/plugins-reference
- Claude Code plugins announcement: https://claude.com/blog/claude-code-plugins
- Codex plugin build docs: https://developers.openai.com/codex/plugins/build
- Codex skills docs: https://developers.openai.com/codex/skills
- GitHub Copilot CLI plugins: https://docs.github.com/copilot/concepts/agents/copilot-cli/about-cli-plugins
- GitHub Copilot plugin reference: https://docs.github.com/en/copilot/reference/cli-plugin-reference
- Gemini CLI extension reference: https://geminicli.com/docs/extensions/reference/
- Gemini CLI custom commands: https://google-gemini.github.io/gemini-cli/docs/cli/custom-commands.html
- Google Gemini CLI to Antigravity transition: https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli
- Pi packages: https://pi.dev/docs/latest/packages
- Pi skills: https://pi.dev/docs/latest/skills
- OMP marketplace docs: https://raw.githubusercontent.com/can1357/oh-my-pi/main/docs/marketplace.md
- OMP plugin manager plumbing: https://raw.githubusercontent.com/can1357/oh-my-pi/main/docs/plugin-manager-installer-plumbing.md

## Out Of Scope For V1

- Runtime hook implementation.
- Generated per-harness package directories.
- Hosted ChatGPT app submission.
- Official marketplace submission to any curated marketplace.
- MCP server implementation.
- Claims of install/load support for a harness that has not been locally validated.
