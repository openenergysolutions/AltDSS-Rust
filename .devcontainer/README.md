# AltDSS-Rust Development Container

This development container provides a complete, multi-architecture development environment for AltDSS-Rust that works on both x86_64 and ARM64 architectures.

## Features

### 🏗️ **Multi-Architecture Support**
- **Native development** on both x86_64 and ARM64 hosts
- **Cross-compilation tools** for building targeting other architectures
- **Automatic architecture detection** and environment setup
- **Platform-specific library paths** and configurations

### 🦀 **Rust Development Environment**
- **Rust 1.74.0** with clippy, rustfmt, and rust-src components
- **Rust Analyzer** with optimized settings for the project
- **Cross-compilation targets** pre-installed
- **Cargo workspace** optimized for development

### 🔧 **Development Tools**
- **Build tools**: gcc, clang, cmake
- **DSS dependencies**: libsuitesparse, libeigen3, protobuf
- **Utilities**: git, jq, file, vim, wget, curl
- **Shell**: bash with custom aliases and environment

## Usage

### **Opening the Development Container**

1. **Prerequisites**:
   - VS Code with Dev Containers extension
   - Docker Desktop or compatible container runtime

2. **Open in VS Code**:
   - Open the repository in VS Code
   - When prompted, click "Reopen in Container"
   - Or use Command Palette: "Dev Containers: Reopen in Container"

3. **First Build**:
   - The container will automatically run `./scripts/build_multiarch.sh`
   - This downloads appropriate DSS C-API binaries for your architecture
   - Builds the project and runs tests

### **Architecture Detection**

The container automatically detects your architecture and sets up the environment:

```bash
# Check current architecture setup
arch-info

# Output example on x86_64:
# Architecture: x86_64
# Platform: linux_x64
# Rust Target: x86_64-unknown-linux-gnu

# Output example on ARM64:
# Architecture: aarch64
# Platform: linux_arm64
# Rust Target: aarch64-unknown-linux-gnu
```

### **Available Commands**

The container provides helpful aliases for development:

```bash
# Basic development
build           # Build the project for current architecture
test            # Run all tests
check           # Check code without building
clean           # Clean build artifacts

# Testing specific components
run-ieee13      # Run IEEE13 test
run-parallel    # Run parallel test

# Cross-compilation (when tools are available)
build-x64       # Cross-compile for x86_64
build-arm64     # Cross-compile for ARM64

# Architecture information
arch-info       # Show detailed architecture information
```

### **Environment Variables**

The container sets up several useful environment variables:

- `TARGET_ARCH`: Current architecture (x86_64 or aarch64)
- `DSS_PLATFORM`: DSS library platform (linux_x64 or linux_arm64)
- `RUST_TARGET`: Rust compilation target
- `LD_LIBRARY_PATH`: Path to DSS C-API libraries
- `CARGO_TARGET_DIR`: Cargo build directory (/tmp/target)
- `RUST_BACKTRACE`: Enabled for better debugging

## Architecture-Specific Behavior

### **On x86_64 Hosts**
- **Native development** for x86_64
- **Cross-compilation support** for ARM64 (with gcc-aarch64-linux-gnu)
- **DSS libraries**: Downloads and uses linux_x64 binaries
- **Performance**: Full native performance

### **On ARM64 Hosts**
- **Native development** for ARM64
- **Cross-compilation support** for x86_64 (when available)
- **DSS libraries**: Downloads and uses linux_arm64 binaries
- **Performance**: Full native performance on ARM64 hardware

## Customization

### **Changing Rust Version**
Edit `.devcontainer/devcontainer.json`:
```json
"build": {
    "dockerfile": "Dockerfile",
    "args": {
        "RUST_VERSION": "1.75.0"  // Change version here
    }
}
```

### **Adding Development Tools**
Edit `.devcontainer/Dockerfile` to add more tools:
```dockerfile
RUN apt-get update && apt-get install -y \
    your-additional-tools \
    && rm -rf /var/lib/apt/lists/*
```

### **Custom Shell Configuration**
Edit `.devcontainer/.bashrc` to customize the shell environment.

## Troubleshooting

### **Container Fails to Build**
1. **Check Docker resources**: Ensure sufficient memory/disk space
2. **Clear Docker cache**: `docker system prune -a`
3. **Check architecture**: Verify your host supports the target architecture

### **DSS Libraries Not Found**
1. **Check architecture detection**: Run `arch-info`
2. **Verify download**: The postCreateCommand should download libraries
3. **Manual download**: Run `./scripts/build_multiarch.sh`

### **Cross-Compilation Issues**
1. **Check available targets**: `rustup target list --installed`
2. **Install missing targets**: `rustup target add <target>`
3. **Verify toolchain**: Check gcc cross-compilation tools are installed

### **VS Code Extensions Not Working**
1. **Reload window**: Command Palette → "Developer: Reload Window"
2. **Check extension compatibility**: Some extensions may not work in containers
3. **Manual installation**: Install extensions manually if auto-install fails

## Performance Tips

1. **Use target directory**: Build artifacts go to `/tmp/target` for better performance
2. **Docker Desktop**: Increase memory allocation for better build performance
3. **Host networking**: The container uses `--network=host` for optimal connectivity
4. **Volume mounts**: Source code is bind-mounted for instant file sync

## Contributing

When making changes to the development container:

1. **Test both architectures** if possible (x86_64 and ARM64)
2. **Update documentation** when adding new features
3. **Verify cross-compilation** still works after changes
4. **Test the postCreateCommand** completes successfully

## Files Structure

```
.devcontainer/
├── devcontainer.json    # Main configuration
├── Dockerfile          # Multi-arch container definition
├── .bashrc             # Custom shell configuration
└── README.md           # This file
```