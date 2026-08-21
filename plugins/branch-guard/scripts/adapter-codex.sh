#!/bin/sh
# Codex PreToolUse adapter for branch-guard.
#
# Codex's PreToolUse wire schema accepts a "permissionDecision":"ask"
# value, but Codex does not implement it yet -- returning it "fails
# open" and the tool call proceeds anyway. Exit code 2 is documented
# and does work as a hard, fail-closed block, so that's what this
# adapter uses instead of an interactive prompt: a real behavior
# difference from Claude Code and Copilot CLI, not an oversight.
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
    printf '%s\n' "$reason" >&2
    exit 2
    ;;
esac

exit 0
