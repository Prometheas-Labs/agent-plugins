#!/bin/sh
# Test helper: sources guard-common.sh and calls bg_decide with the
# given cwd and tool name. Not shipped as part of the plugin itself.
DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$DIR/scripts/guard-common.sh"
bg_decide "$1" "$2"
