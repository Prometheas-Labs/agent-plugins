#!/usr/bin/env bats

# Plugin package validation. JSON parsing uses Node because this repository
# already targets agent harnesses that commonly provide a Node runtime.

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
COMMAND_LINE_LIMIT=40
AGENT_LINE_LIMIT=80
EXPECTED_DESCRIPTION="Product development lifecycle workflows as portable agent skills."
EXPECTED_AUTHOR_NAME="Prometheas Labs"

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

assert_json_parses() {
  local file="$1"
  node -e 'const fs = require("fs"); JSON.parse(fs.readFileSync(process.argv[1], "utf8"));' "$file"
}

assert_json_field_equals() {
  local file="$1"
  local expression="$2"
  local expected="$3"

  node -e '
    const fs = require("fs");
    const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const value = process.argv[2].split(".").reduce((memo, key) => memo && memo[key], data);
    if (value !== process.argv[3]) {
      console.error(`${process.argv[2]} expected ${process.argv[3]}, got ${value}`);
      process.exit(1);
    }
  ' "$file" "$expression" "$expected"
}

assert_json_boolean_equals() {
  local file="$1"
  local expression="$2"
  local expected="$3"

  node -e '
    const fs = require("fs");
    const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const value = process.argv[2].split(".").reduce((memo, key) => memo && memo[key], data);
    const expected = process.argv[3] === "true";
    if (value !== expected) {
      console.error(`${process.argv[2]} expected ${expected}, got ${value}`);
      process.exit(1);
    }
  ' "$file" "$expression" "$expected"
}

assert_json_array_equals() {
  local file="$1"
  local expression="$2"
  shift 2

  node -e '
    const fs = require("fs");
    const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const value = process.argv[2].split(".").reduce((memo, key) => memo && memo[key], data);
    const expected = process.argv.slice(3);
    if (!Array.isArray(value) || value.length !== expected.length || value.some((item, index) => item !== expected[index])) {
      console.error(`${process.argv[2]} expected ${JSON.stringify(expected)}, got ${JSON.stringify(value)}`);
      process.exit(1);
    }
  ' "$file" "$expression" "$@"
}

assert_json_object_keys_equals() {
  local file="$1"
  local expression="$2"
  shift 2

  node -e '
    const fs = require("fs");
    const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const value = process.argv[2] === "."
      ? data
      : process.argv[2].split(".").reduce((memo, key) => memo && memo[key], data);
    const expected = process.argv.slice(3).sort();
    const actual = value && typeof value === "object" && !Array.isArray(value) ? Object.keys(value).sort() : null;
    if (!actual || actual.length !== expected.length || actual.some((item, index) => item !== expected[index])) {
      console.error(`${process.argv[2]} expected keys ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
      process.exit(1);
    }
  ' "$file" "$expression" "$@"
}

assert_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || {
    echo "missing expected text in $file: $expected" >&2
    return 1
  }
}

assert_file_matches() {
  local file="$1"
  local pattern="$2"

  grep -Eq "$pattern" "$file" || {
    echo "missing expected pattern in $file: $pattern" >&2
    return 1
  }
}

assert_shared_agent_contract() {
  local file="$1"

  assert_file_matches "$file" '^---$'
  assert_file_matches "$file" '^name: [a-z][a-z0-9-]*$'
  assert_file_matches "$file" '^description: .+$'
  assert_file_contains "$file" 'skills/product-development/SKILL.md'
  grep -Eq 'skills/product-development/|canonical methodology' "$file" || {
    echo "agent wrapper does not reference canonical skill tree or methodology: $file" >&2
    return 1
  }
  assert_file_contains "$file" 'Bound your job'
  assert_file_contains "$file" 'Do not make edits by default.'
}

assert_compatibility_matrix_contract() {
  local file="$1"

  node - "$file" <<'NODE'
const fs = require("fs");

const file = process.argv[2];
const lines = fs.readFileSync(file, "utf8").split(/\r?\n/);
const tableLines = lines.filter((line) => /^\|.*\|$/.test(line.trim()));
const parse = (line) => line.trim().slice(1, -1).split("|").map((cell) => cell.trim());
const header = tableLines.length > 0 ? parse(tableLines[0]) : [];
const expectedHeader = [
  "harness",
  "V1 support tier",
  "manifest file",
  "skills support",
  "commands support",
  "agents support",
  "validation command",
  "notes",
];

if (JSON.stringify(header) !== JSON.stringify(expectedHeader)) {
  console.error(`compatibility matrix header mismatch: ${JSON.stringify(header)}`);
  process.exit(1);
}

const rows = tableLines
  .slice(2)
  .map(parse)
  .filter((row) => row.length === expectedHeader.length)
  .map((row) => Object.fromEntries(expectedHeader.map((key, index) => [key, row[index]])));

const expectedRows = [
  {
    harness: "Plain Agent Skill",
    "V1 support tier": "supported",
    "manifest file": "skills/product-development/SKILL.md",
    "skills support": "supported",
    "commands support": "shared wrappers",
    "agents support": "documented adapter only",
    "validation command": "bats skills/product-development/tests/init.bats",
  },
  {
    harness: "Claude Code",
    "V1 support tier": "supported",
    "manifest file": ".claude-plugin/plugin.json",
    "skills support": "install validated",
    "commands support": "shared wrappers",
    "agents support": "documented adapter only",
    "validation command": "bats tests/plugin-package.bats + Claude project marketplace smoke test",
  },
  {
    harness: "Codex",
    "V1 support tier": "supported",
    "manifest file": ".codex-plugin/plugin.json",
    "skills support": "install validated",
    "commands support": "shared wrappers",
    "agents support": "documented adapter only",
    "validation command": "bats tests/plugin-package.bats + Codex local marketplace smoke test",
  },
  {
    harness: "GitHub Copilot CLI",
    "V1 support tier": "supported",
    "manifest file": "plugin.json",
    "skills support": "install validated",
    "commands support": "shared wrappers",
    "agents support": "documented adapter only",
    "validation command": "bats tests/plugin-package.bats + Copilot local marketplace smoke test",
  },
  {
    harness: "Gemini/Antigravity",
    "V1 support tier": "manifest prepared",
    "manifest file": "gemini-extension.json",
    "skills support": "manifest prepared",
    "commands support": "documented adapter only",
    "agents support": "documented adapter only",
    "validation command": "bats tests/plugin-package.bats",
  },
  {
    harness: "Pi",
    "V1 support tier": "manifest prepared",
    "manifest file": "package.json",
    "skills support": "manifest prepared",
    "commands support": "shared wrappers",
    "agents support": "documented adapter only",
    "validation command": "bats tests/plugin-package.bats",
  },
  {
    harness: "OMP",
    "V1 support tier": "smoke-test-required",
    "manifest file": ".claude-plugin/plugin.json / package.json",
    "skills support": "smoke-test-required",
    "commands support": "smoke-test-required",
    "agents support": "smoke-test-required",
    "validation command": "manual OMP install/link smoke test",
  },
];

for (const expected of expectedRows) {
  const actual = rows.find((row) => row.harness === expected.harness);
  if (!actual) {
    console.error(`missing compatibility matrix row: ${expected.harness}`);
    process.exit(1);
  }

  for (const [key, value] of Object.entries(expected)) {
    if (actual[key] !== value) {
      console.error(`${expected.harness} ${key} expected ${value}, got ${actual[key]}`);
      process.exit(1);
    }
  }
}

for (const tier of ["supported", "manifest prepared", "documented adapter only", "smoke-test-required"]) {
  if (!lines.some((line) => line.includes(`\`${tier}\``))) {
    console.error(`missing support tier definition: ${tier}`);
    process.exit(1);
  }
}

for (const state of ["shared wrappers"]) {
  if (!lines.some((line) => line.includes(`\`${state}\``))) {
    console.error(`missing capability state definition: ${state}`);
    process.exit(1);
  }
}

if (!lines.some((line) => line.includes("Local Marketplace Layouts"))) {
  console.error("missing local marketplace layouts section");
  process.exit(1);
}
NODE
}

manifest_paths() {
  printf '%s\n' \
    "$REPO_ROOT/plugin.json" \
    "$REPO_ROOT/.claude-plugin/plugin.json" \
    "$REPO_ROOT/.claude-plugin/marketplace.json" \
    "$REPO_ROOT/.codex-plugin/plugin.json" \
    "$REPO_ROOT/.github/plugin/marketplace.json" \
    "$REPO_ROOT/gemini-extension.json" \
    "$REPO_ROOT/package.json"
}

shared_agent_paths() {
  printf '%s\n' \
    "$REPO_ROOT/agents/shared/product-researcher.md" \
    "$REPO_ROOT/agents/shared/spec-reviewer.md" \
    "$REPO_ROOT/agents/shared/plan-reviewer.md" \
    "$REPO_ROOT/agents/shared/implementation-auditor.md"
}

shared_command_paths() {
  printf '%s\n' \
    "$REPO_ROOT/commands/shared/init-product-docs.md" \
    "$REPO_ROOT/commands/shared/create-constitution.md" \
    "$REPO_ROOT/commands/shared/create-vision.md" \
    "$REPO_ROOT/commands/shared/write-prd.md"
}

gemini_command_paths() {
  [ -d "$REPO_ROOT/commands/gemini" ] || return 0
  find "$REPO_ROOT/commands/gemini" -type f -name '*.toml'
}

assert_manifest_declared_paths_exist() {
  local root="$1"
  shift

  node - "$root" "$@" <<'NODE'
const fs = require("fs");
const path = require("path");

const root = fs.realpathSync(process.argv[2]);
let valid = true;

for (const file of process.argv.slice(3)) {
  const data = JSON.parse(fs.readFileSync(file, "utf8"));
  const collect = (owner, fieldPath) => {
    const value = fieldPath.split(".").reduce((memo, key) => memo && memo[key], owner);
    if (value === undefined) {
      return [];
    }

    if (typeof value === "string") {
      return [{ fieldPath, value }];
    }

    if (!Array.isArray(value)) {
      console.error(`${fieldPath} must be a string or array in ${file}`);
      valid = false;
      return [];
    }

    const declaredPaths = [];
    value.forEach((item, index) => {
      if (typeof item !== "string") {
        console.error(`manifest-declared path is not a string in ${file}: ${fieldPath}[${index}]`);
        valid = false;
        return;
      }

      declaredPaths.push({ fieldPath, value: item });
    });

    return declaredPaths;
  };

  const declaredPaths = [
    ...collect(data, "skills"),
    ...collect(data, "agents"),
    ...collect(data, "commands"),
    ...collect(data, "pi.skills"),
  ];

  for (const { fieldPath, value } of declaredPaths) {
    const declaredPath = value.trim();
    if (declaredPath.length === 0) {
      console.error(`manifest-declared path is blank in ${file}: ${fieldPath}`);
      valid = false;
      continue;
    }

    if (path.isAbsolute(declaredPath)) {
      console.error(`manifest-declared path is absolute in ${file}: ${declaredPath}`);
      valid = false;
      continue;
    }

    if (declaredPath.split(/[\\/]+/).includes("..")) {
      console.error(`manifest-declared path contains traversal in ${file}: ${declaredPath}`);
      valid = false;
      continue;
    }

    const resolvedPath = path.resolve(root, declaredPath);
    if (resolvedPath !== root && !resolvedPath.startsWith(`${root}${path.sep}`)) {
      console.error(`manifest-declared path resolves outside repo root in ${file}: ${declaredPath}`);
      valid = false;
      continue;
    }

    if (!fs.existsSync(resolvedPath)) {
      console.error(`manifest-declared path does not exist: ${declaredPath}`);
      valid = false;
    }
  }
}

process.exit(valid ? 0 : 1);
NODE
}

assert_adapter_files_are_thin() {
  local directory="$1"
  local line_limit="$2"

  [ -d "$directory" ] || return 0

  while IFS= read -r file; do
    [ -n "$file" ] || continue
    local line_count
    line_count="$(wc -l < "$file" | tr -d '[:space:]')"
    [ "$line_count" -le "$line_limit" ] || {
      echo "adapter file exceeds ${line_limit} lines: $file has $line_count" >&2
      return 1
    }

    ! grep -Eq '^#{1,6}[[:space:]]+(Foundation Gate|Product Constitution|Product Vision|Requirements|User Stories|Scenarios|TRD)\b' "$file" || {
      echo "adapter file duplicates methodology heading: $file" >&2
      return 1
    }
  done < <(find "$directory" -type f)
}

assert_shared_command_contract() {
  local file="$1"

  assert_file_contains "$file" 'skills/product-development/SKILL.md'
  grep -Eq 'Use the product-development skill|canonical methodology|canonical skill' "$file" || {
    echo "command wrapper does not route to the canonical skill: $file" >&2
    return 1
  }
}

assert_toml_parses() {
  local file="$1"

  python3 - "$file" <<'PY'
import sys

try:
    import tomllib
except ModuleNotFoundError:
    print(
        "Python 3.11+ is required for TOML validation because stdlib tomllib is unavailable. "
        "Run `direnv allow` or `nix develop` to use the pinned dev shell.",
        file=sys.stderr,
    )
    raise SystemExit(2)

with open(sys.argv[1], "rb") as handle:
    tomllib.load(handle)
PY
}

assert_runtime_hooks_absent() {
  local root="$1"

  [ ! -f "$root/hooks.json" ]
  [ ! -f "$root/hooks/hooks.json" ]

  if [ -d "$root/hooks" ]; then
    run find "$root/hooks" -type f
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
  fi
}

assert_no_manifest_hook_declarations() {
  local file="$1"

  node - "$file" <<'NODE'
const fs = require("fs");

const data = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
let valid = true;

function scan(value, path = []) {
  if (!value || typeof value !== "object") {
    return;
  }

  if (Array.isArray(value)) {
    value.forEach((item, index) => scan(item, [...path, `[${index}]`]));
    return;
  }

  for (const [key, nestedValue] of Object.entries(value)) {
    if (key.toLowerCase().includes("hook")) {
      console.error(`manifest declares hook-like key: ${[...path, key].join(".")}`);
      valid = false;
    }
    scan(nestedValue, [...path, key]);
  }
}

scan(data);
process.exit(valid ? 0 : 1);
NODE
}

assert_no_npm_lifecycle_scripts() {
  local file="$1"

  node - "$file" <<'NODE'
const fs = require("fs");

const data = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const scripts = data.scripts || {};
const lifecycleScripts = [
  "preinstall",
  "install",
  "postinstall",
  "prepare",
  "prepublish",
  "prepublishOnly",
  "publish",
  "postpublish",
  "prepack",
  "pack",
  "postpack",
];

for (const scriptName of lifecycleScripts) {
  if (Object.prototype.hasOwnProperty.call(scripts, scriptName)) {
    console.error(`package.json declares npm lifecycle script: ${scriptName}`);
    process.exit(1);
  }
}
NODE
}

@test "required plugin manifests exist" {
  while IFS= read -r file; do
    assert_file_exists "$file"
  done < <(manifest_paths)
}

@test "required compatibility docs exist" {
  assert_file_exists "$REPO_ROOT/docs/compatibility/harness-matrix.md"
  assert_file_exists "$REPO_ROOT/docs/compatibility/hooks.md"
  assert_file_exists "$REPO_ROOT/docs/development.md"
}

@test "README documents skill and plugin package usage" {
  assert_file_contains "$REPO_ROOT/README.md" "# Product Development Plugin"
  assert_file_contains "$REPO_ROOT/README.md" "Plugin installation is the"
  assert_file_contains "$REPO_ROOT/README.md" "preferred path for Codex, Claude Code, and GitHub Copilot CLI"
  assert_file_contains "$REPO_ROOT/README.md" "<summary>Codex</summary>"
  assert_file_contains "$REPO_ROOT/README.md" "<summary>Claude Code</summary>"
  assert_file_contains "$REPO_ROOT/README.md" "<summary>GitHub Copilot CLI</summary>"
  assert_file_contains "$REPO_ROOT/README.md" "<summary>Plain Agent Skill</summary>"
  assert_file_contains "$REPO_ROOT/README.md" "shared command"
  ! grep -Fq "manifests, commands, and agents route" "$REPO_ROOT/README.md"
  assert_file_contains "$REPO_ROOT/README.md" 'docs/compatibility/harness-matrix.md'
  assert_file_contains "$REPO_ROOT/README.md" 'docs/development.md'
  assert_file_contains "$REPO_ROOT/README.md" "Runtime hooks are intentionally deferred"
  assert_file_contains "$REPO_ROOT/README.md" "Metadata-only manifests are documented in the"
  assert_file_contains "$REPO_ROOT/README.md" "compatibility matrix"
  assert_file_contains "$REPO_ROOT/README.md" 'Manifests that declare component paths route back to'
  assert_file_contains "$REPO_ROOT/README.md" '`skills/product-development/`'
  assert_file_contains "$REPO_ROOT/README.md" 'codex plugin marketplace add https://github.com/Prometheas-Labs/agent-plugin-product-development.git --ref main'
  assert_file_contains "$REPO_ROOT/README.md" 'codex plugin add product-development@prometheas-product-development'
  assert_file_contains "$REPO_ROOT/README.md" 'claude plugin marketplace add --scope user https://github.com/Prometheas-Labs/agent-plugin-product-development.git#main'
  assert_file_contains "$REPO_ROOT/README.md" 'claude plugin install product-development@prometheas-product-development'
  assert_file_contains "$REPO_ROOT/README.md" 'copilot plugin marketplace add Prometheas-Labs/agent-plugin-product-development'
  assert_file_contains "$REPO_ROOT/README.md" 'copilot plugin install product-development@prometheas-product-development'
  assert_file_contains "$REPO_ROOT/README.md" 'copilot plugin install Prometheas-Labs/agent-plugin-product-development'
  assert_file_contains "$REPO_ROOT/README.md" 'npx skills add product-development'
  assert_file_contains "$REPO_ROOT/README.md" 'Local marketplace install smoke tests have passed for Codex, Claude Code, and'
  assert_file_contains "$REPO_ROOT/README.md" 'they do not prove runtime'
  ! grep -Fq 'git clone https://github.com/Prometheas-Labs/agent-plugin-product-development.git plugins/product-development' "$REPO_ROOT/README.md"
  ! grep -Fq 'codex plugin marketplace add "$PROJECT_ROOT"' "$REPO_ROOT/README.md"
}

@test "development docs cover local checkout and validation workflows" {
  assert_file_contains "$REPO_ROOT/docs/development.md" '# Development'
  assert_file_contains "$REPO_ROOT/docs/development.md" '## Installing From A Local Checkout'
  assert_file_contains "$REPO_ROOT/docs/development.md" 'git clone https://github.com/Prometheas-Labs/agent-plugin-product-development.git plugins/product-development'
  assert_file_contains "$REPO_ROOT/docs/development.md" 'codex plugin marketplace add "$PROJECT_ROOT"'
  assert_file_contains "$REPO_ROOT/docs/development.md" 'claude plugin install --scope project product-development@local-product-development'
  assert_file_contains "$REPO_ROOT/docs/development.md" 'copilot plugin install product-development@local-product-development'
  assert_file_contains "$REPO_ROOT/docs/development.md" 'nix develop -c bats tests/plugin-package.bats'
  assert_file_contains "$REPO_ROOT/docs/development.md" 'nix develop -c bats skills/product-development/tests/init.bats'
}

@test "compatibility matrix documents the V1 harness contract" {
  assert_compatibility_matrix_contract "$REPO_ROOT/docs/compatibility/harness-matrix.md"
  assert_file_contains "$REPO_ROOT/docs/compatibility/harness-matrix.md" 'V1 includes shared Markdown command wrappers under `commands/shared/`'
  assert_file_contains "$REPO_ROOT/docs/compatibility/harness-matrix.md" 'agent wrappers under `agents/shared/`'
  assert_file_contains "$REPO_ROOT/docs/compatibility/harness-matrix.md" 'Harness-specific command and agent support'
  assert_file_contains "$REPO_ROOT/docs/compatibility/harness-matrix.md" 'no context file, TOML commands'
  assert_file_contains "$REPO_ROOT/docs/compatibility/harness-matrix.md" 'Codex local marketplace smoke test'
  assert_file_contains "$REPO_ROOT/docs/compatibility/harness-matrix.md" '.github/plugin/marketplace.json'
}

@test "hook compatibility document defers runtime hooks" {
  assert_file_contains "$REPO_ROOT/docs/compatibility/hooks.md" "Runtime hooks are deferred for V1."
  assert_file_contains "$REPO_ROOT/docs/compatibility/hooks.md" 'no `hooks.json`'
  assert_file_contains "$REPO_ROOT/docs/compatibility/hooks.md" 'no `hooks/hooks.json`'
  assert_file_contains "$REPO_ROOT/docs/compatibility/hooks.md" "no hook scripts"
  assert_file_contains "$REPO_ROOT/docs/compatibility/hooks.md" "no manifest hook declarations"
  assert_file_contains "$REPO_ROOT/docs/compatibility/hooks.md" "separate design"
  assert_file_contains "$REPO_ROOT/docs/compatibility/hooks.md" "security review"
  assert_file_contains "$REPO_ROOT/docs/compatibility/hooks.md" "per-harness schema"
}

@test "canonical product-development skill layout remains in place" {
  assert_file_exists "$REPO_ROOT/skills/product-development/SKILL.md"
  assert_dir_exists "$REPO_ROOT/skills/product-development/references"
  assert_file_exists "$REPO_ROOT/skills/product-development/scripts/init.sh"
  assert_dir_exists "$REPO_ROOT/skills/product-development/templates"
  assert_file_exists "$REPO_ROOT/skills/product-development/tests/init.bats"
}

@test "runtime hooks are absent" {
  assert_runtime_hooks_absent "$REPO_ROOT"

  local temp_dir
  temp_dir="$(mktemp -d)"
  mkdir -p "$temp_dir/hooks"
  printf '%s\n' "hook placeholder" > "$temp_dir/hooks/non-executable-hook.txt"

  run assert_runtime_hooks_absent "$temp_dir"
  [ "$status" -ne 0 ]

  rm -rf "$temp_dir"
}

@test "shared command wrappers exist" {
  while IFS= read -r file; do
    assert_file_exists "$file"
  done < <(shared_command_paths)
}

@test "shared command wrappers route to canonical methodology" {
  while IFS= read -r file; do
    assert_shared_command_contract "$file"
  done < <(shared_command_paths)
}

@test "Gemini TOML command wrappers parse if present" {
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    assert_toml_parses "$file"
  done < <(gemini_command_paths)
}

@test "shared agent wrappers exist" {
  while IFS= read -r file; do
    assert_file_exists "$file"
  done < <(shared_agent_paths)
}

@test "shared agent wrappers route to canonical methodology and findings-only jobs" {
  while IFS= read -r file; do
    assert_shared_agent_contract "$file"
  done < <(shared_agent_paths)
}

@test "package metadata rejects npm lifecycle scripts" {
  assert_no_npm_lifecycle_scripts "$REPO_ROOT/package.json"

  local temp_dir
  temp_dir="$(mktemp -d)"
  printf '%s\n' '{"scripts":{"postinstall":"node hooks/install.js"}}' > "$temp_dir/package.json"

  run assert_no_npm_lifecycle_scripts "$temp_dir/package.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"package.json declares npm lifecycle script: postinstall"* ]]

  rm -rf "$temp_dir"
}

@test "plugin manifests parse as JSON" {
  while IFS= read -r file; do
    assert_file_exists "$file"
    assert_json_parses "$file"
  done < <(manifest_paths)
}

@test "manifest-declared paths exist" {
  local manifests=()
  while IFS= read -r file; do
    manifests+=("$file")
  done < <(manifest_paths)

  assert_manifest_declared_paths_exist "$REPO_ROOT" "${manifests[@]}"
}

@test "manifest-declared path arrays reject invalid entries" {
  local temp_dir
  temp_dir="$(mktemp -d)"

  printf '%s\n' '{"skills":[42]}' > "$temp_dir/non-string.json"
  run assert_manifest_declared_paths_exist "$REPO_ROOT" "$temp_dir/non-string.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path is not a string"* ]]

  printf '%s\n' '{"skills":["   "]}' > "$temp_dir/blank.json"
  run assert_manifest_declared_paths_exist "$REPO_ROOT" "$temp_dir/blank.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path is blank"* ]]

  printf '%s\n' '{"skills":["/tmp"]}' > "$temp_dir/absolute.json"
  run assert_manifest_declared_paths_exist "$REPO_ROOT" "$temp_dir/absolute.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path is absolute"* ]]

  printf '%s\n' '{"skills":["skills/../product-development"]}' > "$temp_dir/traversal.json"
  run assert_manifest_declared_paths_exist "$REPO_ROOT" "$temp_dir/traversal.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path contains traversal"* ]]

  rm -rf "$temp_dir"
}

@test "manifest-declared string paths reject invalid entries" {
  local temp_dir
  temp_dir="$(mktemp -d)"

  printf '%s\n' '{"skills":42}' > "$temp_dir/non-string.json"
  run assert_manifest_declared_paths_exist "$REPO_ROOT" "$temp_dir/non-string.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"skills must be a string or array"* ]]

  printf '%s\n' '{"skills":"   "}' > "$temp_dir/blank.json"
  run assert_manifest_declared_paths_exist "$REPO_ROOT" "$temp_dir/blank.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path is blank"* ]]

  printf '%s\n' '{"skills":"/tmp"}' > "$temp_dir/absolute.json"
  run assert_manifest_declared_paths_exist "$REPO_ROOT" "$temp_dir/absolute.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path is absolute"* ]]

  printf '%s\n' '{"skills":"skills/../product-development"}' > "$temp_dir/traversal.json"
  run assert_manifest_declared_paths_exist "$REPO_ROOT" "$temp_dir/traversal.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path contains traversal"* ]]

  rm -rf "$temp_dir"
}

@test "manifests point to the canonical product-development skill without adapters or hooks" {
  assert_json_object_keys_equals "$REPO_ROOT/plugin.json" "." "name" "version" "description" "author" "keywords" "skills"
  assert_json_object_keys_equals "$REPO_ROOT/plugin.json" "author" "name"
  assert_json_field_equals "$REPO_ROOT/plugin.json" "name" "product-development"
  assert_json_field_equals "$REPO_ROOT/plugin.json" "version" "0.1.0"
  assert_json_field_equals "$REPO_ROOT/plugin.json" "description" "$EXPECTED_DESCRIPTION"
  assert_json_field_equals "$REPO_ROOT/plugin.json" "author.name" "$EXPECTED_AUTHOR_NAME"
  assert_json_array_equals "$REPO_ROOT/plugin.json" "keywords" "agent-skill" "product-development" "copilot-cli-plugin"
  assert_json_array_equals "$REPO_ROOT/plugin.json" "skills" "skills/product-development"

  assert_json_object_keys_equals "$REPO_ROOT/.claude-plugin/plugin.json" "." "name" "version" "description" "author" "skills"
  assert_json_object_keys_equals "$REPO_ROOT/.claude-plugin/plugin.json" "author" "name"
  assert_json_field_equals "$REPO_ROOT/.claude-plugin/plugin.json" "name" "product-development"
  assert_json_field_equals "$REPO_ROOT/.claude-plugin/plugin.json" "version" "0.1.0"
  assert_json_field_equals "$REPO_ROOT/.claude-plugin/plugin.json" "description" "$EXPECTED_DESCRIPTION"
  assert_json_field_equals "$REPO_ROOT/.claude-plugin/plugin.json" "author.name" "$EXPECTED_AUTHOR_NAME"
  assert_json_array_equals "$REPO_ROOT/.claude-plugin/plugin.json" "skills" "./skills/product-development"

  assert_json_object_keys_equals "$REPO_ROOT/.codex-plugin/plugin.json" "." "name" "version" "description" "author" "keywords" "skills" "interface"
  assert_json_object_keys_equals "$REPO_ROOT/.codex-plugin/plugin.json" "author" "name"
  assert_json_object_keys_equals "$REPO_ROOT/.codex-plugin/plugin.json" "interface" "displayName" "shortDescription" "longDescription" "developerName" "category" "capabilities" "defaultPrompt"
  assert_json_field_equals "$REPO_ROOT/.codex-plugin/plugin.json" "name" "product-development"
  assert_json_field_equals "$REPO_ROOT/.codex-plugin/plugin.json" "version" "0.1.0"
  assert_json_field_equals "$REPO_ROOT/.codex-plugin/plugin.json" "description" "$EXPECTED_DESCRIPTION"
  assert_json_field_equals "$REPO_ROOT/.codex-plugin/plugin.json" "author.name" "Prometheas Labs"
  assert_json_array_equals "$REPO_ROOT/.codex-plugin/plugin.json" "keywords" "agent-skill" "product-development" "codex-plugin"
  assert_json_field_equals "$REPO_ROOT/.codex-plugin/plugin.json" "skills" "./skills/"
  assert_json_field_equals "$REPO_ROOT/.codex-plugin/plugin.json" "interface.displayName" "Product Development"
  assert_json_field_equals "$REPO_ROOT/.codex-plugin/plugin.json" "interface.shortDescription" "Guide product development lifecycle workflows"
  assert_json_field_equals "$REPO_ROOT/.codex-plugin/plugin.json" "interface.longDescription" "Use Product Development to create and review product artifacts through the canonical product-development skill without duplicating methodology in harness adapters."
  assert_json_field_equals "$REPO_ROOT/.codex-plugin/plugin.json" "interface.developerName" "Prometheas Labs"
  assert_json_field_equals "$REPO_ROOT/.codex-plugin/plugin.json" "interface.category" "Developer Tools"
  assert_json_array_equals "$REPO_ROOT/.codex-plugin/plugin.json" "interface.capabilities" "Interactive" "Write"
  assert_json_array_equals "$REPO_ROOT/.codex-plugin/plugin.json" "interface.defaultPrompt" "Use the product-development skill for this feature"

  assert_json_object_keys_equals "$REPO_ROOT/gemini-extension.json" "." "name" "version" "description"
  assert_json_field_equals "$REPO_ROOT/gemini-extension.json" "name" "product-development"
  assert_json_field_equals "$REPO_ROOT/gemini-extension.json" "version" "0.1.0"
  assert_json_field_equals "$REPO_ROOT/gemini-extension.json" "description" "$EXPECTED_DESCRIPTION"

  assert_json_object_keys_equals "$REPO_ROOT/package.json" "." "name" "version" "description" "private" "keywords" "pi"
  assert_json_object_keys_equals "$REPO_ROOT/package.json" "pi" "skills"
  assert_json_field_equals "$REPO_ROOT/package.json" "name" "agent-plugin-product-development"
  assert_json_field_equals "$REPO_ROOT/package.json" "version" "0.1.0"
  assert_json_field_equals "$REPO_ROOT/package.json" "description" "$EXPECTED_DESCRIPTION"
  assert_json_boolean_equals "$REPO_ROOT/package.json" "private" "false"
  assert_json_array_equals "$REPO_ROOT/package.json" "keywords" "agent-plugin" "agent-skill" "product-development" "pi-package"
  assert_json_array_equals "$REPO_ROOT/package.json" "pi.skills" "skills/product-development"
}

@test "manifests do not declare runtime hooks" {
  while IFS= read -r file; do
    assert_no_manifest_hook_declarations "$file"
  done < <(manifest_paths)

  local temp_dir
  temp_dir="$(mktemp -d)"
  printf '%s\n' '{"preToolUseHooks":[]}' > "$temp_dir/plugin.json"

  run assert_no_manifest_hook_declarations "$temp_dir/plugin.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest declares hook-like key: preToolUseHooks"* ]]

  rm -rf "$temp_dir"
}

@test "adapter files stay thin and do not duplicate methodology headings" {
  assert_adapter_files_are_thin "$REPO_ROOT/commands" "$COMMAND_LINE_LIMIT"
  assert_adapter_files_are_thin "$REPO_ROOT/agents" "$AGENT_LINE_LIMIT"
}
