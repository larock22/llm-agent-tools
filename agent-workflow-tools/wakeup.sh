#!/usr/bin/env bash

BANK_DIR="memory-bank"
CORE=("project_brief" "tech_context" "product_context" "current_state_summary" "progress_overview")

wakeup() {
    # Prioritize current_state_summary.md
    local summary_file="current_state_summary"
    local found_summary=0

    for file in "${CORE[@]}"; do
        local filepath="$BANK_DIR/${file}.md"
        if [[ "$file" == "$summary_file" && -f "$filepath" ]]; then
            echo "===== [${file}.md] ====="
            cat "$filepath"
            echo
            found_summary=1
        fi
    done

    for file in "${CORE[@]}"; do
        local filepath="$BANK_DIR/${file}.md"
        if [[ "$file" != "$summary_file" && -f "$filepath" ]]; then
            echo "===== [${file}.md] ====="
            cat "$filepath"
            echo
        fi
    done
}

# Simple CLI argument parser
if [[ $# -eq 0 || "$1" == "wakeup" ]]; then
    wakeup
else
    echo "Usage: $0 [wakeup]"
    exit 1
fi