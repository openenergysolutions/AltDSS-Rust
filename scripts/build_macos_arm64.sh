#!/bin/bash

# Build script for macOS ARM64 (Apple Silicon)
# This script downloads the DSS C-API binaries and builds AltDSS-Rust

set -e

echo "🍎 Building AltDSS-Rust for macOS ARM64 (Apple Silicon)"
echo "======================================================"

# Check if we're on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only"
    exit 1
fi

# Check if we're on ARM64
if [[ "$(uname -m)" != "arm64" ]]; then
    echo "Warning: This script is optimized for ARM64, but detected $(uname -m)"
fi

# Set environment variables for macOS ARM64
export CARGO_CFG_TARGET_ARCH="aarch64"
export CARGO_CFG_TARGET_OS="macos"

# Run the multi-architecture build script
bash ./scripts/build_multiarch.sh

echo "✅ macOS ARM64 build completed successfully!"
echo ""
echo "🚀 You can now run:"
echo "  cargo test"
echo "  cargo run --example ieee13"
echo "  cargo run --example parallel"