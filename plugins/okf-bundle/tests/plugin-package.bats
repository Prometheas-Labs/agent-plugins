#!/usr/bin/env bats

PLUGIN_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SKILL_ROOT="$PLUGIN_ROOT/skills/okf-bundle"
EXAMPLE_ROOT="$SKILL_ROOT/references/example-bundle"
SPEC_COMMIT="0b87c52c6ef999286c745e19998fdfcd03d5dbee"

assert_file_exists() {
  [ -f "$1" ] || {
    echo "missing file: $1" >&2
    return 1
  }
}

json_get() {
  local file="$1"
  local expression="$2"
  node -e '
const fs = require("fs");
const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const fn = new Function("data", `return (${process.argv[2]});`);
const value = fn(data);
console.log(typeof value === "string" ? value : JSON.stringify(value));
' "$file" "$expression"
}

# Prints the frontmatter block of a markdown file, without its delimiters.
frontmatter() {
  awk 'NR == 1 && $0 != "---" { exit } NR == 1 { next } $0 == "---" { exit } { print }' "$1"
}

@test "plugin manifests exist and declare okf-bundle" {
  assert_file_exists "$PLUGIN_ROOT/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/.claude-plugin/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/.codex-plugin/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/gemini-extension.json"

  [ "$(json_get "$PLUGIN_ROOT/plugin.json" "data.name")" = "okf-bundle" ]
  [ "$(json_get "$PLUGIN_ROOT/.claude-plugin/plugin.json" "data.name")" = "okf-bundle" ]
  [ "$(json_get "$PLUGIN_ROOT/.codex-plugin/plugin.json" "data.name")" = "okf-bundle" ]
  [ "$(json_get "$PLUGIN_ROOT/gemini-extension.json" "data.name")" = "okf-bundle" ]
}

@test "plugin ships no scripts, hooks, or runtime dependencies" {
  [ ! -e "$PLUGIN_ROOT/hooks" ]
  [ ! -e "$PLUGIN_ROOT/scripts" ]
  [ ! -e "$SKILL_ROOT/scripts" ]
  [ ! -e "$PLUGIN_ROOT/package.json" ]
}

@test "skill frontmatter names the skill and states its triggers" {
  assert_file_exists "$SKILL_ROOT/SKILL.md"
  frontmatter "$SKILL_ROOT/SKILL.md" | grep -qx 'name: okf-bundle'
  frontmatter "$SKILL_ROOT/SKILL.md" | grep -q '^description: Use when '
}

@test "every relative link in the skill resolves" {
  local file target
  while IFS= read -r file; do
    # The example bundle is checked below; templates hold placeholder links.
    case "$file" in "$EXAMPLE_ROOT"/* | "$SKILL_ROOT/templates"/*) continue ;; esac
    while IFS= read -r target; do
      case "$target" in http://* | https://* | /* | "#"*) continue ;; esac
      [ -e "$(dirname "$file")/${target%%#*}" ] || {
        echo "broken link in $file: $target" >&2
        return 1
      }
    done < <(grep -oE '\]\([^)]+\)' "$file" | sed -E 's/^\]\(//; s/\)$//')
  done < <(find "$SKILL_ROOT" -name '*.md')
}

@test "skill links the spec only at the pinned commit" {
  grep -q "open-knowledge-format/blob/$SPEC_COMMIT/SPEC.md" "$SKILL_ROOT/SKILL.md"
  ! grep -rE 'open-knowledge-format/(blob|tree)/main' "$PLUGIN_ROOT"
}

okf_check() {
  python3 -I "$BATS_TEST_DIRNAME/okf_check.py" "$@"
}

# Copies the example bundle so a test can break one thing in it.
example_copy() {
  cp -R "$EXAMPLE_ROOT" "$BATS_TEST_TMPDIR/bundle"
  echo "$BATS_TEST_TMPDIR/bundle"
}

@test "example bundle meets the three OKF section 11 conformance rules" {
  [ "$(find "$EXAMPLE_ROOT" -name '*.md' ! -name index.md ! -name log.md | wc -l)" -gt 0 ]
  okf_check conformance "$EXAMPLE_ROOT"
}

@test "conformance check rejects each kind of section 11 breakage" {
  local bundle
  while IFS='|' read -r label file script; do
    rm -rf "$BATS_TEST_TMPDIR/bundle"
    bundle="$(example_copy)"
    perl -0pi -e "$script" "$bundle/$file"
    if okf_check conformance "$bundle" >/dev/null; then
      echo "conformance check accepted: $label" >&2
      return 1
    fi
  done <<'CASES'
invalid yaml|metrics/mrr.md|s/^status: stable$/tags: [unterminated/m
unclosed frontmatter|metrics/churn.md|s/\A(---\n.*?\n)---\n/$1/s
empty type|metrics/churn.md|s/^type: .*$/type: ""/m
nested index frontmatter|metrics/index.md|s/\A/---\ntitle: Metrics\n---\n/
index of prose|metrics/index.md|s/^\* .*$/Some prose about metrics./mg
log entry outside a date group|log.md|s/\A# Bundle history\n/# Bundle history\n\nStray note.\n/
log oldest first|log.md|s/2026-06-25/2026-06-19/
index omits a concept|metrics/index.md|s/^\* \[Logo Churn\].*\n//m
heading-only index|metrics/index.md|s/^\* .*\n//mg
impossible log date|log.md|s/2026-06-25/2026-99-99/
heading after the date groups|log.md|s/\z/\n# Later\n\n* Undated note.\n/
CASES
}

@test "example bundle links and footnotes resolve" {
  local file target
  okf_check footnotes "$EXAMPLE_ROOT"
  while IFS= read -r file; do
    while IFS= read -r target; do
      case "$target" in
        http://* | https://*) continue ;;
        /*) [ -e "$EXAMPLE_ROOT$target" ] ;;
        *) [ -e "$(dirname "$file")/$target" ] ;;
      esac || {
        echo "broken link in $file: $target" >&2
        return 1
      }
    done < <(grep -oE '\]\([^)]+\)' "$file" | sed -E 's/^\]\(//; s/\)$//')
  done < <(find "$EXAMPLE_ROOT" -name '*.md')
}

@test "footnote check rejects undefined and unmatched labels" {
  local bundle
  bundle="$(example_copy)"
  printf '\nAn unsupported claim.[^ghost]\n' >> "$bundle/metrics/churn.md"
  run okf_check footnotes "$bundle"
  [ "$status" -eq 1 ]

  rm -rf "$bundle"
  bundle="$(example_copy)"
  perl -0pi -e 's/\[\^finance-handbook\]/[^handbook]/g' "$bundle/metrics/mrr.md"
  run okf_check footnotes "$bundle"
  [ "$status" -eq 1 ]

  rm -rf "$bundle"
  bundle="$(example_copy)"
  printf '\nPolicy[^ghost]: follow the approved process.\n' >> "$bundle/metrics/churn.md"
  run okf_check footnotes "$bundle"
  [ "$status" -eq 1 ]
}

@test "example and templates write v0.2 forms only" {
  ! grep -rE '^timestamp:|^# Citations' "$EXAMPLE_ROOT" "$SKILL_ROOT/templates"
}

@test "example timestamps are datetimes with an explicit offset" {
  local file value
  while IFS= read -r file; do
    while IFS= read -r value; do
      echo "$value" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(Z|[+-][0-9]{2}:[0-9]{2})$' || {
        echo "bad timestamp in $file: $value" >&2
        return 1
      }
    done < <(frontmatter "$file" | grep -oE '(^|[ {])(at|stale_after|last_modified|from|to): *[^ ,}]+' | sed -E 's/^[ {]*[a-z_]+: *//')
  done < <(find "$EXAMPLE_ROOT" -name '*.md' ! -name index.md ! -name log.md)
}

@test "skill keeps timestamps out of flow-style YAML mappings" {
  ! grep -rE '\{[^}]*(at|from|to): *([0-9]|<)' "$SKILL_ROOT"
}

@test "plugin is Apache-2.0 licensed and NOTICE credits the OKF specification" {
  assert_file_exists "$PLUGIN_ROOT/LICENSE"
  grep -q "Apache License" "$PLUGIN_ROOT/LICENSE"
  assert_file_exists "$PLUGIN_ROOT/NOTICE"
  grep -q 'Google LLC' "$PLUGIN_ROOT/NOTICE"
  grep -q 'Apache License' "$PLUGIN_ROOT/NOTICE"
}
