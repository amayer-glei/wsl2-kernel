#!/bin/bash

# Script to fetch the default WSL2 kernel config from Microsoft's repository
# Usage: ./fetch-wsl2-config.sh [output-filename]

set -e

# Default URL for WSL2 kernel config
CONFIG_URL="https://raw.githubusercontent.com/microsoft/WSL2-Linux-Kernel/refs/heads/linux-msft-wsl-6.6.y/arch/x86/configs/config-wsl"

# Default output filename
DEFAULT_OUTPUT="config-wsl2.cfg"
OUTPUT_FILE="${1:-$DEFAULT_OUTPUT}"

# Ensure output file is in the config folder
if [[ "$OUTPUT_FILE" != config/* ]]; then
    OUTPUT_FILE="config/$OUTPUT_FILE"
fi

# Create config directory if it doesn't exist
mkdir -p config

# Check if curl or wget is available
if command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl"
elif command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget"
else
    echo "Error: Neither curl nor wget is available. Please install one of them."
    exit 1
fi

echo "Fetching WSL2 kernel config from Microsoft repository..."
echo "URL: $CONFIG_URL"
echo "Output: $OUTPUT_FILE"

# Download the config file
if [ "$DOWNLOAD_CMD" = "curl" ]; then
    if curl -f -L -o "$OUTPUT_FILE" "$CONFIG_URL"; then
        echo "Successfully downloaded config to $OUTPUT_FILE"
    else
        echo "Error: Failed to download config file"
        exit 1
    fi
elif [ "$DOWNLOAD_CMD" = "wget" ]; then
    if wget -O "$OUTPUT_FILE" "$CONFIG_URL"; then
        echo "Successfully downloaded config to $OUTPUT_FILE"
    else
        echo "Error: Failed to download config file"
        exit 1
    fi
fi

# Verify the file was downloaded and is not empty
if [ ! -s "$OUTPUT_FILE" ]; then
    echo "Error: Downloaded file is empty"
    exit 1
fi

# Count lines in the downloaded file
LINE_COUNT=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
echo "Downloaded config file has $LINE_COUNT lines"
