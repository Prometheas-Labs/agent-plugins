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

@test "the override file entirely replaces the default branch guess" {
  mkdir -p "$TMP_REPO/.config/branch-guard"
  cat > "$TMP_REPO/.config/branch-guard/protected-branches" <<'EOF'
release
EOF
  # still on "main", but the override file doesn't list it
  result="$(decide "$TMP_REPO" "Write")"
  [ "$result" = "pass" ]
}
