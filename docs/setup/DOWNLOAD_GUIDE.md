# Download Guide

## Core Tools (Required)

These are the essential multi-agent tools:

```bash
wget -q https://raw.githubusercontent.com/larock22/llm-agent-tools/main/{scratchpad-multi.sh,knowledge.sh,codemap.sh,context.sh,setup-multi-agent.sh,researcher.sh}
chmod +x *.sh
```

## Optional Components

### LLM Prompts
If you want the pre-configured agent prompts:
```bash
wget -q https://raw.githubusercontent.com/larock22/llm-agent-tools/main/agent_tools_prompt_multi.xml
```

### Legacy Single-Agent Tools
If you need backward compatibility:
```bash
wget -q https://raw.githubusercontent.com/larock22/llm-agent-tools/main/{scratchpad.sh,architect.sh}
chmod +x *.sh
```

### Documentation
For offline reference:
```bash
wget -q https://raw.githubusercontent.com/larock22/llm-agent-tools/main/{README.md,CODEMAP_QUICKSTART.md,MULTI_AGENT_SUMMARY.md}
```

## What Each Tool Does

- **scratchpad-multi.sh** - Multi-agent task tracking with handoffs
- **knowledge.sh** - Agent memory with private/shared knowledge
- **codemap.sh** - Lightweight code intelligence 
- **context.sh** - Context gathering for debugging
- **setup-multi-agent.sh** - Initialize directory structure
- **researcher.sh** - Online research (requires OpenRouter API key)

## Post-Installation

After downloading:
```bash
# Install jq (required for knowledge.sh and codemap.sh)
sudo apt-get install jq  # Debian/Ubuntu
brew install jq          # macOS

# Initialize the directory structure
./setup-multi-agent.sh

# You're ready to go!
./scratchpad-multi.sh --agent myagent start "First task"
```