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

runtime_metadata_paths() {
  printf '%s\n' \
    "$REPO_ROOT/.agents/plugins/marketplace.json" \
    "$REPO_ROOT/.claude-plugin/marketplace.json" \
    "$REPO_ROOT/.github/plugin/marketplace.json" \
    "$REPO_ROOT/plugins/product-development/plugin.json" \
    "$REPO_ROOT/plugins/product-development/package.json" \
    "$REPO_ROOT/plugins/product-development/.codex-plugin/plugin.json" \
    "$REPO_ROOT/plugins/product-development/.claude-plugin/plugin.json" \
    "$REPO_ROOT/plugins/delivery-engineering/plugin.json" \
    "$REPO_ROOT/plugins/delivery-engineering/package.json" \
    "$REPO_ROOT/plugins/delivery-engineering/.codex-plugin/plugin.json" \
    "$REPO_ROOT/plugins/delivery-engineering/.claude-plugin/plugin.json"
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

@test "root marketplace manifests expose delivery-engineering from plugins/delivery-engineering" {
  assert_file_contains "$REPO_ROOT/.agents/plugins/marketplace.json" '"name": "delivery-engineering"'
  assert_file_contains "$REPO_ROOT/.agents/plugins/marketplace.json" '"path": "./plugins/delivery-engineering"'
  assert_file_contains "$REPO_ROOT/.claude-plugin/marketplace.json" '"name": "delivery-engineering"'
  assert_file_contains "$REPO_ROOT/.claude-plugin/marketplace.json" '"source": "./plugins/delivery-engineering"'
  assert_file_contains "$REPO_ROOT/.github/plugin/marketplace.json" '"name": "delivery-engineering"'
  assert_file_contains "$REPO_ROOT/.github/plugin/marketplace.json" '"source": "./plugins/delivery-engineering"'
}

@test "root README documents marketplace install commands" {
  assert_file_contains "$REPO_ROOT/README.md" "# Prometheas Labs Agent Plugins"
  assert_file_contains "$REPO_ROOT/README.md" "Prometheas-Labs/agent-plugins"
  assert_file_contains "$REPO_ROOT/README.md" "product-development@prometheas-labs"
  assert_file_contains "$REPO_ROOT/README.md" "delivery-engineering@prometheas-labs"
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
  [ ! -e "$REPO_ROOT/plugins/delivery-engineering/hooks.json" ]
  [ ! -e "$REPO_ROOT/plugins/delivery-engineering/hooks" ]

  local files=()
  while IFS= read -r file; do
    assert_file_exists "$file"
    files+=("$file")
  done < <(runtime_metadata_paths)

  assert_no_manifest_hook_declarations "${files[@]}"
}
