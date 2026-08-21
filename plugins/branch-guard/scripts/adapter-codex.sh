#!/bin/sh
# Codex PreToolUse adapter for branch-guard.
#
# This plugin directs, it doesn't block: on a protected branch it adds
# a model-visible reminder via "additionalContext" and lets the action
# proceed. It deliberately never sets "permissionDecision", so it's
# never granting or denying anything on its own authority -- the
# action proceeds exactly as it would with no hook installed, just
# with a note attached. A repository that wants an actual block should
# install the repo-side pre-commit hook (see install-defense-hook.sh)
# or use real git host branch protection; that's a deliberate choice,
# not a limitation to work around here.
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./guard-common.sh
. "$DIR/guard-common.sh"

input="$(cat)"
tool_name="$(bg_json_field "$input" "tool_name")"
cwd="$(bg_json_field "$input" "cwd")"

result="$(bg_decide "$cwd" "$tool_name")"

case "$result" in
  ask:*)
    reason="${result#ask:}"
    escaped_reason=$(printf '%s' "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$escaped_reason"
    ;;
esac

exit 0
