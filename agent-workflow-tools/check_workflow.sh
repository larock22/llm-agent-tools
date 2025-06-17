
#!/usr/bin/env bash
# check_workflow.sh - Simple verification that workflow was followed

set -euo pipefail

MEMORY_BANK_DIR="memory-bank"
DONE_DIR="$MEMORY_BANK_DIR/done"

echo "=== Workflow Verification ==="
echo

# Check 1: Was memory bank updated recently?
if [[ -f "$MEMORY_BANK_DIR/current_state_summary.md" ]]; then
    mod_time=$(stat -c %Y "$MEMORY_BANK_DIR/current_state_summary.md" 2>/dev/null || stat -f %m "$MEMORY_BANK_DIR/current_state_summary.md" 2>/dev/null || echo "0")
    current_time=$(date +%s)
    diff=$((current_time - mod_time))
    
    if [[ $diff -lt 3600 ]]; then  # Updated within last hour
        echo "✅ Memory bank updated recently ($(($diff / 60)) minutes ago)"
    else
        echo "⚠️  Memory bank not updated recently (last update: $(($diff / 3600)) hours ago)"
    fi
else
    echo "❌ current_state_summary.md not found"
fi

# Check 2: Are there recent scratchpad archives?
if [[ -d "$DONE_DIR" ]]; then
    recent_count=$(find "$DONE_DIR" -name "*.md" -mtime -1 2>/dev/null | wc -l)
    if [[ $recent_count -gt 0 ]]; then
        echo "✅ Found $recent_count archived scratchpad(s) from today"
        # Show the most recent one
        latest=$(ls -t "$DONE_DIR"/*.md 2>/dev/null | head -1)
        if [[ -n "$latest" ]]; then
            echo "   Latest: $(basename "$latest")"
        fi
    else
        echo "⚠️  No scratchpads archived today"
    fi
else
    echo "❌ Archive directory not found"
fi

# Check 3: Quick summary
echo
if [[ -f "$MEMORY_BANK_DIR/current_state_summary.md" ]]; then
    echo "📋 Current State Summary:"
    grep -A2 "^## Last Session Outcome" "$MEMORY_BANK_DIR/current_state_summary.md" 2>/dev/null || echo "   (No session outcome found)"
fi

echo
echo "✅ Workflow check complete!"