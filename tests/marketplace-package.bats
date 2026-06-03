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
  ! grep -R '"hooks"' "$REPO_ROOT/.agents" "$REPO_ROOT/.claude-plugin" "$REPO_ROOT/.github" "$REPO_ROOT/plugins/product-development" 2>/dev/null
}
