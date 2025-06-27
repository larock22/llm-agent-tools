# llm-agent-tools

## System Architecture Flowchart

```mermaid
flowchart TD
    Start([User Starts]) --> Choice{What do you need?}
    
    Choice -->|Setup| Setup["`**SETUP PHASE**
    ./tools/core/setup-multi-agent.sh
    Creates memory-bank structure`"]
    
    Choice -->|Research| Research["`**RESEARCH PHASE**  
    ./tools/core/researcher.sh
    Gather information`"]
    
    Choice -->|Plan| Plan["`**PLANNING PHASE**
    ./tools/core/architect.sh
    Design workflow`"]
    
    Choice -->|Code| Code["`**CODING PHASE**
    ./tools/core/codemap.sh
    Map project structure`"]
    
    Choice -->|Collaborate| Collab["`**COLLABORATION**
    ./tools/core/scratchpad-multi.sh
    Multi-agent workspace`"]
    
    Setup --> MemBank[("`**MEMORY BANK**
    Central storage
    - agents/
    - shared/
    - locks/
    - context/`")]
    
    Research --> Knowledge["`**KNOWLEDGE TOOL**
    ./tools/core/knowledge.sh
    Store/retrieve info`"]
    
    Plan --> Context["`**CONTEXT TOOL**
    ./tools/core/context.sh
    Manage context windows`"]
    
    Code --> Codemap["`**CODEMAP FEATURES**
    - map: Generate metadata
    - label: Tag files
    - deps: Track dependencies
    - debug: Log bug fixes`"]
    
    Collab --> MultiAgent["`**MULTI-AGENT FEATURES**
    - Agent isolation
    - Shared knowledge
    - Task handoffs
    - Lock management`"]
    
    Knowledge --> MemBank
    Context --> MemBank
    Codemap --> MemBank
    MultiAgent --> MemBank
    
    MemBank --> Output{"`**OUTPUT**
    What's generated?`"}
    
    Output -->|Research| ResOut["`**Research Results**
    - Gathered information
    - Source references
    - Knowledge base entries`"]
    
    Output -->|Planning| PlanOut["`**Architecture Plans**
    - Workflow designs
    - Component specs  
    - Implementation steps`"]
    
    Output -->|Code Maps| CodeOut["`**Code Intelligence**
    - Module metadata
    - Dependency graphs
    - Debug history
    - Component cheatsheets`"]
    
    Output -->|Collaboration| CollabOut["`**Multi-Agent Output**
    - Task completion logs
    - Agent handoffs
    - Shared knowledge
    - Context preservation`"]
    
    ResOut --> End([Results Available])
    PlanOut --> End
    CodeOut --> End  
    CollabOut --> End
    
    style Start fill:#e1f5fe
    style Choice fill:#fff3e0
    style MemBank fill:#f3e5f5
    style Output fill:#fff3e0
    style End fill:#e8f5e8
```

## Value Proposition

A suite of command-line tools to streamline and enhance LLM agent workflows. This project provides modular, easy-to-use utilities designed to improve productivity and simplify complex tasks related to large language model agents.

## Quick Start

Get started in 30 seconds:

1. **One-Line Install**:

   ```bash
   curl -s https://raw.githubusercontent.com/larock22/llm-agent-tools/main/install.sh | bash
   ```

   Or manual install:
   ```bash
   wget https://raw.githubusercontent.com/larock22/llm-agent-tools/main/install.sh
   chmod +x install.sh
   ./install.sh
   ```

2. **Initialize Workspace**:

   ```bash
   ./setup-multi-agent.sh
   ```

3. **Choose Your Workflow**:

   ```bash
   # Research a topic
   ./researcher.sh "machine learning best practices"

   # Plan a project 
   ./architect.sh

   # Map existing code
   ./codemap.sh map

   # Start collaborative work
   ./scratchpad-multi.sh --agent myagent start "Build API"
   ```

## Tool Overview

### Core Tools (`tools/core/`)

| Tool | Purpose | Use When |
|------|---------|----------|
| **setup-multi-agent.sh** | Initialize workspace | Starting new project |
| **researcher.sh** | Gather information | Need to research topic |
| **architect.sh** | Plan workflows | Designing system architecture |
| **codemap.sh** | Map code structure | Working with existing codebase |
| **knowledge.sh** | Store/retrieve facts | Managing persistent knowledge |
| **context.sh** | Manage context windows | Handling large contexts |
| **scratchpad-multi.sh** | Multi-agent collaboration | Team development |

### Directory Structure

```text
llm-agent-tools/
├── tools/core/          # Main executable scripts
├── docs/               # All documentation
│   ├── setup/         # Installation guides
│   ├── tools/         # Individual tool docs
│   ├── guides/        # Workflow examples
│   └── changelog/     # Change history
├── memory-bank/       # Persistent agent memory
├── architecture/      # Project architecture docs
└── examples/         # Usage examples
```

## Common Workflows

### Solo Development

```bash
./setup-multi-agent.sh       # Initialize
./researcher.sh "topic"      # Research
./architect.sh               # Plan
./codemap.sh map            # Map code
./scratchpad-multi.sh       # Execute
```

### Multi-Agent Team

```bash
# Agent A: Research
./researcher.sh "requirements" --agent researcher

# Agent B: Architecture  
./architect.sh --agent architect

# Agent C: Implementation
./scratchpad-multi.sh --agent developer start "Build feature"
```

## Documentation

- **[Setup Guide](docs/setup/)** - Installation and configuration
- **[Tool Reference](docs/tools/)** - Detailed tool documentation  
- **[Workflow Guide](docs/guides/)** - Usage patterns and examples
- **[System Architecture](docs/guides/system-workflow.md)** - Complete flowchart and patterns
- **[Changelog](docs/changelog/)** - Version history and updates
