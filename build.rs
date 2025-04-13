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
                if name.ends_with(".a") {
                    println!("cargo:rustc-link-search=native={}", dir.to_str().unwrap());
                    let len = name.len();
                    println!(
                        "cargo:rustc-link-lib=static:+whole-archive={}",
                        &name[3..len - 2]
                    );
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
    if std::env::var_os("CARGO_CFG_TARGET_ENV").unwrap() == "gnu" {
        println!("cargo:rustc-link-lib=dylib=stdc++");
    } else {
        println!("cargo:rustc-link-lib=dylib=c++");
    }
    //println!("cargo:rustc-link-lib=dylib=asound");
}
