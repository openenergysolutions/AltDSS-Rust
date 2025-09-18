#!/bin/bash

########################
# ARM64-specific build script
# This script forces ARM64 target architecture
########################

export CARGO_CFG_TARGET_ARCH="aarch64"

# Call the generic multi-architecture build script
exec "$(dirname "$0")/build_multiarch.sh"