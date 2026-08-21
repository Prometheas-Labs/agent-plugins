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

decide() {
  sh "$PLUGIN_ROOT/tests/decide-helper.sh" "$1" "$2"
}

call() {
  sh "$PLUGIN_ROOT/tests/call-helper.sh" "$@"
}

@test "asks on the protected branch for a mutating tool" {
  result="$(decide "$TMP_REPO" "Write")"
  case "$result" in
    ask:*) ;;
    *) echo "unexpected: $result" >&2; return 1 ;;
  esac
}

@test "passes on a feature branch" {
  git -C "$TMP_REPO" checkout -q -b feature
  result="$(decide "$TMP_REPO" "Write")"
  [ "$result" = "pass" ]
}

@test "passes for a non-mutating tool on the protected branch" {
  result="$(decide "$TMP_REPO" "Read")"
  [ "$result" = "pass" ]
}

@test "passes when there is no git repo at all" {
  result="$(decide "/tmp" "Write")"
  [ "$result" = "pass" ]
}

@test "passes on detached HEAD" {
  sha="$(git -C "$TMP_REPO" rev-parse HEAD)"
  git -C "$TMP_REPO" checkout -q "$sha"
  result="$(decide "$TMP_REPO" "Write")"
  [ "$result" = "pass" ]
}

@test "an additional protected branch from the override file is honored" {
  mkdir -p "$TMP_REPO/.config/branch-guard"
  cat > "$TMP_REPO/.config/branch-guard/protected-branches" <<'EOF'
main
release
EOF
  git -C "$TMP_REPO" checkout -q -b release
  result="$(decide "$TMP_REPO" "Write")"
  case "$result" in
    ask:*) ;;
    *) echo "unexpected: $result" >&2; return 1 ;;
  esac
}

@test "a wildcard pattern in the override file matches" {
  mkdir -p "$TMP_REPO/.config/branch-guard"
  cat > "$TMP_REPO/.config/branch-guard/protected-branches" <<'EOF'
hotfix/*
EOF
  git -C "$TMP_REPO" checkout -q -b hotfix/urgent
  result="$(decide "$TMP_REPO" "Write")"
  case "$result" in
    ask:*) ;;
    *) echo "unexpected: $result" >&2; return 1 ;;
  esac
}

@test "bg_json_field extracts a simple string field from compact JSON" {
  result="$(call bg_json_field '{"tool_name":"Write","cwd":"/tmp/x"}' "tool_name")"
  [ "$result" = "Write" ]
}

@test "bg_json_field extracts cwd without being confused by an earlier field" {
  result="$(call bg_json_field '{"tool_name":"Write","tool_input":{"file_path":"/a/b"},"cwd":"/tmp/x"}' "cwd")"
  [ "$result" = "/tmp/x" ]
}

@test "bg_json_field returns empty for a missing field" {
  result="$(call bg_json_field '{"tool_name":"Write"}' "cwd")"
  [ -z "$result" ]
}

@test "bg_is_mutating_tool recognizes known mutating tool names" {
  run sh "$PLUGIN_ROOT/tests/call-helper.sh" bg_is_mutating_tool "Write"
  [ "$status" -eq 0 ]
  run sh "$PLUGIN_ROOT/tests/call-helper.sh" bg_is_mutating_tool "bash"
  [ "$status" -eq 0 ]
}

@test "bg_is_mutating_tool rejects a read-only tool name" {
  run sh "$PLUGIN_ROOT/tests/call-helper.sh" bg_is_mutating_tool "Read"
  [ "$status" -ne 0 ]
}

@test "bg_branch_is_protected matches an exact name" {
  run sh "$PLUGIN_ROOT/tests/call-helper.sh" bg_branch_is_protected "main" "main"
  [ "$status" -eq 0 ]
}

@test "bg_branch_is_protected matches a wildcard pattern" {
  run sh "$PLUGIN_ROOT/tests/call-helper.sh" bg_branch_is_protected "hotfix/urgent" "hotfix/*"
  [ "$status" -eq 0 ]
}

@test "bg_branch_is_protected does not match an unrelated branch" {
  run sh "$PLUGIN_ROOT/tests/call-helper.sh" bg_branch_is_protected "feature" "main"
  [ "$status" -ne 0 ]
}

@test "bg_branch_is_protected checks multiple newline-separated patterns" {
  patterns="main
release"
  run sh "$PLUGIN_ROOT/tests/call-helper.sh" bg_branch_is_protected "release" "$patterns"
  [ "$status" -eq 0 ]
}

@test "the override file entirely replaces the default branch guess" {
  mkdir -p "$TMP_REPO/.config/branch-guard"
  cat > "$TMP_REPO/.config/branch-guard/protected-branches" <<'EOF'
release
EOF
  # still on "main", but the override file doesn't list it
  result="$(decide "$TMP_REPO" "Write")"
  [ "$result" = "pass" ]
}
