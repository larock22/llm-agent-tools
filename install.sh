#!/bin/bash

# LLM Agent Tools - One-liner installer
# Usage: curl -sSL https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/master/install.sh | bash

set -e

echo "Installing LLM Agent Tools..."
echo "Current directory: $(pwd)"

# Check if wget or curl is available
if command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -q -O"
elif command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -sSL -o"
else
    echo "Error: Neither wget nor curl is installed. Please install one of them."
    exit 1
fi

echo "Downloading tools..."

# Download bash scripts with error handling
for script in setup-claude-optimization.sh scratchpad.sh claude-rag.sh; do
    echo "  - Downloading $script..."
    if $DOWNLOAD_CMD "$script" "https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/master/$script"; then
        chmod +x "$script"
    else
        echo "Error: Failed to download $script"
        exit 1
    fi
done

# Check if Rust is available for claude-rag
if command -v cargo &> /dev/null; then
    echo "Rust detected. Building claude-rag tool..."
    
    # Create temporary directory for building
    mkdir -p .claude-rag-tmp
    cd .claude-rag-tmp
    
    # Download Rust source files
    echo "  - Downloading source files..."
    $DOWNLOAD_CMD "Cargo.toml" "https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/master/claude-rag/Cargo.toml"
    mkdir -p src
    $DOWNLOAD_CMD "src/main.rs" "https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/master/claude-rag/src/main.rs"
    
    # Build the tool
    echo "  - Building claude-rag..."
    if cargo build --release --quiet 2>/dev/null; then
        mv target/release/claude-rag ../
        echo "  ✓ claude-rag built successfully"
    else
        echo "  ⚠ Warning: Failed to build claude-rag. You can build it manually later."
    fi
    
    # Clean up
    cd ..
    rm -rf .claude-rag-tmp
else
    echo "Note: Rust/Cargo not found. Install Rust to enable claude-rag search features."
    echo "      Visit https://rustup.rs for installation instructions."
fi

# Initialize .claude directory
echo "Initializing .claude directory structure..."
if ./setup-claude-optimization.sh; then
    echo "✓ Directory structure created"
else
    echo "Error: Failed to initialize directory structure"
    exit 1
fi

echo ""
echo "✅ LLM Agent Tools installed successfully!"
echo ""
echo "Quick start:"
echo "  ./scratchpad.sh new task 'my first task'"
echo "  ./scratchpad.sh append task_my_first_task 'some notes'"
echo "  ./scratchpad.sh view task_my_first_task"
echo ""
if command -v cargo &> /dev/null && [ -f "./claude-rag" ]; then
    echo "  ./claude-rag.sh build    # Build search index"
    echo "  ./claude-rag.sh query 'search term'"
fi
echo ""
echo "For more information, see: https://github.com/alchemiststudiosDOTai/llm-agent-tools"