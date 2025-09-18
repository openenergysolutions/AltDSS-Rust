// Copyright 2023 PMeira
// Copyright 2023 DSS-Extensions Contributors
// Copyright 2023 Electric Power Research Institute, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

use std::env;
use std::path::Path;
use std::path::PathBuf;
use std::fs;
use std::io;
use flate2::read::GzDecoder;
use tar::Archive;

fn download_dss_capi(version: &str, platform: &str, target_dir: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let url = format!(
        "https://github.com/dss-extensions/dss_capi/releases/download/{}/dss_capi_{}_{}

.tar.gz",
        version, version, platform
    );
    
    println!("cargo:warning=Downloading DSS C-API {} for {}...", version, platform);
    println!("cargo:warning=URL: {}", url);
    
    // Download the archive
    let response = ureq::get(&url).call()?;
    
    // Create a buffer to read the response
    let mut reader = response.into_reader();
    let mut buffer = Vec::new();
    io::copy(&mut reader, &mut buffer)?;
    
    // Decompress and extract
    let decoder = GzDecoder::new(&buffer[..]);
    let mut archive = Archive::new(decoder);
    
    // Extract to the target directory
    archive.unpack(target_dir)?;
    
    println!("cargo:warning=DSS C-API {} extracted successfully", version);
    Ok(())
}

fn ensure_dss_capi(version: &str, platform: &str, manifest_dir: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let dss_capi_dir = manifest_dir.join("dss_capi");
    let lib_dir = dss_capi_dir.join("lib").join(platform);
    let include_dir = dss_capi_dir.join("include");
    
    // Check if DSS C-API is already available
    if lib_dir.exists() && include_dir.exists() {
        println!("cargo:warning=DSS C-API {} for {} already available", version, platform);
        return Ok(());
    }
    
    // Create the target directory if it doesn't exist
    fs::create_dir_all(manifest_dir)?;
    
    // Download and extract DSS C-API
    download_dss_capi(version, platform, manifest_dir)?;
    
    // Verify extraction was successful
    if !lib_dir.exists() || !include_dir.exists() {
        return Err(format!(
            "DSS C-API extraction failed. Missing directories: lib/{} or include", 
            platform
        ).into());
    }
    
    Ok(())
}

fn main() {
    let pwd_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let manifest_path = Path::new(&*pwd_dir);
    
    // Get version from Cargo.toml
    let version = env::var("CARGO_PKG_VERSION").unwrap();
    
    // Detect target architecture and OS
    let target_arch = env::var("CARGO_CFG_TARGET_ARCH").unwrap_or_else(|_| "x86_64".to_string());
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap_or_else(|_| "linux".to_string());
    
    let lib_subdir = match (target_os.as_str(), target_arch.as_str()) {
        ("linux", "x86_64") => "linux_x64",
        ("linux", "aarch64") => "linux_arm64",
        ("macos", "aarch64") => "macos_arm64",
        ("macos", "x86_64") => "macos_x64",
        (os, arch) => panic!("Unsupported platform: {} on {}", arch, os),
    };
    
    // Ensure DSS C-API is available
    if let Err(e) = ensure_dss_capi(&version, lib_subdir, manifest_path) {
        panic!("Failed to ensure DSS C-API availability: {}", e);
    }
    
    let inc_path = manifest_path.join("./dss_capi/include");
    let lib_path = manifest_path.join(format!("./dss_capi/lib/{}", lib_subdir));

    let profile = env::var("PROFILE").unwrap();

    // Configure linker based on target OS
    match target_os.as_str() {
        "linux" => {
            println!("cargo:rustc-link-arg=-Wl,-rpath={}", lib_path.to_str().unwrap());
        }
        "macos" => {
            println!("cargo:rustc-link-arg=-Wl,-rpath,{}", lib_path.to_str().unwrap());
        }
        _ => {}
    }
    
    // Select the library binary according to the build profile
    match profile.as_str() {
        "debug" => println!("cargo:rustc-link-lib=dylib=dss_capid"),
        _ => println!("cargo:rustc-link-lib=dylib=dss_capi")
    }
    println!("cargo:rustc-link-search=native={}", lib_path.to_str().unwrap());
    // println!("cargo:rerun-if-changed=src/dss_capi_wrapper.h");

    // https://rust-lang.github.io/rust-bindgen/tutorial-3.html
    let bindings = bindgen::Builder::default()
        .clang_arg(format!("-I{}", inc_path.to_str().unwrap()))
        .header_contents("dss_capi_wrapper.h", "#include \"dss_capi_ctx.h\"")
        // .parse_callbacks(Box::new(bindgen::CargoCallbacks))
        .prepend_enum_name(false)
        .generate()
        .expect("Unable to generate bindings");

    // Write the bindings to the $OUT_DIR/bindings.rs file.
    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
    bindings
        .write_to_file(out_path.join("bindings.rs"))
        .expect("Couldn't write bindings!");
}
