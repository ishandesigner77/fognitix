#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::io::{BufRead, BufReader, Write};
use std::path::PathBuf;
use std::process::{Child, Command, Stdio};
use std::sync::Mutex;

struct EngineSession {
    _child: Child,
    stdin: std::process::ChildStdin,
    reader: BufReader<std::process::ChildStdout>,
}

static ENGINE: Mutex<Option<EngineSession>> = Mutex::new(None);

fn engine_binary_name() -> &'static str {
    if cfg!(target_os = "windows") {
        "fognitix-engine.exe"
    } else {
        "fognitix-engine"
    }
}

fn engine_candidates() -> Vec<PathBuf> {
    let mut v = Vec::new();
    if let Ok(p) = std::env::var("FOGNITIX_ENGINE") {
        v.push(PathBuf::from(p));
    }
    if let Ok(exe) = std::env::current_exe() {
        if let Some(dir) = exe.parent() {
            v.push(dir.join(engine_binary_name()));
        }
    }
    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    v.push(
        manifest_dir.join("../../build/windows-release/fognitix-engine.exe"),
    );
    v.push(manifest_dir.join("../../build/Release/fognitix-engine.exe"));
    v.push(manifest_dir.join("../../out/build/x64-Release/fognitix-engine.exe"));
    if let Ok(cwd) = std::env::current_dir() {
        v.push(cwd.join(engine_binary_name()));
    }
    v
}

fn resolve_engine_path() -> Result<PathBuf, String> {
    let candidates = engine_candidates();
    for c in &candidates {
        if c.is_file() {
            return Ok(c.clone());
        }
    }
    Err(format!(
        "fognitix-engine not found. Build the CMake target `fognitix-engine`, or set FOGNITIX_ENGINE to the full path. Tried: {:?}",
        candidates
    ))
}

fn spawn_engine() -> Result<EngineSession, String> {
    let path = resolve_engine_path()?;
    let mut child = Command::new(&path)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::inherit())
        .spawn()
        .map_err(|e| format!("failed to spawn {:?}: {e}", path))?;
    let stdin = child.stdin.take().ok_or("engine stdin unavailable")?;
    let stdout = child.stdout.take().ok_or("engine stdout unavailable")?;
    Ok(EngineSession {
        _child: child,
        stdin,
        reader: BufReader::new(stdout),
    })
}

fn ensure_engine() -> Result<(), String> {
    let mut g = ENGINE.lock().map_err(|e| e.to_string())?;
    if g.is_none() {
        *g = Some(spawn_engine()?);
    }
    Ok(())
}

fn kill_engine_locked(slot: &mut Option<EngineSession>) {
    *slot = None;
}

#[tauri::command]
fn engine_request(line: String) -> Result<String, String> {
    ensure_engine()?;
    let mut g = ENGINE.lock().map_err(|e| e.to_string())?;
    let eng = g.as_mut().ok_or("engine session missing")?;
    eng.stdin
        .write_all(line.as_bytes())
        .map_err(|e| e.to_string())?;
    eng.stdin.write_all(b"\n").map_err(|e| e.to_string())?;
    eng.stdin.flush().map_err(|e| e.to_string())?;
    let mut out = String::new();
    match eng.reader.read_line(&mut out) {
        Ok(0) => {
            kill_engine_locked(&mut g);
            Err("engine closed stdout".into())
        }
        Ok(_) => Ok(out.trim_end().to_string()),
        Err(e) => {
            kill_engine_locked(&mut g);
            Err(e.to_string())
        }
    }
}

#[tauri::command]
fn engine_path_probe() -> Result<String, String> {
    resolve_engine_path().map(|p| p.to_string_lossy().into_owned())
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![engine_request, engine_path_probe])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
