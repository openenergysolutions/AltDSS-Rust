#!/bin/bash

########################
# Detect target architecture
########################
function detect_architecture() {
    local arch=""
    local os=""
    
    # Check if CARGO_CFG_TARGET_ARCH and CARGO_CFG_TARGET_OS are set (for cross-compilation)
    if [[ -n "${CARGO_CFG_TARGET_ARCH}" && -n "${CARGO_CFG_TARGET_OS}" ]]; then
        arch="${CARGO_CFG_TARGET_ARCH}"
        os="${CARGO_CFG_TARGET_OS}"
    else
        # Fall back to system detection
        case "$(uname -m)" in
            x86_64)
                arch="x86_64"
                ;;
            aarch64|arm64)
                arch="aarch64"
                ;;
            *)
                echo "Error: Unsupported architecture $(uname -m)"
                exit 1
                ;;
        esac
        
        case "$(uname -s)" in
            Linux)
                os="linux"
                ;;
            Darwin)
                os="macos"
                ;;
            *)
                echo "Error: Unsupported OS $(uname -s)"
                exit 1
                ;;
        esac
    fi
    
    case "${os}_${arch}" in
        linux_x86_64)
            echo "linux_x64"
            ;;
        linux_aarch64)
            echo "linux_arm64"
            ;;
        macos_x86_64)
            echo "macos_x64"
            ;;
        macos_aarch64)
            echo "macos_arm64"
            ;;
        *)
            echo "Error: Unsupported platform: ${arch} on ${os}"
            exit 1
            ;;
    esac
}

########################
# Install necessary
# dependencies
########################
function install_dependencies() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # macOS dependencies using Homebrew
        if ! command -v brew &> /dev/null; then
            echo "Error: Homebrew is required on macOS. Please install it first."
            echo "Visit: https://brew.sh"
            exit 1
        fi
        
        echo "Installing macOS dependencies..."
        brew install \
            llvm \
            cmake \
            protobuf \
            suite-sparse \
            eigen \
            curl \
            git \
            jq
    else
        # Linux dependencies using apt
        apt-get update && apt-get install -y \
            lldb \
            build-essential \
            clang \
            libclang-dev \
            cmake \
            libprotobuf-dev \
            protobuf-compiler \
            libsuitesparse-dev \
            libeigen3-dev \
            curl \
            git \
            jq
    fi
}

########################
# Build and verify that
# unit-tests work.
########################
function build_and_test() {
    # Detect the target platform
    DSS_CAPI_PLATFORM=$(detect_architecture)
    echo "Building for platform: ${DSS_CAPI_PLATFORM}"
    
    # AltDSS-Rust version follows DSS CAPI version
    DSS_CAPI_VERSION=$(cargo metadata --format-version=1 --no-deps | jq '.packages[0].version' | tr -d '"')
    echo "DSS CAPI version: ${DSS_CAPI_VERSION}"

    # Get dss_capi and necessary files
    echo "Downloading dss_capi_${DSS_CAPI_VERSION}_${DSS_CAPI_PLATFORM}.tar.gz..."
    DOWNLOAD_URL="https://github.com/dss-extensions/dss_capi/releases/download/${DSS_CAPI_VERSION}/dss_capi_${DSS_CAPI_VERSION}_${DSS_CAPI_PLATFORM}.tar.gz"
    echo "Download URL: ${DOWNLOAD_URL}"
    
    # Test if the URL exists first
    if ! curl --head --silent --fail "${DOWNLOAD_URL}" > /dev/null; then
        echo "Error: URL does not exist or is not accessible: ${DOWNLOAD_URL}"
        echo "Available releases can be found at: https://github.com/dss-extensions/dss_capi/releases"
        echo "Please check if dss_capi version ${DSS_CAPI_VERSION} has binaries for platform ${DSS_CAPI_PLATFORM}"
        exit 1
    fi
    
    # Download and extract
    if ! wget -qO- "${DOWNLOAD_URL}" | tar zxv; then
        echo "Error: Failed to download or extract dss_capi for ${DSS_CAPI_PLATFORM}"
        echo "Download URL: ${DOWNLOAD_URL}"
        echo "Please check if the release exists at: https://github.com/dss-extensions/dss_capi/releases/tag/${DSS_CAPI_VERSION}"
        exit 1
    fi

    # If electricdss-tst doesn't exist, clone it.
    if [[ ! -d "$PWD/electricdss-tst" ]]; then    
        echo "Cloning electricdss-tst repository..."
        git clone --depth=1 https://github.com/dss-extensions/electricdss-tst
    fi  
    
    # Build and test.
    echo "Building project..."
    cargo build && \
    echo "Running tests..." && \
    cargo test
}

########################
# Main execution
########################
echo "AltDSS-Rust Multi-Architecture Build Script"
echo "============================================="

install_dependencies
build_and_test

echo "Build completed successfully!"