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

@test "refuses to install over a symlinked pre-commit hook" {
  mkdir -p "$TMP_REPO/.git/hooks"
  outside="$(mktemp)"
  ln -s "$outside" "$TMP_REPO/.git/hooks/pre-commit"
  run sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  [ "$status" -ne 0 ]
  [ -L "$TMP_REPO/.git/hooks/pre-commit" ]
  rm -f "$outside"
}

@test "a pre-existing non-executable pre-commit hook is not preserved or chained" {
  # git never ran a non-executable pre-commit hook in the first place,
  # so there's nothing to preserve.
  mkdir -p "$TMP_REPO/.git/hooks"
  cat > "$TMP_REPO/.git/hooks/pre-commit" <<'EOF'
#!/bin/sh
touch should-not-run.txt
exit 1
EOF
  chmod -x "$TMP_REPO/.git/hooks/pre-commit"
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  [ ! -e "$TMP_REPO/.git/hooks/pre-commit.branch-guard-original" ]
  run git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m "on feature after non-exec original"
  [ ! -f "$TMP_REPO/should-not-run.txt" ]
}

@test "a pre-existing hook that itself blocks a commit still blocks it after install" {
  mkdir -p "$TMP_REPO/.git/hooks"
  cat > "$TMP_REPO/.git/hooks/pre-commit" <<'EOF'
#!/bin/sh
exit 1
EOF
  chmod +x "$TMP_REPO/.git/hooks/pre-commit"
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  git -C "$TMP_REPO" checkout -q -b feature
  run git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m "should be blocked by original hook"
  [ "$status" -ne 0 ]
}

@test "a wildcard protected-branch pattern in the override file is not corrupted by filesystem globbing" {
  mkdir -p "$TMP_REPO/.config/branch-guard"
  cat > "$TMP_REPO/.config/branch-guard/protected-branches" <<'EOF'
hotfix/*
EOF
  git -C "$TMP_REPO" add .config
  git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q -m "add config"
  # A real file matching the glob pattern: an unquoted `for pattern in
  # $patterns` performs pathname expansion as well as word-splitting,
  # so "hotfix/*" would silently expand against files like this one
  # instead of staying a literal pattern for the `case` match, unless
  # `set -f` is in effect around the loop.
  mkdir -p "$TMP_REPO/hotfix"
  touch "$TMP_REPO/hotfix/existing-file"
  git -C "$TMP_REPO" add hotfix
  git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q -m "add matching file"
  git -C "$TMP_REPO" checkout -q -b hotfix/urgent
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  run git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m "direct on hotfix/urgent"
  [ "$status" -ne 0 ]
}

@test "guard script itself is reinstalled idempotently even before the dispatcher check" {
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  guard_path="$TMP_REPO/.git/hooks/branch-guard-pre-commit.sh"
  [ -x "$guard_path" ]
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  [ -x "$guard_path" ]
}
