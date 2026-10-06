"""Template for a thin CLI client matching Hermes' --input_file/--output_file contract.
Forwards requests to a persistent local background server (FastAPI).
If the server is not running, auto-starts it using the dedicated venv Python interpreter.
Server has a 5-minute idle watchdog that shuts it down to free GPU VRAM.

Usage in config.yaml:
  command: '"C:/path/to/venv/Scripts/python.exe" "C:/path/to/hermes_tts_client.py" --input_file "{input_path}" --output_file "{output_path}"'

IMPORTANT: set VENV_PYTHON to the absolute path of your TTS venv's Python.
Do NOT rely on sys.executable — it will point to Hermes' internal env, not yours.
"""
import argparse
import json
import os
import subprocess
import sys
import time
import urllib.request
import urllib.error

# ==============================
# CONFIGURE THESE TWO PATHS
# ==============================
# Absolute path to your TTS venv Python interpreter
VENV_PYTHON = r"C:\path\to\venv\Scripts\python.exe"
# Absolute path to the server script
SERVER_SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tts_server.py")
# ==============================

SERVER_URL = "http://127.0.0.1:8765/synthesize"
HEALTH_URL = "http://127.0.0.1:8765/health"


def is_ready() -> bool:
    try:
        req = urllib.request.Request(HEALTH_URL, method="GET")
        with urllib.request.urlopen(req, timeout=1.5) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return data.get("status") == "ok" and data.get("engine_loaded") is True
    except Exception:
        return False


def start_server():
    """Start tts_server.py using the venv Python, detached (no console window)."""
    print("[TTS Client] Starting TTS server on-demand...", file=sys.stderr)
    creationflags = 0
    if sys.platform == "win32":
        creationflags = 0x08000000 | 0x00000200  # CREATE_NO_WINDOW | CREATE_NEW_PROCESS_GROUP
    log_path = os.path.join(os.path.dirname(SERVER_SCRIPT), "server_startup.log")
    with open(log_path, "a", encoding="utf-8") as f_log:
        subprocess.Popen(
            [VENV_PYTHON, SERVER_SCRIPT],
            cwd=os.path.dirname(SERVER_SCRIPT),
            stdout=f_log,
            stderr=f_log,
            creationflags=creationflags,
            close_fds=(sys.platform != "win32"),
        )


def wait_for_server(timeout=180) -> bool:
    """Poll health endpoint until ready or timeout."""
    start = time.time()
    while time.time() - start < timeout:
        if is_ready():
            return True
        time.sleep(1.0)
    return False


def main():
    parser = argparse.ArgumentParser(description="Hermes TTS Client — on-demand daemon pattern")
    parser.add_argument("--input_file", required=True)
    parser.add_argument("--output_file", required=True)
    parser.add_argument("--voice", default=None)
    parser.add_argument("--speed", default=None)
    parser.add_argument("--format", default=None)
    args = parser.parse_args()

    with open(args.input_file, "r", encoding="utf-8") as f:
        text = f.read().strip()

    if not text:
        print("[TTS Client] Input file was empty.", file=sys.stderr)
        sys.exit(1)

    # Auto-start the server if not responsive
    if not is_ready():
        start_server()
        print("[TTS Client] Waiting for model to load...", file=sys.stderr)
        if not wait_for_server(timeout=180):
            print("[TTS Client] Error: server failed to initialize within 180 seconds.", file=sys.stderr)
            sys.exit(1)
        print("[TTS Client] Server ready.", file=sys.stderr)

    payload = {"text": text}
    if args.voice:
        payload["voice"] = args.voice
    if args.speed:
        payload["speed"] = args.speed

    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        SERVER_URL,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=90) as resp:
            audio_bytes = resp.read()
    except urllib.error.URLError as e:
        print(f"[TTS Client] Failed to reach TTS server ({e}).", file=sys.stderr)
        sys.exit(1)

    with open(args.output_file, "wb") as f:
        f.write(audio_bytes)


if __name__ == "__main__":
    main()


# ==========================================
# SERVER SNIPPET (tts_server.py)
# ==========================================
# Add this idle-shutdown watchdog in your server startup handler:
#
# import time, os, threading
# IDLE_TIMEOUT = 300  # 5 minutes
# last_active = time.time()
#
# def idle_watcher():
#     while True:
#         time.sleep(10)
#         if time.time() - last_active > IDLE_TIMEOUT:
#             # os._exit(0) is the correct way to terminate from a thread
#             os._exit(0)
#
# @app.on_event("startup")
# def startup():
#     global last_active
#     last_active = time.time()
#     # load your model here ...
#     threading.Thread(target=idle_watcher, daemon=True).start()
#
# @app.post("/synthesize")
# def synthesize(req: SynthRequest):
#     global last_active
#     last_active = time.time()   # RESET idle timer on every request
#     ...
