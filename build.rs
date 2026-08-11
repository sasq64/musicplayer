extern crate cmake;
use cmake::Config;
use std::fs;
use std::path::{Path, PathBuf};

fn visit_dirs(dir: &Path, target: &mut Vec<PathBuf>) {
    if dir.is_dir() {
        for entry in fs::read_dir(dir).unwrap() {
            let path = entry.unwrap().path();
            if path.is_dir() {
                visit_dirs(&path, target);
            } else {
                println!("{}", path.to_str().unwrap());
                let name: String = path.file_name().unwrap().to_str().unwrap().to_string();
                // MSVC names its static libs `foo.lib`, everyone else `libfoo.a`.
                let lib = name
                    .strip_suffix(".a")
                    .and_then(|stem| stem.strip_prefix("lib"))
                    .or_else(|| name.strip_suffix(".lib"));
                if let Some(lib) = lib {
                    println!("cargo:rustc-link-search=native={}", dir.to_str().unwrap());
                    println!("cargo:rustc-link-lib=static:+whole-archive={}", lib);
                }

                target.push(path);
            }
        }
    }
}

fn main() {
    let dst = Config::new(".")
        .build_target("musix_static")
        .define("RUST_BUILD", "ON")
        .build();

    let mut paths = Vec::new();
    visit_dirs(&dst, &mut paths);

    //println!("cargo:rustc-link-search=native={}", dst.display());
    //println!("cargo:rustc-link-lib=dylib=musix");
    // MSVC gets its C++ runtime through the CRT the Rust target already links
    // (msvcrt); there is no `c++.lib` to ask for.
    match std::env::var("CARGO_CFG_TARGET_ENV")
        .unwrap_or_default()
        .as_str()
    {
        "msvc" => {}
        "gnu" => println!("cargo:rustc-link-lib=dylib=stdc++"),
        _ => println!("cargo:rustc-link-lib=dylib=c++"),
    }
    //println!("cargo:rustc-link-lib=dylib=asound");
}
