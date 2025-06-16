#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# researcher.sh – OpenRouter API client for online research & multimodal queries
#
# Commands:
#   ask <prompt>                  → Simple text query (uses gpt-4o:online)
#   research <topic>              → Deep research with online model
#   analyze-image <url> <prompt>  → Analyze image with prompt
#   chat                          → Interactive chat mode
#   models                        → List available models
#   set-key <key>                 → Set OpenRouter API key
#
# Requires: curl, jq
# ──────────────────────────────────────────────────────────────
set -euo pipefail

CONFIG_DIR=".researcher"
CONFIG_FILE="$CONFIG_DIR/config.json"
HISTORY_FILE="$CONFIG_DIR/history.json"
DEFAULT_MODEL="openai/gpt-4o:online"
API_URL="https://openrouter.ai/api/v1/chat/completions"

# ──────────────────────────────────────────────────────────────
usage() {
  cat >&2 <<EOF
Usage: $0 {ask|research|analyze-image|chat|models|set-key} [...]

Commands:
  ask <prompt>                 Quick question with online search
  research <topic>             Deep research on a topic
  analyze-image <url> <text>   Analyze image with prompt
  chat                         Interactive chat mode
  models                       List available models
  set-key <api-key>           Set your OpenRouter API key

Environment:
  OPENROUTER_API_KEY          API key (or use set-key command)
  RESEARCHER_MODEL            Override default model

Examples:
  $0 ask "What happened in tech news today?"
  $0 research "Latest developments in quantum computing"
  $0 analyze-image "https://example.com/chart.png" "What does this chart show?"
  $0 chat
EOF
  exit 1
}

# ───────────────────── helpers ────────────────────────────
ensure_deps() {
  for cmd in curl jq; do
    command -v "$cmd" >/dev/null || { echo "ERROR: Missing dependency: $cmd" >&2; exit 1; }
  done
}

ensure_config() {
  mkdir -p "$CONFIG_DIR"
  [[ -f "$CONFIG_FILE" ]] || echo '{}' > "$CONFIG_FILE"
  [[ -f "$HISTORY_FILE" ]] || echo '[]' > "$HISTORY_FILE"
}

get_api_key() {
  local key="${OPENROUTER_API_KEY:-}"
  if [[ -z "$key" ]] && [[ -f "$CONFIG_FILE" ]]; then
    key=$(jq -r '.api_key // empty' "$CONFIG_FILE")
  fi
  if [[ -z "$key" ]]; then
    echo "ERROR: No API key found. Set OPENROUTER_API_KEY or run '$0 set-key <key>'" >&2
    exit 1
  fi
  echo "$key"
}

api_call() {
  local model="${1}"
  local messages="${2}"
  local api_key=$(get_api_key)
  
  local response=$(curl -s -X POST "$API_URL" \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"$model\",
      \"messages\": $messages
    }")
  
  # Check for errors
  local error=$(echo "$response" | jq -r '.error // empty')
  if [[ -n "$error" ]]; then
    echo "ERROR: API Error: $error" >&2
    return 1
  fi
  
  # Extract content
  echo "$response" | jq -r '.choices[0].message.content // empty'
}

save_to_history() {
  local query="$1"
  local response="$2"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  jq --arg q "$query" --arg r "$response" --arg t "$timestamp" \
    '. += [{"timestamp": $t, "query": $q, "response": $r}]' \
    "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
}

# ─────────────────────── commands ───────────────────────────
ensure_deps
ensure_config

cmd="${1:-}" ; shift || true

case "$cmd" in
  # ───── ask ─────────────────────────────────────────────────
  ask)
    [[ $# -ge 1 ]] || usage
    prompt="$*"
    model="${RESEARCHER_MODEL:-$DEFAULT_MODEL}"
    
    echo "Asking $model..." >&2
    
    messages='[{"role": "user", "content": "'"$prompt"'"}]'
    response=$(api_call "$model" "$messages")
    
    if [[ -n "$response" ]]; then
      echo "$response"
      save_to_history "$prompt" "$response"
    fi
    ;;

  # ───── research ────────────────────────────────────────────
  research)
    [[ $# -ge 1 ]] || usage
    topic="$*"
    model="${RESEARCHER_MODEL:-$DEFAULT_MODEL}"
    
    echo "Researching: $topic" >&2
    echo "Using model: $model" >&2
    echo "" >&2
    
    # Craft a research-focused prompt
    prompt="Please conduct thorough online research about: $topic

Focus on:
1. Latest developments and current state
2. Key facts and statistics
3. Important sources and references
4. Recent news or updates
5. Expert opinions or analysis

Provide a comprehensive summary with sources when possible."
    
    messages='[{"role": "user", "content": "'"$prompt"'"}]'
    response=$(api_call "$model" "$messages")
    
    if [[ -n "$response" ]]; then
      echo "$response"
      save_to_history "Research: $topic" "$response"
      
      # Save research to file
      research_file="$CONFIG_DIR/research_$(date +%Y%m%d_%H%M%S).md"
      {
        echo "# Research: $topic"
        echo "_Date: $(date '+%Y-%m-%d %H:%M:%S')_"
        echo "_Model: $model"
        echo ""
        echo "$response"
      } > "$research_file"
      
      echo "" >&2
      echo "Research saved to: $research_file" >&2
    fi
    ;;

  # ───── analyze-image ───────────────────────────────────────
  analyze-image)
    [[ $# -ge 2 ]] || usage
    image_url="$1"
    shift
    prompt="$*"
    model="${RESEARCHER_MODEL:-openai/gpt-4o}"  # Use vision-capable model
    
    echo "Analyzing image..." >&2
    
    # Build multimodal message
    messages='[
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "'"$prompt"'"
          },
          {
            "type": "image_url",
            "image_url": {
              "url": "'"$image_url"'"
            }
          }
        ]
      }
    ]'
    
    response=$(api_call "$model" "$messages")
    
    if [[ -n "$response" ]]; then
      echo "$response"
      save_to_history "Image analysis: $prompt" "$response"
    fi
    ;;

  # ───── chat ────────────────────────────────────────────────
  chat)
    model="${RESEARCHER_MODEL:-$DEFAULT_MODEL}"
    echo "Chat mode (model: $model). Type 'exit' to quit." >&2
    echo "" >&2
    
    conversation='[]'
    
    while true; do
      echo -n "You: "
      read -r input
      
      [[ "$input" == "exit" ]] && break
      [[ -z "$input" ]] && continue
      
      # Add user message to conversation
      conversation=$(echo "$conversation" | jq --arg msg "$input" '. += [{"role": "user", "content": $msg}]')
      
      # Get response
      echo -n "AI: "
      response=$(api_call "$model" "$conversation")
      echo "$response"
      echo ""
      
      # Add assistant message to conversation
      conversation=$(echo "$conversation" | jq --arg msg "$response" '. += [{"role": "assistant", "content": $msg}]')
    done
    
    echo "Chat ended." >&2
    ;;

  # ───── models ──────────────────────────────────────────────
  models)
    echo "Available models for research:" >&2
    echo "" >&2
    echo "Online/Research models:" >&2
    echo "  - openai/gpt-4o:online (default)" >&2
    echo "  - perplexity/sonar-medium-online" >&2
    echo "  - perplexity/sonar-small-online" >&2
    echo "" >&2
    echo "Vision models (for image analysis):" >&2
    echo "  - openai/gpt-4o" >&2
    echo "  - anthropic/claude-3.5-sonnet" >&2
    echo "  - google/gemini-pro-1.5" >&2
    echo "" >&2
    echo "Set model with: export RESEARCHER_MODEL=<model-name>" >&2
    ;;

  # ───── set-key ─────────────────────────────────────────────
  set-key)
    [[ $# -eq 1 ]] || usage
    api_key="$1"
    
    # Validate key format (basic check)
    if [[ ! "$api_key" =~ ^sk- ]]; then
      echo "Warning: API key should start with 'sk-'" >&2
    fi
    
    # Save to config
    jq --arg key "$api_key" '.api_key = $key' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && \
      mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    
    echo "API key saved to $CONFIG_FILE" >&2
    ;;

  *) usage ;;
esac