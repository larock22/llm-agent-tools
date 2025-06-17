#!/usr/bin/env bash
# bankctl.sh — init / sync / plan / status / gc  for Cline-style Memory Bank
set -euo pipefail

BANK_DIR="memory-bank"
CORE=(project_brief tech_context product_context current_state_summary progress_overview)

init() {
  mkdir -p "$BANK_DIR/done"

  # Create core files with meaningful initial content
  cat > "$BANK_DIR/project_brief.md" <<EOF
# Project Brief

Key project goals and requirements will be documented here.

_TODO: Add project brief_
EOF

  cat > "$BANK_DIR/tech_context.md" <<EOF
# Technical Context

Architectural decisions and technical choices will be documented here.

_TODO: Add technical context_
EOF

  cat > "$BANK_DIR/product_context.md" <<EOF
# Product Context

User experience goals and product functionality will be documented here.

_TODO: Add product context_
EOF

  cat > "$BANK_DIR/current_state_summary.md" <<EOF
# Current State Summary

A concise summary of the current project state and immediate next objectives.

_TODO: Add current state summary_
EOF

  cat > "$BANK_DIR/progress_overview.md" <<EOF
# Progress Overview

High-level tracking of features and milestones.

_TODO: Add progress overview_
EOF

  echo "Memory Bank initialised."
}


status() {
  echo "Memory Bank: $BANK_DIR"
  for f in "${CORE[@]}"; do
    printf "• %-17s %4s lines\n" "${f}.md" "$(wc -l < "$BANK_DIR/${f}.md")"
  done
}

gc() { find "$BANK_DIR/done" -type f -mtime +30 -print -delete; }

case "${1:-}" in
  init)   init ;;
  status) status ;;
  gc)     gc ;;
  *) echo "Usage: $0 {init|status|gc}"; exit 1 ;;
esac
