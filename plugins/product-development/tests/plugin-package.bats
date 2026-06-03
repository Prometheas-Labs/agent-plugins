#!/usr/bin/env bats

PLUGIN_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
REPO_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)"
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

assert_file_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || {
    echo "missing expected text in $file: $expected" >&2
    return 1
  }
}

assert_dir_exists() {
  [ -d "$1" ] || {
    echo "missing directory: $1" >&2
    return 1
  }
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

manifest_paths() {
  printf '%s\n' \
    "$PLUGIN_ROOT/plugin.json" \
    "$PLUGIN_ROOT/package.json" \
    "$PLUGIN_ROOT/gemini-extension.json" \
    "$PLUGIN_ROOT/.codex-plugin/plugin.json" \
    "$PLUGIN_ROOT/.claude-plugin/plugin.json"
}

shared_command_paths() {
  printf '%s\n' \
    "$PLUGIN_ROOT/commands/shared/init-product-docs.md" \
    "$PLUGIN_ROOT/commands/shared/create-constitution.md" \
    "$PLUGIN_ROOT/commands/shared/create-vision.md" \
    "$PLUGIN_ROOT/commands/shared/write-prd.md"
}

shared_agent_paths() {
  printf '%s\n' \
    "$PLUGIN_ROOT/agents/shared/product-researcher.md" \
    "$PLUGIN_ROOT/agents/shared/spec-reviewer.md" \
    "$PLUGIN_ROOT/agents/shared/plan-reviewer.md" \
    "$PLUGIN_ROOT/agents/shared/implementation-auditor.md"
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
      console.error(`manifest-declared path resolves outside plugin root in ${file}: ${declaredPath}`);
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

assert_no_manifest_hook_declarations() {
  node - "$@" <<'NODE'
const fs = require("fs");

let valid = true;

function scan(value, file, path = []) {
  if (!value || typeof value !== "object") {
    return;
  }

  if (Array.isArray(value)) {
    value.forEach((item, index) => scan(item, file, [...path, `[${index}]`]));
    return;
  }

  for (const [key, nestedValue] of Object.entries(value)) {
    const nextPath = [...path, key];
    if (/hook/i.test(key)) {
      console.error(`manifest declares hook-like key in ${file}: ${nextPath.join(".")}`);
      valid = false;
    }
    scan(nestedValue, file, nextPath);
  }
}

for (const file of process.argv.slice(2)) {
  scan(JSON.parse(fs.readFileSync(file, "utf8")), file);
}

process.exit(valid ? 0 : 1);
NODE
}

assert_no_npm_lifecycle_scripts() {
  local file="$1"

  node - "$file" <<'NODE'
const fs = require("fs");

const data = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const scripts = data.scripts || {};
const lifecycle = [
  "preinstall",
  "install",
  "postinstall",
  "prepare",
  "prepack",
  "pack",
  "postpack",
  "prepublish",
  "prepublishOnly",
  "publish",
  "postpublish",
];

for (const name of lifecycle) {
  if (Object.prototype.hasOwnProperty.call(scripts, name)) {
    console.error(`lifecycle script is not allowed: ${name}`);
    process.exit(1);
  }
}
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
  assert_dir_exists "$PLUGIN_ROOT/skills/product-development/references"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/scripts/init.sh"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/tests/init.bats"
  assert_dir_exists "$PLUGIN_ROOT/skills/product-development/templates"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/templates/README.md.tmpl"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/templates/AGENTS.md.tmpl"
}

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

@test "manifest-declared paths exist inside plugin package" {
  local manifests=()
  while IFS= read -r file; do
    manifests+=("$file")
  done < <(manifest_paths)

  assert_manifest_declared_paths_exist "$PLUGIN_ROOT" "${manifests[@]}"
}

@test "manifest-declared path arrays reject invalid entries" {
  local temp_dir
  temp_dir="$(mktemp -d)"

  printf '%s\n' '{"skills":[42]}' > "$temp_dir/non-string.json"
  run assert_manifest_declared_paths_exist "$PLUGIN_ROOT" "$temp_dir/non-string.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path is not a string"* ]]

  printf '%s\n' '{"skills":["   "]}' > "$temp_dir/blank.json"
  run assert_manifest_declared_paths_exist "$PLUGIN_ROOT" "$temp_dir/blank.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path is blank"* ]]

  printf '%s\n' '{"skills":["/tmp"]}' > "$temp_dir/absolute.json"
  run assert_manifest_declared_paths_exist "$PLUGIN_ROOT" "$temp_dir/absolute.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path is absolute"* ]]

  printf '%s\n' '{"skills":["skills/../product-development"]}' > "$temp_dir/traversal.json"
  run assert_manifest_declared_paths_exist "$PLUGIN_ROOT" "$temp_dir/traversal.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path contains traversal"* ]]

  rm -rf "$temp_dir"
}

@test "manifest-declared string paths reject invalid entries" {
  local temp_dir
  temp_dir="$(mktemp -d)"

  printf '%s\n' '{"skills":42}' > "$temp_dir/non-string.json"
  run assert_manifest_declared_paths_exist "$PLUGIN_ROOT" "$temp_dir/non-string.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"skills must be a string or array"* ]]

  printf '%s\n' '{"skills":"   "}' > "$temp_dir/blank.json"
  run assert_manifest_declared_paths_exist "$PLUGIN_ROOT" "$temp_dir/blank.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path is blank"* ]]

  printf '%s\n' '{"skills":"/tmp"}' > "$temp_dir/absolute.json"
  run assert_manifest_declared_paths_exist "$PLUGIN_ROOT" "$temp_dir/absolute.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path is absolute"* ]]

  printf '%s\n' '{"skills":"skills/../product-development"}' > "$temp_dir/traversal.json"
  run assert_manifest_declared_paths_exist "$PLUGIN_ROOT" "$temp_dir/traversal.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manifest-declared path contains traversal"* ]]

  rm -rf "$temp_dir"
}

@test "manifests point to canonical product-development skill without adapters" {
  assert_json_object_keys_equals "$PLUGIN_ROOT/plugin.json" "." "name" "version" "description" "author" "keywords" "skills"
  assert_json_object_keys_equals "$PLUGIN_ROOT/plugin.json" "author" "name"
  assert_json_field_equals "$PLUGIN_ROOT/plugin.json" "name" "product-development"
  assert_json_field_equals "$PLUGIN_ROOT/plugin.json" "version" "0.1.0"
  assert_json_field_equals "$PLUGIN_ROOT/plugin.json" "description" "$EXPECTED_DESCRIPTION"
  assert_json_field_equals "$PLUGIN_ROOT/plugin.json" "author.name" "$EXPECTED_AUTHOR_NAME"
  assert_json_array_equals "$PLUGIN_ROOT/plugin.json" "keywords" "agent-skill" "product-development" "copilot-cli-plugin"
  assert_json_array_equals "$PLUGIN_ROOT/plugin.json" "skills" "skills/product-development"

  assert_json_object_keys_equals "$PLUGIN_ROOT/.claude-plugin/plugin.json" "." "name" "version" "description" "author" "skills"
  assert_json_object_keys_equals "$PLUGIN_ROOT/.claude-plugin/plugin.json" "author" "name"
  assert_json_field_equals "$PLUGIN_ROOT/.claude-plugin/plugin.json" "name" "product-development"
  assert_json_field_equals "$PLUGIN_ROOT/.claude-plugin/plugin.json" "version" "0.1.0"
  assert_json_field_equals "$PLUGIN_ROOT/.claude-plugin/plugin.json" "description" "$EXPECTED_DESCRIPTION"
  assert_json_field_equals "$PLUGIN_ROOT/.claude-plugin/plugin.json" "author.name" "$EXPECTED_AUTHOR_NAME"
  assert_json_array_equals "$PLUGIN_ROOT/.claude-plugin/plugin.json" "skills" "./skills/product-development"

  assert_json_object_keys_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "." "name" "version" "description" "author" "keywords" "skills" "interface"
  assert_json_object_keys_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "author" "name"
  assert_json_object_keys_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "interface" "displayName" "shortDescription" "longDescription" "developerName" "category" "capabilities" "defaultPrompt"
  assert_json_field_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "name" "product-development"
  assert_json_field_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "version" "0.1.0"
  assert_json_field_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "description" "$EXPECTED_DESCRIPTION"
  assert_json_field_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "author.name" "$EXPECTED_AUTHOR_NAME"
  assert_json_array_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "keywords" "agent-skill" "product-development" "codex-plugin"
  assert_json_field_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "skills" "./skills/"
  assert_json_field_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "interface.displayName" "Product Development"
  assert_json_field_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "interface.shortDescription" "Guide product development lifecycle workflows"
  assert_json_field_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "interface.longDescription" "Use Product Development to create and review product artifacts through the canonical product-development skill without duplicating methodology in harness adapters."
  assert_json_field_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "interface.developerName" "$EXPECTED_AUTHOR_NAME"
  assert_json_field_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "interface.category" "Developer Tools"
  assert_json_array_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "interface.capabilities" "Interactive" "Write"
  assert_json_array_equals "$PLUGIN_ROOT/.codex-plugin/plugin.json" "interface.defaultPrompt" "Use the product-development skill for this feature"

  assert_json_object_keys_equals "$PLUGIN_ROOT/gemini-extension.json" "." "name" "version" "description"
  assert_json_field_equals "$PLUGIN_ROOT/gemini-extension.json" "name" "product-development"
  assert_json_field_equals "$PLUGIN_ROOT/gemini-extension.json" "version" "0.1.0"
  assert_json_field_equals "$PLUGIN_ROOT/gemini-extension.json" "description" "$EXPECTED_DESCRIPTION"

  assert_json_object_keys_equals "$PLUGIN_ROOT/package.json" "." "name" "version" "description" "private" "keywords" "pi"
  assert_json_object_keys_equals "$PLUGIN_ROOT/package.json" "pi" "skills"
  assert_json_field_equals "$PLUGIN_ROOT/package.json" "name" "product-development"
  assert_json_field_equals "$PLUGIN_ROOT/package.json" "version" "0.1.0"
  assert_json_field_equals "$PLUGIN_ROOT/package.json" "description" "$EXPECTED_DESCRIPTION"
  assert_json_boolean_equals "$PLUGIN_ROOT/package.json" "private" "false"
  assert_json_array_equals "$PLUGIN_ROOT/package.json" "keywords" "agent-plugin" "agent-skill" "product-development" "pi-package"
  assert_json_array_equals "$PLUGIN_ROOT/package.json" "pi.skills" "skills/product-development"
}

@test "package metadata rejects npm lifecycle scripts" {
  assert_no_npm_lifecycle_scripts "$PLUGIN_ROOT/package.json"

  local temp_dir
  temp_dir="$(mktemp -d)"

  printf '%s\n' '{"scripts":{"postinstall":"echo bad"}}' > "$temp_dir/package.json"
  run assert_no_npm_lifecycle_scripts "$temp_dir/package.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"lifecycle script is not allowed: postinstall"* ]]

  printf '%s\n' '{"scripts":{"publish":"echo bad"}}' > "$temp_dir/package.json"
  run assert_no_npm_lifecycle_scripts "$temp_dir/package.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"lifecycle script is not allowed: publish"* ]]

  rm -rf "$temp_dir"
}

@test "manifests do not declare runtime hooks" {
  local files=()
  while IFS= read -r file; do
    assert_file_exists "$file"
    files+=("$file")
  done < <(manifest_paths)

  assert_no_manifest_hook_declarations "${files[@]}"
}

@test "shared commands route to canonical methodology" {
  while IFS= read -r file; do
    assert_file_exists "$file"
    assert_file_contains "$file" "product-development skill"
    grep -Eq 'canonical methodology|canonical skill|skills/product-development/SKILL.md' "$file" || {
      echo "command wrapper does not route to canonical skill: $file" >&2
      return 1
    }
  done < <(shared_command_paths)
}

@test "shared agents route to canonical methodology" {
  while IFS= read -r file; do
    assert_file_exists "$file"
    grep -Eq 'product-development skill|canonical methodology|skills/product-development/SKILL.md' "$file" || {
      echo "agent wrapper does not route to canonical skill: $file" >&2
      return 1
    }
  done < <(shared_agent_paths)
}

@test "adapter files do not duplicate methodology headings" {
  while IFS= read -r file; do
    assert_file_exists "$file"
    ! grep -Eq '^#+ (Foundation Gate|Product Constitution|Product Vision|Requirements Workflow|Technical Design|User Stories|Scenarios|Acceptance Criteria)' "$file" || {
      echo "adapter file duplicates methodology heading: $file" >&2
      return 1
    }
  done < <(
    shared_command_paths
    shared_agent_paths
  )
}

@test "adapter files stay thin" {
  assert_adapter_files_are_thin "$PLUGIN_ROOT/commands" "$COMMAND_LINE_LIMIT"
  assert_adapter_files_are_thin "$PLUGIN_ROOT/agents" "$AGENT_LINE_LIMIT"
}
