# Marketplace Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Promote the repository into the `prometheas-labs` marketplace while keeping `product-development` as the first plugin package.

**Architecture:** Root files become marketplace catalog metadata, docs, and tests. The complete Product Development plugin package moves under `plugins/product-development/`, where all plugin manifests point to the moved canonical skill tree. Tests enforce the boundary: marketplace files expose plugins; plugin package files own the methodology and adapter routing.

**Tech Stack:** Markdown docs, JSON plugin manifests, Bats tests, Node JSON parsing inside Bats, Nix dev shell.

---

## File Structure

Root marketplace files:

- Create: `.agents/plugins/marketplace.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `.github/plugin/marketplace.json`
- Modify: `README.md`
- Modify: `docs/development.md`
- Modify: `docs/compatibility/harness-matrix.md`
- Modify: `docs/compatibility/hooks.md`
- Create: `tests/marketplace-package.bats`
- Delete or replace: `tests/plugin-package.bats`

Product Development plugin package files:

- Move: `plugin.json` to `plugins/product-development/plugin.json`
- Move: `package.json` to `plugins/product-development/package.json`
- Move: `gemini-extension.json` to `plugins/product-development/gemini-extension.json`
- Move: `.codex-plugin/plugin.json` to `plugins/product-development/.codex-plugin/plugin.json`
- Move: `.claude-plugin/plugin.json` to `plugins/product-development/.claude-plugin/plugin.json`
- Move: `agents/shared/` to `plugins/product-development/agents/shared/`
- Move: `commands/shared/` to `plugins/product-development/commands/shared/`
- Move: `skills/product-development/` to `plugins/product-development/skills/product-development/`
- Create: `plugins/product-development/tests/plugin-package.bats`

Implementation notes:

- Keep `.claude-plugin/marketplace.json` at root as marketplace metadata.
- Keep `.github/plugin/marketplace.json` at root as marketplace metadata.
- Add `.agents/plugins/marketplace.json` at root for Codex marketplace metadata.
- Do not add hook manifests or hook scripts.
- Do not keep root plugin manifests after the move.

## Task 1: Add Marketplace-Aware Failing Tests

**Files:**

- Create: `tests/marketplace-package.bats`
- Create: `plugins/product-development/tests/plugin-package.bats`
- Reference: `tests/plugin-package.bats`

- [ ] **Step 1: Create the root marketplace test skeleton**

Create `tests/marketplace-package.bats` with helpers copied from the existing `tests/plugin-package.bats` style:

```bash
#!/usr/bin/env bats

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

assert_file_exists() {
  [ -f "$1" ] || {
    echo "missing file: $1" >&2
    return 1
  }
}

assert_file_absent() {
  [ ! -e "$1" ] || {
    echo "unexpected file exists: $1" >&2
    return 1
  }
}

assert_file_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || {
    echo "missing expected text in $file: $expected" >&2
    return 1
  }
}

json_get() {
  local file="$1"
  local expression="$2"
  node -e '
const fs = require("fs");
const file = process.argv[1];
const expression = process.argv[2];
const data = JSON.parse(fs.readFileSync(file, "utf8"));
const fn = new Function("data", `return (${expression});`);
const value = fn(data);
if (typeof value === "string") {
  console.log(value);
} else {
  console.log(JSON.stringify(value));
}
' "$file" "$expression"
}
```

- [ ] **Step 2: Add failing root marketplace manifest tests**

Append these tests to `tests/marketplace-package.bats`:

```bash
@test "root marketplace manifests exist and plugin manifests do not" {
  assert_file_exists "$REPO_ROOT/.agents/plugins/marketplace.json"
  assert_file_exists "$REPO_ROOT/.claude-plugin/marketplace.json"
  assert_file_exists "$REPO_ROOT/.github/plugin/marketplace.json"

  assert_file_absent "$REPO_ROOT/plugin.json"
  assert_file_absent "$REPO_ROOT/package.json"
  assert_file_absent "$REPO_ROOT/gemini-extension.json"
  assert_file_absent "$REPO_ROOT/.codex-plugin/plugin.json"
  assert_file_absent "$REPO_ROOT/.claude-plugin/plugin.json"
}

@test "root marketplace manifests name prometheas-labs" {
  [ "$(json_get "$REPO_ROOT/.agents/plugins/marketplace.json" "data.name")" = "prometheas-labs" ]
  [ "$(json_get "$REPO_ROOT/.claude-plugin/marketplace.json" "data.name")" = "prometheas-labs" ]
  [ "$(json_get "$REPO_ROOT/.github/plugin/marketplace.json" "data.name")" = "prometheas-labs" ]
}

@test "root marketplace manifests expose product-development from plugins/product-development" {
  assert_file_contains "$REPO_ROOT/.agents/plugins/marketplace.json" '"name": "product-development"'
  assert_file_contains "$REPO_ROOT/.agents/plugins/marketplace.json" '"path": "./plugins/product-development"'
  assert_file_contains "$REPO_ROOT/.claude-plugin/marketplace.json" '"name": "product-development"'
  assert_file_contains "$REPO_ROOT/.claude-plugin/marketplace.json" '"source": "./plugins/product-development"'
  assert_file_contains "$REPO_ROOT/.github/plugin/marketplace.json" '"name": "product-development"'
  assert_file_contains "$REPO_ROOT/.github/plugin/marketplace.json" '"source": "./plugins/product-development"'
}
```

- [ ] **Step 3: Add failing root docs and hook tests**

Append:

```bash
@test "root README documents marketplace install commands" {
  assert_file_contains "$REPO_ROOT/README.md" "# Prometheas Labs Agent Plugins"
  assert_file_contains "$REPO_ROOT/README.md" "Prometheas-Labs/agent-plugins"
  assert_file_contains "$REPO_ROOT/README.md" "product-development@prometheas-labs"
  assert_file_contains "$REPO_ROOT/README.md" "currently contains one plugin"
  ! grep -Fq "product-development@prometheas-product-development" "$REPO_ROOT/README.md"
}

@test "development docs describe marketplace and plugin package development" {
  assert_file_contains "$REPO_ROOT/docs/development.md" "marketplace maintenance"
  assert_file_contains "$REPO_ROOT/docs/development.md" "plugins/product-development"
  assert_file_contains "$REPO_ROOT/docs/development.md" "nix develop -c bats tests/marketplace-package.bats"
  assert_file_contains "$REPO_ROOT/docs/development.md" "nix develop -c bats plugins/product-development/skills/product-development/tests/init.bats"
}

@test "compatibility docs use marketplace framing" {
  assert_file_contains "$REPO_ROOT/docs/compatibility/harness-matrix.md" "Prometheas Labs agent plugin marketplace"
  assert_file_contains "$REPO_ROOT/docs/compatibility/harness-matrix.md" "product-development@prometheas-labs"
  assert_file_contains "$REPO_ROOT/docs/compatibility/harness-matrix.md" "plugins/product-development"
}

@test "runtime hooks are absent" {
  [ ! -e "$REPO_ROOT/hooks.json" ]
  [ ! -e "$REPO_ROOT/hooks" ]
  [ ! -e "$REPO_ROOT/plugins/product-development/hooks.json" ]
  [ ! -e "$REPO_ROOT/plugins/product-development/hooks" ]
  node -e '
const fs = require("fs");
const files = process.argv.slice(1);
const scan = (value, file, path = []) => {
  if (!value || typeof value !== "object") return;
  for (const [key, child] of Object.entries(value)) {
    if (/hook/i.test(key)) {
      console.error(`runtime hook key found in ${file}: ${[...path, key].join(".")}`);
      process.exitCode = 1;
    }
    scan(child, file, [...path, key]);
  }
};
for (const file of files) {
  scan(JSON.parse(fs.readFileSync(file, "utf8")), file);
}
' \
    "$REPO_ROOT/.agents/plugins/marketplace.json" \
    "$REPO_ROOT/.claude-plugin/marketplace.json" \
    "$REPO_ROOT/.github/plugin/marketplace.json" \
    "$REPO_ROOT/plugins/product-development/plugin.json" \
    "$REPO_ROOT/plugins/product-development/package.json" \
    "$REPO_ROOT/plugins/product-development/gemini-extension.json" \
    "$REPO_ROOT/plugins/product-development/.codex-plugin/plugin.json" \
    "$REPO_ROOT/plugins/product-development/.claude-plugin/plugin.json"
}
```

- [ ] **Step 4: Create plugin package test skeleton**

Create `plugins/product-development/tests/plugin-package.bats`:

```bash
#!/usr/bin/env bats

PLUGIN_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
REPO_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)"

assert_file_exists() {
  [ -f "$1" ] || {
    echo "missing file: $1" >&2
    return 1
  }
}

assert_file_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || {
    echo "missing expected text in $file: $expected" >&2
    return 1
  }
}
```

- [ ] **Step 5: Add failing plugin package tests**

Append:

```bash
@test "plugin manifests exist under plugin package root" {
  assert_file_exists "$PLUGIN_ROOT/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/package.json"
  assert_file_exists "$PLUGIN_ROOT/gemini-extension.json"
  assert_file_exists "$PLUGIN_ROOT/.codex-plugin/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/.claude-plugin/plugin.json"
}

@test "plugin manifests name product-development and point to moved skill tree" {
  assert_file_contains "$PLUGIN_ROOT/plugin.json" '"name": "product-development"'
  assert_file_contains "$PLUGIN_ROOT/plugin.json" '"skills/product-development"'
  assert_file_contains "$PLUGIN_ROOT/package.json" '"name": "product-development"'
  assert_file_contains "$PLUGIN_ROOT/package.json" '"skills/product-development"'
  assert_file_contains "$PLUGIN_ROOT/.codex-plugin/plugin.json" '"skills": "./skills/"'
  assert_file_contains "$PLUGIN_ROOT/.claude-plugin/plugin.json" '"./skills/product-development"'
}

@test "canonical product-development skill layout moved under plugin package" {
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/SKILL.md"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/scripts/init.sh"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/tests/init.bats"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/templates/README.md.tmpl"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/templates/AGENTS.md.tmpl"
}
```

- [ ] **Step 6: Add failing adapter thinness tests**

Append:

```bash
@test "shared commands route to canonical methodology" {
  for file in "$PLUGIN_ROOT"/commands/shared/*.md; do
    assert_file_contains "$file" "product-development skill"
    grep -Eq 'canonical methodology|canonical skill|skills/product-development/SKILL.md' "$file" || {
      echo "command wrapper does not route to canonical skill: $file" >&2
      return 1
    }
  done
}

@test "shared agents route to canonical methodology" {
  for file in "$PLUGIN_ROOT"/agents/shared/*.md; do
    grep -Eq 'product-development skill|canonical methodology|skills/product-development/SKILL.md' "$file" || {
      echo "agent wrapper does not route to canonical skill: $file" >&2
      return 1
    }
  done
}

@test "adapter files do not duplicate methodology headings" {
  for file in "$PLUGIN_ROOT"/commands/shared/*.md "$PLUGIN_ROOT"/agents/shared/*.md; do
    ! grep -Eq '^#+ (Foundation Gate|Product Constitution|Product Vision|Requirements Workflow|Technical Design|User Stories|Scenarios|Acceptance Criteria)' "$file" || {
      echo "adapter file duplicates methodology heading: $file" >&2
      return 1
    }
  done
}
```

- [ ] **Step 7: Run the new tests and confirm they fail**

Run:

```bash
nix develop -c bats tests/marketplace-package.bats
nix develop -c bats plugins/product-development/tests/plugin-package.bats
```

Expected: failures for missing moved files, old names, and old source paths.

- [ ] **Step 8: Commit failing tests**

Run:

```bash
git add tests/marketplace-package.bats plugins/product-development/tests/plugin-package.bats
git commit -m "test: cover marketplace package layout" -m "Add failing coverage for the Prometheas Labs marketplace root and moved product-development plugin package." -m "Refs #10"
```

## Task 2: Move Plugin Package And Update Manifests

**Files:**

- Create: `.agents/plugins/marketplace.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `.github/plugin/marketplace.json`
- Move files into `plugins/product-development/`

- [ ] **Step 1: Create plugin package directories**

Run:

```bash
mkdir -p plugins/product-development/.codex-plugin
mkdir -p plugins/product-development/.claude-plugin
mkdir -p plugins/product-development/agents
mkdir -p plugins/product-development/commands
mkdir -p plugins/product-development/skills
```

- [ ] **Step 2: Move plugin package files**

Run:

```bash
git mv plugin.json plugins/product-development/plugin.json
git mv package.json plugins/product-development/package.json
git mv gemini-extension.json plugins/product-development/gemini-extension.json
git mv .codex-plugin/plugin.json plugins/product-development/.codex-plugin/plugin.json
git mv .claude-plugin/plugin.json plugins/product-development/.claude-plugin/plugin.json
git mv agents/shared plugins/product-development/agents/shared
git mv commands/shared plugins/product-development/commands/shared
git mv skills/product-development plugins/product-development/skills/product-development
```

- [ ] **Step 3: Remove empty old adapter directories**

Run:

```bash
rmdir .codex-plugin
rmdir agents
rmdir commands
```

Expected: `.claude-plugin/` remains because root marketplace metadata still lives there.

- [ ] **Step 4: Add Codex marketplace manifest**

Create `.agents/plugins/marketplace.json`:

```json
{
  "name": "prometheas-labs",
  "description": "Prometheas Labs agent plugin marketplace.",
  "owner": {
    "name": "Prometheas Labs"
  },
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

- [ ] **Step 5: Update Claude marketplace manifest**

Replace `.claude-plugin/marketplace.json` with:

```json
{
  "name": "prometheas-labs",
  "description": "Prometheas Labs agent plugin marketplace.",
  "owner": {
    "name": "Prometheas Labs"
  },
  "plugins": [
    {
      "name": "product-development",
      "source": "./plugins/product-development"
    }
  ]
}
```

- [ ] **Step 6: Update Copilot marketplace manifest**

Replace `.github/plugin/marketplace.json` with:

```json
{
  "name": "prometheas-labs",
  "owner": {
    "name": "Prometheas Labs"
  },
  "plugins": [
    {
      "name": "product-development",
      "source": "./plugins/product-development"
    }
  ]
}
```

- [ ] **Step 7: Update moved plugin package manifests**

Set `plugins/product-development/package.json` to:

```json
{
  "name": "product-development",
  "version": "0.1.0",
  "description": "Product development lifecycle workflows as portable agent skills.",
  "private": false,
  "keywords": [
    "agent-plugin",
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

Keep `plugins/product-development/plugin.json` skills as:

```json
"skills": [
  "skills/product-development"
]
```

Keep `plugins/product-development/.codex-plugin/plugin.json` skills as:

```json
"skills": "./skills/"
```

Keep `plugins/product-development/.claude-plugin/plugin.json` skills as:

```json
"skills": [
  "./skills/product-development"
]
```

- [ ] **Step 8: Run marketplace and plugin tests**

Run:

```bash
nix develop -c bats tests/marketplace-package.bats
nix develop -c bats plugins/product-development/tests/plugin-package.bats
```

Expected: manifest/layout tests pass or fail only on docs assertions that Task 3 will fix.

- [ ] **Step 9: Commit moved package and manifests**

Run:

```bash
git add .agents .claude-plugin .github plugins tests
git commit -m "refactor: move product-development into marketplace plugin package" -m "Move the product-development plugin package under plugins/product-development and add root marketplace manifests for prometheas-labs." -m "Refs #10"
```

## Task 3: Update Root And Development Documentation

**Files:**

- Modify: `README.md`
- Modify: `docs/development.md`
- Modify: `docs/compatibility/harness-matrix.md`
- Modify: `docs/compatibility/hooks.md`
- Optional modify: `presentation.html` if present

- [ ] **Step 1: Rewrite README title and opening**

Update the top of `README.md` to begin:

```markdown
# Prometheas Labs Agent Plugins

This repository is the Prometheas Labs agent plugin marketplace. It currently
contains one plugin, `product-development`, and is structured to host additional
Prometheas Labs plugins over time.

The canonical Product Development methodology lives inside
`plugins/product-development/skills/product-development/`. Marketplace manifests
and adapter wrappers expose the plugin; they do not duplicate methodology.
```

- [ ] **Step 2: Replace consumer install commands**

Ensure `README.md` contains:

````markdown
## Getting Started

Register the marketplace, then install `product-development`.

<details>
<summary>Codex</summary>

```bash
codex plugin marketplace add Prometheas-Labs/agent-plugins --ref main
codex plugin add product-development@prometheas-labs
```

</details>

<details>
<summary>Claude Code</summary>

```bash
claude plugin marketplace add --scope user Prometheas-Labs/agent-plugins@main
claude plugin install product-development@prometheas-labs
```

</details>

<details>
<summary>GitHub Copilot CLI</summary>

```bash
copilot plugin marketplace add Prometheas-Labs/agent-plugins
copilot plugin install product-development@prometheas-labs
```

</details>
````

- [ ] **Step 3: Update README package contents**

Ensure `README.md` package section includes:

```markdown
## Marketplace Contents

- `.agents/plugins/marketplace.json` - Codex marketplace metadata.
- `.claude-plugin/marketplace.json` - Claude Code marketplace metadata.
- `.github/plugin/marketplace.json` - GitHub Copilot CLI marketplace metadata.
- `plugins/product-development/` - Product Development plugin package.

The `product-development` plugin package contains its own plugin manifests,
shared command wrappers, shared agent wrappers, and canonical skill tree.
```

- [ ] **Step 4: Rewrite development docs structure section**

Update `docs/development.md` structure section to:

````markdown
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
    └── product-development/
        ├── plugin.json
        ├── package.json
        ├── gemini-extension.json
        ├── .codex-plugin/plugin.json
        ├── .claude-plugin/plugin.json
        ├── agents/shared/
        ├── commands/shared/
        ├── skills/product-development/
        └── tests/plugin-package.bats
```
````

- [ ] **Step 5: Update local checkout install docs**

In `docs/development.md`, document local marketplace install from this checkout:

````markdown
## Installing From A Local Checkout

Use local checkout installs for development. Register the checkout root as the
marketplace, then install `product-development@prometheas-labs`.

```bash
codex plugin marketplace add "$PWD"
codex plugin add product-development@prometheas-labs
```

```bash
claude plugin validate "$PWD"
claude plugin marketplace add --scope project "$PWD"
claude plugin install --scope project product-development@prometheas-labs
```

```bash
copilot plugin marketplace add "$PWD"
copilot plugin install product-development@prometheas-labs
```
````

- [ ] **Step 6: Update validation docs**

In `docs/development.md`, include:

````markdown
## Running Tests

```bash
nix develop -c bats tests/marketplace-package.bats
nix develop -c bats plugins/product-development/tests/plugin-package.bats
nix develop -c bats plugins/product-development/skills/product-development/tests/init.bats
git diff --check
```
````

- [ ] **Step 7: Update compatibility matrix**

Revise `docs/compatibility/harness-matrix.md` so it states:

```markdown
This repository is the Prometheas Labs agent plugin marketplace. The root
marketplace exposes `product-development@prometheas-labs` from
`plugins/product-development/`.
```

Update manifest paths in the matrix:

```markdown
| Codex | supported | `.agents/plugins/marketplace.json` + `plugins/product-development/.codex-plugin/plugin.json` | install validated | shared wrappers | documented adapter only | `bats tests/marketplace-package.bats` + Codex marketplace smoke test |
| Claude Code | supported | `.claude-plugin/marketplace.json` + `plugins/product-development/.claude-plugin/plugin.json` | install validated | shared wrappers | documented adapter only | `bats tests/marketplace-package.bats` + Claude marketplace smoke test |
| GitHub Copilot CLI | supported | `.github/plugin/marketplace.json` + `plugins/product-development/plugin.json` | install validated | shared wrappers | documented adapter only | `bats tests/marketplace-package.bats` + Copilot marketplace smoke test |
```

- [ ] **Step 8: Update hook docs**

Ensure `docs/compatibility/hooks.md` states:

```markdown
No lifecycle hook declarations are shipped in the marketplace root or in
`plugins/product-development/`. Hooks remain deferred until a separate hook
implementation issue is approved.
```

- [ ] **Step 9: Update presentation if present**

Run:

```bash
find . -maxdepth 2 -name 'presentation.html' -print
```

If it exists, replace old install strings with:

```text
Prometheas-Labs/agent-plugins
product-development@prometheas-labs
```

- [ ] **Step 10: Run doc-focused tests**

Run:

```bash
nix develop -c bats tests/marketplace-package.bats
```

Expected: root marketplace docs tests pass.

- [ ] **Step 11: Commit docs**

Run:

```bash
git add README.md docs tests presentation.html
git commit -m "docs: present repository as plugin marketplace" -m "Update public and development documentation for the Prometheas Labs marketplace and product-development plugin package layout." -m "Refs #10"
```

If `presentation.html` does not exist, omit it from `git add`.

## Task 4: Finish Package Test Migration And Path Updates

**Files:**

- Modify: `plugins/product-development/tests/plugin-package.bats`
- Modify: `plugins/product-development/skills/product-development/tests/init.bats`
- Modify: files containing old paths found by search
- Delete: `tests/plugin-package.bats`

- [ ] **Step 1: Port useful existing package tests**

Review old `tests/plugin-package.bats` and port still-relevant checks into `plugins/product-development/tests/plugin-package.bats`:

```bash
@test "plugin manifests parse as JSON" {
  for file in \
    "$PLUGIN_ROOT/plugin.json" \
    "$PLUGIN_ROOT/package.json" \
    "$PLUGIN_ROOT/gemini-extension.json" \
    "$PLUGIN_ROOT/.codex-plugin/plugin.json" \
    "$PLUGIN_ROOT/.claude-plugin/plugin.json"; do
    node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$file"
  done
}

@test "package metadata rejects npm lifecycle scripts" {
  node -e '
const data = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
const scripts = data.scripts || {};
const lifecycle = ["preinstall", "install", "postinstall", "prepare", "prepack", "postpack", "prepublish", "prepublishOnly"];
for (const name of lifecycle) {
  if (Object.prototype.hasOwnProperty.call(scripts, name)) {
    console.error(`lifecycle script is not allowed: ${name}`);
    process.exit(1);
  }
}
' "$PLUGIN_ROOT/package.json"
}

@test "manifests do not declare runtime hooks" {
  node -e '
const fs = require("fs");
const files = process.argv.slice(1);
const scan = (value, file, path = []) => {
  if (!value || typeof value !== "object") return;
  for (const [key, child] of Object.entries(value)) {
    if (/hook/i.test(key)) {
      console.error(`runtime hook key found in ${file}: ${[...path, key].join(".")}`);
      process.exitCode = 1;
    }
    scan(child, file, [...path, key]);
  }
};
for (const file of files) {
  scan(JSON.parse(fs.readFileSync(file, "utf8")), file);
}
' \
    "$PLUGIN_ROOT/plugin.json" \
    "$PLUGIN_ROOT/package.json" \
    "$PLUGIN_ROOT/gemini-extension.json" \
    "$PLUGIN_ROOT/.codex-plugin/plugin.json" \
    "$PLUGIN_ROOT/.claude-plugin/plugin.json"
}
```

- [ ] **Step 2: Search for old repository names and package names**

Run:

```bash
rg -n "agent-plugin-product-development|prometheas-product-development|product-development@prometheas-product-development|skills/product-development|tests/plugin-package.bats|\\.codex-plugin/plugin.json|\\.claude-plugin/plugin.json|plugin.json" README.md docs tests plugins
```

Expected: remaining `skills/product-development` matches should be either inside `plugins/product-development/...` files or explicitly describing plugin-relative paths.

- [ ] **Step 3: Update old path references**

Update references according to this mapping:

```text
skills/product-development/ -> plugins/product-development/skills/product-development/
tests/plugin-package.bats -> plugins/product-development/tests/plugin-package.bats or tests/marketplace-package.bats
.codex-plugin/plugin.json -> plugins/product-development/.codex-plugin/plugin.json
.claude-plugin/plugin.json -> plugins/product-development/.claude-plugin/plugin.json
plugin.json -> plugins/product-development/plugin.json when referring to plugin manifest
```

Keep plugin manifest internals relative to `plugins/product-development/`:

```text
skills/product-development
./skills/
./skills/product-development
```

- [ ] **Step 4: Remove old root package test**

Run:

```bash
git rm tests/plugin-package.bats
```

- [ ] **Step 5: Run package and init tests**

Run:

```bash
nix develop -c bats plugins/product-development/tests/plugin-package.bats
nix develop -c bats plugins/product-development/skills/product-development/tests/init.bats
```

Expected: both pass.

- [ ] **Step 6: Commit package test migration**

Run:

```bash
git add plugins tests docs README.md
git commit -m "test: validate moved product-development package" -m "Move plugin package validation under plugins/product-development and update path assertions for the marketplace layout." -m "Refs #10"
```

## Task 5: Final Validation And Smoke Notes

**Files:**

- Modify: `docs/development.md`
- Modify: `docs/compatibility/harness-matrix.md`
- Modify: `README.md` if validation notes need correction

- [ ] **Step 1: Run full local validation**

Run:

```bash
nix develop -c bats tests/marketplace-package.bats
nix develop -c bats plugins/product-development/tests/plugin-package.bats
nix develop -c bats plugins/product-development/skills/product-development/tests/init.bats
git diff --check
```

Expected: all pass.

- [ ] **Step 2: Run stale-name scans**

Run:

```bash
rg -n "agent-plugin-product-development|prometheas-product-development|product-development@prometheas-product-development" .
```

Expected: no matches except historical notes in already-approved design or plan docs. Do not leave matches in README, compatibility docs, marketplace manifests, or plugin package metadata.

- [ ] **Step 3: Run hook scans**

Run:

```bash
find . -path './.git' -prune -o -iname '*hook*' -print
nix develop -c bats tests/marketplace-package.bats
nix develop -c bats plugins/product-development/tests/plugin-package.bats
```

Expected: the file-name scan returns docs-only hook references, and both Bats
suites pass. Runtime hook JSON keys are enforced by recursive `/hook/i` manifest
key scans inside the Bats tests, not by string grep.

- [ ] **Step 4: Optionally run harness smoke tests with ephemeral homes**

Only run these if the harness CLIs are installed and can be isolated without touching user config.

Codex:

```bash
tmp="$(mktemp -d)"
CODEX_HOME="$tmp/codex" codex plugin marketplace add "$PWD"
CODEX_HOME="$tmp/codex" codex plugin add product-development@prometheas-labs
CODEX_HOME="$tmp/codex" codex plugin list
```

Claude Code:

```bash
tmp="$(mktemp -d)"
CLAUDE_CONFIG_DIR="$tmp/claude" claude plugin validate "$PWD"
CLAUDE_CONFIG_DIR="$tmp/claude" claude plugin marketplace add --scope project "$PWD"
CLAUDE_CONFIG_DIR="$tmp/claude" claude plugin install --scope project product-development@prometheas-labs
```

GitHub Copilot CLI:

```bash
tmp="$(mktemp -d)"
XDG_CONFIG_HOME="$tmp/config" copilot plugin marketplace add "$PWD"
XDG_CONFIG_HOME="$tmp/config" copilot plugin install product-development@prometheas-labs
XDG_CONFIG_HOME="$tmp/config" copilot plugin list
```

Record only what was actually tested. Do not claim runtime command or agent loading unless tested directly.

- [ ] **Step 5: Update validation notes if smoke tests were run**

If smoke tests were run, add a short note to `docs/compatibility/harness-matrix.md`:

```markdown
Validation notes distinguish marketplace registration, plugin installation, and
runtime component loading. Current smoke tests validate marketplace registration
and plugin installation only unless this document explicitly says otherwise.
```

- [ ] **Step 6: Commit final validation note changes if any**

If files changed in Step 5:

```bash
git add docs/compatibility/harness-matrix.md README.md docs/development.md
git commit -m "docs: record marketplace validation scope" -m "Clarify marketplace registration, plugin installation, and runtime loading claims for the marketplace refactor." -m "Refs #10"
```

- [ ] **Step 7: Check final status**

Run:

```bash
git status --short --branch
git log --oneline --decorate -6
```

Expected: worktree clean, branch ahead of `origin/main` by the design commit and implementation commits.
