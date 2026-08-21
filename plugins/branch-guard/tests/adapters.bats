#!/usr/bin/env bats

PLUGIN_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  TMP_REPO="$(mktemp -d)"
  TMP_REPO="$(cd "$TMP_REPO" && pwd -P)"
  git -C "$TMP_REPO" init -q -b main
  git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m init
}

teardown() {
  rm -rf "$TMP_REPO"
}

@test "Claude adapter asks (stdout JSON) on the protected branch" {
  payload="{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$TMP_REPO/f.txt\"},\"cwd\":\"$TMP_REPO\"}"
  output="$(echo "$payload" | sh "$PLUGIN_ROOT/scripts/adapter-claude.sh")"
  case "$output" in
    *'"permissionDecision":"ask"'*) ;;
    *) echo "unexpected: $output" >&2; return 1 ;;
  esac
}

@test "Claude adapter produces no output on a feature branch" {
  git -C "$TMP_REPO" checkout -q -b feature
  payload="{\"tool_name\":\"Write\",\"tool_input\":{},\"cwd\":\"$TMP_REPO\"}"
  output="$(echo "$payload" | sh "$PLUGIN_ROOT/scripts/adapter-claude.sh")"
  [ -z "$output" ]
}

@test "Codex adapter exits 2 with a stderr reason on the protected branch, never mentions allow" {
  payload="{\"tool_name\":\"Write\",\"tool_input\":{},\"cwd\":\"$TMP_REPO\"}"
  run bash -c "echo '$payload' | sh '$PLUGIN_ROOT/scripts/adapter-codex.sh'"
  [ "$status" -eq 2 ]
  case "$output" in
    *"branch-guard"*) ;;
    *) echo "unexpected: $output" >&2; return 1 ;;
  esac
  case "$output" in
    *"allow"*) echo "adapter must never mention allow" >&2; return 1 ;;
  esac
}

@test "Codex adapter exits 0 on a feature branch" {
  git -C "$TMP_REPO" checkout -q -b feature
  payload="{\"tool_name\":\"Write\",\"tool_input\":{},\"cwd\":\"$TMP_REPO\"}"
  run bash -c "echo '$payload' | sh '$PLUGIN_ROOT/scripts/adapter-codex.sh'"
  [ "$status" -eq 0 ]
}

@test "Copilot adapter asks using camelCase fields on the protected branch" {
  payload="{\"toolName\":\"create\",\"toolArgs\":{},\"cwd\":\"$TMP_REPO\"}"
  output="$(echo "$payload" | sh "$PLUGIN_ROOT/scripts/adapter-copilot.sh")"
  case "$output" in
    *'"permissionDecision":"ask"'*) ;;
    *) echo "unexpected: $output" >&2; return 1 ;;
  esac
}
