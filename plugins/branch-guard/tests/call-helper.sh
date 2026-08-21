#!/bin/sh
# Test helper: sources guard-common.sh and calls the named function
# with the given arguments, printing its output. Not shipped as part
# of the plugin itself.
DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$DIR/scripts/guard-common.sh"
fn="$1"
shift
"$fn" "$@"
