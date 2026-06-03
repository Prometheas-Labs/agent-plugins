#!/usr/bin/env bats

PLUGIN_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
REPO_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)"

assert_file_exists() {
  [ -f "$1" ] || {
    echo "missing file: $1" >&2
    return 1
  }
}

assert_file_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || {
    echo "missing expected text in $file: $expected" >&2
    return 1
  }
}

shared_command_paths() {
  printf '%s\n' \
    "$PLUGIN_ROOT/commands/shared/init-product-docs.md" \
    "$PLUGIN_ROOT/commands/shared/create-constitution.md" \
    "$PLUGIN_ROOT/commands/shared/create-vision.md" \
    "$PLUGIN_ROOT/commands/shared/write-prd.md"
}

shared_agent_paths() {
  printf '%s\n' \
    "$PLUGIN_ROOT/agents/shared/product-researcher.md" \
    "$PLUGIN_ROOT/agents/shared/spec-reviewer.md" \
    "$PLUGIN_ROOT/agents/shared/plan-reviewer.md" \
    "$PLUGIN_ROOT/agents/shared/implementation-auditor.md"
}

@test "plugin manifests exist under plugin package root" {
  assert_file_exists "$PLUGIN_ROOT/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/package.json"
  assert_file_exists "$PLUGIN_ROOT/gemini-extension.json"
  assert_file_exists "$PLUGIN_ROOT/.codex-plugin/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/.claude-plugin/plugin.json"
}

@test "plugin manifests name product-development and point to moved skill tree" {
  assert_file_contains "$PLUGIN_ROOT/plugin.json" '"name": "product-development"'
  assert_file_contains "$PLUGIN_ROOT/plugin.json" '"skills/product-development"'
  assert_file_contains "$PLUGIN_ROOT/package.json" '"name": "product-development"'
  assert_file_contains "$PLUGIN_ROOT/package.json" '"skills/product-development"'
  assert_file_contains "$PLUGIN_ROOT/.codex-plugin/plugin.json" '"skills": "./skills/"'
  assert_file_contains "$PLUGIN_ROOT/.claude-plugin/plugin.json" '"./skills/product-development"'
}

@test "canonical product-development skill layout moved under plugin package" {
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/SKILL.md"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/scripts/init.sh"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/tests/init.bats"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/templates/README.md.tmpl"
  assert_file_exists "$PLUGIN_ROOT/skills/product-development/templates/AGENTS.md.tmpl"
}

@test "shared commands route to canonical methodology" {
  while IFS= read -r file; do
    assert_file_exists "$file"
    assert_file_contains "$file" "product-development skill"
    grep -Eq 'canonical methodology|canonical skill|skills/product-development/SKILL.md' "$file" || {
      echo "command wrapper does not route to canonical skill: $file" >&2
      return 1
    }
  done < <(shared_command_paths)
}

@test "shared agents route to canonical methodology" {
  while IFS= read -r file; do
    assert_file_exists "$file"
    grep -Eq 'product-development skill|canonical methodology|skills/product-development/SKILL.md' "$file" || {
      echo "agent wrapper does not route to canonical skill: $file" >&2
      return 1
    }
  done < <(shared_agent_paths)
}

@test "adapter files do not duplicate methodology headings" {
  while IFS= read -r file; do
    assert_file_exists "$file"
    ! grep -Eq '^#+ (Foundation Gate|Product Constitution|Product Vision|Requirements Workflow|Technical Design|User Stories|Scenarios|Acceptance Criteria)' "$file" || {
      echo "adapter file duplicates methodology heading: $file" >&2
      return 1
    }
  done < <(
    shared_command_paths
    shared_agent_paths
  )
}
