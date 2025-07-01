#!/bin/bash

# LLM Agent Tools - One-liner installer
# Usage: curl -sSL https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/main/install.sh | bash

set -e

echo "Installing LLM Agent Tools..."

# Download bash scripts
wget -q https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/main/setup-claude-optimization.sh
wget -q https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/main/scratchpad.sh
wget -q https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/main/claude-rag.sh

# Make scripts executable
chmod +x setup-claude-optimization.sh scratchpad.sh claude-rag.sh

# Download pre-built claude-rag binary (if available)
# For now, we'll build it locally
if command -v cargo &> /dev/null; then
    echo "Building claude-rag tool..."
    # Download the Rust source
    mkdir -p .claude-rag-tmp
    cd .claude-rag-tmp
    wget -q https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/main/claude-rag/Cargo.toml
    wget -q https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/main/claude-rag/src/main.rs
    mkdir -p src
    mv main.rs src/
    cargo build --release
    mv target/release/claude-rag ../
    cd ..
    rm -rf .claude-rag-tmp
else
    echo "Warning: Rust/Cargo not found. Please install Rust to use claude-rag features."
fi

# Initialize .claude directory
./setup-claude-optimization.sh

echo "✓ LLM Agent Tools installed successfully!"
echo ""
echo "Quick start:"
echo "  ./scratchpad.sh new task 'my first task'"
echo "  ./claude-rag.sh build  # (if Rust is installed)"
echo ""