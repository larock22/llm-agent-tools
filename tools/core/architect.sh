#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# architect.sh – Architecture documentation management for LLM agents
#
# Commands:
#   init                          → Initialize architecture docs
#   map [--update]               → Generate/update repository map
#   describe <file> <desc>       → Add/update file description
#   add-module <name> <desc>     → Document architectural module
#   add-decision <title>         → Record architectural decision
#   add-flow <name>              → Document process/data flow
#   link <file> <module>         → Link files to modules
#   search <term>                → Search all architecture docs
#   status                       → Show documentation coverage
#   export                       → Generate full architecture doc
#
# ──────────────────────────────────────────────────────────────
set -euo pipefail

BANK_DIR="memory-bank"
ARCH_DIR="$BANK_DIR/architecture"
REPO_MAP="$ARCH_DIR/repo_map.md"
MODULES_DIR="$ARCH_DIR/modules"
DECISIONS_DIR="$ARCH_DIR/decisions"
FLOWS_DIR="$ARCH_DIR/flows"
DEPS_FILE="$ARCH_DIR/dependencies.md"
METADATA="$ARCH_DIR/.metadata.json"

# ──────────────────────────────────────────────────────────────
usage() {
  cat >&2 <<EOF
Usage: $0 {init|map|describe|add-module|add-decision|add-flow|link|search|status|export} [...]

Commands:
  init                        Initialize architecture documentation
  map [--update]             Generate or update repository map
  describe <file> <desc>     Add/update description for a file
  add-module <name> <desc>   Document an architectural module
  add-decision <title>       Record an architectural decision
  add-flow <name>            Document a process/data flow
  link <file> <module>       Link files to architectural modules
  search <term>              Search across all documentation
  status                     Show documentation coverage stats
  export                     Generate complete architecture document
EOF
  exit 1
}

# ───────────────────── helpers ────────────────────────────
ensure_init() {
  [[ -d "$ARCH_DIR" ]] || { 
    echo "ERROR: Architecture not initialized. Run '$0 init' first." >&2
    exit 1
  }
}

get_file_desc() {
  local file="$1"
  [[ -f "$METADATA" ]] && jq -r ".files[\"$file\"].description // empty" "$METADATA" 2>/dev/null || echo ""
}

set_file_desc() {
  local file="$1"
  local desc="$2"
  if [[ ! -f "$METADATA" ]]; then
    echo '{"files":{}}' > "$METADATA"
  fi
  jq --arg f "$file" --arg d "$desc" '.files[$f].description = $d' "$METADATA" > "$METADATA.tmp" && mv "$METADATA.tmp" "$METADATA"
}

generate_tree() {
  local dir="${1:-.}"
  find "$dir" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rb" -o -name "*.sh" -o -name "*.md" \) \
    | grep -v node_modules | grep -v "\.git" | grep -v "^./architecture" | sort
}

# ─────────────────────── commands ───────────────────────────
cmd="${1:-}" ; shift || true

case "$cmd" in
  # ───── init ────────────────────────────────────────────────
  init)
    if [[ -d "$ARCH_DIR" ]]; then
      echo "Warning: Architecture already initialized"
      exit 0
    fi
    
    mkdir -p "$ARCH_DIR" "$MODULES_DIR" "$DECISIONS_DIR" "$FLOWS_DIR"
    echo '{"files":{}}' > "$METADATA"
    
    cat > "$REPO_MAP" <<EOF
# Repository Map
_Generated: $(date '+%Y-%m-%d %H:%M:%S')_

## Overview
This document provides a quick reference for all files in the codebase.

## File Structure
EOF
    
    cat > "$DEPS_FILE" <<EOF
# Dependencies
_Last updated: $(date '+%Y-%m-%d %H:%M:%S')_

## External Dependencies
EOF
    
    echo "Architecture documentation initialized in $ARCH_DIR/"
    ;;

  # ───── map ─────────────────────────────────────────────────
  map)
    ensure_init
    update_mode=""
    [[ "${1:-}" == "--update" ]] && update_mode="1"
    
    echo "Scanning repository structure..."
    
    # Start new map content
    {
      echo "# Repository Map"
      echo "_Generated: $(date '+%Y-%m-%d %H:%M:%S')_"
      echo ""
      echo "## File Structure"
      echo '```'
    } > "$REPO_MAP.tmp"
    
    # Generate tree with descriptions
    last_dir=""
    while read -r file; do
      dir=$(dirname "$file")
      base=$(basename "$file")
      
      # Print directory if changed
      if [[ "$dir" != "$last_dir" ]]; then
        echo "$dir/" >> "$REPO_MAP.tmp"
        last_dir="$dir"
      fi
      
      # Get description
      desc=$(get_file_desc "$file")
      if [[ -z "$desc" ]] && [[ -z "$update_mode" ]]; then
        # Auto-detect common patterns
        case "$base" in
          index.*) desc="Main entry point" ;;
          main.*) desc="Main application file" ;;
          app.*) desc="Application configuration" ;;
          server.*) desc="Server setup" ;;
          *test*) desc="Test file" ;;
          *spec*) desc="Test specification" ;;
          config*) desc="Configuration file" ;;
          *route*) desc="Route definitions" ;;
          *model*) desc="Data model" ;;
          *controller*) desc="Controller logic" ;;
          *service*) desc="Service layer" ;;
          *util*|*helper*) desc="Utility functions" ;;
        esac
        [[ -n "$desc" ]] && set_file_desc "$file" "$desc"
      fi
      
      # Format output
      indent="  "
      if [[ -n "$desc" ]]; then
        printf "%s├── %-30s # %s\n" "$indent" "$base" "$desc" >> "$REPO_MAP.tmp"
      else
        printf "%s├── %s\n" "$indent" "$base" >> "$REPO_MAP.tmp"
      fi
    done < <(generate_tree)
    
    echo '```' >> "$REPO_MAP.tmp"
    
    mv "$REPO_MAP.tmp" "$REPO_MAP"
    echo "Repository map generated: $REPO_MAP"
    ;;

  # ───── describe ────────────────────────────────────────────
  describe)
    ensure_init
    [[ $# -ge 2 ]] || usage
    
    file="$1"
    shift
    desc="$*"
    
    [[ -f "$file" ]] || { echo "ERROR: File not found: $file" >&2; exit 1; }
    
    set_file_desc "$file" "$desc"
    echo "Updated description for $file"
    ;;

  # ───── add-module ──────────────────────────────────────────
  add-module)
    ensure_init
    [[ $# -ge 2 ]] || usage
    
    name="$1"
    shift
    desc="$*"
    
    module_file="$MODULES_DIR/${name// /_}.md"
    
    cat > "$module_file" <<EOF
# $name Module

## Overview
$desc

## Related Files
<!-- Use 'architect link' to associate files -->

## Dependencies

## Key Concepts

## API/Interface

_Created: $(date '+%Y-%m-%d %H:%M:%S')_
EOF
    
    echo "Created module documentation: $module_file"
    ;;

  # ───── add-decision ────────────────────────────────────────
  add-decision)
    ensure_init
    [[ $# -ge 1 ]] || usage
    
    title="$*"
    count=$(find "$DECISIONS_DIR" -name "*.md" | wc -l)
    num=$(printf "%03d" $((count + 1)))
    decision_file="$DECISIONS_DIR/${num}-${title// /-}.md"
    
    cat > "$decision_file" <<EOF
# ADR-${num}: $title

## Status
Proposed

## Context
What is the issue that we're seeing that is motivating this decision?

## Decision
What is the change that we're proposing and/or doing?

## Consequences
What becomes easier or more difficult to do because of this change?

_Date: $(date '+%Y-%m-%d')_
_Author: $(git config user.name 2>/dev/null || echo "Unknown")_
EOF
    
    echo "Created ADR: $decision_file"
    ${EDITOR:-nano} "$decision_file"
    ;;

  # ───── add-flow ────────────────────────────────────────────
  add-flow)
    ensure_init
    [[ $# -ge 1 ]] || usage
    
    name="$*"
    flow_file="$FLOWS_DIR/${name// /_}.md"
    
    cat > "$flow_file" <<EOF
# $name Flow

## Overview

## Steps
1. 
2. 
3. 

## Participants
- 

## Data Flow
\`\`\`
Start → [Process] → End
\`\`\`

## Error Handling

_Created: $(date '+%Y-%m-%d %H:%M:%S')_
EOF
    
    echo "Created flow documentation: $flow_file"
    ${EDITOR:-nano} "$flow_file"
    ;;

  # ───── link ────────────────────────────────────────────────
  link)
    ensure_init
    [[ $# -eq 2 ]] || usage
    
    file_pattern="$1"
    module="$2"
    module_file="$MODULES_DIR/${module// /_}.md"
    
    [[ -f "$module_file" ]] || { echo "ERROR: Module not found: $module" >&2; exit 1; }
    
    # Find files matching pattern
    files=$(find . -path "$file_pattern" -type f 2>/dev/null | grep -v "\.git" || true)
    
    if [[ -z "$files" ]]; then
      echo "ERROR: No files match pattern: $file_pattern"
      exit 1
    fi
    
    # Update module file
    temp_file=$(mktemp)
    awk -v files="$files" '
      /## Related Files/ { print; getline; print; print files; next }
      { print }
    ' "$module_file" > "$temp_file"
    
    mv "$temp_file" "$module_file"
    echo "Linked files to module $module"
    ;;

  # ───── search ──────────────────────────────────────────────
  search)
    ensure_init
    [[ $# -ge 1 ]] || usage
    
    term="$*"
    echo "Searching for: $term"
    echo ""
    
    # Search in all architecture files
    grep -r -i -n "$term" "$ARCH_DIR" 2>/dev/null | grep -v "\.json" | while read -r result; do
      file=$(echo "$result" | cut -d: -f1)
      line=$(echo "$result" | cut -d: -f2)
      content=$(echo "$result" | cut -d: -f3-)
      
      echo "Found in $file:$line"
      echo "   $content"
      echo ""
    done
    ;;

  # ───── status ──────────────────────────────────────────────
  status)
    ensure_init
    
    total_files=$(generate_tree | wc -l)
    documented=$(jq -r '.files | length' "$METADATA" 2>/dev/null || echo 0)
    modules=$(find "$MODULES_DIR" -name "*.md" | wc -l)
    decisions=$(find "$DECISIONS_DIR" -name "*.md" | wc -l)
    flows=$(find "$FLOWS_DIR" -name "*.md" | wc -l)
    
    coverage=$((documented * 100 / (total_files + 1)))
    
    echo "Architecture Documentation Status"
    echo ""
    echo "Files documented:  $documented / $total_files ($coverage%)"
    echo "Modules:          $modules"
    echo "Decisions (ADRs): $decisions"
    echo "Process flows:    $flows"
    echo ""
    
    if [[ $documented -lt $total_files ]]; then
      echo "Undocumented files:"
      generate_tree | while read -r file; do
        desc=$(get_file_desc "$file")
        [[ -z "$desc" ]] && echo "   - $file"
      done
    fi
    ;;

  # ───── export ──────────────────────────────────────────────
  export)
    ensure_init
    
    output="architecture_export_$(date +%Y%m%d_%H%M%S).md"
    
    {
      echo "# Architecture Documentation"
      echo "_Exported: $(date '+%Y-%m-%d %H:%M:%S')_"
      echo ""
      
      # Repository map
      cat "$REPO_MAP"
      echo -e "\n---\n"
      
      # Modules
      echo "# Architectural Modules"
      echo ""
      for module in "$MODULES_DIR"/*.md; do
        [[ -f "$module" ]] && cat "$module" && echo -e "\n---\n"
      done
      
      # Decisions
      echo "# Architecture Decision Records"
      echo ""
      for decision in "$DECISIONS_DIR"/*.md; do
        [[ -f "$decision" ]] && cat "$decision" && echo -e "\n---\n"
      done
      
      # Flows
      echo "# Process Flows"
      echo ""
      for flow in "$FLOWS_DIR"/*.md; do
        [[ -f "$flow" ]] && cat "$flow" && echo -e "\n---\n"
      done
      
      # Dependencies
      cat "$DEPS_FILE"
    } > "$output"
    
    echo "Exported architecture documentation: $output"
    ;;

  *) usage ;;
esac