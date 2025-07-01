# LLM Agent Tools

A comprehensive toolkit for AI agents to manage knowledge, take notes, and retrieve information efficiently.

## Tools Overview

### 1. **setup-claude-optimization.sh**
Creates the `.claude` directory structure for organized knowledge management.

### 2. **scratchpad.sh**
Temporary note-taking system for AI agents during work sessions.

### 3. **claude-rag.sh**
Fast retrieval system using Rust/Tantivy for searching the knowledge base.

## Quick Start

```bash
# 1. Setup (only needed once)
./setup-claude-optimization.sh

# 2. Create a scratchpad for your work
./scratchpad.sh new task "implement feature X"

# 3. Add notes as you work
./scratchpad.sh append task_implement_feature_X "Found solution: use pattern Y"

# 4. Complete and file the scratchpad
./scratchpad.sh complete task_implement_feature_X
# Then file it to appropriate .claude directory
./scratchpad.sh filed task_implement_feature_X

# 5. Build/update the search index
./claude-rag.sh build

# 6. Search your knowledge base
./claude-rag.sh query "pattern Y"
```

## Example Workflow

### Debugging Session Example

```bash
# Start debugging session
./scratchpad.sh new debug "API timeout issue"

# Add findings
./scratchpad.sh append debug_API_timeout_issue "Error occurs after 30s"
./scratchpad.sh append debug_API_timeout_issue "Root cause: missing timeout config"

# Complete and review
./scratchpad.sh complete debug_API_timeout_issue

# File to debug_history
echo "Filing to .claude/debug_history/api_timeout_fix.md"
# [AI agent writes the file]

# Mark as filed
./scratchpad.sh filed debug_API_timeout_issue

# Update search index
./claude-rag.sh build

# Later, search for similar issues
./claude-rag.sh query "timeout" --category debug_history
```

## Directory Structure

```
.claude/
├── metadata/       # Component information
├── code_index/     # Code relationships
├── debug_history/  # Debugging sessions
├── patterns/       # Implementation patterns
├── cheatsheets/    # Quick references
├── qa/            # Questions & answers
├── delta/         # Change logs
├── anchors/       # Important locations
└── scratchpad/    # Temporary notes
    ├── active/    # Current work
    └── archive/   # Old scratchpads
```

## Key Features

- **Systematic Knowledge Management**: Organized directory structure
- **Temporary → Permanent**: Scratchpads become searchable knowledge
- **Fast Retrieval**: BM25-indexed search with <50ms query time
- **Category Filtering**: Search within specific knowledge domains
- **AI-Optimized**: JSON output format for agent consumption

## Requirements

- Bash shell
- Rust/Cargo (for RAG system)
- Unix-like environment

## Installation

```bash
# Clone and setup
git clone <repository>
cd llm-agent-tools

# Make scripts executable
chmod +x *.sh

# Run initial setup
./setup-claude-optimization.sh

# Build RAG system (requires Rust)
./claude-rag.sh build
```

## Best Practices

1. **Use descriptive names** for scratchpads
2. **File promptly** - Don't let scratchpads accumulate
3. **Rebuild index** after filing new content
4. **Search before creating** - Check if knowledge exists
5. **Categorize properly** - Use the right .claude subdirectory

## Tips

- Query with natural language: `./claude-rag.sh query "how to handle errors"`
- Filter by category: `./claude-rag.sh query "debug" --category debug_history`
- Check stats: `./claude-rag.sh stats`
- List active work: `./scratchpad.sh list`