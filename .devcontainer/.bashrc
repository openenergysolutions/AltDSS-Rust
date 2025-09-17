# AltDSS-Rust Development Container Configuration
# This file is automatically loaded in the devcontainer

# Source the default bashrc if it exists
if [ -f /etc/bash.bashrc ]; then
    source /etc/bash.bashrc
fi

# Architecture detection and setup
export TARGET_ARCH=$(uname -m)
case "$TARGET_ARCH" in
    x86_64)
        export DSS_PLATFORM="linux_x64"
        export RUST_TARGET="x86_64-unknown-linux-gnu"
        ;;
    aarch64|arm64)
        export DSS_PLATFORM="linux_arm64"
        export RUST_TARGET="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo "Warning: Unsupported architecture $TARGET_ARCH"
        export DSS_PLATFORM="unknown"
        export RUST_TARGET="unknown"
        ;;
esac

# Set library path for runtime
if [ -d "/workspaces/AltDSS-Rust/dss_capi/lib/$DSS_PLATFORM" ]; then
    export LD_LIBRARY_PATH="/workspaces/AltDSS-Rust/dss_capi/lib/$DSS_PLATFORM:$LD_LIBRARY_PATH"
    echo "✅ Library path set for $DSS_PLATFORM"
else
    echo "⚠️  DSS library path not found for $DSS_PLATFORM"
fi

# Helpful aliases for development
alias build='cargo build'
alias test='cargo test'
alias run-ieee13='cargo test ieee13'
alias run-parallel='cargo test parallel'
alias clean='cargo clean'
alias check='cargo check'

# Architecture-specific aliases
alias build-x64='cargo build --target x86_64-unknown-linux-gnu'
alias build-arm64='cargo build --target aarch64-unknown-linux-gnu'
alias arch-info='echo "Architecture: $TARGET_ARCH, Platform: $DSS_PLATFORM, Rust Target: $RUST_TARGET"'

# Development environment info
echo "🦀 AltDSS-Rust Development Environment"
echo "📋 Architecture: $TARGET_ARCH"
echo "🏗️  Platform: $DSS_PLATFORM"
echo "🎯 Rust Target: $RUST_TARGET"
if [ -n "$LD_LIBRARY_PATH" ]; then
    echo "📚 Library Path: $LD_LIBRARY_PATH"
fi
echo ""
echo "🔧 Available commands:"
echo "  arch-info    - Show architecture information"
echo "  build        - Build the project"
echo "  test         - Run all tests"
echo "  run-ieee13   - Run IEEE13 test"
echo "  run-parallel - Run parallel test"
echo "  build-x64    - Cross-compile for x86_64"
echo "  build-arm64  - Cross-compile for ARM64"
echo ""

# Rust environment
export CARGO_TARGET_DIR="/tmp/target"
export RUST_BACKTRACE=1