# Agent Workflow Tools

Memory management and task tracking tools for AI agents working on software projects.

## Quick Install

Add these tools to any existing project:

```bash
wget -qO- https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/main/agent-workflow-tools/install.sh | bash
```

Or manually:

```bash
wget https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/main/agent-workflow-tools/setup.sh
chmod +x setup.sh
./setup.sh
rm setup.sh
```

## What This Adds

- **agent-tools/** - Workflow scripts
  - `wakeup.sh` - Read project context
  - `scratchpad.sh` - Task logging system
  - `check_workflow.sh` - Simple verification check
  - `bankctl.sh` - Memory bank management

- **memory-bank/** - Project knowledge base
  - `project_brief.md` - What and why
  - `tech_context.md` - Technical decisions
  - `product_context.md` - User experience goals
  - `current_state_summary.md` - Current status
  - `progress_overview.md` - Task tracker

## Basic Workflow

1. **Start session**: `./wakeup.sh`
2. **Begin task**: `./scratchpad.sh start "Task name"`
3. **Log work**: `./scratchpad.sh step "What I did"`
4. **Complete**: `./scratchpad.sh close "Task done"`
5. **Update memory**: Edit `memory-bank/current_state_summary.md`
6. **Verify** (optional): `./agent-tools/check_workflow.sh`

## For Existing Projects

If you already have a project in progress:
- The tools will detect existing memory-bank folders
- Just run `./wakeup.sh` to read your current state
- Continue working with the scratchpad system

## Full Documentation

After installation, see:
- `agent-tools/workflow-guide.md` - Complete workflow philosophy
- `agent-tools/workflow-tutorial.md` - Step-by-step tutorial
