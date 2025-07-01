#!/bin/bash

echo "Debug installer for LLM Agent Tools"
echo "==================================="
echo ""
echo "Testing download methods..."
echo ""

BASE_URL="https://raw.githubusercontent.com/alchemiststudiosDOTai/llm-agent-tools/master"
TEST_FILE="setup-claude-optimization.sh"
TEST_URL="${BASE_URL}/${TEST_FILE}"

echo "1. Testing with curl:"
if command -v curl &> /dev/null; then
    echo "   curl is available"
    echo "   Testing URL: ${TEST_URL}"
    curl -sSL -o test-curl.sh "${TEST_URL}"
    if [ $? -eq 0 ] && [ -f "test-curl.sh" ]; then
        echo "   ✓ curl download successful ($(wc -c < test-curl.sh) bytes)"
        rm -f test-curl.sh
    else
        echo "   ✗ curl download failed with exit code: $?"
        curl -v "${TEST_URL}" 2>&1 | head -20
    fi
else
    echo "   curl not found"
fi

echo ""
echo "2. Testing with wget:"
if command -v wget &> /dev/null; then
    echo "   wget is available"
    echo "   Testing URL: ${TEST_URL}"
    wget -O test-wget.sh "${TEST_URL}" 2>&1
    if [ $? -eq 0 ] && [ -f "test-wget.sh" ]; then
        echo "   ✓ wget download successful ($(wc -c < test-wget.sh) bytes)"
        rm -f test-wget.sh
    else
        echo "   ✗ wget download failed"
    fi
else
    echo "   wget not found"
fi

echo ""
echo "3. Testing DNS resolution:"
nslookup raw.githubusercontent.com 2>&1 | head -10

echo ""
echo "4. Testing direct connection:"
curl -I "${TEST_URL}" 2>&1 | head -15

echo ""
echo "5. Manual download commands you can try:"
echo "   wget ${TEST_URL}"
echo "   curl -O ${TEST_URL}"
echo ""
echo "If these fail, there might be a network/firewall issue."