#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# knowledge.sh – Lightweight knowledge base for LLM agents
#
# Commands (with optional --agent <name>):
#   store <key> <value>           → Store a fact/discovery
#   get <key>                     → Retrieve a specific fact
#   search <pattern>              → Search for keys matching pattern
#   list [--shared]               → List all stored knowledge
#   tag <key> <tags...>           → Add tags to a knowledge entry
#   export [file]                 → Export knowledge to markdown
#   import <file>                 → Import knowledge from file
#   share <key>                   → Share private knowledge to shared pool
#   sync                          → Sync agent knowledge with shared pool
#
# Storage:
# - Private: memory-bank/agents/<agent>/knowledge.json
# - Shared: memory-bank/shared/knowledge_base.json
#
# Requires: Bash ≥ 4, jq.
# ──────────────────────────────────────────────────────────────
set -euo pipefail

# Default configuration
BANK_DIR="${BANK_DIR:-memory-bank}"
AGENT_NAME="${AGENT_NAME:-default}"

# Parse --agent parameter
while [[ $# -gt 0 ]] && [[ "$1" =~ ^-- ]]; do
  case "$1" in
    --agent)
      AGENT_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Set up paths
AGENT_DIR="$BANK_DIR/agents/$AGENT_NAME"
SHARED_DIR="$BANK_DIR/shared"
PRIVATE_KB="$AGENT_DIR/knowledge.json"
SHARED_KB="$SHARED_DIR/knowledge_base.json"

# ──────────────────────────────────────────────────────────────
usage() {
  cat >&2 <<EOF
Usage: $0 [--agent <name>] {store|get|search|list|tag|export|import|share|sync} [...]

Knowledge Management Commands:
  store <key> <value>         Store a fact or discovery
  get <key>                   Retrieve value for a specific key
  search <pattern>            Search keys matching pattern (regex)
  list [--shared]             List all knowledge (add --shared for shared pool)
  tag <key> <tags...>         Add tags to a knowledge entry
  export [file]               Export knowledge to markdown file
  import <file>               Import knowledge from JSON/markdown
  share <key>                 Copy private knowledge to shared pool
  sync                        Pull relevant shared knowledge to private

Examples:
  $0 --agent researcher store "api.endpoint" "https://api.example.com/v2"
  $0 --agent researcher store "auth.method" "Bearer token with 24h expiry"
  $0 --agent researcher tag "api.endpoint" api production critical
  $0 --agent researcher search "api.*"
  $0 --agent researcher share "api.endpoint"
  $0 --agent coder get "api.endpoint"
  $0 --agent coder sync
  $0 list --shared
EOF
  exit 1
}

# ───────────────────── helpers ────────────────────────────
init_dirs() {
  mkdir -p "$AGENT_DIR" "$SHARED_DIR"
  [[ -f "$PRIVATE_KB" ]] || echo '{}' > "$PRIVATE_KB"
  [[ -f "$SHARED_KB" ]] || echo '{}' > "$SHARED_KB"
}

# Check if jq is available
check_jq() {
  command -v jq >/dev/null 2>&1 || {
    echo "ERROR: jq is required but not installed." >&2
    echo "Install with: apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)" >&2
    exit 1
  }
}

# Store a key-value pair with metadata
store_knowledge() {
  local key="$1"
  local value="$2"
  local kb_file="$3"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  jq --arg k "$key" \
     --arg v "$value" \
     --arg t "$timestamp" \
     --arg a "$AGENT_NAME" \
     '.[$k] = {
       "value": $v,
       "created": $t,
       "updated": $t,
       "agent": $a,
       "tags": []
     }' "$kb_file" > "$kb_file.tmp" && mv "$kb_file.tmp" "$kb_file"
}

# Update existing entry
update_knowledge() {
  local key="$1"
  local value="$2"
  local kb_file="$3"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  jq --arg k "$key" \
     --arg v "$value" \
     --arg t "$timestamp" \
     '.[$k].value = $v | .[$k].updated = $t' "$kb_file" > "$kb_file.tmp" && mv "$kb_file.tmp" "$kb_file"
}

# ─────────────────────── commands ───────────────────────────
cmd="${1:-}" ; shift || true

check_jq
init_dirs

case "$cmd" in
  # ───── store ───────────────────────────────────────────────
  store)
    [[ $# -ge 2 ]] || usage
    key="$1"
    shift
    value="$*"
    
    # Check if key exists
    if jq -e --arg k "$key" 'has($k)' "$PRIVATE_KB" >/dev/null 2>&1; then
      update_knowledge "$key" "$value" "$PRIVATE_KB"
      echo "Updated: $key"
    else
      store_knowledge "$key" "$value" "$PRIVATE_KB"
      echo "Stored: $key"
    fi
    ;;

  # ───── get ─────────────────────────────────────────────────
  get)
    [[ $# -eq 1 ]] || usage
    key="$1"
    
    # Try private first, then shared
    value=$(jq -r --arg k "$key" '.[$k].value // empty' "$PRIVATE_KB" 2>/dev/null)
    if [[ -z "$value" ]]; then
      value=$(jq -r --arg k "$key" '.[$k].value // empty' "$SHARED_KB" 2>/dev/null)
      if [[ -n "$value" ]]; then
        echo "$value (from shared)"
      else
        echo "Key not found: $key" >&2
        exit 1
      fi
    else
      echo "$value"
    fi
    ;;

  # ───── search ──────────────────────────────────────────────
  search)
    [[ $# -eq 1 ]] || usage
    pattern="$1"
    
    echo "=== Private Knowledge (Agent: $AGENT_NAME) ==="
    jq -r --arg p "$pattern" '
      to_entries | 
      map(select(.key | test($p))) | 
      .[] | 
      "\(.key): \(.value.value)"
    ' "$PRIVATE_KB" 2>/dev/null || echo "(none found)"
    
    echo ""
    echo "=== Shared Knowledge ==="
    jq -r --arg p "$pattern" '
      to_entries | 
      map(select(.key | test($p))) | 
      .[] | 
      "\(.key): \(.value.value) [by \(.value.agent)]"
    ' "$SHARED_KB" 2>/dev/null || echo "(none found)"
    ;;

  # ───── list ────────────────────────────────────────────────
  list)
    if [[ "${1:-}" == "--shared" ]]; then
      echo "=== Shared Knowledge Base ==="
      jq -r '
        to_entries | 
        sort_by(.key) | 
        .[] | 
        "• \(.key): \(.value.value)\n  Tags: \(.value.tags | join(", "))\n  By: \(.value.agent) on \(.value.updated)"
      ' "$SHARED_KB" 2>/dev/null || echo "(empty)"
    else
      echo "=== Private Knowledge (Agent: $AGENT_NAME) ==="
      jq -r '
        to_entries | 
        sort_by(.key) | 
        .[] | 
        "• \(.key): \(.value.value)\n  Tags: \(.value.tags | join(", "))\n  Updated: \(.value.updated)"
      ' "$PRIVATE_KB" 2>/dev/null || echo "(empty)"
    fi
    ;;

  # ───── tag ─────────────────────────────────────────────────
  tag)
    [[ $# -ge 2 ]] || usage
    key="$1"
    shift
    tags=("$@")
    
    # Check if key exists
    if ! jq -e --arg k "$key" 'has($k)' "$PRIVATE_KB" >/dev/null 2>&1; then
      echo "Key not found: $key" >&2
      exit 1
    fi
    
    # Add tags
    for tag in "${tags[@]}"; do
      jq --arg k "$key" --arg t "$tag" '
        .[$k].tags = (.[$k].tags + [$t] | unique)
      ' "$PRIVATE_KB" > "$PRIVATE_KB.tmp" && mv "$PRIVATE_KB.tmp" "$PRIVATE_KB"
    done
    
    echo "Tagged '$key' with: ${tags[*]}"
    ;;

  # ───── share ───────────────────────────────────────────────
  share)
    [[ $# -eq 1 ]] || usage
    key="$1"
    
    # Get entry from private
    entry=$(jq --arg k "$key" '.[$k] // empty' "$PRIVATE_KB")
    if [[ -z "$entry" || "$entry" == "null" ]]; then
      echo "Key not found in private knowledge: $key" >&2
      exit 1
    fi
    
    # Copy to shared
    jq --arg k "$key" --argjson e "$entry" '.[$k] = $e' "$SHARED_KB" > "$SHARED_KB.tmp" && mv "$SHARED_KB.tmp" "$SHARED_KB"
    echo "Shared to common knowledge pool: $key"
    ;;

  # ───── sync ────────────────────────────────────────────────
  sync)
    echo "Syncing relevant shared knowledge..."
    
    # Get all tags from private knowledge
    private_tags=$(jq -r '[.[].tags[]] | unique | .[]' "$PRIVATE_KB" 2>/dev/null)
    
    if [[ -z "$private_tags" ]]; then
      echo "No tags found in private knowledge. Tag your entries to enable smart sync."
      exit 0
    fi
    
    # Find shared entries with matching tags
    count=0
    while read -r tag; do
      entries=$(jq -r --arg t "$tag" '
        to_entries | 
        map(select(.value.tags | contains([$t]))) | 
        .[].key
      ' "$SHARED_KB" 2>/dev/null)
      
      for key in $entries; do
        # Skip if already in private
        if jq -e --arg k "$key" 'has($k)' "$PRIVATE_KB" >/dev/null 2>&1; then
          continue
        fi
        
        # Copy from shared to private
        entry=$(jq --arg k "$key" '.[$k]' "$SHARED_KB")
        jq --arg k "$key" --argjson e "$entry" '.[$k] = $e' "$PRIVATE_KB" > "$PRIVATE_KB.tmp" && mv "$PRIVATE_KB.tmp" "$PRIVATE_KB"
        echo "Synced: $key (tag: $tag)"
        ((count++))
      done
    done <<< "$private_tags"
    
    echo "Synced $count entries from shared knowledge"
    ;;

  # ───── export ──────────────────────────────────────────────
  export)
    output="${1:-knowledge_export_$(date +%Y%m%d_%H%M%S).md}"
    
    {
      echo "# Knowledge Export"
      echo "_Agent: $AGENT_NAME_"
      echo "_Exported: $(date '+%Y-%m-%d %H:%M:%S')_"
      echo ""
      echo "## Private Knowledge"
      echo ""
      
      jq -r '
        to_entries | 
        sort_by(.key) | 
        .[] | 
        "### \(.key)\n\n**Value:** \(.value.value)\n\n**Tags:** \(.value.tags | join(", "))\n\n**Updated:** \(.value.updated)\n\n---\n"
      ' "$PRIVATE_KB" 2>/dev/null || echo "(none)"
      
      echo ""
      echo "## Relevant Shared Knowledge"
      echo ""
      
      # Export shared entries that match private tags
      private_tags=$(jq -r '[.[].tags[]] | unique' "$PRIVATE_KB" 2>/dev/null)
      if [[ "$private_tags" != "[]" && "$private_tags" != "null" ]]; then
        jq -r --argjson tags "$private_tags" '
          to_entries | 
          map(select(.value.tags as $vtags | $tags | any(. as $t | $vtags | contains([$t])))) |
          sort_by(.key) | 
          .[] | 
          "### \(.key)\n\n**Value:** \(.value.value)\n\n**Tags:** \(.value.tags | join(", "))\n\n**By:** \(.value.agent)\n\n**Updated:** \(.value.updated)\n\n---\n"
        ' "$SHARED_KB" 2>/dev/null || echo "(none)"
      else
        echo "(no matching shared knowledge)"
      fi
    } > "$output"
    
    echo "Exported to: $output"
    ;;

  # ───── import ──────────────────────────────────────────────
  import)
    [[ $# -eq 1 ]] || usage
    import_file="$1"
    
    [[ -f "$import_file" ]] || { echo "File not found: $import_file" >&2; exit 1; }
    
    # Check if it's JSON
    if jq empty "$import_file" 2>/dev/null; then
      # Merge JSON data
      jq -s '.[0] * .[1]' "$PRIVATE_KB" "$import_file" > "$PRIVATE_KB.tmp" && mv "$PRIVATE_KB.tmp" "$PRIVATE_KB"
      count=$(jq 'length' "$import_file")
      echo "Imported $count entries from JSON"
    else
      echo "ERROR: Only JSON import is currently supported" >&2
      exit 1
    fi
    ;;

  *) usage ;;
esac