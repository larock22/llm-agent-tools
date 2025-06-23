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
