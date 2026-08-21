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

@test "installs an executable pre-commit dispatcher" {
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  hook_path="$TMP_REPO/.git/hooks/pre-commit"
  [ -x "$hook_path" ]
  grep -q "branch-guard" "$hook_path"
}

@test "committing directly on main is blocked after install" {
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  run git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m "direct on main"
  [ "$status" -ne 0 ]
}

@test "committing on a feature branch is not blocked" {
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  git -C "$TMP_REPO" checkout -q -b feature
  run git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m "on feature"
  [ "$status" -eq 0 ]
}

@test "committing on main with --no-verify still succeeds" {
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  run git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --no-verify --allow-empty -m "bypass"
  [ "$status" -eq 0 ]
}

@test "a pre-existing executable pre-commit hook is preserved and still runs" {
  mkdir -p "$TMP_REPO/.git/hooks"
  cat > "$TMP_REPO/.git/hooks/pre-commit" <<'EOF'
#!/bin/sh
touch marker-from-original-hook.txt
exit 0
EOF
  chmod +x "$TMP_REPO/.git/hooks/pre-commit"
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  git -C "$TMP_REPO" checkout -q -b feature
  git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m "on feature"
  [ -f "$TMP_REPO/marker-from-original-hook.txt" ]
}

@test "installer is idempotent" {
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  first_hash="$(shasum -a 256 "$TMP_REPO/.git/hooks/pre-commit" | cut -d' ' -f1)"
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  second_hash="$(shasum -a 256 "$TMP_REPO/.git/hooks/pre-commit" | cut -d' ' -f1)"
  [ "$first_hash" = "$second_hash" ]
}
