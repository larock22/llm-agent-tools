#!/usr/bin/env bash
# scratchpad.sh — micro-reasoning log for Memory Bank
# Commands:
#   start  <title>         – create/overwrite scratchpad.md
#   plan   <text>|-        – write precise scope / files / done-when block
#   step   <text>|-        – add next numbered step
#   branch <N>  <text>|-   – add sub-step N.x
#   revise <N>  <text>|-   – add revision N~y
#   append <text>|-        – raw append (no numbering)
#   status                 – quick summary
#   close  [title]         – archive pad to memory-bank/done/
# Requirements: Bash ≥4, coreutils
set -euo pipefail

: "${BANK_DIR:=memory-bank}"
PAD="scratchpad.md"

usage() {
  cat >&2 <<EOF
Usage: $0 {start|plan|step|branch|revise|append|status|close} [...]

Commands
  start  <task-title>        Begin new scratchpad
  plan   <text>|-            Record plan block before coding
  step   <text>|-            Add numbered step
  branch <N> <text>|-        Add sub-step N.x
  revise <N> <text>|-        Add revision N~y
  append <text>|-            Raw append (no numbering)
  status                     Show latest index numbers
  close  [task-title]        Archive pad → $BANK_DIR/done/
EOF
  exit 1
}

_line() { [[ $# -eq 0 || $1 == "-" ]] && cat || printf '%s\n' "$*"; }
_die()  { echo "ERROR: $*"; exit 1; }
need_pad() { [[ -f $PAD ]] || _die "No active scratchpad; run '$0 start' first."; }

last_main()   { grep -Po '^\[\d+\]'      "$PAD" | tail -1 | tr -d '[]' || echo 0; }
last_branch() { grep -Po "^\[$1\.\d+\]" "$PAD" | tail -1 | sed -E 's/^\['"$1"'\.([0-9]+)\].*/\1/' || echo 0; }
last_rev()    { grep -Po "^\[$1~\d+\]"  "$PAD" | tail -1 | sed -E 's/^\['"$1"'~([0-9]+)\].*/\1/' || echo 0; }

cmd="${1:-}"; shift || true
case "$cmd" in
  start)
    [[ $# -ge 1 ]] || usage
    mkdir -p "$BANK_DIR"
    printf "# %s\n_Started: %s_\n\n" "$*" "$(date '+%Y-%m-%d %H:%M:%S')" > "$PAD"
    ;;
  plan)
    need_pad
    printf "## Plan — %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" >> "$PAD"
    _line "$@" >> "$PAD"
    printf "\n" >> "$PAD"
    ;;
  step)
    need_pad
    n=$(( $(last_main) + 1 ))
    _line "$@" | sed "s/^/[${n}] /" >> "$PAD"
    ;;
  branch)
    need_pad; [[ $# -ge 2 ]] || usage
    p=$1; shift; b=$(( $(last_branch "$p") + 1 ))
    _line "$@" | sed "s/^/[${p}.${b}] /" >> "$PAD"
    ;;
  revise)
    need_pad; [[ $# -ge 2 ]] || usage
    p=$1; shift; r=$(( $(last_rev "$p") + 1 ))
    _line "$@" | sed "s/^/[${p}~${r}] /" >> "$PAD"
    ;;
  append)
    need_pad; _line "$@" >> "$PAD"
    ;;
  status)
    need_pad
    echo "Pad: $(head -1 "$PAD")"
    echo "Latest main : $(last_main)"
    ;;
  close)
    need_pad
    ts="$(date '+%Y-%m-%d_%H%M%S')"
    title="${1:-$(head -1 "$PAD" | sed 's/^# //')}"
    safe_title="$(echo "$title" | sed 's/[^a-zA-Z0-9._-]/_/g')"
    out="${safe_title}_${ts}_scratchpad.md"
    mkdir -p "$BANK_DIR/done"
    mv "$PAD" "$BANK_DIR/done/$out"
    printf 'Archived → %s/done/%s\n' "$BANK_DIR" "$out"
    ;;
  *) usage ;;
esac
