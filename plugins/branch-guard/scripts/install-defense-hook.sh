#!/bin/sh
# usage: install-defense-hook.sh <repo-path>
#
# Installs branch-guard's pre-commit backstop, but only into an empty
# slot: if the target repo already has a pre-commit hook (ours or
# someone else's), this script does not touch it. Overwriting or
# chaining onto an existing hook risks breaking it or silently
# changing its behavior; the repo may well already have its own
# branch-protection check. Instead it points the user at the guard
# script so they can wire it in themselves if they want it.
set -eu

repo_path="${1:?usage: install-defense-hook.sh <repo-path>}"
script_dir="$(cd "$(dirname "$0")" && pwd)"

hooks_dir="$(git -C "$repo_path" rev-parse --path-format=absolute --git-path hooks)"
mkdir -p "$hooks_dir"
hook_path="$hooks_dir/pre-commit"
guard_script="$script_dir/pre-commit-guard.sh"

if [ -e "$hook_path" ] || [ -L "$hook_path" ]; then
  if grep -q "branch-guard: managed pre-commit hook" "$hook_path" 2>/dev/null; then
    echo "branch-guard: pre-commit hook already installed at $hook_path" >&2
    exit 0
  fi
  echo "branch-guard: a pre-commit hook already exists at $hook_path -- leaving it in place." >&2
  echo "branch-guard: to add protected-branch enforcement, call $guard_script from it, or fold its logic in directly." >&2
  exit 0
fi

tmp="$hook_path.branch-guard.tmp.$$"
cp "$guard_script" "$tmp"
chmod +x "$tmp"
mv "$tmp" "$hook_path"
