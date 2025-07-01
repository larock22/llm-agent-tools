#!/bin/bash

# LLM Agent Tools - One-liner installer
# Usage: curl -sSL https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/master/install.sh | bash

echo "Installing LLM Agent Tools..."
echo "Current directory: $(pwd)"

# Base URL for downloads
BASE_URL="https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/master"

# Track if we have any download tool
HAS_DOWNLOADER=false

# Download bash scripts
echo "Downloading tools..."

for script in setup-claude-optimization.sh scratchpad.sh claude-rag.sh; do
    echo "  - Downloading ${script}..."
    
    downloaded=false
    
    # Try curl first
    if command -v curl &> /dev/null; then
        HAS_DOWNLOADER=true
        if curl -fsSL -o "${script}" "${BASE_URL}/${script}" 2>/dev/null; then
            downloaded=true
        fi
    fi
    
    # If curl failed or not available, try wget
    if [ "$downloaded" = false ] && command -v wget &> /dev/null; then
        HAS_DOWNLOADER=true
        if wget -q -O "${script}" "${BASE_URL}/${script}" 2>/dev/null; then
            downloaded=true
        fi
    fi
    
    if [ "$downloaded" = true ]; then
        chmod +x "${script}"
        echo "    ✓ Downloaded successfully"
    else
        echo "    ✗ Failed to download ${script}"
        echo "    URL: ${BASE_URL}/${script}"
        
        if [ "$HAS_DOWNLOADER" = false ]; then
            echo ""
            echo "Error: Neither curl nor wget is installed."
            echo "Please install one of them and try again."
            exit 1
        else
            echo ""
            echo "Failed to download. Please try manually:"
            echo "  curl -O ${BASE_URL}/${script}"
            echo "  # or"
            echo "  wget ${BASE_URL}/${script}"
            exit 1
        fi
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
    
    # Try to download Cargo.toml
    if curl -fsSL -o "Cargo.toml" "${BASE_URL}/claude-rag/Cargo.toml" 2>/dev/null || \
       wget -q -O "Cargo.toml" "${BASE_URL}/claude-rag/Cargo.toml" 2>/dev/null; then
        echo "    ✓ Cargo.toml downloaded"
    else
        echo "    ⚠ Warning: Failed to download Cargo.toml"
    fi
    
    # Try to download main.rs
    mkdir -p src
    if curl -fsSL -o "src/main.rs" "${BASE_URL}/claude-rag/src/main.rs" 2>/dev/null || \
       wget -q -O "src/main.rs" "${BASE_URL}/claude-rag/src/main.rs" 2>/dev/null; then
        echo "    ✓ main.rs downloaded"
    else
        echo "    ⚠ Warning: Failed to download main.rs"
    fi
    
    # Build the tool if files exist
    if [ -f "Cargo.toml" ] && [ -f "src/main.rs" ]; then
        echo "  - Building claude-rag..."
        if cargo build --release 2>/dev/null; then
            if [ -f "target/release/claude-rag" ]; then
                mv target/release/claude-rag ../
                echo "  ✓ claude-rag built successfully"
            else
                echo "  ⚠ Warning: Build succeeded but binary not found"
            fi
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
if [ -f "./setup-claude-optimization.sh" ]; then
    if ./setup-claude-optimization.sh; then
        echo "✓ Directory structure created"
    else
        echo "⚠ Warning: Failed to initialize directory structure"
        echo "  You can run ./setup-claude-optimization.sh manually"
    fi
else
    echo "⚠ Error: setup-claude-optimization.sh not found"
    exit 1
fi

echo ""
echo "✅ LLM Agent Tools installed successfully!"
echo ""
echo "Files downloaded:"
[ -f "setup-claude-optimization.sh" ] && echo "  ✓ setup-claude-optimization.sh"
[ -f "scratchpad.sh" ] && echo "  ✓ scratchpad.sh"
[ -f "claude-rag.sh" ] && echo "  ✓ claude-rag.sh"
[ -f "claude-rag" ] && echo "  ✓ claude-rag (binary)"
echo ""
echo "Quick start:"
echo "  ./scratchpad.sh new task 'my first task'"
echo "  ./scratchpad.sh append task_my_first_task 'some notes'"
echo "  ./scratchpad.sh view task_my_first_task"
echo ""
if [ -f "./claude-rag" ]; then
    echo "  ./claude-rag.sh build    # Build search index"
    echo "  ./claude-rag.sh query 'search term'"
    echo ""
fi
echo "For more information, see: https://github.com/alchemiststudiosDOTai/llm-agent-tools"