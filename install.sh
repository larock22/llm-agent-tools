#!/bin/bash

# LLM Agent Tools - Simple installer
# Just downloads the bash scripts - users can build claude-rag separately if needed

echo "Installing LLM Agent Tools..."
echo ""

# Base URL
BASE_URL="https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/master"

# Download the three bash scripts
echo "Downloading scripts..."
for script in setup-claude-optimization.sh scratchpad.sh claude-rag.sh; do
    echo "  - ${script}"
    if curl -fsSL -o "${script}" "${BASE_URL}/${script}" 2>/dev/null; then
        chmod +x "${script}"
    elif wget -q -O "${script}" "${BASE_URL}/${script}" 2>/dev/null; then
        chmod +x "${script}"
    else
        echo "    ✗ Failed to download ${script}"
        echo "    Please manually download from:"
        echo "    ${BASE_URL}/${script}"
        exit 1
    fi
done

echo ""
echo "✅ Scripts downloaded successfully!"
echo ""

# Initialize .claude directory
if ./setup-claude-optimization.sh >/dev/null 2>&1; then
    echo "✅ Created .claude directory structure"
else
    echo "⚠️  Failed to create .claude directory"
fi

echo ""
echo "Installation complete! You now have:"
echo "  • setup-claude-optimization.sh - Creates .claude directory structure"
echo "  • scratchpad.sh - Temporary note-taking system"
echo "  • claude-rag.sh - Search interface (requires Rust to build)"
echo ""
echo "Quick start:"
echo "  ./scratchpad.sh new task 'my first task'"
echo ""
echo "To enable search features, install Rust and run:"
echo "  git clone https://github.com/alchemiststudiosDOTai/llm-agent-tools.git"
echo "  cd llm-agent-tools/claude-rag"
echo "  cargo build --release"
echo "  cp target/release/build_index target/release/retrieve ../"
echo ""