# Claude RAG System

A fast Retrieval-Augmented Generation (RAG) system for the `.claude` directory using Rust and Tantivy.

## Features

- **BM25 Indexing**: Fast full-text search using Tantivy
- **Category Filtering**: Search within specific `.claude` subdirectories
- **Chunked Retrieval**: Returns relevant text chunks with context
- **JSON Output**: Structured output for AI agent consumption

## Installation

1. Install Rust if not already installed:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. Build the index:
   ```bash
   ./claude-rag.sh build
   ```

## Usage

### Build/Rebuild Index
```bash
./claude-rag.sh build
```

### Query the Index
```bash
# Simple query
./claude-rag.sh query "error handling"

# Filter by category
./claude-rag.sh query "debug session" --category debug_history

# Limit results
./claude-rag.sh query "patterns" --limit 5
```

### View Statistics
```bash
./claude-rag.sh stats
```

## How It Works

1. **Indexing**: Walks through `.claude/**` and indexes all `.md`, `.txt`, and `.json` files
2. **Chunking**: Splits documents into ~1000 character chunks for granular retrieval
3. **Searching**: Uses BM25 ranking to find the most relevant chunks
4. **Output**: Returns JSON with context and suggested tools

## Categories

- `debug_history`: Debugging sessions and fixes
- `patterns`: Implementation patterns and best practices
- `qa`: Questions and answers
- `cheatsheets`: Quick references
- `metadata`: Component information
- `code_index`: Code relationships
- `anchors`: Important code locations
- `scratchpad`: Working notes
- `delta`: Change logs

## Performance

- Index building: ~1000 documents/second
- Query time: <50ms for typical queries
- Memory usage: ~50MB during indexing