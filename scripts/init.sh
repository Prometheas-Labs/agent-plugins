#!/usr/bin/env bash
set -euo pipefail

# init.sh — Initialize product documentation structure for a project.
#
# Usage:
#   ./init.sh <project-root> [options]
#
# Options:
#   --project-name NAME                 Project name (used in headings)
#   --surfaces "mobile,web,tv"          Comma-separated list of app surfaces
#   --surface-scenario-example TEXT      Short surface-specific scenario example
#   --platform-scenario-example TEXT     Short platform-level scenario example
#   --dry-run                            Show what would be created without writing
#
# When an option is omitted, the script prompts interactively.
# When --non-interactive is set, missing options use sensible defaults.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

# --- Defaults ---
PROJECT_ROOT=""
PROJECT_NAME=""
SURFACES=""
SURFACE_SCENARIO_EXAMPLE=""
PLATFORM_SCENARIO_EXAMPLE=""
DRY_RUN=false
NON_INTERACTIVE=false

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-name)
      [[ -z "${2:-}" || "$2" == --* ]] && { echo "Error: --project-name requires a value" >&2; exit 1; }
      PROJECT_NAME="$2"; shift 2 ;;
    --surfaces)
      [[ -z "${2:-}" || "$2" == --* ]] && { echo "Error: --surfaces requires a value" >&2; exit 1; }
      SURFACES="$2"; shift 2 ;;
    --surface-scenario-example)
      [[ -z "${2:-}" || "$2" == --* ]] && { echo "Error: --surface-scenario-example requires a value" >&2; exit 1; }
      SURFACE_SCENARIO_EXAMPLE="$2"; shift 2 ;;
    --platform-scenario-example)
      [[ -z "${2:-}" || "$2" == --* ]] && { echo "Error: --platform-scenario-example requires a value" >&2; exit 1; }
      PLATFORM_SCENARIO_EXAMPLE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --non-interactive) NON_INTERACTIVE=true; shift ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

if [[ -z "$PROJECT_ROOT" ]]; then
  echo "Usage: init.sh <project-root> [options]" >&2
  exit 1
fi

# --- Resolve project root ---
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

# --- Interactive prompts for missing values ---
prompt() {
  local var_name="$1" prompt_text="$2" default="$3"
  local current_val="${!var_name}"

  if [[ -n "$current_val" ]]; then
    return
  fi

  if $NON_INTERACTIVE; then
    printf -v "$var_name" '%s' "$default"
    return
  fi

  if [[ -n "$default" ]]; then
    read -rp "$prompt_text [$default]: " input
    printf -v "$var_name" '%s' "${input:-$default}"
  else
    read -rp "$prompt_text: " input
    printf -v "$var_name" '%s' "$input"
  fi
}

# --- Detect project context ---
detect_project_name() {
  if [[ -n "$PROJECT_NAME" ]]; then return; fi
  # Try package.json name, then directory name
  if [[ -f "$PROJECT_ROOT/package.json" ]]; then
    local pkg_name
    pkg_name=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_ROOT/package.json" | head -1 | sed 's/.*"name"[[:space:]]*:[[:space:]]*"//' | sed 's/"//')
    if [[ -n "$pkg_name" ]]; then
      PROJECT_NAME="$pkg_name"
    fi
  fi
  if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME="$(basename "$PROJECT_ROOT")"
  fi
}

detect_surfaces() {
  if [[ -n "$SURFACES" ]]; then return; fi
  if [[ -d "$PROJECT_ROOT/apps" ]]; then
    SURFACES=$(find "$PROJECT_ROOT/apps" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort | tr '\n' ',' | sed 's/,$//')
  fi
}

detect_project_name
detect_surfaces

# --- Prompt for remaining values ---
prompt PROJECT_NAME "Project name" "$PROJECT_NAME"
prompt SURFACES "App surfaces (comma-separated)" "${SURFACES:-mobile}"
prompt PLATFORM_SCENARIO_EXAMPLE \
  "Example platform-level scenario (surface-neutral)" \
  "Error reports for non-consented users contain no persistent identifier."
prompt SURFACE_SCENARIO_EXAMPLE \
  "Example surface-specific scenario (bound to interaction model)" \
  "Swiping down during a breathing round triggers haptic feedback."

# --- Derived values ---
# Map surface directory names to human-friendly prose
humanize_surface() {
  case "$1" in
    mobile) echo "a phone" ;;
    tv)     echo "a TV" ;;
    web)    echo "a browser" ;;
    watch)  echo "a watch" ;;
    vr)     echo "a VR headset" ;;
    *)      echo "$1" ;;
  esac
}

# "a phone, TV, or VR headset" style prose from surfaces list
IFS=',' read -ra SURFACE_ARRAY <<< "$SURFACES"
if [[ ${#SURFACE_ARRAY[@]} -eq 1 ]]; then
  SURFACE_LIST_PROSE="$(humanize_surface "${SURFACE_ARRAY[0]}")"
elif [[ ${#SURFACE_ARRAY[@]} -eq 2 ]]; then
  SURFACE_LIST_PROSE="$(humanize_surface "${SURFACE_ARRAY[0]}") or $(humanize_surface "${SURFACE_ARRAY[1]}")"
else
  SURFACE_LIST_PROSE=""
  for i in "${!SURFACE_ARRAY[@]}"; do
    s="$(humanize_surface "${SURFACE_ARRAY[$i]// /}")"
    if [[ $i -eq $(( ${#SURFACE_ARRAY[@]} - 1 )) ]]; then
      SURFACE_LIST_PROSE="${SURFACE_LIST_PROSE}or $s"
    else
      SURFACE_LIST_PROSE="${SURFACE_LIST_PROSE}$s, "
    fi
  done
fi

# Short form for scenario hint (e.g., "haptic feedback on swipe, D-pad navigation")
SURFACE_SCENARIO_SHORT="${SURFACE_SCENARIO_EXAMPLE%%.*}"
SURFACE_SCENARIO_SHORT="${SURFACE_SCENARIO_SHORT%%—*}"
SURFACE_SCENARIO_SHORT="$(echo "$SURFACE_SCENARIO_SHORT" | sed 's/[[:space:]]*$//')"

# Example features line (blank if no features directory exists)
EXAMPLE_FEATURES_LINE=""
if [[ -d "$PROJECT_ROOT/docs/product/features" ]]; then
  features=$(ls -1 "$PROJECT_ROOT/docs/product/features" 2>/dev/null | head -5 | sed 's/^/`/' | sed 's/$/\/`/' | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
  if [[ -n "$features" ]]; then
    EXAMPLE_FEATURES_LINE="- Use the existing feature directories as examples: ${features}."
  fi
fi

# --- Template substitution ---

# Escape sed replacement special characters: & \ |
escape_sed() {
  printf '%s' "$1" | sed -e 's/[&\\|]/\\&/g'
}

substitute() {
  local template="$1"
  local esc_project_name esc_surfaces esc_surface_prose esc_platform_ex esc_surface_ex esc_surface_ex_full esc_features
  esc_project_name="$(escape_sed "$PROJECT_NAME")"
  esc_surfaces="$(escape_sed "$SURFACES")"
  esc_surface_prose="$(escape_sed "$SURFACE_LIST_PROSE")"
  esc_platform_ex="$(escape_sed "$PLATFORM_SCENARIO_EXAMPLE")"
  esc_surface_ex="$(escape_sed "$SURFACE_SCENARIO_SHORT")"
  esc_surface_ex_full="$(escape_sed "$SURFACE_SCENARIO_EXAMPLE")"
  esc_features="$(escape_sed "$EXAMPLE_FEATURES_LINE")"
  sed \
    -e "s|{{PROJECT_NAME}}|${esc_project_name}|g" \
    -e "s|{{SURFACES}}|${esc_surfaces}|g" \
    -e "s|{{SURFACE_LIST_PROSE}}|${esc_surface_prose}|g" \
    -e "s|{{PLATFORM_SCENARIO_EXAMPLE}}|${esc_platform_ex}|g" \
    -e "s|{{SURFACE_SCENARIO_EXAMPLE}}|${esc_surface_ex}|g" \
    -e "s|{{SURFACE_SCENARIO_EXAMPLE_FULL}}|${esc_surface_ex_full}|g" \
    -e "$(if [[ -n "$esc_features" ]]; then echo "s|{{EXAMPLE_FEATURES_LINE}}|${esc_features}|g"; else echo "/{{EXAMPLE_FEATURES_LINE}}/d"; fi)" \
    "$template"
}

# --- File generation ---
generate() {
  local template="$1" target="$2"

  if [[ -f "$target" ]]; then
    echo "  SKIP  $target (already exists)"
    return
  fi

  if $DRY_RUN; then
    echo "  WOULD CREATE  $target"
    return
  fi

  mkdir -p "$(dirname "$target")"
  substitute "$template" > "$target"
  echo "  CREATE  $target"
}

echo ""
echo "Initializing product documentation for $PROJECT_NAME"
echo "  Project root: $PROJECT_ROOT"
echo "  Surfaces:     $SURFACES"
echo ""

generate "$TEMPLATE_DIR/README.md.tmpl" "$PROJECT_ROOT/docs/product/README.md"
generate "$TEMPLATE_DIR/AGENTS.md.tmpl" "$PROJECT_ROOT/docs/product/AGENTS.md"

# Create features directory
if [[ ! -d "$PROJECT_ROOT/docs/product/features" ]]; then
  if $DRY_RUN; then
    echo "  WOULD CREATE  $PROJECT_ROOT/docs/product/features/"
  else
    mkdir -p "$PROJECT_ROOT/docs/product/features"
    echo "  CREATE  $PROJECT_ROOT/docs/product/features/"
  fi
else
  echo "  SKIP  $PROJECT_ROOT/docs/product/features/ (already exists)"
fi

echo ""
echo "Done. Next steps:"
echo "  1. Review the generated files under docs/product/"
echo "  2. Create docs/product/constitution.md and docs/product/vision.md if they don't exist"
echo "  3. Start your first feature with: docs/product/features/{feature}/PRD.md"
