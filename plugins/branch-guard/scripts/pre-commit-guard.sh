#!/bin/sh
# branch-guard: repository-side backstop. Best-practices nudge, not a
# security boundary -- `git commit --no-verify` is an accepted,
# visible bypass for anyone who genuinely means to commit here.
#
# Detached HEAD is allowed through: normal git workflows unrelated to
# this plugin's concern (interactive rebase, bisect, cherry-pick)
# legitimately commit from a detached HEAD.
set -eu

repo_root="$(git rev-parse --show-toplevel)"
branch="$(git symbolic-ref --quiet --short HEAD || true)"
[ -z "$branch" ] && exit 0

override_file="$repo_root/.config/branch-guard/protected-branches"
if [ -f "$override_file" ]; then
  patterns="$(grep -v '^[[:space:]]*#' "$override_file" | grep -v '^[[:space:]]*$' || true)"
else
  ref="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  patterns="${ref#origin/}"
fi
[ -z "$patterns" ] && patterns="main"

is_protected=false
old_ifs="$IFS"
IFS='
'
set -f
for pattern in $patterns; do
  case "$branch" in
    $pattern) is_protected=true ;;
  esac
done
set +f
IFS="$old_ifs"

if [ "$is_protected" = "true" ]; then
  echo "branch-guard: direct commits to '$branch' are discouraged by this repository's pre-commit hook." >&2
  echo "Switch to a feature branch, or use 'git commit --no-verify' if you mean to commit here." >&2
  exit 1
fi

exit 0
