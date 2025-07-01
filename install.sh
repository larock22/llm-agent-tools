#!/bin/bash

# LLM Agent Tools - One-liner installer
# Usage: curl -sSL https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/master/install.sh | bash

set -e

echo "Installing LLM Agent Tools..."
echo "Current directory: $(pwd)"

# Base URL for downloads
BASE_URL="https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/master"

# Download function with better error handling
download_file() {
    local filename=$1
    local url="${BASE_URL}/${filename}"
    
    echo "  - Downloading ${filename}..."
    
    if command -v wget &> /dev/null; then
        wget -O "${filename}" "${url}" 2>/dev/null || {
            echo "    Error: wget failed to download ${filename}"
            echo "    URL: ${url}"
            return 1
        }
    elif command -v curl &> /dev/null; then
        curl -sSL -o "${filename}" "${url}" || {
            echo "    Error: curl failed to download ${filename}"
            echo "    URL: ${url}"
            return 1
        }
    else
        echo "Error: Neither wget nor curl is installed. Please install one of them."
        exit 1
    fi
    
    chmod +x "${filename}"
    echo "    ✓ Downloaded successfully"
}

echo "Downloading tools..."

# Download bash scripts
for script in setup-claude-optimization.sh scratchpad.sh claude-rag.sh; do
    if ! download_file "$script"; then
        echo ""
        echo "Installation failed. Please check your internet connection and try again."
        echo "You can also manually download the scripts from:"
        echo "  ${BASE_URL}"
        exit 1
    fi
done

# Check if Rust is available for claude-rag
if command -v cargo &> /dev/null; then
    echo ""
    echo "Rust detected. Building claude-rag tool..."
    
    # Create temporary directory for building
    mkdir -p .claude-rag-tmp
    cd .claude-rag-tmp
    
    # Download Rust source files
    echo "  - Downloading source files..."
    
    if command -v wget &> /dev/null; then
        wget -O "Cargo.toml" "${BASE_URL}/claude-rag/Cargo.toml" 2>/dev/null || echo "    Warning: Failed to download Cargo.toml"
        mkdir -p src
        wget -O "src/main.rs" "${BASE_URL}/claude-rag/src/main.rs" 2>/dev/null || echo "    Warning: Failed to download main.rs"
    else
        curl -sSL -o "Cargo.toml" "${BASE_URL}/claude-rag/Cargo.toml" || echo "    Warning: Failed to download Cargo.toml"
        mkdir -p src
        curl -sSL -o "src/main.rs" "${BASE_URL}/claude-rag/src/main.rs" || echo "    Warning: Failed to download main.rs"
    fi
    
    # Build the tool
    if [ -f "Cargo.toml" ] && [ -f "src/main.rs" ]; then
        echo "  - Building claude-rag..."
        if cargo build --release 2>/dev/null; then
            mv target/release/claude-rag ../ 2>/dev/null || echo "    Warning: Failed to move claude-rag binary"
            echo "  ✓ claude-rag built successfully"
        else
            echo "  ⚠ Warning: Failed to build claude-rag. You can build it manually later."
        fi
    else
        echo "  ⚠ Warning: Could not download Rust source files for claude-rag"
    fi
    
    # Clean up
    cd ..
    rm -rf .claude-rag-tmp
else
    echo ""
    echo "Note: Rust/Cargo not found. Install Rust to enable claude-rag search features."
    echo "      Visit https://rustup.rs for installation instructions."
fi

# Initialize .claude directory
echo ""
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
    echo ""
fi
echo "For more information, see: https://github.com/alchemiststudiosDOTai/llm-agent-tools"