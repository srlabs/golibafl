use std::env;
use std::path::PathBuf;
use std::process::{exit, Command};

fn main() {
    // Enable cgo
    env::set_var("CGO_ENABLED", "1");

    let harness_path = env::var("HARNESS").unwrap_or_else(|_| String::from("./harnesses/promql"));

    // Define the output directory for the Go library
    let out_dir = match env::var("OUT_DIR") {
        Ok(out) => PathBuf::from(out),
        Err(err) => {
            eprintln!("Failed to get OUT_DIR: {err}");
            exit(1);
        }
    };

    // Build the Go code as a static library
    let status = Command::new("go")
        .args([
            "build",
            "-buildmode=c-archive",
            "-tags=libfuzzer,gofuzz",
            "-gcflags=all=-d=libfuzzer", // Enable coverage instrumentation for libfuzzer
            // avoid instrumenting unnecessary packages
            "-gcflags=runtime/cgo=-d=libfuzzer=0",
            "-gcflags=runtime/pprof=-d=libfuzzer=0",
            "-gcflags=runtime/race=-d=libfuzzer=0",
            "-gcflags=syscall=-d=libfuzzer=0",
            "-o",
        ])
        .arg(out_dir.join("libharness.a"))
        .current_dir(harness_path)
        .status();

    match status {
        Ok(status) if status.success() => (),
        Ok(exit_code) => {
            eprintln!("Go build failed");
            match exit_code.code() {
                Some(code) => exit(code),
                None => exit(2),
            }
        }
        Err(err) => {
            eprintln!("Failed to execute Go build: {err}");
            exit(3);
        }
    }

    // Tell cargo to look for the library in the output directory
    println!("cargo:rustc-link-search=native={}", out_dir.display());
    // Tell cargo to link the static Go library
    println!("cargo:rustc-link-lib=static=harness");
}
