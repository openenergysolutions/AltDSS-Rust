# Multi-architecture Dockerfile for AltDSS-Rust development
# Supports both x86_64 and ARM64 architectures

ARG RUST_VERSION=1.74.0
FROM rust:${RUST_VERSION}-bookworm

# Install architecture-agnostic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    libclang-dev \
    cmake \
    libprotobuf-dev \
    protobuf-compiler \
    libsuitesparse-dev \
    libeigen3-dev \
    curl \
    wget \
    git \
    jq \
    file \
    vim \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Install cross-compilation tools for both architectures
# This allows development and cross-compilation regardless of host architecture
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        apt-get update && apt-get install -y \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu \
        && rm -rf /var/lib/apt/lists/* \
        && rustup target add aarch64-unknown-linux-gnu; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        apt-get update && apt-get install -y \
        gcc-x86-64-linux-gnu \
        g++-x86-64-linux-gnu \
        && rm -rf /var/lib/apt/lists/* \
        && rustup target add x86_64-unknown-linux-gnu || true; \
    fi

# Set up Rust analyzer and useful tools
RUN rustup component add clippy rustfmt rust-src

# Create workspace directory
WORKDIR /workspaces/AltDSS-Rust

# Set up environment variables for multi-arch development
ENV CARGO_TARGET_DIR=/tmp/target
ENV RUST_BACKTRACE=1

# Architecture detection script
RUN echo '#!/bin/bash\n\
case "$(uname -m)" in\n\
    x86_64)\n\
        echo "x86_64 architecture detected"\n\
        export DSS_PLATFORM="linux_x64"\n\
        export RUST_TARGET="x86_64-unknown-linux-gnu"\n\
        ;;\n\
    aarch64)\n\
        echo "ARM64 architecture detected"\n\
        export DSS_PLATFORM="linux_arm64"\n\
        export RUST_TARGET="aarch64-unknown-linux-gnu"\n\
        ;;\n\
    *)\n\
        echo "Unknown architecture: $(uname -m)"\n\
        exit 1\n\
        ;;\n\
esac\n\
echo "Platform: $DSS_PLATFORM"\n\
echo "Rust Target: $RUST_TARGET"\n\
' > /usr/local/bin/detect-arch && chmod +x /usr/local/bin/detect-arch

# Default command
CMD ["/bin/bash"]