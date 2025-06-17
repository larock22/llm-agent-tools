#!/bin/bash

# Agent Workflow Tools Setup
# This script adds agent workflow tools to your existing project

set -e

echo "=== Agent Workflow Tools Setup ==="
echo "Adding agent workflow tools to your project..."
echo

# Create agent-tools directory in current project
mkdir -p agent-tools

# Base URL for downloading files
BASE_URL="https://raw.githubusercontent.com/larock22/llm-agent-tools/main/agent-workflow-tools"

# Download workflow scripts
echo "📥 Downloading workflow scripts..."
if ! wget -q "$BASE_URL/wakeup.sh" -O agent-tools/wakeup.sh; then
    echo "❌ Failed to download wakeup.sh"
    exit 1
fi
if ! wget -q "$BASE_URL/scratchpad.sh" -O agent-tools/scratchpad.sh; then
    echo "❌ Failed to download scratchpad.sh"
    exit 1
fi
if ! wget -q "$BASE_URL/check_workflow.sh" -O agent-tools/check_workflow.sh; then
    echo "❌ Failed to download check_workflow.sh"
    exit 1
fi
if ! wget -q "$BASE_URL/bankctl.sh" -O agent-tools/bankctl.sh; then
    echo "❌ Failed to download bankctl.sh"
    exit 1
fi

# Make scripts executable
chmod +x agent-tools/*.sh

# Download documentation
echo "📥 Downloading documentation..."
if ! wget -q "$BASE_URL/WORKFLOW_GUIDE.md" -O agent-tools/WORKFLOW_GUIDE.md; then
    echo "❌ Failed to download WORKFLOW_GUIDE.md"
    exit 1
fi

# Download the agent tools prompt (optional)
wget -q "$BASE_URL/agent_tools_prompt.xml" -O agent-tools/agent_tools_prompt.xml 2>/dev/null || true

# Check if this is an existing project with memory-bank
if [ -d "memory-bank" ]; then
    echo "✅ Existing memory-bank found. Tools configured for your project."
else
    echo "🔧 No memory-bank found. Initializing..."
    # Create memory-bank structure
    mkdir -p memory-bank
    mkdir -p memory-bank/done
    mkdir -p memory-bank/qa_reports
    
    # Create starter templates
    cat > memory-bank/project_brief.md << 'EOF'
# Project Brief

## What is this project?
[Describe your project's purpose]

## Why does it exist?
[Explain the problem it solves]

## Core requirements
- [ ] Requirement 1
- [ ] Requirement 2
EOF

    cat > memory-bank/tech_context.md << 'EOF'
# Technical Context

## Technologies Used
- Language: [e.g., Python 3.9+]
- Framework: [e.g., FastAPI]
- Database: [e.g., PostgreSQL]

## Architecture Decisions
[Document key technical decisions]

## Development Setup
[How to set up the development environment]
EOF

    cat > memory-bank/product_context.md << 'EOF'
# Product Context

## User Experience Goals
[What should users be able to do?]

## Target Audience
[Who will use this?]

## Success Metrics
[How do we measure success?]
EOF

    cat > memory-bank/current_state_summary.md << 'EOF'
# Current State Summary

## Last Session Outcome
[What was accomplished in the last work session?]

## Immediate Next Steps
1. [Next priority task]
2. [Following task]

## Key Blockers or Decisions
[Any critical issues to address]
EOF

    cat > memory-bank/progress_overview.md << 'EOF'
# Progress Overview

## To Do
- [ ] Feature/Task 1
- [ ] Feature/Task 2

## In Progress
- [ ] Current work item

## Done
- [x] Completed item
EOF

    echo "📝 Created starter memory-bank templates. Please edit them for your project."
fi

# Create convenient symlinks in project root
ln -sf agent-tools/wakeup.sh wakeup.sh 2>/dev/null || true
ln -sf agent-tools/scratchpad.sh scratchpad.sh 2>/dev/null || true

# Add to .gitignore
if [ -f .gitignore ]; then
    # Check if agent workflow section already exists
    if ! grep -q "# Agent workflow" .gitignore; then
        echo "" >> .gitignore
        echo "# Agent workflow temporary files" >> .gitignore
        echo ".current_scratchpad_file" >> .gitignore
        echo ".current_qa_log_path" >> .gitignore
        echo ".qa_temp/" >> .gitignore
        echo "scratchpad_*.md" >> .gitignore
        echo "*.tmp" >> .gitignore
    fi
else
    # Create .gitignore with agent workflow entries
    cat > .gitignore << 'EOF'
# Agent workflow temporary files
.current_scratchpad_file
.current_qa_log_path
.qa_temp/
scratchpad_*.md
*.tmp

# Common development files
*.log
.DS_Store
.env
.venv/
venv/
__pycache__/
*.pyc
node_modules/
EOF
    echo "📝 Created .gitignore with agent workflow entries"
fi

echo
echo "✅ Setup complete!"
echo
echo "📁 Project structure:"
echo "  agent-tools/"
echo "  ├── wakeup.sh          # Read memory bank"
echo "  ├── scratchpad.sh      # Task logging" 
echo "  ├── check_workflow.sh  # Simple verification"
echo "  ├── bankctl.sh         # Memory bank control"
echo "  └── WORKFLOW_GUIDE.md  # Complete workflow documentation"
echo
echo "  memory-bank/"
echo "  ├── project_brief.md"
echo "  ├── tech_context.md"
echo "  ├── product_context.md"
echo "  ├── current_state_summary.md"
echo "  └── progress_overview.md"
echo
echo "🚀 Quick start:"
echo "  1. Edit memory-bank/*.md files with your project details"
echo "  2. ./wakeup.sh                    # Read current context"
echo "  3. ./scratchpad.sh start 'Task'   # Begin new task"
echo "  4. ./scratchpad.sh step 'Action'  # Log progress"
echo "  5. ./scratchpad.sh close 'Done'   # Complete task"
echo
echo "📖 Full guide: cat agent-tools/WORKFLOW_GUIDE.md"