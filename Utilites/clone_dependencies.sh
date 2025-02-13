#!/bin/bash

set -e  # Exit on error

# ANSI escape codes for colors
GREEN='\033[92m'
BLUE='\033[94m'
RED='\033[91m'
RESET='\033[0m'

# Arguments
LOCK_FILE=""
VENDOR_DIR=""

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --lock-file) LOCK_FILE="$2"; shift 2;;
        --vendor-dir) VENDOR_DIR="$2"; shift 2;;
        --help)
            echo "Usage: $0 --lock-file <file> --vendor-dir <dir>"
            echo "  --lock-file  : Path to the Package.resolved file"
            echo "  --vendor-dir : Path to the vendor directory"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${RESET}"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$LOCK_FILE" || -z "$VENDOR_DIR" ]]; then
    echo -e "${RED}Error: Both --lock-file and --vendor-dir arguments are required.${RESET}"
    exit 0
fi

mkdir -p "$VENDOR_DIR"

# Extract dependencies from Package.resolved file
jq -c '.pins[]' "$LOCK_FILE" | while read -r pin; do
    IDENTITY=$(echo "$pin" | jq -r '.identity')
    REPO_URL=$(echo "$pin" | jq -r '.location')
    REVISION=$(echo "$pin" | jq -r '.state.revision')
    DEST_DIR="$VENDOR_DIR/$IDENTITY"

    echo -e "${BLUE}Cloning $IDENTITY...${RESET}"
    
    if [ -d "$DEST_DIR" ]; then
        echo "$IDENTITY already exists. Pulling latest changes..."
        git -C "$DEST_DIR" fetch origin
    else
        git clone --no-checkout "$REPO_URL" "$DEST_DIR"
    fi

    # Checkout the specific revision
    git -c advice.detachedHead=false -C "$DEST_DIR" checkout "$REVISION"
    echo -e "${GREEN}$IDENTITY checked out to $REVISION${RESET}\n"
done

echo -e "${GREEN}All dependencies cloned and checked out successfully!${RESET}"
