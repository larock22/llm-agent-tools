#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# context.sh - Gather and store context for a given task or issue.
#
# Commands:
#   start <issue-title>      - Create a new context file.
#   add "<command>"          - Run a command and append its output.
#   add-file <file_path> ... - Append file contents.
#   add-text <text>|-        - Append raw text.
#   finish [issue-title]     - Archive the context file.
#
# Requires: Bash >= 4, coreutils.
# ------------------------------------------------------------------------------
set -euo pipefail

BANK_DIR="memory-bank"
CONTEXT_DIR="$BANK_DIR/context"
CONTEXT_FILE="$CONTEXT_DIR/context.md"

# ------------------------------------------------------------------------------
usage() {
  cat >&2 <<EOF
Usage: $0 {start|add|add-file|add-text|finish} [...]

Commands:
  start <issue-title>      - Create a new context file.
  add "<command>"          - Run a command and append its output to the context file.
  add-file <file_path> ... - Append one or more file contents.
  add-text <text>|-        - Append raw text to the context file (use '-' for stdin).
  finish [issue-title]     - Archive the context file.
EOF
  exit 1
}

# ------------------------------------------------------------------------------
# COMMANDS
# ------------------------------------------------------------------------------
cmd="${1:-}"
if [[ $# -gt 0 ]]; then
  shift
fi

case "$cmd" in
  # -------------------- start --------------------
  start)
    [[ $# -ge 1 ]] || usage
    issue_title="$*"
    mkdir -p "$CONTEXT_DIR"
    {
      echo "# Context for: $issue_title"
      echo "_Started: $(date '+%Y-%m-%d %H:%M:%S')_"
      echo
    } > "$CONTEXT_FILE"
    echo "Context file created: $CONTEXT_FILE"
    ;;

  # -------------------- add --------------------
  add)
    [[ $# -ge 1 ]] || usage
    command_to_run="$*"
    {
      echo "---"
      echo "### \\\`$command_to_run\\\`"
      echo "\`\`\`"
      eval "$command_to_run"
      echo "\`\`\`"
      echo
    } >> "$CONTEXT_FILE"
    echo "Added output of '$command_to_run' to context."
    ;;

  # -------------------- add-file --------------------
  add-file)
    [[ $# -ge 1 ]] || usage
    for file_path in "$@"; do
      if [[ -f "$file_path" ]]; then
        {
          echo "---"
          echo "### Contents of \\\`$file_path\\\`"
          echo "\`\`\`"
          cat "$file_path"
          echo "\`\`\`"
          echo
        } >> "$CONTEXT_FILE"
        echo "Added contents of '$file_path' to context."
      else
        echo "Warning: File not found: $file_path" >&2
      fi
    done
    ;;

  # -------------------- add-text --------------------
  add-text)
    [[ $# -ge 1 ]] || usage
    if [[ "$1" == "-" ]]; then
      text="$(cat)"
    else
      text="$*"
    fi
    {
      echo "---"
      echo "$text"
      echo
    } >> "$CONTEXT_FILE"
    echo "Added text to context."
    ;;

  # -------------------- finish --------------------
  finish)
    [[ -f "$CONTEXT_FILE" ]] || { echo "No active context file to finish." >&2; exit 1; }
    
    issue_title="${1:-$(head -n 1 "$CONTEXT_FILE" | sed 's/# Context for: //')}"
    # Sanitize title for filename
    safe_title=$(echo "$issue_title" | sed 's/[^a-zA-Z0-9]/-/g' | tr -s '-' | tr '[:upper:]' '[:lower:]')
    timestamp=$(date +%Y%m%d_%H%M%S)
    archive_dir="$BANK_DIR/context_archive"
    archive_file="$archive_dir/${timestamp}_${safe_title}.md"
    
    mkdir -p "$archive_dir"
    mv "$CONTEXT_FILE" "$archive_file"
    
    echo "Context archived to: $archive_file"
    ;;

  *)
    usage
    ;;
esac
