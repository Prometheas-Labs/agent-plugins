#!/bin/sh
# GitHub Copilot CLI preToolUse adapter for branch-guard. Reads
# camelCase field names (toolName, cwd), unlike Claude Code/Codex's
# snake_case (tool_name, cwd).
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./guard-common.sh
. "$DIR/guard-common.sh"

input="$(cat)"
tool_name="$(bg_json_field "$input" "toolName")"
cwd="$(bg_json_field "$input" "cwd")"

result="$(bg_decide "$cwd" "$tool_name")"

case "$result" in
  ask:*)
    reason="${result#ask:}"
    escaped_reason=$(printf '%s' "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"permissionDecision":"ask","permissionDecisionReason":"%s"}\n' "$escaped_reason"
    ;;
esac

exit 0
