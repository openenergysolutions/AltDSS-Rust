# AltDSS-Rust
A crate with Rust bindings (currently based on bindgen) to AltDSS/DSS C-API, the alternative OpenDSS implementation from DSS-Extensions.

Initial tracking is done at https://github.com/dss-extensions/dss-extensions/issues/34  
The issue tracker here will be used after the initial issue is closed.

The current milestones are:

1. **(DONE)** Provide access to the classic API, organized to mimic the original OpenDSS COM classes (note that COM objects are **not** used on DSS-Extensions; COM is a Windows-only technology).
    - Expose all of the classic DSS C-API functions.

2. Try the upcoming wrapper for the official OpenDSSDirect.DLL. The DLL was rewritten recently (but it's still Windows-only right now).

3. Provide access to the new API, which exposes all DSS classes and functions more conveniently.

This project is then expected to allow using both the official OpenDSS, within its limitations, and the DSS-Extensions implementation (aka AltDSS/DSS C-API).

----

# Current status

- Testing done on x64 and ARM64 Linux and macOS, based on DSS C-API v**0.14.3**.
- **NEW**: Multi-platform support! Linux (x64/ARM64) and macOS (Intel/Apple Silicon) are fully supported.
- **NEW**: Automatic dependency management! DSS C-API binaries are automatically downloaded during build - no manual setup required.
- Exposes nearly all of the classic OpenDSS API and most of the classic API extensions in AltDSS/DSS C-API.
- Organized in two main high-level structs: a `common::DSSContext` and `classic::IDSS`. `IDSS` mimics the COM organization, per [DSS-Python](https://dss-extensions.org/dss_python/dss/#module-dss.IDSS) (plus [DSS Sharp](https://dss-extensions.org/dss_sharp/html/6ec40528-724b-089f-8ac5-ce043f8f981f.htm) and DSS MATLAB) and the official implementation per https://opendss.epri.com/COMInterface.html
- Future interfaces, exposed in other modules, will reuse the `DSSContext` struct.
- Nearly all methods return a `Result<sometype, DSSError>` since DSS errors could be produced by nearly all DSS C-API functions. Future Rust versions could make this more comfortable.
- Multi-threading confirmed to work fine on all supported platforms.

Pending tasks and decisions:

- Tests and docs; for the general API functions, the best is to document the DSS C-API header and automate porting those to all other projects (this is partially done right now; could be more integrated).
- ~~Adjust licensing (move to Apache 2)~~
- ~~Merge relevant code from the OpenEnergySolutions repositories~~
- Mirror in Rust the default behavior from https://github.com/dss-extensions/AltDSS-Go/issues/2
- ~~Wait for DSS C-API 0.14.0 to be released~~
- ~~Identifiers: decide if/what/how to adapt the naming style, original vs. Rust's snake case (for most things).~~
    - The closer the names are to the other bindings (the other DSS-Extensions, and the official OpenDSS COM), the easier it would be to port code and ease the transition from other programming languages.
    - OpenDSS uses units as names in lot of places. Capitalization is important for those. Although `kWh` is acceptable as `kwh`, many other quantities would be ambiguous in lowercase: `kV` vs `Kv` (kilovolts vs some K constant), `MV` vs `mV` (megavolts vs millivolts). In other words, although there are some bad function names in OpenDSS and DSS C-API, the correct capitalization of units does provide context that could be enough to avoid reading for the documentation in many situations.
        - The warning from the compiler are not useful in most cases, so we would need to check each function name and document the changes. From one of the examples, there is a variable named `losses_kWh` and the compiler suggestion is `losses_k_wh`.
        - This will only get worse (more manual work) when we expose all 50+ DSS object types. For a motivating example, see https://github.com/dss-extensions/dss_python/blob/0.15.0b1/tests/test_obj.py#L500 -- in Python, which already exposes all objects, the names are intentionally kept as close as possible to the DSS property names (and follows the renaming we're doing for the upcoming DSS C-API release), in fact it allows easily transforming a .DSS script to a Python script without too much hassle. If we were to adapt the names for each programming language, it would be challenging to both maintain and use.
    - Rust is a typed language and IDE integration is already quite good; that's a good argument against worrying about the naming convention.
    - Would there be any overhead if we decide to duplicate everything (as wrappers) to rename the methods for those who really value this kind of convention?


# Getting started

## Using as a Dependency

To use AltDSS-Rust in your own project, simply add it to your `Cargo.toml`:

```toml
[dependencies]
altdss = { git = "https://github.com/dss-extensions/AltDSS-Rust" }
```

The DSS C-API binaries will be **automatically downloaded** during the build process based on your target architecture. No manual setup required!

## Development Setup

For developing AltDSS-Rust itself, you can use either the automated devcontainer setup or manual installation.

## Supported Platforms

AltDSS-Rust supports multiple architectures and operating systems:

### Linux
- **x86_64** (Intel/AMD 64-bit)
- **ARM64** (AArch64) - including AWS Graviton, Raspberry Pi 4/5, etc.

### macOS
- **x86_64** (Intel Macs)
- **ARM64** (Apple Silicon - M1, M2, M3, etc.)

The build system automatically detects your platform and downloads the appropriate DSS C-API binaries.

## Quick Start Instructions

Some direct instructions to get up and running (assuming Rust and tools are already installed):

### Automatic (Recommended - works on all platforms):
```shell
mkdir altdss-tests
cd altdss-tests

# Automatically detect platform and download the correct DSS C-API
OS=$(uname -s)
ARCH=$(uname -m)

case "${OS}_${ARCH}" in
    Linux_x86_64)
        PLATFORM_SUFFIX="linux_x64"
        ;;
    Linux_aarch64)
        PLATFORM_SUFFIX="linux_arm64"
        ;;
    Darwin_x86_64)
        PLATFORM_SUFFIX="macos_x64"
        ;;
    Darwin_arm64)
        PLATFORM_SUFFIX="macos_arm64"
        ;;
    *)
        echo "Unsupported platform: ${OS} on ${ARCH}"
        exit 1
        ;;
esac

# Download appropriate DSS C-API
wget -qO- https://github.com/dss-extensions/dss_capi/releases/download/0.14.3/dss_capi_0.14.3_${PLATFORM_SUFFIX}.tar.gz | tar zxv
git clone --depth=1 https://github.com/dss-extensions/electricdss-tst
git clone https://github.com/dss-extensions/altdss-rust

# Set library path based on OS
if [[ "$OS" == "Darwin" ]]; then
    export DYLD_LIBRARY_PATH=`pwd`/dss_capi/lib/${PLATFORM_SUFFIX}
else
    export LD_LIBRARY_PATH=`pwd`/dss_capi/lib/${PLATFORM_SUFFIX}
fi

cd altdss-rust
cargo build
cargo run --example ieee13
cargo run --example list_props
cargo run --example parallel
```

### Platform-specific Examples:

#### Linux x86_64 (Intel/AMD 64-bit):
```shell
mkdir altdss-tests
cd altdss-tests
wget -qO- https://github.com/dss-extensions/dss_capi/releases/download/0.14.3/dss_capi_0.14.3_linux_x64.tar.gz | tar zxv
git clone --depth=1 https://github.com/dss-extensions/electricdss-tst
git clone https://github.com/dss-extensions/altdss-rust
export LD_LIBRARY_PATH=`pwd`/dss_capi/lib/linux_x64
cd altdss-rust
cargo build
cargo run --example ieee13
cargo run --example list_props
cargo run --example parallel
```

#### Linux ARM64 (AArch64):
```shell
mkdir altdss-tests
cd altdss-tests
wget -qO- https://github.com/dss-extensions/dss_capi/releases/download/0.14.3/dss_capi_0.14.3_linux_arm64.tar.gz | tar zxv
git clone --depth=1 https://github.com/dss-extensions/electricdss-tst
git clone https://github.com/dss-extensions/altdss-rust
export LD_LIBRARY_PATH=`pwd`/dss_capi/lib/linux_arm64
cd altdss-rust
cargo build
cargo run --example ieee13
cargo run --example list_props
cargo run --example parallel
```

#### macOS x86_64 (Intel Macs):
```shell
mkdir altdss-tests
cd altdss-tests
wget -qO- https://github.com/dss-extensions/dss_capi/releases/download/0.14.3/dss_capi_0.14.3_macos_x64.tar.gz | tar zxv
git clone --depth=1 https://github.com/dss-extensions/electricdss-tst
git clone https://github.com/dss-extensions/altdss-rust
export DYLD_LIBRARY_PATH=`pwd`/dss_capi/lib/macos_x64
cd altdss-rust
cargo build
cargo run --example ieee13
cargo run --example list_props
cargo run --example parallel
```

#### macOS ARM64 (Apple Silicon - M1, M2, M3):
```shell
mkdir altdss-tests
cd altdss-tests
wget -qO- https://github.com/dss-extensions/dss_capi/releases/download/0.14.3/dss_capi_0.14.3_macos_arm64.tar.gz | tar zxv
git clone --depth=1 https://github.com/dss-extensions/electricdss-tst
git clone https://github.com/dss-extensions/altdss-rust
export DYLD_LIBRARY_PATH=`pwd`/dss_capi/lib/macos_arm64
cd altdss-rust
cargo build
cargo run --example ieee13
cargo run --example list_props
cargo run --example parallel
```

### Automated Build Scripts:
Alternatively, you can use the provided build scripts that automatically handle platform detection:

```shell
git clone https://github.com/dss-extensions/altdss-rust
cd altdss-rust
./scripts/build_multiarch.sh  # Automatically detects your platform
```

Or use platform-specific scripts:
```shell
# Linux
./scripts/build_linux_x64.sh     # Force Linux x86_64 build
./scripts/build_linux_arm64.sh   # Force Linux ARM64 build

# macOS  
./scripts/build_macos_x64.sh     # Force macOS Intel build
./scripts/build_macos_arm64.sh   # Force macOS Apple Silicon build
```

# Examples

Check some examples in the [`tests`](https://github.com/dss-extensions/AltDSS-Rust/tree/main/tests) folder. These include basics, multithreading, and use of the properties API.
