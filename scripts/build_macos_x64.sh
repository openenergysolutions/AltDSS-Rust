#!/bin/bash

# Build script for macOS x64 (Intel)
# This script downloads the DSS C-API binaries and builds AltDSS-Rust

set -e

echo "🍎 Building AltDSS-Rust for macOS x64 (Intel)"
echo "=============================================="

# Check if we're on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only"
    exit 1
fi

# Set environment variables for macOS x64
export CARGO_CFG_TARGET_ARCH="x86_64"
export CARGO_CFG_TARGET_OS="macos"

# Run the multi-architecture build script
bash ./scripts/build_multiarch.sh

echo "✅ macOS x64 build completed successfully!"
echo ""
echo "🚀 You can now run:"
echo "  cargo test"
echo "  cargo run --example ieee13"
echo "  cargo run --example parallel"