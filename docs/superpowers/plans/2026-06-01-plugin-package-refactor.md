# Plugin Package Refactor Implementation Plan

## Context

Approved design:

- `docs/superpowers/specs/2026-05-31-plugin-package-design.md`

Current branch:

- `codex/plugin-package-refactor`

Current state:

- Repo is still skills-only except for the approved design spec.
- Canonical methodology lives under `skills/product-development/`.
- V1 must keep plain Agent Skill installability intact.
- V1 must not ship runtime hooks.

Primary rule:

The whole `skills/product-development/` tree owns methodology. Plugin manifests, commands, agents, and compatibility docs may route to the canonical skill, but must not duplicate lifecycle rules.

## Commit Strategy

Keep commits bite-sized and logically cohesive:

1. `test: add plugin package validation`
2. `feat: add plugin package manifests`
3. `docs: add plugin compatibility guidance`
4. `feat: add plugin agent wrappers`
5. `feat: add plugin command wrappers`
6. `docs: document plugin install paths`
7. `test: validate plugin package integration`

Do not squash these during implementation. Each commit should pass the relevant targeted tests before moving on.

The first commit should not be a red test-only commit. Task 1 writes the validation tests; Task 2 adds the minimal files needed to make those tests pass; then both are committed together as `test: add plugin package validation`. Later tasks add richer manifests, docs, agents, commands, and README updates in their own commits.

## Validation Commands

Use these commands throughout:

```bash
bats skills/product-development/tests/init.bats
bats tests/plugin-package.bats
git diff --check
```

If `bats` is not available in the environment, stop and report the blocker. Do not replace BATS tests with ad hoc shell checks.

## Task 1: Add Plugin Package Validation Tests

**Goal:** Write failing tests that define the plugin-package contract before adding manifests or adapters.

**Files:**

- Create: `tests/plugin-package.bats`
- Create: `tests/fixtures/adapter-drift-fixtures/` only if needed for targeted drift test fixtures

### Steps

- [ ] Create `tests/plugin-package.bats`.

The test file should cover:

1. Required manifest paths:
   - `plugin.json`
   - `.claude-plugin/plugin.json`
   - `.codex-plugin/plugin.json`
   - `gemini-extension.json`
   - `package.json`
2. Required docs:
   - `docs/compatibility/harness-matrix.md`
   - `docs/compatibility/hooks.md`
3. Canonical skill remains in place:
   - `skills/product-development/SKILL.md`
   - `skills/product-development/references/`
   - `skills/product-development/scripts/init.sh`
   - `skills/product-development/templates/`
   - `skills/product-development/tests/init.bats`
4. Runtime hooks are absent:
   - no root `hooks.json`
   - no `hooks/hooks.json`
   - no executable hook scripts under `hooks/`
5. Manifests parse as JSON where applicable.
6. Manifest-declared paths exist.
7. Adapter files stay thin:
   - command wrappers below a documented line limit
   - agent wrappers below a documented line limit
   - no adapter file has methodology headings such as `## Foundation Gate`, `## Product Constitution`, `## Product Vision`, `## Requirements`, `## User Stories`, `## Scenarios`, or `## TRD`

- [ ] Prefer BATS helper functions at the top of the file:

```bash
assert_file_exists() {
  [ -f "$1" ] || {
    echo "missing file: $1" >&2
    return 1
  }
}

assert_dir_exists() {
  [ -d "$1" ] || {
    echo "missing directory: $1" >&2
    return 1
  }
}
```

- [ ] Use `node -e 'JSON.parse(...)'` for JSON parsing if Node is available in this repo environment. If not, use `python3 -m json.tool`. Document the chosen parser in a test comment.

- [ ] Run the new tests and confirm they fail for missing manifests/docs:

```bash
bats tests/plugin-package.bats
```

Expected: FAIL because plugin package files do not exist yet.

- [ ] Do not commit this failing test-only state. Carry the test into Task 2 and commit once the minimal manifest/docs slice passes.

## Task 2: Add Minimal Plugin Manifests To Pass Validation

**Goal:** Add the minimal manifest and compatibility-doc files needed to make Task 1 validation pass without adding full adapter behavior.

**Files:**

- Create: `plugin.json`
- Create: `.claude-plugin/plugin.json`
- Create: `.codex-plugin/plugin.json`
- Create: `gemini-extension.json`
- Create: `package.json`
- Create: `docs/compatibility/harness-matrix.md`
- Create: `docs/compatibility/hooks.md`
- Modify: `tests/plugin-package.bats`

### Steps

- [ ] Add `plugin.json` for GitHub Copilot CLI compatibility.

Keep it minimal:

```json
{
  "name": "product-development",
  "version": "0.1.0",
  "description": "Product development lifecycle workflows as portable agent skills.",
  "skills": ["skills/product-development"],
  "agents": ["agents/shared"],
  "commands": ["commands/shared"]
}
```

If current Copilot CLI docs require different field names, use current docs and update the test expectations.

- [ ] Add `.claude-plugin/plugin.json`.

Keep it pointed at shared content:

```json
{
  "name": "product-development",
  "version": "0.1.0",
  "description": "Product development lifecycle workflows as portable agent skills.",
  "skills": ["skills/product-development"],
  "agents": ["agents/shared"]
}
```

- [ ] Add `.codex-plugin/plugin.json`.

Use the current Codex plugin manifest fields. At minimum, include:

```json
{
  "name": "product-development",
  "version": "0.1.0",
  "description": "Product development lifecycle workflows as portable agent skills.",
  "skills": ["skills/product-development"]
}
```

- [ ] Add `gemini-extension.json`.

Do not claim hooks. Do not declare commands until TOML command files exist.

```json
{
  "name": "product-development",
  "version": "0.1.0",
  "description": "Product development lifecycle workflows as portable agent skills."
}
```

- [ ] Add `package.json` for package metadata and future Pi/OMP compatibility.

Do not add npm dependencies.

```json
{
  "name": "agent-skill-product-development",
  "version": "0.1.0",
  "description": "Product development lifecycle workflows as portable agent skills.",
  "private": false,
  "license": "MIT",
  "keywords": [
    "agent-skill",
    "product-development",
    "pi-package"
  ],
  "pi": {
    "skills": [
      "skills/product-development"
    ]
  }
}
```

If the repository license is not MIT, use the actual existing license or omit the field until confirmed.

- [ ] Add minimal `docs/compatibility/harness-matrix.md`.

It only needs enough content to satisfy the first validation slice:

```markdown
# Harness Compatibility Matrix

V1 uses support tiers. A harness is only marked supported after local validation.
```

- [ ] Add minimal `docs/compatibility/hooks.md`.

It must state that runtime hooks are deferred and no hook config ships in V1:

```markdown
# Hook Compatibility

Runtime hooks are intentionally deferred for V1. The package must not ship `hooks.json`, `hooks/hooks.json`, hook scripts, or manifest hook declarations until a separate hook design and security review are approved.
```

- [ ] Update `tests/plugin-package.bats` to validate the exact fields that were added.

- [ ] Run:

```bash
bats tests/plugin-package.bats
git diff --check
```

Expected: PASS.

- [ ] Commit:

```bash
git add plugin.json .claude-plugin/plugin.json .codex-plugin/plugin.json gemini-extension.json package.json docs/compatibility/harness-matrix.md docs/compatibility/hooks.md tests/plugin-package.bats
git commit -m "test: add plugin package validation"
```

## Task 3: Expand Compatibility Documentation And Manifests

**Goal:** Expand the minimal docs and manifests into the full V1 compatibility contract.

**Files:**

- Modify: `docs/compatibility/harness-matrix.md`
- Modify: `docs/compatibility/hooks.md`
- Modify: `plugin.json`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.codex-plugin/plugin.json`
- Modify: `gemini-extension.json`
- Modify: `package.json`
- Modify: `tests/plugin-package.bats`

### Steps

- [ ] Expand `docs/compatibility/harness-matrix.md`.

Include a table with:

- harness
- V1 support tier
- manifest file
- skills support
- commands support
- agents support
- validation command
- notes

Use support tiers:

- `supported`: local load/install validation passes
- `manifest prepared`: manifest exists and paths validate, but no runtime load was proven
- `documented adapter only`: docs explain future work; no runtime claim
- `smoke-test-required`: likely support, but target is too unstable to claim without live test

- [ ] Expand `docs/compatibility/hooks.md`.

State:

- runtime hooks are deferred
- no hook config ships in V1
- no `hooks.json`, `hooks/hooks.json`, hook scripts, or manifest hook declarations are allowed
- future hooks require separate design, security review, and per-harness schema validation

- [ ] Expand manifests with only fields that are supported by the current target docs and validated by local tests.

- [ ] Update tests to assert docs and manifests match the expanded compatibility contract.

- [ ] Run:

```bash
bats tests/plugin-package.bats
git diff --check
```

Expected: PASS.

- [ ] Commit:

```bash
git add docs/compatibility/harness-matrix.md docs/compatibility/hooks.md plugin.json .claude-plugin/plugin.json .codex-plugin/plugin.json gemini-extension.json package.json tests/plugin-package.bats
git commit -m "feat: add plugin package manifests"
```

## Task 4: Add Shared Agent Wrappers

**Goal:** Add focused agent prompts without duplicating methodology.

**Files:**

- Create: `agents/shared/product-researcher.md`
- Create: `agents/shared/spec-reviewer.md`
- Create: `agents/shared/plan-reviewer.md`
- Create: `agents/shared/implementation-auditor.md`
- Create: `agents/copilot/spec-reviewer.agent.md` only if needed for Copilot format validation
- Modify: `tests/plugin-package.bats`

### Steps

- [ ] Add shared agent prompt files.

Each agent should:

- have a short name and description
- tell the harness to consult `skills/product-development/SKILL.md`
- define a bounded job
- return findings, not make edits by default
- avoid lifecycle methodology headings

Example body pattern:

```markdown
---
name: spec-reviewer
description: Review product-development specs for gaps, contradictions, and drift from canonical skill guidance.
---

Review the provided product-development artifact.

Use `skills/product-development/SKILL.md` and files under `skills/product-development/` as the canonical methodology.

Return findings ordered by severity. Do not rewrite the methodology. Do not duplicate lifecycle rules.
```

- [ ] Add Copilot `.agent.md` wrapper only if current validation expects it. Keep it a wrapper around the shared prompt, not a second methodology copy.

- [ ] Extend tests:
  - agent files exist
  - agent files stay under line limit
  - agent files do not contain banned methodology headings

- [ ] Run:

```bash
bats tests/plugin-package.bats
git diff --check
```

Expected: PASS.

- [ ] Commit:

```bash
git add agents tests/plugin-package.bats
git commit -m "feat: add product development agent wrappers"
```

## Task 5: Add Thin Command Wrappers

**Goal:** Add convenience command wrappers that route into the canonical skill.

**Files:**

- Create: `commands/shared/init-product-docs.md`
- Create: `commands/shared/create-constitution.md`
- Create: `commands/shared/create-vision.md`
- Create: `commands/shared/write-prd.md`
- Create: `commands/gemini/write-prd.toml` only if using Gemini command support in V1
- Modify: `tests/plugin-package.bats`

### Steps

- [ ] Add Markdown command wrappers under `commands/shared/`.

Each wrapper must be short. Example:

```markdown
Use the product-development skill at `skills/product-development/SKILL.md`.

Run the Requirements workflow for the current feature. Respect all approval gates from the skill.
```

- [ ] Add Gemini TOML commands only for commands that will be validated in V1.

Example shape, adjusted to current Gemini CLI docs:

```toml
description = "Route to the product-development PRD workflow"
prompt = """
Use the product-development skill at skills/product-development/SKILL.md.
Run the Requirements workflow for the current feature. Respect all approval gates from the skill.
"""
```

- [ ] Extend tests:
  - command files exist
  - Markdown command wrappers stay under line limit
  - TOML command files parse if present
  - no command wrapper contains banned methodology headings

- [ ] Run:

```bash
bats tests/plugin-package.bats
git diff --check
```

Expected: PASS.

- [ ] Commit:

```bash
git add commands tests/plugin-package.bats
git commit -m "feat: add product development command wrappers"
```

## Task 6: Update README Install And Development Docs

**Goal:** Make the repo documentation match the new plugin package while preserving existing skill install guidance.

**Files:**

- Modify: `README.md`
- Modify: `tests/plugin-package.bats` if README assertions are added

### Steps

- [ ] Update `README.md` to state:
  - the repo remains installable as a plain Agent Skill
  - the repo also contains plugin-package manifests
  - support levels are documented in `docs/compatibility/harness-matrix.md`
  - hooks are intentionally deferred
  - adapters route to `skills/product-development/` and do not own methodology

- [ ] Keep the existing BATS test instructions for init script coverage.

- [ ] Add plugin package validation command:

```bash
bats tests/plugin-package.bats
```

- [ ] Run:

```bash
bats skills/product-development/tests/init.bats
bats tests/plugin-package.bats
git diff --check
```

Expected: PASS.

- [ ] Commit:

```bash
git add README.md tests/plugin-package.bats
git commit -m "docs: document plugin package usage"
```

## Task 7: Final Verification And Cleanup

**Goal:** Verify the whole branch and make any small doc/test corrections as a final cohesive commit if needed.

**Files:**

- Modify only files that fail final validation.

### Steps

- [ ] Run full local validation:

```bash
bats skills/product-development/tests/init.bats
bats tests/plugin-package.bats
git diff --check
git status --short
```

Expected:

- both BATS suites pass
- no whitespace errors
- working tree clean, unless final fixes are needed

- [ ] If any manifest parser or path validation fails, fix the exact manifest or test expectation.

- [ ] If fixes were needed, commit:

```bash
git add <changed-files>
git commit -m "test: validate plugin package integration"
```

- [ ] Review commit history:

```bash
git log --oneline origin/main..HEAD
```

Expected: bite-sized commits matching the commit strategy.

## Review Checkpoints

Request review after:

1. Task 2: manifests and validation pass.
2. Task 5: agents and commands exist, drift guard passes.
3. Task 7: final branch verification passes.

Reviews should look for:

- methodology duplicated outside `skills/product-development/`
- support claims without validation
- accidental hook files
- manifest paths pointing at copied adapters instead of canonical content
- commands or agents growing into hidden workflow definitions

## Non-Goals

- Runtime hook implementation.
- Public marketplace submission.
- Hosted ChatGPT app submission.
- MCP server implementation.
- Per-harness generated package trees.
- Claiming support for any harness that was not locally validated.
