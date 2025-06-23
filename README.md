# LLM Agent Tools

A comprehensive toolkit of bash scripts designed to enhance LLM agent capabilities for software development workflows. Now with **multi-agent support** for collaborative work, knowledge sharing, and task coordination.

## Overview

Modern LLM agents need better ways to:

- **Track complex multi-step tasks** with branching decision trees and agent handoffs
- **Share knowledge and discoveries** between multiple specialized agents
- **Document and understand codebases** with lightweight, actionable intelligence
- **Research current information** using online-capable models

This toolkit provides specialized bash scripts that work together seamlessly:

1. **scratchpad-multi.sh** - Multi-agent task tracking with isolation and handoffs
2. **knowledge.sh** - Private/shared knowledge bases for agent memory
3. **codemap.sh** - Lightweight code intelligence (replaces architect.sh)
4. **context.sh** - Context gathering for debugging
5. **researcher.sh** - Online research via OpenRouter API

All tools store data within a clean `memory-bank/` directory structure.



## Key Features

- **Multi-agent support** - Multiple agents can work concurrently with isolated workspaces
- **Knowledge sharing** - Private and shared knowledge bases for collective intelligence
- **Task coordination** - Hand off work between specialized agents
- **Zero dependencies** - Pure bash (except jq for knowledge.sh/codemap.sh)
- **Self-contained** - All data stored within `memory-bank/` directory
- **LLM-optimized** - Designed specifically for AI agent workflows
- **High-impact approach** - Focus on what actually helps agents (80/20 rule)



## Quick Start

```bash
# 1. Download tools and prompt
mkdir -p llm-agent-tools && cd llm-agent-tools
wget -q https://raw.githubusercontent.com/larock22/llm-agent-tools/main/{scratchpad-multi.sh,knowledge.sh,codemap.sh,context.sh,setup-multi-agent.sh,researcher.sh,agent_tools_prompt.xml}
chmod +x *.sh

# 2. Install jq (if not already installed)
which jq || sudo apt-get install -y jq  # Debian/Ubuntu
which jq || brew install jq              # macOS

# 3. Initialize and start
./setup-multi-agent.sh
./scratchpad-multi.sh --agent myagent start "My first task"
```

For researcher.sh, set your OpenRouter API key:
```bash
export OPENROUTER_API_KEY="sk-or-v1-your-key-here"
# Or: ./researcher.sh set-key "sk-or-v1-your-key-here"
```

---

# Individual Tool Documentation

## 1. Scratchpad-multi.sh (Multi-Agent Task Tracking)

Enhanced version of scratchpad with agent isolation, task handoffs, and concurrent support.

### Commands

All commands support `--agent <name>` for agent-specific operation:

- `start <task-title>` – Create new scratchpad with task header
- `step <text>|-` – Add next numbered step (auto-increments)
- `revise <N> <text>|-` – Add revision to step N (marked as [N~1], [N~2], etc.)
- `branch <N> <text>|-` – Create sub-step under step N (marked as [N.1], [N.2], etc.)
- `append <text>|-` – Raw text append without formatting
- `status` – Show current progress and step counts
- `finish [task-title]` – Archive completed scratchpad with timestamp
- `handoff <to-agent> <message>` – Transfer task to another agent
- `agents` – List all active agents and their current tasks



### Usage Example

```bash
# Agent 1: Researcher
./scratchpad-multi.sh --agent researcher start "Research authentication options"
./scratchpad-multi.sh --agent researcher step "Found JWT vs OAuth2 comparison"
./scratchpad-multi.sh --agent researcher step "OAuth2 recommended for our use case"
./scratchpad-multi.sh --agent researcher handoff implementer "Research complete, please implement OAuth2"

# Agent 2: Implementer
./scratchpad-multi.sh --agent implementer status
./scratchpad-multi.sh --agent implementer step "Implementing OAuth2 flow"
./scratchpad-multi.sh --agent implementer finish
```



---

## 2. Knowledge.sh (Agent Memory System)

Lightweight knowledge base for storing discoveries, sharing between agents, and building collective intelligence.

### Commands

All commands support `--agent <name>` for agent-specific operation:

- `store <key> <value>` – Store a fact or discovery
- `get <key>` – Retrieve value for a specific key
- `search <pattern>` – Search keys matching pattern (regex)
- `list [--shared]` – List all knowledge (add --shared for shared pool)
- `tag <key> <tags...>` – Add tags to a knowledge entry
- `share <key>` – Copy private knowledge to shared pool
- `sync` – Pull relevant shared knowledge based on tags
- `export [file]` – Export knowledge to markdown

### Usage Example

```bash
# Researcher stores discoveries
./knowledge.sh --agent researcher store "api.endpoint" "https://api.example.com/v2"
./knowledge.sh --agent researcher store "api.auth" "Bearer token with 24h expiry"
./knowledge.sh --agent researcher tag "api.endpoint" api production
./knowledge.sh --agent researcher share "api.endpoint"

# Developer retrieves shared knowledge
./knowledge.sh --agent developer sync
./knowledge.sh --agent developer get "api.endpoint"
```




# Multi-Agent Workflow

## Directory Structure

All agent work is organized within `memory-bank/`:

```
memory-bank/
├── agents/<name>/          # Agent-specific workspaces
│   ├── scratchpad.md      # Current task
│   └── knowledge.json     # Private knowledge
├── shared/                # Shared resources
│   ├── done_tasks/       # Completed tasks
│   ├── handoffs/         # Task transfers
│   └── knowledge_base.json
├── codemap/              # Code intelligence
│   ├── metadata/         # File labels & deps
│   ├── cheatsheets/      # Component docs
│   └── debug_history/    # Bug→fix patterns
└── context/              # Active debugging
```

## Common Patterns

### Research → Implementation
```bash
# Researcher discovers information
./scratchpad-multi.sh --agent researcher start "Research API"
./knowledge.sh --agent researcher store "api.url" "https://..."
./knowledge.sh --agent researcher share "api.url"
./scratchpad-multi.sh --agent researcher handoff coder "Ready to implement"

# Coder uses research
./knowledge.sh --agent coder sync
./knowledge.sh --agent coder get "api.url"
```

### Parallel Development
Multiple agents working on different aspects:
- Frontend agent handles UI
- Backend agent handles API
- Tester agent writes tests
- All share discoveries via knowledge.sh



---



## 3. Codemap.sh (Lightweight Code Intelligence)

High-impact, low-overhead code intelligence focused on what actually helps agents: module metadata, component cheatsheets, and debug patterns.



### Core Features

1. **Module Metadata** (`metadata/modules.json`)
   - Auto-detects file types and dependencies
   - Labels files as impl/interface/test/config
   - Instant roadmap for agents

2. **Component Cheatsheets** (`cheatsheets/`)
   - Public APIs and common patterns
   - Gotchas and edge cases
   - Prevents hallucinations and API misuse

3. **Debug History** (`debug_history/`)
   - Bug→fix patterns for reuse
   - Prevents repeating old mistakes
   - Builds institutional memory



### Commands

- `init` – Initialize codemap structure
- `map` – Auto-scan project (detects types and dependencies)
- `label <file> <type> <desc>` – Label file type (impl/interface/test/config)
- `deps <file> <deps...>` – Record file dependencies
- `cheat <component>` – Create/edit component cheatsheet
- `debug <bug> <fix>` – Log a bug→fix pattern
- `search <term>` – Search across all codemap data
- `summary` – Show high-level project overview



### Usage Example

```bash
# Initialize and scan
./codemap.sh init
./codemap.sh map

# Document as you learn
./codemap.sh label "server.js" entry "Express server entry point"
./codemap.sh deps "server.js" "express" "auth" "database"

# Create cheatsheets for complex parts
./codemap.sh cheat auth    # Opens editor

# Log issues as you fix them
./codemap.sh debug "JWT tokens not expiring" "Added expiry check in auth.js:42"

# Search everything
./codemap.sh search "auth"
```



---

## 4. Context.sh (Debugging Helper)

Gather and store context when debugging issues. Captures command outputs, file contents, and notes in a structured format.

### Commands

- `start <issue-title>` – Create a new context file
- `add "<command>"` – Run command and append output
- `add-file <file_path>...` – Append file contents
- `add-text <text>|-` – Append raw text or stdin
- `finish [issue-title]` – Archive context file

### Usage Example

```bash
./context.sh start "Database connection timeout"
./context.sh add "ps aux | grep postgres"
./context.sh add-file "config/database.yml"
./context.sh add-text "Happens only under load"
./context.sh finish
```



---



## 5. Researcher.sh (Online Research)

An OpenRouter API client for online research and multimodal queries. Enables LLM agents to perform web searches, analyze images, and conduct research using models with internet access.



### Commands

- `ask <prompt>` – Quick question with online search capability
- `research <topic>` – Deep research on any topic with comprehensive results
- `analyze-image <url> <prompt>` – Analyze images with natural language queries
- `chat` – Interactive chat mode for extended conversations
- `models` – List available models (online & vision-capable)
- `set-key <api-key>` – Configure OpenRouter API key



## Key Features



- **Online Research**: Uses models with internet access (gpt-4o:online by default)

- **Multimodal Support**: Analyze images alongside text prompts

- **History Tracking**: Saves all queries and responses

- **Research Archives**: Exports research results to markdown files

- **Model Flexibility**: Switch between different models via environment variable



## Usage Examples



```bash

# Set up API key (get from https://openrouter.ai/keys)

./researcher.sh set-key sk-or-v1-xxxxx



# Quick online search

./researcher.sh ask "What happened in AI news today?"



# Deep research on a topic

./researcher.sh research "latest breakthroughs in protein folding"



# Analyze an image

./researcher.sh analyze-image "https://example.com/chart.png" "What trends does this chart show?"



# Interactive chat mode

./researcher.sh chat



# Use a different model

export RESEARCHER_MODEL="perplexity/sonar-medium-online"

./researcher.sh research "quantum computing startups 2024"

```



## Configuration



- API keys stored in `~/.config/researcher/config.json`

- Research saved to `~/.config/researcher/research_*.md`

- History tracked in `~/.config/researcher/history.json`



## Available Models



**Online Research:**

- `openai/gpt-4o:online` (default)

- `perplexity/sonar-medium-online`

- `perplexity/sonar-small-online`



**Vision/Multimodal:**

- `openai/gpt-4o`

- `anthropic/claude-3.5-sonnet`

- `google/gemini-pro-1.5`



---

# System Requirements

- **OS**: Linux or macOS
- **Bash**: Version 4.0 or higher
- **jq**: Required for knowledge.sh and codemap.sh
- **Optional**: OpenRouter API key for researcher.sh

# Getting Started

```bash
# 1. Download tools
mkdir -p llm-agent-tools && cd llm-agent-tools
wget -q https://raw.githubusercontent.com/larock22/llm-agent-tools/main/{scratchpad-multi.sh,knowledge.sh,codemap.sh,context.sh,setup-multi-agent.sh,researcher.sh}
chmod +x *.sh

# 2. Install jq (if needed)
sudo apt-get install jq  # Debian/Ubuntu
brew install jq          # macOS

# 3. Initialize structure
./setup-multi-agent.sh

# 4. Start using!
./scratchpad-multi.sh --agent myagent start "My task"
./codemap.sh init && ./codemap.sh map
```

# Best Practices

1. **Agent Naming**: Use descriptive names (researcher, coder, tester)
2. **Knowledge Sharing**: Share discoveries immediately after validation
3. **Task Handoffs**: Include clear context in handoff messages
4. **Code Documentation**: Use codemap.sh as you learn the codebase
5. **Debug Logging**: Record bug→fix patterns immediately

# Contributing

Contributions welcome! Please:
- Keep tools lightweight and bash-based
- Follow the 80/20 principle (high impact, low overhead)
- Test with multiple concurrent agents
- Update documentation with examples

# License

MIT License - See LICENSE file for details