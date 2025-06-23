#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# codemap.sh – Lightweight code intelligence for LLM agents
#
# Commands:
#   init                          → Initialize codemap directories
#   map                           → Generate/update module metadata
#   label <file> <type> <desc>    → Label a file (impl/interface/test/config)
#   deps <file> <deps...>         → Record file dependencies
#   cheat <component> <content|-  → Add component cheatsheet
#   debug <bug> <fix>             → Log a bug/fix pair
#   search <term>                 → Search all codemap data
#   summary                       → Show project overview
#
# High-impact, low-overhead approach:
# 1. metadata/ - Module labels and dependencies
# 2. cheatsheets/ - Component quick references
# 3. debug_history/ - Bug→fix patterns
#
# ──────────────────────────────────────────────────────────────
set -euo pipefail

BANK_DIR="${BANK_DIR:-memory-bank}"
CODEMAP_DIR="$BANK_DIR/codemap"
METADATA_FILE="$CODEMAP_DIR/metadata/modules.json"
CHEATSHEET_DIR="$CODEMAP_DIR/cheatsheets"
DEBUG_DIR="$CODEMAP_DIR/debug_history"

# ──────────────────────────────────────────────────────────────
usage() {
  cat >&2 <<EOF
Usage: $0 {init|map|label|deps|cheat|debug|search|summary} [...]

Lightweight Code Intelligence Commands:
  init                        Initialize codemap structure
  map                         Auto-scan and generate module metadata
  label <file> <type> <desc>  Label file type (impl/interface/test/config)
  deps <file> <deps...>       Record what a file depends on
  cheat <component>           Create/edit component cheatsheet
  debug <bug> <fix>           Log a bug→fix pattern
  search <term>               Search across all codemap data
  summary                     Show high-level project overview

Examples:
  $0 init
  $0 map                                          # Auto-scan project
  $0 label "src/auth.js" impl "JWT authentication logic"
  $0 deps "src/auth.js" "crypto" "config.js" "user-model.js"
  $0 cheat auth "# Auth Module\n\nPublic API:\n- authenticate(user, pass)\n- validateToken(token)"
  $0 debug "JWT expiry not checked" "Added expiry validation in auth.js:42"
  $0 search "auth"
  $0 summary
EOF
  exit 1
}

# ───────────────────── helpers ────────────────────────────
init_dirs() {
  mkdir -p "$CODEMAP_DIR/metadata" "$CHEATSHEET_DIR" "$DEBUG_DIR"
  [[ -f "$METADATA_FILE" ]] || echo '{}' > "$METADATA_FILE"
}

check_jq() {
  command -v jq >/dev/null 2>&1 || {
    echo "ERROR: jq is required. Install with: apt-get install jq" >&2
    exit 1
  }
}

# Auto-detect file type based on patterns
detect_file_type() {
  local file="$1"
  local base=$(basename "$file")
  
  case "$base" in
    *test*|*spec*) echo "test" ;;
    *interface*|*types*|*.d.ts) echo "interface" ;;
    *config*|*.json|*.yaml|*.yml) echo "config" ;;
    index.*|main.*|app.*) echo "entry" ;;
    *) echo "impl" ;;
  esac
}

# Extract likely dependencies from file
extract_deps() {
  local file="$1"
  local deps=""
  
  # Common import patterns
  if [[ -f "$file" ]]; then
    # JavaScript/TypeScript imports
    deps=$(grep -E "^import .* from ['\"]|require\(['\"]" "$file" 2>/dev/null | \
           sed -E "s/.*from ['\"]([^'\"]+)['\"].*/\1/g; s/.*require\(['\"]([^'\"]+)['\"].*/\1/g" | \
           grep -v "^[./]" | sort -u | tr '\n' ' ' || true)
    
    # Python imports
    if [[ -z "$deps" ]]; then
      deps=$(grep -E "^import |^from .* import" "$file" 2>/dev/null | \
             sed -E "s/^import ([^ ]+).*/\1/g; s/^from ([^ ]+) import.*/\1/g" | \
             sort -u | tr '\n' ' ' || true)
    fi
  fi
  
  echo "$deps"
}

# ─────────────────────── commands ───────────────────────────
cmd="${1:-}" ; shift || true

case "$cmd" in
  # ───── init ────────────────────────────────────────────────
  init)
    check_jq
    init_dirs
    
    cat > "$CODEMAP_DIR/README.md" <<'EOF'
# Codemap - Lightweight Code Intelligence

This directory contains high-impact, low-overhead code intelligence for LLM agents.

## Structure

- `metadata/modules.json` - File labels, types, and dependencies
- `cheatsheets/` - Component quick references (public APIs, gotchas)
- `debug_history/` - Bug→fix patterns for reuse

## Why This Matters

1. **Instant roadmap**: Agents know where things are without searching
2. **Fewer hallucinations**: Cheatsheets prevent wrong API usage
3. **Learn from history**: Debug logs prevent repeating old mistakes
EOF
    
    echo "Codemap initialized in $CODEMAP_DIR/"
    ;;

  # ───── map ─────────────────────────────────────────────────
  map)
    check_jq
    init_dirs
    
    echo "Scanning codebase for modules..."
    
    # Find all code files
    files=$(find . -type f \( \
      -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \
      -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rb" \
      \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/$BANK_DIR/*" | sort)
    
    count=0
    for file in $files; do
      # Skip if already labeled
      if jq -e --arg f "$file" 'has($f)' "$METADATA_FILE" >/dev/null 2>&1; then
        continue
      fi
      
      # Auto-detect type and deps
      type=$(detect_file_type "$file")
      deps=$(extract_deps "$file")
      
      # Add to metadata
      jq --arg f "$file" \
         --arg t "$type" \
         --arg d "$deps" \
         '.[$f] = {"type": $t, "deps": ($d | split(" ") | map(select(. != ""))), "description": ""}' \
         "$METADATA_FILE" > "$METADATA_FILE.tmp" && mv "$METADATA_FILE.tmp" "$METADATA_FILE"
      
      ((count++))
    done
    
    echo "Mapped $count new files. Total: $(jq 'length' "$METADATA_FILE")"
    echo "Run '$0 summary' to see overview"
    ;;

  # ───── label ───────────────────────────────────────────────
  label)
    [[ $# -ge 3 ]] || usage
    check_jq
    init_dirs
    
    file="$1"
    type="$2"
    shift 2
    desc="$*"
    
    # Validate type
    case "$type" in
      impl|interface|test|config|entry) ;;
      *) echo "ERROR: Type must be: impl, interface, test, config, or entry" >&2; exit 1 ;;
    esac
    
    # Update metadata
    jq --arg f "$file" \
       --arg t "$type" \
       --arg d "$desc" \
       '.[$f] = (.[$f] // {}) | .type = $t | .description = $d' \
       "$METADATA_FILE" > "$METADATA_FILE.tmp" && mv "$METADATA_FILE.tmp" "$METADATA_FILE"
    
    echo "Labeled $file as $type: $desc"
    ;;

  # ───── deps ────────────────────────────────────────────────
  deps)
    [[ $# -ge 2 ]] || usage
    check_jq
    init_dirs
    
    file="$1"
    shift
    deps=("$@")
    
    # Update dependencies
    jq --arg f "$file" \
       --argjson d "$(printf '%s\n' "${deps[@]}" | jq -R . | jq -s .)" \
       '.[$f] = (.[$f] // {}) | .deps = $d' \
       "$METADATA_FILE" > "$METADATA_FILE.tmp" && mv "$METADATA_FILE.tmp" "$METADATA_FILE"
    
    echo "Updated dependencies for $file"
    ;;

  # ───── cheat ───────────────────────────────────────────────
  cheat)
    [[ $# -ge 1 ]] || usage
    init_dirs
    
    component="$1"
    cheatsheet="$CHEATSHEET_DIR/${component}.md"
    
    if [[ $# -ge 2 ]]; then
      # Content provided
      shift
      if [[ "$1" == "-" ]]; then
        cat > "$cheatsheet"
      else
        echo "$*" > "$cheatsheet"
      fi
      echo "Created cheatsheet: $cheatsheet"
    else
      # Open editor
      if [[ ! -f "$cheatsheet" ]]; then
        cat > "$cheatsheet" <<EOF
# $component Cheatsheet

## Public API

## Common Patterns

## Gotchas & Edge Cases

## Dependencies

## Examples
EOF
      fi
      ${EDITOR:-nano} "$cheatsheet"
    fi
    ;;

  # ───── debug ───────────────────────────────────────────────
  debug)
    [[ $# -ge 2 ]] || usage
    init_dirs
    
    bug="$1"
    shift
    fix="$*"
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    debug_file="$DEBUG_DIR/debug_$(date +%Y%m).md"
    
    # Append to monthly debug log
    {
      echo "## [$timestamp] $bug"
      echo "**Fix:** $fix"
      echo ""
    } >> "$debug_file"
    
    echo "Logged debug entry to $debug_file"
    ;;

  # ───── search ──────────────────────────────────────────────
  search)
    [[ $# -ge 1 ]] || usage
    init_dirs
    
    term="$*"
    
    echo "=== Module Metadata ==="
    jq -r --arg t "$term" '
      to_entries | 
      map(select(.key | test($t, "i")) + select(.value.description | test($t, "i"))) |
      .[] | 
      "\(.key) [\(.value.type)]: \(.value.description)"
    ' "$METADATA_FILE" 2>/dev/null || echo "(no matches)"
    
    echo ""
    echo "=== Cheatsheets ==="
    grep -l -i "$term" "$CHEATSHEET_DIR"/*.md 2>/dev/null | while read -r file; do
      echo "Found in: $file"
      grep -i -n -C1 "$term" "$file" | head -5
      echo "..."
    done || echo "(no matches)"
    
    echo ""
    echo "=== Debug History ==="
    grep -i -n "$term" "$DEBUG_DIR"/*.md 2>/dev/null | head -10 || echo "(no matches)"
    ;;

  # ───── summary ─────────────────────────────────────────────
  summary)
    check_jq
    init_dirs
    
    echo "=== Codemap Summary ==="
    echo ""
    
    # File type breakdown
    echo "File Types:"
    jq -r '[.[].type] | group_by(.) | map({type: .[0], count: length}) | .[] | "  \(.type): \(.count)"' "$METADATA_FILE"
    
    echo ""
    echo "Entry Points:"
    jq -r 'to_entries | map(select(.value.type == "entry")) | .[] | "  \(.key): \(.value.description)"' "$METADATA_FILE"
    
    echo ""
    echo "Interfaces:"
    jq -r 'to_entries | map(select(.value.type == "interface")) | .[] | "  \(.key): \(.value.description)"' "$METADATA_FILE" | head -10
    
    # Cheatsheets
    if [[ -d "$CHEATSHEET_DIR" ]] && [[ -n "$(ls -A "$CHEATSHEET_DIR" 2>/dev/null)" ]]; then
      echo ""
      echo "Component Cheatsheets:"
      ls "$CHEATSHEET_DIR"/*.md 2>/dev/null | while read -r file; do
        echo "  - $(basename "$file" .md)"
      done
    fi
    
    # Debug entries
    debug_count=$(find "$DEBUG_DIR" -name "*.md" -exec grep -c "^## " {} + 2>/dev/null | awk '{s+=$1} END {print s}' || echo 0)
    echo ""
    echo "Debug History: $debug_count entries"
    
    # Most complex modules (by dependency count)
    echo ""
    echo "Most Complex Modules (by dependencies):"
    jq -r 'to_entries | map({file: .key, deps: (.value.deps | length)}) | sort_by(.deps) | reverse | .[0:5] | .[] | "  \(.file): \(.deps) deps"' "$METADATA_FILE"
    ;;

  *) usage ;;
esac