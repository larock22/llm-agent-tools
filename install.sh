#!/usr/bin/env bash

# LLM Agent Tools - Clean Installation Script
set -e

REPO_URL="https://raw.githubusercontent.com/larock22/llm-agent-tools/main"
TOOLS=("scratchpad-multi.sh" "knowledge.sh" "codemap.sh" "context.sh" "setup-multi-agent.sh" "researcher.sh" "agent_tools_prompt.xml")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  LLM Agent Tools Installer${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

clean_directory() {
    echo -e "${YELLOW}Current directory: $(pwd)${NC}"
    
    # Check if any target files exist
    local files_exist=false
    for tool in "${TOOLS[@]}"; do
        if [[ -f "$tool" ]]; then
            files_exist=true
            break
        fi
    done
    
    if [[ "$files_exist" == true ]]; then
        echo -e "${YELLOW}Found existing tool files:${NC}"
        for tool in "${TOOLS[@]}"; do
            [[ -f "$tool" ]] && echo "  - $tool"
        done
        echo
        
        read -p "Remove existing files before installation? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for tool in "${TOOLS[@]}"; do
                if [[ -f "$tool" ]]; then
                    rm -f "$tool"
                    print_success "Removed $tool"
                fi
            done
            echo
        fi
    fi
}

download_tools() {
    echo -e "${BLUE}Downloading tools...${NC}"
    
    # Create wget command with all files
    local wget_urls=""
    for tool in "${TOOLS[@]}"; do
        wget_urls="${wget_urls}${REPO_URL}/${tool},"
    done
    # Remove trailing comma
    wget_urls="${wget_urls%,}"
    
    # Download all files at once
    if wget -q "${REPO_URL}/{$(IFS=,; echo "${TOOLS[*]}")}"; then
        print_success "Downloaded all tools successfully"
    else
        print_error "Failed to download tools"
        exit 1
    fi
    
    # Make shell scripts executable
    for tool in "${TOOLS[@]}"; do
        if [[ "$tool" == *.sh ]]; then
            chmod +x "$tool"
            print_success "Made $tool executable"
        fi
    done
}

verify_installation() {
    echo
    echo -e "${BLUE}Verifying installation...${NC}"
    
    local all_good=true
    for tool in "${TOOLS[@]}"; do
        if [[ -f "$tool" ]]; then
            if [[ "$tool" == *.sh ]] && [[ -x "$tool" ]]; then
                print_success "$tool (executable)"
            elif [[ "$tool" == *.xml ]]; then
                print_success "$tool (prompt file)"
            else
                print_success "$tool"
            fi
        else
            print_error "$tool not found"
            all_good=false
        fi
    done
    
    echo
    if [[ "$all_good" == true ]]; then
        print_success "Installation completed successfully!"
        echo
        echo -e "${GREEN}Quick start:${NC}"
        echo "  ./scratchpad-multi.sh start \"My first task\""
        echo "  ./setup-multi-agent.sh"
        echo "  ./researcher.sh set-key \"your-openrouter-key\""
        echo
        echo -e "${BLUE}For OpenRouter API key:${NC} https://openrouter.ai/keys"
    else
        print_error "Installation incomplete - some files missing"
        exit 1
    fi
}

main() {
    print_header
    clean_directory
    download_tools
    verify_installation
}

# Run main function
main "$@"