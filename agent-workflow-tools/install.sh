#!/bin/bash
# Quick installer for agent workflow tools
# Usage: wget -qO- https://raw.githubusercontent.com/larock22/llm-agent-tools/main/agent-workflow-tools/install.sh | bash

wget https://raw.githubusercontent.com/larock22/llm-agent-tools/main/agent-workflow-tools/setup.sh -O setup.sh && chmod +x setup.sh && ./setup.sh && rm setup.sh