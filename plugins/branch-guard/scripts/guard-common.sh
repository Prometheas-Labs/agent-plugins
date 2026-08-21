#!/bin/sh
# Shared helpers for branch-guard hook adapters. Sourced by each
# per-harness adapter script. POSIX sh only, no Node dependency.
#
# This plugin nudges agents away from editing a repository's protected
# branch directly. It is a best-practices guardrail, not a security
# boundary: it trusts the hook's reported cwd, uses a short explicit
# list of tool names rather than a cross-harness taxonomy, and fails
# open whenever it can't cleanly determine the branch. MVP scope --
# see plugins/branch-guard/README.md for what this deliberately does
# not attempt.

# Extracts a single string field's value from compact single-line JSON.
# Only handles simple "key":"value" string fields, which is all this
# plugin's hook payloads need.
bg_json_field() {
  json="$1"
  key="$2"
  printf '%s' "$json" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -n 1 | sed -E 's/^"'"$key"'"[[:space:]]*:[[:space:]]*"//; s/"$//'
}

# Returns 0 (true) if the given tool name is one this plugin treats as
# a mutating action worth checking.
bg_is_mutating_tool() {
  case "$1" in
    Write | Edit | NotebookEdit | MultiEdit | Bash | create | edit | bash | powershell)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Prints the repo's default branch name (no "origin/" prefix).
bg_default_branch() {
  repo_root="$1"
  ref="$(git -C "$repo_root" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"
  if [ -n "$ref" ]; then
    printf '%s\n' "${ref#origin/}"
  else
    printf '%s\n' "main"
  fi
}

# Prints the list of protected branch names/patterns, one per line.
bg_protected_branches() {
  repo_root="$1"
  override_file="$repo_root/.config/branch-guard/protected-branches"
  if [ -f "$override_file" ]; then
    grep -v '^[[:space:]]*#' "$override_file" | grep -v '^[[:space:]]*$'
    return 0
  fi
  bg_default_branch "$repo_root"
}

# Returns 0 if $1 (branch name) matches any pattern in $2 (newline list).
bg_branch_is_protected() {
  branch="$1"
  patterns="$2"
  old_ifs="$IFS"
  IFS='
'
  matched=1
  set -f
  for pattern in $patterns; do
    case "$branch" in
      $pattern) matched=0 ;;
    esac
  done
  set +f
  IFS="$old_ifs"
  return "$matched"
}

# Core decision: given a cwd and tool name, decides "ask" or "pass".
# Prints "ask:<reason>" or "pass" on stdout.
bg_decide() {
  cwd="$1"
  tool_name="$2"

  if ! bg_is_mutating_tool "$tool_name"; then
    printf 'pass\n'
    return 0
  fi

  repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)"
  if [ -z "$repo_root" ]; then
    # Not inside a git repository (or git failed to answer). Nothing to
    # guard here; fail open rather than asking outside any repo.
    printf 'pass\n'
    return 0
  fi

  branch="$(git -C "$repo_root" symbolic-ref --quiet --short HEAD 2>/dev/null)"
  if [ -z "$branch" ]; then
    # Detached HEAD or unborn branch. Can't confirm this is "the"
    # protected branch; fail open rather than pester during a normal
    # rebase/bisect/cherry-pick workflow.
    printf 'pass\n'
    return 0
  fi

  patterns="$(bg_protected_branches "$repo_root")"
  if bg_branch_is_protected "$branch" "$patterns"; then
    printf 'ask:branch-guard: %s is a protected branch. Approve this action in your harness'"'"'s own permission prompt, or switch to a feature branch.\n' "$branch"
  else
    printf 'pass\n'
  fi
}
