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

@test "installs an executable, marked pre-commit hook into an empty slot" {
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  hook_path="$TMP_REPO/.git/hooks/pre-commit"
  [ -x "$hook_path" ]
  grep -q "branch-guard: managed pre-commit hook" "$hook_path"
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

@test "a pre-existing pre-commit hook is left untouched, not overwritten or chained" {
  mkdir -p "$TMP_REPO/.git/hooks"
  cat > "$TMP_REPO/.git/hooks/pre-commit" <<'EOF'
#!/bin/sh
exit 0
EOF
  chmod +x "$TMP_REPO/.git/hooks/pre-commit"
  before_hash="$(shasum -a 256 "$TMP_REPO/.git/hooks/pre-commit" | cut -d' ' -f1)"
  run sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  [ "$status" -eq 0 ]
  after_hash="$(shasum -a 256 "$TMP_REPO/.git/hooks/pre-commit" | cut -d' ' -f1)"
  [ "$before_hash" = "$after_hash" ]
  [[ "$output" == *"leaving it in place"* ]]
}

@test "a pre-existing hook that itself blocks a commit is left alone and keeps blocking" {
  mkdir -p "$TMP_REPO/.git/hooks"
  cat > "$TMP_REPO/.git/hooks/pre-commit" <<'EOF'
#!/bin/sh
exit 1
EOF
  chmod +x "$TMP_REPO/.git/hooks/pre-commit"
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  git -C "$TMP_REPO" checkout -q -b feature
  run git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m "should still be blocked by the pre-existing hook"
  [ "$status" -ne 0 ]
}

@test "a pre-existing hook that is a symlink is left untouched" {
  mkdir -p "$TMP_REPO/.git/hooks"
  outside="$(mktemp)"
  echo '#!/bin/sh' > "$outside"
  echo 'exit 0' >> "$outside"
  ln -s "$outside" "$TMP_REPO/.git/hooks/pre-commit"
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  [ -L "$TMP_REPO/.git/hooks/pre-commit" ]
  target="$(readlink "$TMP_REPO/.git/hooks/pre-commit")"
  [ "$target" = "$outside" ]
  rm -f "$outside"
}

@test "installer is idempotent" {
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  first_hash="$(shasum -a 256 "$TMP_REPO/.git/hooks/pre-commit" | cut -d' ' -f1)"
  run sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  [ "$status" -eq 0 ]
  second_hash="$(shasum -a 256 "$TMP_REPO/.git/hooks/pre-commit" | cut -d' ' -f1)"
  [ "$first_hash" = "$second_hash" ]
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

@test "a protected-branch config line with a trailing comment is still honored, not silently dropped" {
  mkdir -p "$TMP_REPO/.config/branch-guard"
  cat > "$TMP_REPO/.config/branch-guard/protected-branches" <<'EOF'
release  # kept in sync with the release process
EOF
  git -C "$TMP_REPO" add .config
  git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q -m "add config"
  git -C "$TMP_REPO" checkout -q -b release
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  run git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m "direct on release"
  [ "$status" -ne 0 ]
}

@test "master, production, develop, and development are protected by default at the pre-commit layer too" {
  sh "$PLUGIN_ROOT/scripts/install-defense-hook.sh" "$TMP_REPO"
  for name in master production develop development; do
    git -C "$TMP_REPO" checkout -q -b "$name"
    run git -C "$TMP_REPO" -c user.email=t@example.com -c user.name=t -c commit.gpgsign=false commit -q --allow-empty -m "direct on $name"
    [ "$status" -ne 0 ]
    git -C "$TMP_REPO" checkout -q main
    git -C "$TMP_REPO" branch -q -D "$name"
  done
}
