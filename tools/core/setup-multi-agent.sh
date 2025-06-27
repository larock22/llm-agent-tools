#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# setup-multi-agent.sh – Initialize multi-agent directory structure
# ──────────────────────────────────────────────────────────────
set -euo pipefail

BANK_DIR="${BANK_DIR:-memory-bank}"

echo "Setting up multi-agent directory structure..."

# Create directory structure
mkdir -p "$BANK_DIR"/{agents,shared/{done_tasks,handoffs,knowledge},locks,context,context_archive,codemap/{metadata,cheatsheets,debug_history}}

# Initialize shared knowledge base
[[ -f "$BANK_DIR/shared/knowledge_base.json" ]] || echo '{}' > "$BANK_DIR/shared/knowledge_base.json"

# Create README files
cat > "$BANK_DIR/README.md" <<'EOF'
# Memory Bank - Multi-Agent System

This directory contains the shared memory system for multiple LLM agents.

## Directory Structure

```
memory-bank/
├── agents/                    # Agent-specific directories
│   └── <agent-name>/         # Each agent's private space
│       ├── scratchpad.md     # Current task tracking
│       └── knowledge.json    # Private knowledge base
├── shared/                   # Shared resources
│   ├── done_tasks/          # Completed task archives
│   ├── handoffs/            # Task handoff records
│   └── knowledge_base.json  # Shared knowledge pool
├── locks/                   # File locks for concurrent access
├── context/                 # Active context gathering
├── context_archive/         # Archived context files
└── codemap/                # Lightweight code intelligence
    ├── metadata/           # Module labels and dependencies
    ├── cheatsheets/        # Component quick references
    └── debug_history/      # Bug→fix patterns
```

## Usage

Use the multi-agent tools with the `--agent` flag:

```bash
# Start a task as the researcher agent
./scratchpad-multi.sh --agent researcher start "Research API documentation"

# Store knowledge as the researcher
./knowledge.sh --agent researcher store "api.endpoint" "https://api.example.com/v2"

# Hand off to another agent
./scratchpad-multi.sh --agent researcher handoff coder "Research complete, please implement"

# Access as the coder agent
./scratchpad-multi.sh --agent coder status
./knowledge.sh --agent coder get "api.endpoint"
```
EOF

cat > "$BANK_DIR/agents/README.md" <<'EOF'
# Agent Directories

Each subdirectory here represents an individual agent's private workspace.

Agents are created automatically when first referenced.
EOF

cat > "$BANK_DIR/shared/README.md" <<'EOF'
# Shared Resources

This directory contains resources shared between all agents:

- `done_tasks/` - Archived completed tasks from all agents
- `handoffs/` - Records of task handoffs between agents
- `knowledge_base.json` - Shared knowledge accessible to all agents
EOF

# Set permissions
chmod -R 755 "$BANK_DIR"

echo "Multi-agent directory structure created successfully!"
echo ""
echo "Directory layout:"
tree -L 3 "$BANK_DIR" 2>/dev/null || find "$BANK_DIR" -type d | head -20

echo ""
echo "To get started:"
echo "  ./scratchpad-multi.sh --agent myagent start 'My first task'"
echo "  ./knowledge.sh --agent myagent store 'key' 'value'"
echo ""
echo "For backward compatibility, the original tools still work:"
echo "  ./scratchpad.sh start 'Task'"
echo "  (uses default agent)"