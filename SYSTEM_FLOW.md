# System Flow - Claude-Optimized LLM Agent Tools

```mermaid
flowchart TD
    Start([Start]) --> Init{System Ready?}
    
    Init -->|No| Setup["`**Initial Setup**
    ./setup-claude-optimization.sh
    Creates .claude/ structure`"]
    
    Init -->|Yes| Work["`**Work Session**
    Choose your task`"]
    
    Setup --> Claude[("`**.claude/**
    ├── metadata/
    ├── code_index/
    ├── debug_history/
    ├── patterns/
    ├── cheatsheets/
    ├── qa/
    ├── delta/
    ├── anchors/
    └── scratchpad/`")]
    
    Claude --> Work
    
    Work --> Action{Action?}
    
    Action -->|Take Notes| Scratch["`**Create Scratchpad**
    ./scratchpad.sh new [type] [desc]
    Types: task, debug, plan`"]
    
    Action -->|Search| Query["`**Search Knowledge**
    ./claude-rag.sh query 'terms'
    Optional: --category --limit`"]
    
    Scratch --> Notes["`**Add Notes**
    ./scratchpad.sh append [file] 'text'
    ./scratchpad.sh view [file]`"]
    
    Notes --> Complete["`**Complete Work**
    ./scratchpad.sh complete [file]
    Shows filing instructions`"]
    
    Complete --> File["`**File to .claude/**
    Agent determines category
    Writes to appropriate dir`"]
    
    File --> Mark["`**Mark as Filed**
    ./scratchpad.sh filed [file]
    Removes from active`"]
    
    Mark --> Index["`**Update Index**
    ./claude-rag.sh build
    Refreshes search index`"]
    
    Query --> RAG["`**RAG Engine**
    Tantivy BM25 Search
    <50ms response time`"]
    
    RAG --> Results["`**JSON Results**
    - Ranked chunks
    - Categories
    - Context
    - Suggested tools`"]
    
    Index --> Knowledge[("`**Knowledge Base**
    Persistent
    Searchable
    Categorized`")]
    
    Results --> Decision{Continue?}
    Index --> Decision
    
    Decision -->|Yes| Work
    Decision -->|No| End([End])
    
    style Start fill:#e1f5fe
    style Claude fill:#f3e5f5
    style Knowledge fill:#e8f5e9
    style End fill:#c8e6c9
    style RAG fill:#fff9c4
```

## Key Workflow Patterns

### 1. **Note-Taking Pattern**
```
Create → Write → Complete → File → Index
```

### 2. **Search Pattern**
```
Query → RAG → Results → Use
```

### 3. **Knowledge Growth**
```
Work → Document → File → Search Later
```

## Tool Commands Reference

### Scratchpad Workflow
```bash
# Create
./scratchpad.sh new task "implement feature"

# Work
./scratchpad.sh append task_implement_feature "notes"

# Complete
./scratchpad.sh complete task_implement_feature

# File (done by agent)
# Then mark as filed
./scratchpad.sh filed task_implement_feature
```

### Search Workflow
```bash
# Build/update index
./claude-rag.sh build

# Search everything
./claude-rag.sh query "search terms"

# Search specific category
./claude-rag.sh query "debug" --category debug_history

# Limit results
./claude-rag.sh query "patterns" --limit 5
```

## System Benefits

- **Simple**: 3 tools, clear workflow
- **Fast**: Indexed search, quick retrieval
- **Persistent**: Knowledge accumulates
- **Organized**: Automatic categorization
- **Scalable**: Handles large knowledge bases