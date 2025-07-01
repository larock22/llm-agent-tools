# Migration Guide: From Multi-Agent to Claude-Optimized Architecture

## Architecture Evolution

### Previous Architecture (Multi-Agent System)
- Complex multi-tool setup
- Separate tools for research, planning, coding
- File-based memory bank
- Manual context management
- No integrated search

### New Architecture (Claude-Optimized System)
- Simplified 3-tool approach
- Unified knowledge management
- Fast indexed search with RAG
- Automatic categorization
- Persistent, searchable knowledge base

## Tool Mapping

| Old Tool | Purpose | New Equivalent |
|----------|---------|----------------|
| `setup-multi-agent.sh` | Create memory bank | `setup-claude-optimization.sh` |
| `researcher.sh` | Gather information | `scratchpad.sh` + manual filing |
| `architect.sh` | Design workflows | `scratchpad.sh` → patterns/ |
| `codemap.sh` | Map project structure | Built into .claude/code_index/ |
| `knowledge.sh` | Store/retrieve info | `claude-rag.sh query` |
| `context.sh` | Manage context | Automatic in scratchpad workflow |
| `scratchpad-multi.sh` | Multi-agent workspace | `scratchpad.sh` (simplified) |

## Key Differences

### 1. Knowledge Organization
**Before**: 
```
memory-bank/
├── agents/
├── shared/
├── locks/
└── context/
```

**After**:
```
.claude/
├── debug_history/
├── patterns/
├── qa/
├── cheatsheets/
├── metadata/
├── code_index/
├── anchors/
├── delta/
└── scratchpad/
```

### 2. Workflow Simplification

**Before**: 
1. Run researcher.sh
2. Store in knowledge.sh
3. Use architect.sh for planning
4. Map with codemap.sh
5. Manage context manually

**After**:
1. Create scratchpad
2. Work and add notes
3. Complete and file
4. Search instantly

### 3. Search Capabilities

**Before**: No integrated search
**After**: BM25 full-text search with <50ms response time

## Migration Steps

1. **Install new tools**:
   ```bash
   git clone <new-repo>
   cd llm-agent-tools
   chmod +x *.sh
   ```

2. **Run setup**:
   ```bash
   ./setup-claude-optimization.sh
   ```

3. **Build initial index**:
   ```bash
   ./claude-rag.sh build
   ```

4. **Migrate existing knowledge**:
   - Move debug logs to `.claude/debug_history/`
   - Move patterns to `.claude/patterns/`
   - Move Q&As to `.claude/qa/`

5. **Rebuild index**:
   ```bash
   ./claude-rag.sh build
   ```

## Advantages of New System

1. **Simplicity**: 3 tools vs 7+ tools
2. **Speed**: Indexed search vs file scanning
3. **Organization**: Clear categories vs generic storage
4. **Persistence**: Knowledge accumulates systematically
5. **Integration**: Unified workflow vs separate tools

## Example: Old vs New Workflow

### Old Workflow
```bash
# Research phase
./tools/core/researcher.sh "API authentication"
./tools/core/knowledge.sh store "api-auth" "findings.md"

# Planning phase  
./tools/core/architect.sh "design API auth"
./tools/core/context.sh save "api-auth-context"

# Coding phase
./tools/core/codemap.sh map src/
./tools/core/codemap.sh debug "Fixed auth bug"
```

### New Workflow
```bash
# Single unified workflow
./scratchpad.sh new task "implement API auth"
./scratchpad.sh append task_implement_API_auth "Research: OAuth2 best practices"
./scratchpad.sh append task_implement_API_auth "Design: JWT with refresh tokens"
./scratchpad.sh complete task_implement_API_auth
# File to patterns/
./scratchpad.sh filed task_implement_API_auth

# Later, search everything
./claude-rag.sh query "API authentication JWT"
```

## Summary

The new architecture dramatically simplifies the workflow while adding powerful search capabilities. Instead of managing multiple tools and manual coordination, you now have a streamlined process: **Work → File → Search**.