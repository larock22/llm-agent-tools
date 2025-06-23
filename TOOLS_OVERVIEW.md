# Tools Overview

## Core Multi-Agent Tools (Download These)

These 6 scripts provide complete multi-agent functionality:

1. **scratchpad-multi.sh** - Multi-agent task tracking with handoffs
2. **knowledge.sh** - Private/shared knowledge bases (requires jq)
3. **codemap.sh** - Lightweight code intelligence (requires jq)
4. **context.sh** - Context gathering for debugging
5. **setup-multi-agent.sh** - Initialize directory structure
6. **researcher.sh** - Online research (requires OpenRouter API key)

## Legacy Tools (Not Needed for New Users)

These are kept for backward compatibility:

- **scratchpad.sh** - Original single-agent version (replaced by scratchpad-multi.sh)
- **architect.sh** - Complex architecture tool (replaced by codemap.sh)

## Supporting Files

- **agent_tools_prompt_multi.xml** - LLM prompt for multi-agent coordination
- **agent_tools_prompt.xml** - Original single-agent prompt

## Why This Design?

1. **Multi-agent by default** - All core tools support `--agent <name>`
2. **Clean directory** - Everything in `memory-bank/`
3. **High impact** - Focus on what actually helps (80/20 rule)
4. **Lightweight** - Pure bash + jq, no heavy dependencies
5. **Practical** - Based on real usage patterns

## Installation Command

```bash
# Just the essentials
wget -q https://raw.githubusercontent.com/larock22/llm-agent-tools/main/{scratchpad-multi.sh,knowledge.sh,codemap.sh,context.sh,setup-multi-agent.sh,researcher.sh}
```