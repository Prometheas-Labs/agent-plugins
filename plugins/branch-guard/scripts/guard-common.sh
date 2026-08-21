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
# plugin's hook payloads need. Uses awk rather than `grep -o`, which
# POSIX doesn't specify; if some grep lacks -o, bg_json_field would
# silently return empty and every action would be misclassified as
# non-mutating.
bg_json_field() {
  json="$1"
  key="$2"
  printf '%s' "$json" | awk -v key="$key" '
    {
      prefix = "\"" key "\"[[:space:]]*:[[:space:]]*\""
      if (match($0, prefix)) {
        value = substr($0, RSTART + RLENGTH)
        sub(/".*$/, "", value)
        print value
        exit
      }
    }
  '
}

# Returns 0 (true) if the given tool name is one this plugin treats as
# a mutating action worth checking. Includes apply_patch: that's
# Codex's canonical tool_name for file mutations (Write/Edit are
# matcher aliases Codex also accepts, but the hook payload's tool_name
# is apply_patch), so omitting it would silently miss real Codex edits.
bg_is_mutating_tool() {
  case "$1" in
    Write | Edit | NotebookEdit | MultiEdit | Bash | apply_patch | create | edit | bash | powershell)
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

# Prints the list of protected branch names/patterns, one per line:
# the repo's detected default branch, a handful of other conventional
# names, and anything an optional override file adds on top. The
# built-in names are always present (not replaced by the override
# file), so an override file that's empty, comment-only, or missing
# never results in "nothing is protected."
bg_protected_branches() {
  repo_root="$1"
  bg_default_branch "$repo_root"
  # "main" is always included, not just as bg_default_branch's
  # fallback: if the repo's detected default is something else (say
  # "trunk"), a "main" branch left over from before that switch, or
  # kept around for other reasons, should still be protected.
  printf '%s\n' "main" "master" "production" "develop" "development"
  override_file="$repo_root/.config/branch-guard/protected-branches"
  if [ -f "$override_file" ]; then
    # Strip trailing "# comment" text (not just whole-line comments)
    # before dropping blank lines, so "release  # note" is honored as
    # "release" rather than kept as a literal, never-matching pattern.
    sed 's/#.*$//' "$override_file" | sed 's/[[:space:]]*$//' | grep -v '^[[:space:]]*$'
  fi
  return 0
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
    printf 'ask:branch-guard: %s is a protected branch. Consider switching to a feature branch, or confirm this change is intentional before continuing.\n' "$branch"
  else
    printf 'pass\n'
  fi
}
