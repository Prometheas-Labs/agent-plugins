#!/usr/bin/env bats

PLUGIN_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

assert_file_exists() {
  [ -f "$1" ] || {
    echo "missing file: $1" >&2
    return 1
  }
}

json_get() {
  local file="$1"
  local expression="$2"
  node -e '
const fs = require("fs");
const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const fn = new Function("data", `return (${process.argv[2]});`);
const value = fn(data);
console.log(typeof value === "string" ? value : JSON.stringify(value));
' "$file" "$expression"
}

@test "plugin manifests exist and declare branch-guard" {
  assert_file_exists "$PLUGIN_ROOT/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/.claude-plugin/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/.codex-plugin/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/gemini-extension.json"

  [ "$(json_get "$PLUGIN_ROOT/plugin.json" "data.name")" = "branch-guard" ]
  [ "$(json_get "$PLUGIN_ROOT/.claude-plugin/plugin.json" "data.name")" = "branch-guard" ]
  [ "$(json_get "$PLUGIN_ROOT/.codex-plugin/plugin.json" "data.name")" = "branch-guard" ]
  [ "$(json_get "$PLUGIN_ROOT/gemini-extension.json" "data.name")" = "branch-guard" ]
}

@test "Claude Code and Codex hook manifests exist and are valid JSON" {
  assert_file_exists "$PLUGIN_ROOT/hooks/hooks.json"
  assert_file_exists "$PLUGIN_ROOT/.codex-plugin/hooks.json"
  node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$PLUGIN_ROOT/hooks/hooks.json"
  node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$PLUGIN_ROOT/.codex-plugin/hooks.json"
}

@test "Codex plugin.json declares an explicit hooks override" {
  [ "$(json_get "$PLUGIN_ROOT/.codex-plugin/plugin.json" "data.hooks")" = "./.codex-plugin/hooks.json" ]
}

@test "all hook and adapter scripts are executable" {
  for f in "$PLUGIN_ROOT"/scripts/*.sh; do
    [ -x "$f" ] || {
      echo "not executable: $f" >&2
      return 1
    }
  done
}
