#!/usr/bin/env bats

# Tests for scripts/init.sh — product documentation initialization

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
INIT_SCRIPT="$SCRIPT_DIR/scripts/init.sh"

setup() {
  TEST_PROJECT="$(mktemp -d)"
}

teardown() {
  rm -rf "$TEST_PROJECT"
}

# --- Scaffolding ---

@test "creates docs/product/README.md" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "TestApp"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/docs/product/README.md" ]
}

@test "creates docs/product/AGENTS.md" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "TestApp"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/docs/product/AGENTS.md" ]
}

@test "creates docs/product/features/ directory" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "TestApp"
  [ "$status" -eq 0 ]
  [ -d "$TEST_PROJECT/docs/product/features" ]
}

# --- Placeholder substitution ---

@test "substitutes project name in README" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "Eirene"
  grep -q "Product documentation for Eirene" "$TEST_PROJECT/docs/product/README.md"
}

@test "humanizes surfaces in boundary rule prose" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X" --surfaces "mobile,web,tv"
  grep -q "a phone, a browser, or a TV" "$TEST_PROJECT/docs/product/README.md"
}

@test "humanizes two surfaces without Oxford comma" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X" --surfaces "mobile,web"
  grep -q "a phone or a browser" "$TEST_PROJECT/docs/product/README.md"
}

@test "humanizes single surface without 'or'" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X" --surfaces "mobile"
  grep -q "a phone" "$TEST_PROJECT/docs/product/README.md"
}

@test "passes through unknown surface names" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X" --surfaces "desktop"
  grep -q "desktop" "$TEST_PROJECT/docs/product/README.md"
}

@test "substitutes platform scenario example in quotes" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X" \
    --platform-scenario-example "All sessions have a pause button."
  grep -q '"All sessions have a pause button."' "$TEST_PROJECT/docs/product/README.md"
}

@test "substitutes surface scenario example in quotes" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X" \
    --surface-scenario-example "Double-tap pauses the session."
  grep -q '"Double-tap pauses the session."' "$TEST_PROJECT/docs/product/README.md"
}

# --- Skip existing files ---

@test "skips README if it already exists" {
  mkdir -p "$TEST_PROJECT/docs/product"
  echo "existing content" > "$TEST_PROJECT/docs/product/README.md"

  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "NewName"
  [ "$status" -eq 0 ]

  # Original content preserved
  grep -q "existing content" "$TEST_PROJECT/docs/product/README.md"
  # New content not written
  ! grep -q "NewName" "$TEST_PROJECT/docs/product/README.md"
}

@test "skips AGENTS.md if it already exists" {
  mkdir -p "$TEST_PROJECT/docs/product"
  echo "existing agents" > "$TEST_PROJECT/docs/product/AGENTS.md"

  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "NewName"
  [ "$status" -eq 0 ]

  grep -q "existing agents" "$TEST_PROJECT/docs/product/AGENTS.md"
}

@test "skips features directory if it already exists" {
  mkdir -p "$TEST_PROJECT/docs/product/features/analytics"

  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  [ "$status" -eq 0 ]

  # Existing subdirectory preserved
  [ -d "$TEST_PROJECT/docs/product/features/analytics" ]
}

@test "reports SKIP for existing files" {
  mkdir -p "$TEST_PROJECT/docs/product"
  echo "existing" > "$TEST_PROJECT/docs/product/README.md"

  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  [[ "$output" == *"SKIP"* ]]
}

# --- Auto-detection ---

@test "detects project name from package.json" {
  echo '{"name": "my-cool-project", "version": "1.0.0"}' > "$TEST_PROJECT/package.json"

  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive
  [ "$status" -eq 0 ]
  grep -q "my-cool-project" "$TEST_PROJECT/docs/product/README.md"
}

@test "falls back to directory name when no package.json" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive
  [ "$status" -eq 0 ]

  # Should use the temp directory basename (varies per run, just check it was substituted)
  ! grep -q "{{PROJECT_NAME}}" "$TEST_PROJECT/docs/product/README.md"
}

@test "detects surfaces from apps/ subdirectories" {
  mkdir -p "$TEST_PROJECT/apps/mobile" "$TEST_PROJECT/apps/tv"

  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  [ "$status" -eq 0 ]
  # Surfaces are humanized: mobile → "a phone", tv → "a TV"
  grep -q "a phone" "$TEST_PROJECT/docs/product/README.md"
  grep -q "a TV" "$TEST_PROJECT/docs/product/README.md"
}

@test "detects existing feature directories with trailing slash for AGENTS.md" {
  mkdir -p "$TEST_PROJECT/docs/product/features/analytics"
  mkdir -p "$TEST_PROJECT/docs/product/features/error-tracking"

  # Only README and features/ exist, not AGENTS.md — so AGENTS.md gets created
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  [ "$status" -eq 0 ]
  grep -q '`analytics/`' "$TEST_PROJECT/docs/product/AGENTS.md"
  grep -q '`error-tracking/`' "$TEST_PROJECT/docs/product/AGENTS.md"
}

# --- Dry run ---

@test "dry run creates no files" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X" --dry-run
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_PROJECT/docs/product/README.md" ]
  [ ! -f "$TEST_PROJECT/docs/product/AGENTS.md" ]
}

@test "dry run reports WOULD CREATE" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X" --dry-run
  [[ "$output" == *"WOULD CREATE"* ]]
}

# --- Error handling ---

@test "fails when no project root given" {
  run "$INIT_SCRIPT"
  [ "$status" -ne 0 ]
}

@test "fails when project root does not exist" {
  run "$INIT_SCRIPT" "/nonexistent/path" --non-interactive
  [ "$status" -ne 0 ]
}

# --- Template completeness ---

@test "no unsubstituted placeholders in README" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X" --surfaces "mobile"
  [ "$status" -eq 0 ]
  ! grep -q '{{' "$TEST_PROJECT/docs/product/README.md"
}

@test "no unsubstituted placeholders in AGENTS.md" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  [ "$status" -eq 0 ]
  ! grep -q '{{' "$TEST_PROJECT/docs/product/AGENTS.md"
}

# --- Output structure ---

@test "README contains artifact flow section" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  grep -q "## Artifact flow" "$TEST_PROJECT/docs/product/README.md"
}

@test "README contains boundary rule section" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  grep -q "## Boundary rule" "$TEST_PROJECT/docs/product/README.md"
}

@test "README contains directory structure section" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  grep -q "## Directory structure" "$TEST_PROJECT/docs/product/README.md"
}

@test "AGENTS.md references README" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  grep -q "README.md" "$TEST_PROJECT/docs/product/AGENTS.md"
}

@test "AGENTS.md contains specification evolution section" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  grep -q "Specification evolution" "$TEST_PROJECT/docs/product/AGENTS.md"
}

@test "AGENTS.md references METHODOLOGY.md" {
  run "$INIT_SCRIPT" "$TEST_PROJECT" --non-interactive --project-name "X"
  grep -q "METHODOLOGY.md" "$TEST_PROJECT/docs/product/AGENTS.md"
}
