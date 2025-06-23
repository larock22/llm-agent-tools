#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# scratchpad-multi.sh – Multi-agent enhanced scratchpad workflow
#
# Commands (with optional --agent <name>):
#   start   <task‑title>          → create/overwrite scratchpad.md
#   step    <text>|‑              → add next sequential thinking step
#   revise  <N>    <text>|‑       → attach a revision to step N
#   branch  <N>    <text>|‑       → start sub‑step N.x (branch)
#   append  <text>|‑              → raw append (fallback / free‑form)
#   status                       → show counters & last entries
#   finish  [task‑title]          → archive scratchpad to done_tasks
#   handoff <to-agent> <message>  → handoff task to another agent
#   agents                       → list active agents
#
# Multi-agent features:
# - Agent-specific scratchpads: memory-bank/agents/<agent>/scratchpad.md
# - Shared memory space: memory-bank/shared/
# - File locking for concurrent access
# - Agent handoff capabilities
#
# Requires: Bash ≥ 4, coreutils, flock.
# ──────────────────────────────────────────────────────────────
set -euo pipefail

# Default configuration
BANK_DIR="${BANK_DIR:-memory-bank}"
AGENT_NAME="${AGENT_NAME:-default}"
LOCK_TIMEOUT="${LOCK_TIMEOUT:-5}"

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

# Set up paths based on agent
AGENT_DIR="$BANK_DIR/agents/$AGENT_NAME"
SHARED_DIR="$BANK_DIR/shared"
SCRATCH="$AGENT_DIR/scratchpad.md"
LOCK_FILE="$BANK_DIR/locks/${AGENT_NAME}.lock"

# ──────────────────────────────────────────────────────────────
usage() {
  cat >&2 <<EOF
Usage: $0 [--agent <name>] {start|step|revise|branch|append|status|finish|handoff|agents} [...]

Multi-Agent Commands:
  --agent <name>                 Use agent-specific scratchpad (default: "default")
  
Standard Commands:
  start  <task-title>            Create/overwrite scratchpad with header
  step   <text>|-               Add next sequential step (or read STDIN)
  revise <step-no> <text>|-     Add a revision to an existing step
  branch <step-no> <text>|-     Add a branched sub‑step under <step-no>
  append <text>|-               Raw append (no numbering / validation)
  status                        Show last main/branch/revision indices
  finish [task-title]           Archive scratchpad to shared/done_tasks

Multi-Agent Commands:
  handoff <to-agent> <message>  Hand off current task to another agent
  agents                        List all active agents with their current tasks

Examples:
  $0 --agent researcher start "Research latest AI papers"
  $0 --agent coder step "Implementing authentication module"
  $0 --agent researcher handoff coder "Research complete, please implement"
  $0 agents
EOF
  exit 1
}

# ───────────────────── helpers ────────────────────────────
init_dirs() {
  mkdir -p "$AGENT_DIR" "$SHARED_DIR/done_tasks" "$BANK_DIR/locks"
}

_line() {
  if [[ $# -eq 0 || "$1" == "-" ]]; then
    cat
  else
    printf '%s\n' "$*"
  fi
}

ensure_file() { 
  [[ -f "$SCRATCH" ]] || { 
    echo "ERROR: No active scratchpad for agent '$AGENT_NAME'; run '$0 --agent $AGENT_NAME start' first." >&2
    exit 1
  }
}

# File locking wrapper
with_lock() {
  local lock_file="$1"
  shift
  
  mkdir -p "$(dirname "$lock_file")"
  
  # Try to acquire lock with timeout
  if command -v flock >/dev/null 2>&1; then
    flock -w "$LOCK_TIMEOUT" "$lock_file" "$@"
  else
    # Fallback for systems without flock
    "$@"
  fi
}

# Safe file operations with locking
safe_append() {
  local file="$1"
  local content="$2"
  with_lock "$LOCK_FILE" bash -c "echo '$content' >> '$file'"
}

last_main()   { grep -Po '^\[\d+\]'      "$SCRATCH" 2>/dev/null | tail -1 | tr -d '[]' || echo 0; }
last_branch() { grep -Po "^\[$1\.\d+\]" "$SCRATCH" 2>/dev/null | tail -1 | sed -E "s/^\[$1\.([0-9]+)\].*/\1/" || echo 0; }
last_rev()    { grep -Po "^\[$1~\d+\]"  "$SCRATCH" 2>/dev/null | tail -1 | sed -E "s/^\[$1~([0-9]+)\].*/\1/" || echo 0; }

# Get current task from scratchpad
get_current_task() {
  [[ -f "$SCRATCH" ]] && head -1 "$SCRATCH" | sed 's/^# //' || echo "No active task"
}

# ─────────────────────── dispatcher ───────────────────────────
cmd="${1:-}" ; shift || true
case "$cmd" in
  # ───── start ───────────────────────────────────────────────
  start)
    [[ $# -ge 1 ]] || usage
    task="$*"
    init_dirs
    
    with_lock "$LOCK_FILE" bash -c "cat > '$SCRATCH' <<EOF
# $task
_Started: $(date '+%Y-%m-%d %H:%M:%S')_
_Agent: $AGENT_NAME

EOF"
    
    echo "Agent '$AGENT_NAME' started task: $task"
    ;;

  # ───── step ────────────────────────────────────────────────
  step)
    ensure_file
    next=$(( $(last_main) + 1 ))
    content=$(_line "$@" | sed "s/^/[${next}] /")
    safe_append "$SCRATCH" "$content"
    echo "Added step $next"
    ;;

  # ───── revise ──────────────────────────────────────────────
  revise)
    ensure_file
    [[ $# -ge 2 ]] || usage
    target="$1" ; shift
    [[ "$target" =~ ^[0-9]+$ ]] || { echo "Invalid step number '$target'." >&2; exit 1; }
    grep -q "^\[$target\]" "$SCRATCH" || { echo "Step $target not found." >&2; exit 1; }
    r=$(( $(last_rev "$target") + 1 ))
    content=$(_line "$@" | sed "s/^/[${target}~${r}] /")
    safe_append "$SCRATCH" "$content"
    echo "Added revision ${target}~${r}"
    ;;

  # ───── branch ──────────────────────────────────────────────
  branch)
    ensure_file
    [[ $# -ge 2 ]] || usage
    parent="$1" ; shift
    [[ "$parent" =~ ^[0-9]+$ ]] || { echo "Invalid step number '$parent'." >&2; exit 1; }
    grep -q "^\[$parent\]" "$SCRATCH" || { echo "Step $parent not found." >&2; exit 1; }
    b=$(( $(last_branch "$parent") + 1 ))
    content=$(_line "$@" | sed "s/^/[${parent}.${b}] /")
    safe_append "$SCRATCH" "$content"
    echo "Added branch ${parent}.${b}"
    ;;

  # ───── append (raw) ────────────────────────────────────────
  append)
    ensure_file
    content=$(_line "$@")
    safe_append "$SCRATCH" "$content"
    ;;

  # ───── status ──────────────────────────────────────────────
  status)
    ensure_file
    echo "Agent: $AGENT_NAME"
    echo "Task: $(get_current_task)"
    echo "Latest main step : $(last_main)"
    if [[ $(last_main) -gt 0 ]]; then
      echo "Latest branches  :"
      while read -r step; do
        lastb=$(last_branch "$step")
        [[ $lastb -gt 0 ]] && printf "  • %s → %s\n" "$step" "$step.$lastb"
      done < <(grep -Po '^\[\d+\]' "$SCRATCH" 2>/dev/null | tr -d '[]' | sort -un)
      echo "Latest revisions :"
      while read -r step; do
        lastr=$(last_rev "$step")
        [[ $lastr -gt 0 ]] && printf "  • %s → %s~%s\n" "$step" "$step" "$lastr"
      done < <(grep -Po '^\[\d+\]' "$SCRATCH" 2>/dev/null | tr -d '[]' | sort -un)
    fi
    ;;

  # ───── finish ──────────────────────────────────────────────
  finish)
    ensure_file
    ts="$(date '+%Y-%m-%d_%H%M%S')"
    title="${1:-$(get_current_task)}"
    safe_title="${title// /_}"
    out="${AGENT_NAME}_${safe_title}_${ts}_scratchpad.md"
    
    with_lock "$LOCK_FILE" mv "$SCRATCH" "$SHARED_DIR/done_tasks/$out"
    echo "Agent '$AGENT_NAME' archived task to: $SHARED_DIR/done_tasks/$out"
    ;;

  # ───── handoff ─────────────────────────────────────────────
  handoff)
    ensure_file
    [[ $# -ge 2 ]] || usage
    to_agent="$1"
    shift
    message="$*"
    
    # Create handoff record
    handoff_file="$SHARED_DIR/handoffs/${AGENT_NAME}_to_${to_agent}_$(date +%s).md"
    mkdir -p "$SHARED_DIR/handoffs"
    
    with_lock "$LOCK_FILE" bash -c "
      echo '# Handoff from $AGENT_NAME to $to_agent' > '$handoff_file'
      echo '_Time: $(date '+%Y-%m-%d %H:%M:%S')_' >> '$handoff_file'
      echo '' >> '$handoff_file'
      echo '## Message' >> '$handoff_file'
      echo '$message' >> '$handoff_file'
      echo '' >> '$handoff_file'
      echo '## Current Scratchpad' >> '$handoff_file'
      cat '$SCRATCH' >> '$handoff_file'
      
      # Copy scratchpad to target agent
      mkdir -p '$BANK_DIR/agents/$to_agent'
      cp '$SCRATCH' '$BANK_DIR/agents/$to_agent/scratchpad.md'
      
      # Archive current agent's scratchpad
      mv '$SCRATCH' '${SCRATCH}.handed_off_$(date +%s)'
    "
    
    echo "Task handed off from '$AGENT_NAME' to '$to_agent'"
    echo "Handoff record: $handoff_file"
    ;;

  # ───── agents ──────────────────────────────────────────────
  agents)
    echo "Active Agents:"
    echo ""
    
    if [[ -d "$BANK_DIR/agents" ]]; then
      for agent_dir in "$BANK_DIR/agents"/*; do
        if [[ -d "$agent_dir" ]]; then
          agent=$(basename "$agent_dir")
          if [[ -f "$agent_dir/scratchpad.md" ]]; then
            task=$(head -1 "$agent_dir/scratchpad.md" 2>/dev/null | sed 's/^# //')
            echo "• $agent: $task"
          else
            echo "• $agent: (no active task)"
          fi
        fi
      done
    else
      echo "(No agents found)"
    fi
    
    # Show recent handoffs
    if [[ -d "$SHARED_DIR/handoffs" ]] && [[ -n "$(ls -A "$SHARED_DIR/handoffs" 2>/dev/null)" ]]; then
      echo ""
      echo "Recent Handoffs:"
      ls -t "$SHARED_DIR/handoffs" | head -5 | while read -r handoff; do
        echo "  - $handoff"
      done
    fi
    ;;

  *) usage ;;
esac