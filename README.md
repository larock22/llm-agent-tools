# LLM Agent Tools

A comprehensive toolkit of bash scripts designed to enhance LLM agent capabilities for software development workflows. These tools provide structured task tracking, architecture documentation, and online research capabilities that work seamlessly together.

## Overview

Modern LLM agents need better ways to:
- **Track complex multi-step tasks** with branching decision trees
- **Document and understand codebases** with persistent architectural knowledge
- **Research current information** using online-capable models

This toolkit provides three specialized bash scripts that address these needs:

1. **scratchpad.sh** - Dynamic task tracking with branching and revisions
2. **architect.sh** - Architecture documentation and codebase mapping
3. **researcher.sh** - Online research via OpenRouter API (web search + multimodal)

All tools are designed to work together, creating a comprehensive workflow enhancement system for LLM agents.

## Key Features

- **Zero dependencies** - Pure bash, works on any Linux/macOS system
- **LLM-optimized** - Designed specifically for AI agent workflows
- **Research-backed** - Prompt design based on [ATLAS research principles](https://arxiv.org/html/2312.16171v1)
- **Integrated workflow** - Tools work together seamlessly
- **Persistent memory** - Archive completed tasks and maintain project documentation

---

# Individual Tool Documentation

## Scratchpad.sh

A lightweight Bash script for structured note-taking and task tracking with an LLM-friendly workflow. Features dynamic numbering, revisions, and branching capabilities.

## Commands

- `start <task-title>` – Create new scratchpad with task header
- `step <text>|-` – Add next numbered step (auto-increments)
- `revise <N> <text>|-` – Add revision to step N (marked as [N~1], [N~2], etc.)
- `branch <N> <text>|-` – Create sub-step under step N (marked as [N.1], [N.2], etc.)
- `append <text>|-` – Raw text append without formatting
- `status` – Show current progress and step counts
- `finish [task-title]` – Archive completed scratchpad with timestamp

All text commands support stdin input with `-`.

## Usage Example

```bash
./scratchpad.sh start "Design authentication system"
./scratchpad.sh step "Define user requirements"
./scratchpad.sh step "Choose auth method"
./scratchpad.sh branch 2 "Research JWT approach"
./scratchpad.sh branch 2 "Research OAuth2 approach"
./scratchpad.sh revise 1 "Add rate limiting requirements"
./scratchpad.sh status
./scratchpad.sh finish
```

## Output Format

Creates a structured markdown file with:
- `[N]` – Main sequential steps
- `[N.x]` – Branched alternatives under step N
- `[N~x]` – Revisions to step N

Archived files are timestamped and stored in `memory_bank/done_task/`.

## Quick Start

```bash
# Set up in a new directory
printf 'Setup: creating llm-tooling/ and downloading tools...\n'
mkdir -p llm-tooling && cd llm-tooling
wget -q https://raw.githubusercontent.com/larock22/llm-agent-tools/main/{scratchpad.sh,architect.sh,researcher.sh,agent_tools_prompt.xml}
chmod +x *.sh

# For researcher.sh, set your OpenRouter API key
export OPENROUTER_API_KEY="sk-or-v1-your-key-here"
# Or use: ./researcher.sh set-key "sk-or-v1-your-key-here"

# Start using the tools!
./scratchpad.sh start "My first task"
./architect.sh init
./researcher.sh ask "What's new in AI today?"
```

## Installation

### Option 1: wget (Recommended)
```bash
# Download all files into llm-tooling directory
mkdir -p llm-tooling && cd llm-tooling
wget -q https://raw.githubusercontent.com/larock22/llm-agent-tools/main/{scratchpad.sh,architect.sh,researcher.sh,agent_tools_prompt.xml}
chmod +x *.sh
```

### Option 2: Clone Repository
```bash
git clone https://github.com/larock22/llm-agent-tools.git
cd llm-agent-tools
chmod +x *.sh
```

---

# Architect.sh

A documentation management tool for maintaining up-to-date architecture documentation and codebase maps. Helps LLM agents quickly understand project structure and locate relevant information.

## Core Features

### Repository Map (`repo_map.md`)
Maintains a comprehensive file listing with brief descriptions:
```
src/
├── index.js          # Main entry point, Express server setup
├── auth/
│   ├── jwt.js        # JWT token generation and validation
│   └── middleware.js # Auth middleware for protected routes
├── models/
│   ├── user.js       # User schema and methods
│   └── product.js    # Product model with inventory tracking
└── utils/
    └── logger.js     # Winston logger configuration
```

## Commands

- `architect init` – Initialize architecture docs in current project
- `architect map [--update]` – Generate/update repository map with file descriptions
- `architect describe <file> <description>` – Add/update description for a specific file
- `architect add-module <name> <description>` – Document a new architectural module/component
- `architect add-decision <title>` – Record architectural decision (ADR format)
- `architect add-flow <name>` – Document a process/data flow
- `architect link <file> <module>` – Link files to architectural modules
- `architect search <term>` – Search across all architecture docs
- `architect status` – Show documentation coverage and outdated entries
- `architect export` – Generate full architecture document

## Architecture Documents Structure

```
architecture/
├── repo_map.md           # File-by-file codebase overview
├── modules/              # High-level component descriptions
│   ├── auth.md          
│   ├── api.md           
│   └── database.md      
├── decisions/            # Architecture Decision Records (ADRs)
│   ├── 001-auth-jwt.md  
│   └── 002-postgres.md  
├── flows/                # Process and data flow diagrams
│   ├── user-login.md    
│   └── order-process.md 
└── dependencies.md       # External dependencies and rationale
```

## Usage Examples

```bash
# Initialize in a new project
./architect.sh init

# Generate initial repo map
./architect.sh map

# Add descriptions to key files
./architect.sh describe "src/auth/jwt.js" "Handles JWT creation, verification, and refresh tokens"
./architect.sh describe "src/models/user.js" "User model with bcrypt password hashing and role management"

# Document architectural modules
./architect.sh add-module "Authentication" "JWT-based auth system with refresh tokens and role-based access"
./architect.sh link "src/auth/*" "Authentication"

# Record architectural decisions
./architect.sh add-decision "Why JWT over sessions"

# Update repo map after changes
./architect.sh map --update

# Check documentation status
./architect.sh status
```

## Smart Features

- **Auto-detection**: Recognizes common patterns (routes, models, controllers) and suggests descriptions
- **Git integration**: Tracks when files change to flag outdated documentation
- **Import detection**: Analyzes imports to understand file relationships
- **Coverage reporting**: Shows which files lack documentation
- **Quick search**: Fast lookup across all architecture docs
- **LLM-optimized output**: Formats documentation for efficient context consumption

---

# Researcher.sh

An OpenRouter API client for online research and multimodal queries. Enables LLM agents to perform web searches, analyze images, and conduct research using models with internet access.

## Commands

- `researcher ask <prompt>` – Quick question with online search capability
- `researcher research <topic>` – Deep research on any topic with comprehensive results
- `researcher analyze-image <url> <prompt>` – Analyze images with natural language queries
- `researcher chat` – Interactive chat mode for extended conversations
- `researcher models` – List available models (online & vision-capable)
- `researcher set-key <api-key>` – Configure OpenRouter API key

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

## LLM Agent Integration

An XML system prompt is included (`agent_tools_prompt.xml`) that instructs LLM agents on optimal usage of all three tools. This prompt is designed following the 26 principles from the ATLAS research paper ["Principled Instructions Are All You Need for Questioning LLaMA-1/2, GPT-3.5/4"](https://arxiv.org/html/2312.16171v1).

Key principles applied:
- Direct communication without unnecessary politeness (Principle #1)
- Expert audience specification (Principle #2)
- Affirmative directives and role assignment (Principles #4, #16)
- Structured formatting with delimiters (Principles #8, #17)
- Few-shot examples (Principle #7)
- Step-by-step thinking (Principle #12)
- Task requirements and penalties (Principles #9, #10)
- Tip incentive for quality output (Principle #6)

### Integration Example

```xml
<system_prompt>
  <!-- Load the agent tools prompt -->
  <include file="agent_tools_prompt.xml"/>
</system_prompt>
```

The prompt ensures agents:
1. Track complex tasks with scratchpad.sh
2. Document architecture with architect.sh
3. Research current information with researcher.sh
4. Follow established workflow patterns
5. Maintain comprehensive documentation