# Clean Directory Update

## Changes Made

All scripts have been updated to keep all generated files within the `memory-bank/` directory to maintain a clean project structure.

### Script Updates

1. **context.sh**
   - Changed: `CONTEXT_DIR="context"` → `CONTEXT_DIR="$BANK_DIR/context"`
   - Now stores active context in `memory-bank/context/`
   - Archives remain in `memory-bank/context_archive/`

2. **architect.sh**
   - Changed: `ARCH_DIR="architecture"` → `ARCH_DIR="$BANK_DIR/architecture"`
   - Now stores all architecture docs in `memory-bank/architecture/`
   - Includes subdirectories: modules/, decisions/, flows/

3. **scratchpad.sh & scratchpad-multi.sh**
   - Already correctly using `memory-bank/` - no changes needed

4. **setup-multi-agent.sh**
   - Updated to create all necessary subdirectories within `memory-bank/`

### New Directory Structure

```
llm-agent-tools/
├── *.sh                     # All script files
├── *.md                     # Documentation files
├── .gitignore              # Updated to handle memory-bank contents
└── memory-bank/            # ALL agent-generated content
    ├── agents/             # Agent-specific data
    ├── shared/             # Shared resources
    ├── locks/              # File locks
    ├── context/            # Active context files
    ├── context_archive/    # Archived contexts
    └── architecture/       # Architecture documentation
```

### Benefits

1. **Clean Workspace**: All generated files are contained in `memory-bank/`
2. **Easy Distribution**: Users can wget scripts without worrying about scattered files
3. **Simple Cleanup**: Delete `memory-bank/` to remove all agent data
4. **Git-Friendly**: .gitignore properly handles working vs archived files

### Usage Remains the Same

```bash
# All commands work exactly as before
./scratchpad.sh start "Task"
./context.sh start "Debug issue"
./architect.sh init

# Multi-agent commands
./scratchpad-multi.sh --agent researcher start "Research"
./knowledge.sh --agent researcher store "key" "value"
```

The only difference is that all output is now neatly organized within `memory-bank/`.