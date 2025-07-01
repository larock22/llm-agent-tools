# Architecture Flow - LLM Agent Tools

## Updated System Architecture

```mermaid
flowchart TD
    Start([User/Agent Starts]) --> Choice{What do you need?}
    
    Choice -->|Initial Setup| Setup["`**SETUP PHASE**
    ./setup-claude-optimization.sh
    Creates .claude structure`"]
    
    Choice -->|Take Notes| Scratch["`**WORKING NOTES**  
    ./scratchpad.sh new
    Create temporary workspace`"]
    
    Choice -->|Search Knowledge| Search["`**SEARCH PHASE**
    ./claude-rag.sh query
    Fast BM25 retrieval`"]
    
    Choice -->|Build Index| Index["`**INDEX PHASE**
    ./claude-rag.sh build
    Index all knowledge`"]
    
    Setup --> Claude[("`**CLAUDE LAYER**
    .claude/
    ├── metadata/
    ├── code_index/
    ├── debug_history/
    ├── patterns/
    ├── cheatsheets/
    ├── qa/
    ├── delta/
    ├── anchors/
    └── scratchpad/`")]
    
    Scratch --> Work["`**SCRATCHPAD WORKFLOW**
    1. new - Create workspace
    2. append - Add notes
    3. view/edit - Review
    4. complete - Prepare filing`"]
    
    Work --> Complete["`**COMPLETION PHASE**
    Agent reviews content
    Determines category
    Files to .claude/[dir]`"]
    
    Complete --> Filed["`**FILE & INDEX**
    ./scratchpad.sh filed
    ./claude-rag.sh build`"]
    
    Search --> RAG["`**RAG FEATURES**
    - BM25 ranking
    - Category filtering
    - JSON output
    - <50ms queries`"]
    
    Index --> Tantivy["`**TANTIVY ENGINE**
    - Rust-based indexing
    - Document chunking
    - Metadata tracking
    - Fast retrieval`"]
    
    Claude --> Knowledge{"`**KNOWLEDGE BASE**
    Organized by type`"}
    
    Knowledge -->|Debug Sessions| Debug["`**debug_history/**
    - Error fixes
    - Troubleshooting
    - Solution pairs`"]
    
    Knowledge -->|Patterns| Patterns["`**patterns/**
    - Implementation patterns
    - Best practices
    - Reusable solutions`"]
    
    Knowledge -->|Q&A| QA["`**qa/**
    - Answered questions
    - Problem solutions
    - Explanations`"]
    
    Knowledge -->|References| Refs["`**cheatsheets/**
    - Quick references
    - Common commands
    - Shortcuts`"]
    
    Filed --> Claude
    RAG --> Results["`**SEARCH RESULTS**
    Relevant chunks
    Scored by relevance
    With context`"]
    
    Tantivy --> Claude
    
    Debug --> End([Knowledge Available])
    Patterns --> End
    QA --> End
    Refs --> End
    Results --> End
    
    style Start fill:#e1f5fe
    style Choice fill:#fff3e0
    style Claude fill:#f3e5f5
    style Knowledge fill:#e8f5e9
    style End fill:#c8e6c9
    style RAG fill:#fff9c4
    style Tantivy fill:#ffccbc
```

## Key Improvements from Previous Version

### 1. **Simplified Architecture**
- **Before**: Multiple tools (researcher, architect, codemap, etc.)
- **After**: Three core tools (setup, scratchpad, claude-rag)

### 2. **Persistent Knowledge Structure**
- **Before**: Memory bank with various subdirectories
- **After**: Organized .claude directory with clear categories

### 3. **Integrated Search**
- **Before**: No search capability
- **After**: Fast BM25 search with Tantivy

### 4. **Workflow Optimization**
- **Before**: Complex multi-agent coordination
- **After**: Simple scratchpad → file → search workflow

### 5. **Performance**
- **Before**: File-based lookups
- **After**: <50ms indexed searches

## Usage Flow

1. **Setup Once**: `./setup-claude-optimization.sh`
2. **Work Loop**:
   - Create scratchpad for task
   - Add notes while working
   - Complete and file to appropriate category
   - Rebuild index
   - Search when needed

## Benefits

- **Simplicity**: Fewer tools, clearer workflow
- **Speed**: Rust-based indexing and retrieval
- **Organization**: Systematic categorization
- **Persistence**: Knowledge grows over time
- **Searchability**: Everything is indexed and queryable