#!/bin/sh
# usage: install-defense-hook.sh <repo-path>
#
# Installs (or non-destructively extends) the target repo's
# `pre-commit` hook with branch-guard's backstop check. If a
# pre-commit hook already exists and is executable, it is preserved
# under a new name and chained via `exec` after the guard passes, so
# it still runs exactly as before regardless of what language it's
# written in.
set -eu

repo_path="${1:?usage: install-defense-hook.sh <repo-path>}"
script_dir="$(cd "$(dirname "$0")" && pwd)"

hooks_dir="$(git -C "$repo_path" rev-parse --path-format=absolute --git-path hooks)"
mkdir -p "$hooks_dir"

guard_path="$hooks_dir/branch-guard-pre-commit.sh"
hook_path="$hooks_dir/pre-commit"
original_path="$hooks_dir/pre-commit.branch-guard-original"

cp "$script_dir/pre-commit-guard.sh" "$guard_path"
chmod +x "$guard_path"

if [ -e "$hook_path" ] || [ -L "$hook_path" ]; then
  if [ -L "$hook_path" ]; then
    echo "branch-guard: refusing to install over a symlinked pre-commit hook at $hook_path" >&2
    exit 1
  fi
  if grep -q "branch-guard: managed dispatcher" "$hook_path" 2>/dev/null; then
    exit 0
  fi
  if [ -x "$hook_path" ]; then
    cp "$hook_path" "$original_path"
    chmod +x "$original_path"
  fi
fi

{
  echo '#!/bin/sh'
  echo '# branch-guard: managed dispatcher, do not edit by hand.'
  printf '"%s" "$@" || exit 1\n' "$guard_path"
  if [ -x "$original_path" ]; then
    printf 'exec "%s" "$@"\n' "$original_path"
  fi
} > "$hook_path"
chmod +x "$hook_path"
