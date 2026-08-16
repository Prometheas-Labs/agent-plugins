#!/usr/bin/env bats

PLUGIN_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

assert_file_exists() {
  [ -f "$1" ] || {
    echo "missing file: $1" >&2
    return 1
  }
}

assert_dir_exists() {
  [ -d "$1" ] || {
    echo "missing directory: $1" >&2
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

manifest_paths() {
  printf '%s\n' \
    "$PLUGIN_ROOT/plugin.json" \
    "$PLUGIN_ROOT/package.json" \
    "$PLUGIN_ROOT/gemini-extension.json" \
    "$PLUGIN_ROOT/.codex-plugin/plugin.json" \
    "$PLUGIN_ROOT/.claude-plugin/plugin.json"
}

assert_manifest_declared_paths_exist() {
  local root="$1"
  shift

  node - "$root" "$@" <<'NODE'
const fs = require("fs");
const path = require("path");

const root = fs.realpathSync(process.argv[2]);
let valid = true;

for (const file of process.argv.slice(3)) {
  const data = JSON.parse(fs.readFileSync(file, "utf8"));
  const collect = (owner, fieldPath) => {
    const value = fieldPath.split(".").reduce((memo, key) => memo && memo[key], owner);
    if (value === undefined) {
      return [];
    }

    if (typeof value === "string") {
      return [{ fieldPath, value }];
    }

    if (!Array.isArray(value)) {
      console.error(`${fieldPath} must be a string or array in ${file}`);
      valid = false;
      return [];
    }

    return value.map((item, index) => {
      if (typeof item !== "string") {
        console.error(`manifest-declared path is not a string in ${file}: ${fieldPath}[${index}]`);
        valid = false;
        return null;
      }
      return { fieldPath, value: item };
    }).filter(Boolean);
  };

  const declaredPaths = [
    ...collect(data, "skills"),
    ...collect(data, "agents"),
    ...collect(data, "commands"),
    ...collect(data, "pi.skills"),
  ];

  for (const { value } of declaredPaths) {
    const declaredPath = value.trim();
    if (declaredPath.length === 0) {
      continue;
    }

    const resolvedPath = path.resolve(root, declaredPath);
    if (resolvedPath !== root && !resolvedPath.startsWith(`${root}${path.sep}`)) {
      console.error(`manifest-declared path resolves outside plugin root in ${file}: ${declaredPath}`);
      valid = false;
      continue;
    }

    if (!fs.existsSync(resolvedPath)) {
      console.error(`manifest-declared path does not exist: ${declaredPath}`);
      valid = false;
    }
  }
}

process.exit(valid ? 0 : 1);
NODE
}

assert_no_manifest_hook_declarations() {
  node - "$@" <<'NODE'
const fs = require("fs");

let valid = true;

function scan(value, file, path = []) {
  if (!value || typeof value !== "object") {
    return;
  }

  if (Array.isArray(value)) {
    value.forEach((item, index) => scan(item, file, [...path, `[${index}]`]));
    return;
  }

  for (const [key, nestedValue] of Object.entries(value)) {
    const nextPath = [...path, key];
    if (/hook/i.test(key)) {
      console.error(`manifest declares hook-like key in ${file}: ${nextPath.join(".")}`);
      valid = false;
    }
    scan(nestedValue, file, nextPath);
  }
}

for (const file of process.argv.slice(2)) {
  scan(JSON.parse(fs.readFileSync(file, "utf8")), file);
}

process.exit(valid ? 0 : 1);
NODE
}

assert_no_npm_lifecycle_scripts() {
  node - "$1" <<'NODE'
const fs = require("fs");

const data = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const scripts = data.scripts || {};
const lifecycle = [
  "preinstall", "install", "postinstall", "prepare",
  "prepack", "pack", "postpack",
  "prepublish", "prepublishOnly", "publish", "postpublish",
];

for (const name of lifecycle) {
  if (Object.prototype.hasOwnProperty.call(scripts, name)) {
    console.error(`lifecycle script is not allowed: ${name}`);
    process.exit(1);
  }
}
NODE
}

@test "plugin manifests exist under plugin package root" {
  assert_file_exists "$PLUGIN_ROOT/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/package.json"
  assert_file_exists "$PLUGIN_ROOT/gemini-extension.json"
  assert_file_exists "$PLUGIN_ROOT/.codex-plugin/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/.claude-plugin/plugin.json"
  assert_file_exists "$PLUGIN_ROOT/README.md"
}

@test "plugin manifests name delivery-engineering and point to the skill tree" {
  assert_file_contains "$PLUGIN_ROOT/plugin.json" '"name": "delivery-engineering"'
  assert_file_contains "$PLUGIN_ROOT/plugin.json" '"skills/review-gated-implementation-loop"'
  assert_file_contains "$PLUGIN_ROOT/package.json" '"name": "delivery-engineering"'
  assert_file_contains "$PLUGIN_ROOT/package.json" '"skills/review-gated-implementation-loop"'
  assert_file_contains "$PLUGIN_ROOT/.codex-plugin/plugin.json" '"skills": "./skills/"'
  assert_file_contains "$PLUGIN_ROOT/.claude-plugin/plugin.json" '"./skills/review-gated-implementation-loop"'
}

@test "review-gated-implementation-loop skill layout exists under plugin package" {
  assert_file_exists "$PLUGIN_ROOT/skills/review-gated-implementation-loop/SKILL.md"
  assert_dir_exists "$PLUGIN_ROOT/skills/review-gated-implementation-loop/resources"
  assert_file_exists "$PLUGIN_ROOT/skills/review-gated-implementation-loop/resources/index.md"
  assert_dir_exists "$PLUGIN_ROOT/skills/review-gated-implementation-loop/resources/templates"
}

@test "plugin manifests parse as JSON" {
  while IFS= read -r file; do
    node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$file"
  done < <(manifest_paths)
}

@test "manifest-declared paths exist inside plugin package" {
  local manifests=()
  while IFS= read -r file; do
    manifests+=("$file")
  done < <(manifest_paths)

  assert_manifest_declared_paths_exist "$PLUGIN_ROOT" "${manifests[@]}"
}

@test "plugin manifests declare no hooks" {
  local manifests=()
  while IFS= read -r file; do
    manifests+=("$file")
  done < <(manifest_paths)

  assert_no_manifest_hook_declarations "${manifests[@]}"
}

@test "plugin package declares no npm lifecycle scripts" {
  assert_no_npm_lifecycle_scripts "$PLUGIN_ROOT/package.json"
}

@test "runtime hooks are absent from the plugin package" {
  [ ! -e "$PLUGIN_ROOT/hooks.json" ]
  [ ! -e "$PLUGIN_ROOT/hooks" ]
}
