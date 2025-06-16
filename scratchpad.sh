#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# scratchpad.sh – lightweight scratch‑pad workflow for an LLM agent
#
#   start   <task‑title>          → create/overwrite scratchpad.md
#   step    <text>|‑              → add next sequential thinking step
#   revise  <N>    <text>|‑       → attach a revision to step N
#   branch  <N>    <text>|‑       → start sub‑step N.x (branch)
#   append  <text>|‑              → raw append (fallback / free‑form)
#   status                       → show counters & last entries
#   finish  [task‑title]          → archive scratchpad to /memory_bank/done_task
#
# Requires: Bash ≥ 4, coreutils.
# ──────────────────────────────────────────────────────────────
set -euo pipefail

SCRATCH="scratchpad.md"          # working file (always in repo root)
BANK_DIR="memory-bank"

# ──────────────────────────────────────────────────────────────
usage() {
  cat >&2 <<EOF
Usage: $0 {start|step|revise|branch|append|status|finish} [...]

Commands
  start  <task-title>            Create/overwrite $SCRATCH with header
  step   <text>|-               Add next sequential step (or read STDIN)
  revise <step-no> <text>|-     Add a revision to an existing step
  branch <step-no> <text>|-     Add a branched sub‑step under <step-no>
  append <text>|-               Raw append (no numbering / validation)
  status                        Show last main/branch/revision indices
  finish [task-title]           Archive scratchpad to $BANK_DIR
EOF
  exit 1
}

# ───────────────────────── helpers ────────────────────────────
_line() {                        # echo input respecting "-" ⇒ STDIN
  if [[ $# -eq 0 || "$1" == "-" ]]; then
    cat
  else
    printf '%s\n' "$*"
  fi
}

ensure_file() { [[ -f $SCRATCH ]] || { echo "ERROR: No active scratchpad; run '$0 start' first." >&2; exit 1; }; }

last_main()   { grep -Po '^\[\d+\]'      "$SCRATCH" | tail -1 | tr -d '[]' || echo 0; }
last_branch() { grep -Po "^\[$1\.\d+\]" "$SCRATCH" | tail -1 | sed -E "s/^\[$1\.([0-9]+)\].*/\1/" || echo 0; }
last_rev()    { grep -Po "^\[$1~\d+\]"  "$SCRATCH" | tail -1 | sed -E "s/^\[$1~([0-9]+)\].*/\1/" || echo 0; }

# ─────────────────────── dispatcher ───────────────────────────
cmd="${1:-}" ; shift || true
case "$cmd" in
  # ───── start ───────────────────────────────────────────────
  start)
    [[ $# -ge 1 ]] || usage
    task="$*"
    {
      echo "# $task"
      echo "_Started: $(date '+%Y-%m-%d %H:%M:%S')_"
      echo
    } > "$SCRATCH"
    ;;

  # ───── step ────────────────────────────────────────────────
  step)
    ensure_file
    next=$(( $(last_main) + 1 ))
    _line "$@" | sed "s/^/[${next}] /" >> "$SCRATCH"
    ;;

  # ───── revise ──────────────────────────────────────────────
  revise)
    ensure_file
    [[ $# -ge 2 ]] || usage
    target="$1" ; shift
    [[ "$target" =~ ^[0-9]+$ ]] || { echo "Invalid step number '$target'." >&2; exit 1; }
    grep -q "^\[$target\]" "$SCRATCH" || { echo "Step $target not found." >&2; exit 1; }
    r=$(( $(last_rev "$target") + 1 ))
    _line "$@" | sed "s/^/[${target}~${r}] /" >> "$SCRATCH"
    ;;

  # ───── branch ──────────────────────────────────────────────
  branch)
    ensure_file
    [[ $# -ge 2 ]] || usage
    parent="$1" ; shift
    [[ "$parent" =~ ^[0-9]+$ ]] || { echo "Invalid step number '$parent'." >&2; exit 1; }
    grep -q "^\[$parent\]" "$SCRATCH" || { echo "Step $parent not found." >&2; exit 1; }
    b=$(( $(last_branch "$parent") + 1 ))
    _line "$@" | sed "s/^/[${parent}.${b}] /" >> "$SCRATCH"
    ;;

  # ───── append (raw) ────────────────────────────────────────
  append)
    ensure_file
    _line "$@" >> "$SCRATCH"
    ;;

  # ───── status ──────────────────────────────────────────────
  status)
    ensure_file
    echo "File: $(head -1 "$SCRATCH")"
    echo "Latest main step : $(last_main)"
    if [[ $(last_main) -gt 0 ]]; then
      echo "Latest branches  :"
      while read -r step; do
        lastb=$(last_branch "$step")
        [[ $lastb -gt 0 ]] && printf "  • %s → %s\n" "$step" "$step.$lastb"
      done < <(grep -Po '^\[\d+\]' "$SCRATCH" | tr -d '[]' | sort -un)
      echo "Latest revisions :"
      while read -r step; do
        lastr=$(last_rev "$step")
        [[ $lastr -gt 0 ]] && printf "  • %s → %s~%s\n" "$step" "$step" "$lastr"
      done < <(grep -Po '^\[\d+\]' "$SCRATCH" | tr -d '[]' | sort -un)
    fi
    ;;

  # ───── finish ──────────────────────────────────────────────
  finish)
    ensure_file
    mkdir -p "$BANK_DIR"
    ts="$(date '+%Y-%m-%d_%H%M%S')"
    title="${1:-$(head -1 "$SCRATCH" | sed 's/^# //')}"
    out="${title// /_}_${ts}_scratchpad.md"
    mv "$SCRATCH" "$BANK_DIR/$out"
    printf 'Archived to %s/%s\n' "$BANK_DIR" "$out"
    ;;

  *) usage ;;
esac


