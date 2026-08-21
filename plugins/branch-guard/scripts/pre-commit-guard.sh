#!/bin/sh
# branch-guard: managed pre-commit hook, do not edit by hand.
# Repository-side backstop. Best-practices nudge, not a
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

# Built-in protected names (the repo's detected default branch, plus
# a handful of conventional names) are always in the list; an
# optional override file adds to them, it never replaces them. This
# keeps an empty/comment-only/missing override file from ever meaning
# "nothing is protected," and keeps this script's decision consistent
# with guard-common.sh's bg_protected_branches.
ref="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
default_branch="${ref#origin/}"
[ -z "$default_branch" ] && default_branch="main"
patterns="$default_branch
master
production
develop
development"

override_file="$repo_root/.config/branch-guard/protected-branches"
if [ -f "$override_file" ]; then
  # Strip trailing "# comment" text (not just whole-line comments)
  # before dropping blank lines, so "release  # note" is honored as
  # "release" rather than kept as a literal, never-matching pattern.
  extra="$(sed 's/#.*$//' "$override_file" | sed 's/[[:space:]]*$//' | grep -v '^[[:space:]]*$' || true)"
  [ -n "$extra" ] && patterns="$patterns
$extra"
fi

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
