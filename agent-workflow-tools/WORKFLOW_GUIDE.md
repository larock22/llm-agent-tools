# Agent Workflow Guide: Memory Management for AI Sessions

## Overview

This workflow enables AI agents to maintain persistent context across sessions despite complete memory loss between interactions. It provides a structured approach to task management, documentation, and knowledge preservation.

## Core Philosophy

### Two Memory Systems

1. **Memory Bank** - Long-term, summarized knowledge base
   - Persistent across sessions
   - Contains project context, goals, and current state
   - Updated with synthesized summaries only

2. **Scratchpad** - Short-term, detailed work logs
   - Temporary per-task documentation
   - Contains step-by-step actions and decisions
   - Archived after task completion

## Complete Workflow Steps

### 1. Project Setup (First Time Only)

```bash
# Initialize memory bank structure
./agent-tools/bankctl.sh init

# Edit the created templates with your project details:
# - memory-bank/project_brief.md       (What & Why)
# - memory-bank/tech_context.md        (Technical decisions)
# - memory-bank/product_context.md     (User experience goals)
# - memory-bank/current_state_summary.md (Current status)
# - memory-bank/progress_overview.md   (Task tracker)
```

### 2. Start New Session - Wake Up

```bash
./wakeup.sh
```

This reads all memory bank files to regain context:
- Shows current_state_summary.md first (most important)
- Displays project brief, technical context, and progress
- Provides immediate understanding of where to continue

### 3. Begin Task - Create Scratchpad

```bash
./scratchpad.sh start "Implement user authentication"
```

Creates a new scratchpad file for the specific task.

### 4. Plan Task - Document Approach

```bash
./scratchpad.sh plan "Steps: 1. Create User model 2. Add auth endpoints 3. Implement JWT tokens 4. Write tests"
```

Records your implementation plan in the scratchpad.

### 5. Execute Task - Log Progress

```bash
# Log each significant action
./scratchpad.sh step "Created User model with email and password_hash fields"
./scratchpad.sh step "Implemented POST /auth/register endpoint"
./scratchpad.sh step "Added JWT token generation using jose library"
./scratchpad.sh step "Wrote unit tests for registration flow - all passing"
```

Document every important decision, code change, or issue encountered.

### 6. Complete Task - Archive Scratchpad

```bash
./scratchpad.sh close "User authentication complete"
```

Archives the detailed scratchpad to memory-bank/done/ directory.
Note: Special characters in the message are automatically sanitized to underscores.

### 7. Update Memory Bank

Manually edit `memory-bank/current_state_summary.md` to reflect:
- What was accomplished in this session
- Current project state
- Immediate next steps
- Any critical decisions or blockers

Update `memory-bank/progress_overview.md` if major features were completed.

### 8. Verify Workflow (Optional)

```bash
# Simple check that workflow was followed
./agent-tools/check_workflow.sh
```

This quick verification shows:
- When memory bank was last updated
- Recent archived scratchpads
- Current state summary


## Quick Reference

### Essential Commands

| Action | Command |
|--------|---------|
| Read context | `./wakeup.sh` |
| Start task | `./scratchpad.sh start "Task name"` |
| Plan approach | `./scratchpad.sh plan "Plan details"` |
| Log progress | `./scratchpad.sh step "What you did"` |
| Complete task | `./scratchpad.sh close "Task complete"` |
| Check workflow | `./agent-tools/check_workflow.sh` |

### Memory Bank Files

| File | Purpose | Update Frequency |
|------|---------|------------------|
| current_state_summary.md | Latest status & next steps | After every session |
| progress_overview.md | Feature/task tracker | When features complete |
| project_brief.md | Project goals & requirements | Rarely |
| tech_context.md | Technical decisions | When architecture changes |
| product_context.md | User experience goals | When product pivots |

## Best Practices

1. **Always start with wakeup.sh** - Never begin work without reading context
2. **Use scratchpad for everything** - Even small tasks benefit from documentation
3. **Log detailed steps** - Future you will thank current you
4. **Keep summaries concise** - Memory bank should be scannable, not verbose
5. **Archive everything** - Detailed history lives in scratchpad archives
6. **Occasionally verify** - Run check_workflow.sh to ensure nothing was missed

## Example: Bug Fix Session

```bash
# 1. Wake up and read context
./wakeup.sh

# 2. Start debugging session
./scratchpad.sh start "Fix login redirect bug"

# 3. Plan investigation
./scratchpad.sh plan "1. Reproduce issue 2. Check auth middleware 3. Review redirect logic 4. Implement fix"

# 4. Log investigation steps
./scratchpad.sh step "Reproduced: login redirects to /undefined instead of /dashboard"
./scratchpad.sh step "Found issue in auth.js line 47 - redirect URL not properly set"
./scratchpad.sh step "Fixed by reading redirect from session storage before clearing"
./scratchpad.sh step "Tested fix - login now redirects correctly to /dashboard"

# 5. Archive work
./scratchpad.sh close "Fixed login redirect bug"

# 6. Update memory bank
# Edit current_state_summary.md:
# - Fixed login redirect bug where users were sent to /undefined
# - Next: Implement password reset functionality

# 7. Verify workflow (optional)
./agent-tools/check_workflow.sh
```

## Troubleshooting

- **Can't find memory-bank?** Run `./agent-tools/bankctl.sh init` first
- **Scratchpad commands fail?** Check you're in the project root directory
- **QA verification fails?** Ensure you updated current_state_summary.md
- **Archive not found?** Remember filenames are sanitized (spaces become underscores)

## Philosophy Summary

This workflow combats AI memory loss by:
- Maintaining persistent context in Memory Bank
- Capturing detailed work in temporary Scratchpads
- Enforcing structured documentation practices
- Providing clear entry/exit procedures for each session

The key is separation: strategic memory (Memory Bank) vs operational memory (Scratchpad).