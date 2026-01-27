#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     PAYLOAD PIPELINE - DOCKER COMPOSE                     ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Create directory structure
log "Setting up workspace..."
mkdir -p shellcode output hashes logs
echo ""

# Check for shellcode files
log "Checking for shellcode files..."
REQUIRED_FILES=("https_x64.bin" "https_x86.bin" "https.64.exe")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "shellcode/$file" ]; then
        MISSING_FILES+=("$file")
    else
        info "✓ Found: $file"
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo ""
    error "Missing required shellcode files:"
    for file in "${MISSING_FILES[@]}"; do
        echo "  - shellcode/$file"
    done
    echo ""
    info "Please place the following files in the shellcode/ directory:"
    echo "  - https_x64.bin"
    echo "  - https_x86.bin"
    echo "  - https.64.exe"
    exit 1
fi

echo ""
log "All required shellcode files present!"
echo ""

# Pull all images
log "Pulling Docker images from GHCR..."
echo ""
docker-compose pull

echo ""
log "Starting payload generation pipeline..."
echo ""

# Run the pipeline
docker-compose up --abort-on-container-exit

echo ""
log "Pipeline complete!"
echo ""

# Generate summary
PAYLOAD_COUNT=$(find output -type f \( -name "*.exe" -o -name "*.cpl" -o -name "*.iso" -o -name "*.zip" \) 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh output 2>/dev/null | cut -f1)

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     PIPELINE SUMMARY                                      ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

info "Generated Payloads: $PAYLOAD_COUNT"
info "Total Size: $TOTAL_SIZE"
info "Output Directory: $(pwd)/output"
echo ""

# List generated files
if [ $PAYLOAD_COUNT -gt 0 ]; then
    echo "Generated Files:"
    echo "────────────────────────────────────────────────────────────"
    ls -lh output/ 2>/dev/null | tail -n +2 | awk '{printf "  %-8s  %s\n", $5, $9}'
    echo ""
fi

# Display hash CSV if generated
HASH_CSV=$(ls -1 hashes/payload-hashes-*.csv 2>/dev/null | tail -1)
if [ -f "$HASH_CSV" ]; then
    echo "Hash Report:"
    echo "────────────────────────────────────────────────────────────"
    info "CSV Report: $HASH_CSV"
    echo ""
    head -n 5 "$HASH_CSV" | column -t -s','
    echo "  ..."
    echo ""
fi

# Cleanup
log "Cleaning up containers..."
docker-compose down

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     PIPELINE COMPLETE ✓                                   ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

echo "Next Steps:"
echo "  1. Review payloads in: $(pwd)/output/"
echo "  2. Review hash report in: $HASH_CSV"
echo "  3. Transfer to target environment for testing"
echo ""
