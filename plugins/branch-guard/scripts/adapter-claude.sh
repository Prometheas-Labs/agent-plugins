#!/bin/sh
# Claude Code PreToolUse adapter for branch-guard.
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
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$escaped_reason"
    ;;
esac

exit 0
