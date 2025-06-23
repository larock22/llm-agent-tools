# Multi-Agent Workflow Cheatsheet

## Quick Start
```bash
./setup-multi-agent.sh              # Initialize directory structure
./scratchpad-multi.sh agents        # List active agents
```

## Core Commands

### Task Tracking (scratchpad-multi.sh)
```bash
./scratchpad-multi.sh --agent researcher start "Research task"
./scratchpad-multi.sh --agent researcher step "Found important info"
./scratchpad-multi.sh --agent researcher handoff coder "Please implement"
./scratchpad-multi.sh --agent coder status
```

### Knowledge Management (knowledge.sh)
```bash
./knowledge.sh --agent researcher store "api.url" "https://example.com"
./knowledge.sh --agent researcher share "api.url"
./knowledge.sh --agent coder sync
./knowledge.sh --agent coder get "api.url"
```

### Code Intelligence (codemap.sh)
```bash
./codemap.sh map                    # Auto-scan project
./codemap.sh label "file.js" impl "Description"
./codemap.sh cheat component        # Create component docs
./codemap.sh debug "bug" "fix"     # Log bug patterns
```

## Common Patterns

1. **Research → Implementation**
   - Researcher discovers and stores knowledge
   - Researcher shares findings
   - Researcher hands off to implementer
   - Implementer syncs and retrieves knowledge

2. **Parallel Work**
   - Multiple agents work on different aspects
   - Use knowledge.sh to share discoveries
   - Check `agents` command to avoid conflicts

## Directory Structure
All work stored in `memory-bank/`:
- `agents/<name>/` - Private agent data
- `shared/` - Shared resources
- `codemap/` - Code intelligence