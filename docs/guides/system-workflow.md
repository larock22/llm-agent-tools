# LLM Agent Tools - System Workflow

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

## Tool Interaction Flow

```mermaid
flowchart LR
    subgraph "User Interface"
        CLI[Command Line Interface]
    end
    
    subgraph "Core Tools"
        Setup[setup-multi-agent.sh]
        Research[researcher.sh]  
        Architect[architect.sh]
        Codemap[codemap.sh]
        Knowledge[knowledge.sh]
        Context[context.sh]
        Scratchpad[scratchpad-multi.sh]
    end
    
    subgraph "Memory Bank"
        Agents[agents/]
        Shared[shared/]
        Locks[locks/]  
        ContextDir[context/]
        CodemapDir[codemap/]
    end
    
    subgraph "Data Structures"  
        JSON[JSON Files]
        MD[Markdown Files]
        Locks2[Lock Files]
    end
    
    CLI --> Setup
    CLI --> Research
    CLI --> Architect  
    CLI --> Codemap
    CLI --> Knowledge
    CLI --> Context
    CLI --> Scratchpad
    
    Setup --> Agents
    Setup --> Shared
    Setup --> Locks
    Setup --> ContextDir
    Setup --> CodemapDir
    
    Research --> Knowledge
    Architect --> Context  
    Codemap --> CodemapDir
    Knowledge --> JSON
    Context --> MD
    Scratchpad --> Locks2
    
    Agents --> JSON
    Shared --> JSON
    Shared --> MD
    CodemapDir --> JSON
    CodemapDir --> MD
```

## Workflow Patterns

### Pattern 1: Solo Development

```bash
1. setup-multi-agent.sh     → Initialize workspace
2. researcher.sh            → Gather requirements  
3. architect.sh             → Plan implementation
4. codemap.sh map           → Generate project map
5. scratchpad-multi.sh      → Execute tasks
```

### Pattern 2: Multi-Agent Collaboration

```bash
1. setup-multi-agent.sh                    → Initialize shared workspace
2. Agent A: researcher.sh                  → Research phase
3. Agent A → Agent B: knowledge handoff    → Share findings
4. Agent B: architect.sh                   → Design phase  
5. Agent B → Agent C: context handoff      → Share design
6. Agent C: codemap.sh + implementation    → Build phase
```

### Pattern 3: Iterative Development

```bash
1. codemap.sh init          → Initialize tracking
2. scratchpad-multi.sh      → Implement feature
3. codemap.sh debug         → Log issues found
4. context.sh               → Update context
5. scratchpad-multi.sh      → Fix issues
6. Repeat 2-5 as needed
```

## Key Features

### Multi-Agent Coordination

- Isolated agent workspaces
- Shared knowledge base
- Lock-based coordination
- Task handoff system

### Intelligence Layer

- Code mapping and metadata
- Context window management  
- Knowledge persistence
- Debug history tracking

### Developer Experience

- Consistent CLI interface
- Clear help documentation
- Backward compatibility
- Modular tool design

### Organized Structure

- Centralized memory bank
- Categorized documentation
- Separated core/legacy tools
- Example workflows
