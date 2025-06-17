#!/usr/bin/env bash
# qa_task.sh — Subcommand-based QA workflow for Memory Bank agent
# Usage: qa_task.sh {start_qa|verify_memory_updated|verify_scratchpad_archived|log_qa_step|complete_qa} [...]

set -euo pipefail

QA_TEMP_DIR=".qa_temp"
QA_ARCHIVE_DIR="memory-bank/qa_reports"
MEMORY_BANK_DIR="memory-bank"
DONE_DIR="$MEMORY_BANK_DIR/done"
STATE_FILE=".current_qa_log_path"

usage() {
  cat >&2 <<EOF
Usage: $0 {start_qa|verify_memory_updated|verify_scratchpad_archived|log_qa_step|complete_qa} [...]

Subcommands:
  start_qa <task_description_or_id>
      Initializes a QA session and creates a temp log file.
  verify_memory_updated
      Checks if current_state_summary.md and progress_overview.md exist and are non-empty.
  verify_scratchpad_archived <task_id_pattern>
      Checks if a scratchpad archive exists matching the pattern.
  log_qa_step <message>
      Appends a QA log entry with timestamp.
  complete_qa <task_description_or_id>
      Completes QA session, archives log, and reports status.
EOF
  exit 1
}

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

require_log() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "ERROR: No active QA session. Run '$0 start_qa <task_id>' first." >&2
    exit 1
  fi
  LOG_PATH="$(cat "$STATE_FILE")"
  if [[ ! -f "$LOG_PATH" ]]; then
    echo "ERROR: QA log file not found: $LOG_PATH" >&2
    exit 1
  fi
}

case "${1:-}" in
  start_qa)
    [[ $# -ge 2 ]] || usage
    mkdir -p "$QA_TEMP_DIR"
    mkdir -p "$QA_ARCHIVE_DIR"
    TASK_ID="$2"
    LOG_PATH="$QA_TEMP_DIR/qa_session_${TASK_ID}_$(date +%Y%m%d_%H%M%S).log"
    echo "$LOG_PATH" > "$STATE_FILE"
    echo "[$(timestamp)] QA session started for '$TASK_ID'" > "$LOG_PATH"
    echo "Log file: $LOG_PATH" >> "$LOG_PATH"
    echo "QA session started for '$TASK_ID'. Log file: $LOG_PATH"
    ;;

  verify_memory_updated)
    require_log
    LOG_PATH="$(cat "$STATE_FILE")"
    CSS="$MEMORY_BANK_DIR/current_state_summary.md"
    PO="$MEMORY_BANK_DIR/progress_overview.md"
    PASS_CSS="FAIL"
    PASS_PO="FAIL"
    MSG=""
    if [[ -s "$CSS" ]]; then
      # Check if modified in last 24h (bonus)
      if [[ $(find "$CSS" -mmin -1440) ]]; then
        PASS_CSS="PASS"
      else
        PASS_CSS="PASS (old)"
      fi
    fi
    if [[ -s "$PO" ]]; then
      if [[ $(find "$PO" -mmin -1440) ]]; then
        PASS_PO="PASS"
      else
        PASS_PO="PASS (old)"
      fi
    fi
    MSG="Memory Update Check: Current_State_Summary.md: $PASS_CSS, Progress_Overview.md: $PASS_PO"
    echo "[$(timestamp)] $MSG" >> "$LOG_PATH"
    echo "$MSG"
    ;;

  verify_scratchpad_archived)
    require_log
    LOG_PATH="$(cat "$STATE_FILE")"
    PATTERN="${2:-}"
    FOUND="Not Found"
    PASS="FAIL"
    if [[ -d "$DONE_DIR" ]]; then
      if [[ -n "$PATTERN" ]]; then
        FILE=$(find "$DONE_DIR" -type f -name "*${PATTERN}*_scratchpad.md" | head -n 1 || true)
        if [[ -n "$FILE" ]]; then
          FOUND="$(basename "$FILE")"
          PASS="PASS"
        fi
      else
        FILE=$(find "$DONE_DIR" -type f | head -n 1 || true)
        if [[ -n "$FILE" ]]; then
          FOUND="$(basename "$FILE")"
          PASS="PASS"
        fi
      fi
    fi
    MSG="Scratchpad Archival Check: $PASS - Found: $FOUND"
    echo "[$(timestamp)] $MSG" >> "$LOG_PATH"
    echo "$MSG"
    ;;

  log_qa_step)
    require_log
    LOG_PATH="$(cat "$STATE_FILE")"
    [[ $# -ge 2 ]] || { echo "ERROR: log_qa_step requires a message." >&2; exit 1; }
    shift
    MSG="$*"
    echo "[$(timestamp)] $MSG" >> "$LOG_PATH"
    echo "QA step logged: '$MSG'"
    ;;

  complete_qa)
    require_log
    LOG_PATH="$(cat "$STATE_FILE")"
    [[ $# -ge 2 ]] || { echo "ERROR: complete_qa requires <task_description_or_id>." >&2; exit 1; }
    TASK_ID="$2"
    # Count failures in log
    FAILS=$(grep -c 'FAIL' "$LOG_PATH" || true)
    if [[ "$FAILS" -eq 0 ]]; then
      STATUS="QA Completed for $TASK_ID. All checks passed."
    else
      STATUS="QA Completed for $TASK_ID. $FAILS checks failed."
    fi
    echo "[$(timestamp)] $STATUS" >> "$LOG_PATH"
    # Archive log
    ARCHIVE_FILE="$QA_ARCHIVE_DIR/qa_report_${TASK_ID}_$(date +%Y%m%d_%H%M%S).log"
    mv "$LOG_PATH" "$ARCHIVE_FILE"
    rm -f "$STATE_FILE"
    echo "QA session for '$TASK_ID' completed. Report archived to: $ARCHIVE_FILE"
    ;;

  *)
    usage
    ;;
esac