---
name: custom-voice-tts-pipeline
description: Build, debug, and integrate 2-stage Text-to-Speech (Base TTS + RVC Voice Conversion) pipelines and wire them into AI agents as custom command-type TTS providers.
tags: [tts, rvc, voice-cloning, audio, edge-tts, hermes-tts]
---

# Custom Voice TTS & RVC Conversion Pipelines

This skill covers building 2-stage voice synthesis pipelines (Base TTS $\rightarrow$ RVC Voice Conversion) and wiring local speech engines into AI agents like Hermes Agent via custom command-type providers.

## Architecture

1. **Stage 1: Base Acoustic Synthesis**
   - Use ultra-fast neural base TTS engines (e.g. `edge-tts` with `en-US-AnaNeural` or `ja-JP-NanamiNeural`, or local `piper`) to produce clean timing, pronunciation, and intonation into a temporary 16kHz WAV.
2. **Stage 2: Voice Conversion (RVC)**
   - Extract semantic features using HuBERT (`hubert_base.pt`).
   - Extract pitch (F0) using `pm` (parselmouth, ultra-fast) or `rmvpe` (high quality).
   - Query FAISS index (`added_*.index`) to blend target speaker timbre.
   ### 3. Server-Client Daemon Pattern (Low Latency & VRAM Optimization)

   For heavy deep-learning models (like Chatterbox, VITS, GPT-SoVITS), reloading model weights inside a raw CLI script execution on every call takes 20-30+ seconds.

   **Pattern**: 
   1. Run a persistent local background server (FastAPI) that keeps the model warm.
   2. Implement **on-demand startup** in your client: If the server isn't running, start it before forwarding the synthesis request.
   3. Implement **idle timeout shutdown**: Add a background daemon thread in the server that monitors the last request time and exits (`os._exit(0)`) if idle beyond a threshold (e.g., 300s) to free GPU VRAM.

   **Pitfall (Python Interpreter)**: 
   When your client script runs from a different environment (e.g., Hermes' own internal environment), `sys.executable` will NOT point to your TTS project's `venv-chatterbox`. Always explicitly resolve the absolute path to your TTS project's virtualenv Python interpreter in your client script to avoid `ModuleNotFoundError` for model dependencies.

   ```python
   # Client: Always point to the correct venv
   PYTHON_EXE = r"C:/Users/name/Documents/TTS/venv/Scripts/python.exe"
   # Start process
   subprocess.Popen([PYTHON_EXE, server_script], ...)
   ```

   **Implementation (Server Idle Daemon)**:
   ```python
   def check_idle_timeout():
       while True:
           time.sleep(10)
           if time.time() - last_request_time > 300: # 5 min
               os._exit(0)
   # Start in startup()
   threading.Thread(target=check_idle_timeout, daemon=True).start()
   ```

---

## RVC Version Differences & Pitfalls

### 1. RVC v2 vs v1 Feature Dimensions
- **RVC v1**: HuBERT layer 9 features projected to 256 dimensions (`feats = model.final_proj(logits[0])`). Uses `TextEncoder256`.
- **RVC v2**: HuBERT layer 12 features directly at 768 dimensions (`feats = logits[0]`, omitting `final_proj`). The model's `emb_phone` has weight shape `[hidden_channels, 768]`.
- **Pitfall**: Instantiating standard v1 `SynthesizerTrnMs256NSFsid` on a v2 checkpoint throws `RuntimeError: size mismatch for enc_p.emb_phone.weight: copying param shape [192, 768] into [192, 256]`.
- **Fix**: Subclass `TextEncoder` to handle 768-dim input:
  ```python
  class TextEncoder768(TextEncoder256):
      def __init__(self, out_channels, hidden_channels, filter_channels, n_heads, n_layers, kernel_size, p_dropout, f0=True):
          super().__init__(out_channels, hidden_channels, filter_channels, n_heads, n_layers, kernel_size, p_dropout, f0=f0)
          self.emb_phone = nn.Linear(768, hidden_channels)

  class SynthesizerTrnMs768NSFsid(SynthesizerTrnMs256NSFsid):
      def __init__(self, *args, **kwargs):
          super().__init__(*args, **kwargs)
          self.enc_p = TextEncoder768(
              args[2], args[3], args[4], args[5], args[6], args[7], args[8],
              f0=(args[9] == '1' or args[9] == 1)
          )
  ```

### 2. FAISS DirectMap Not Initialized
- **Pitfall**: When reconstructing vectors from an IVF FAISS index (`added_IVF*.index`), calling `index.reconstruct(i)` raises:
  `RuntimeError: Error in DirectMap::get: direct map not initialized`
- **Fix**: Initialize direct map immediately after loading index:
  ```python
  index = faiss.read_index(index_path)
  index.make_direct_map()
  ```

### 3. Subprocess FFmpeg Path on Windows
- `my_utils.load_audio` calls `ffmpeg` via subprocess. If ffmpeg is bundled locally in the RVC root but missing from global system PATH, loading audio throws `FileNotFoundError: [WinError 2]`.
- **Fix**: Prepend RVC root to `os.environ["PATH"]` before invoking `load_audio`:
  ```python
  os.environ["PATH"] = RVC_ROOT + os.pathsep + os.path.join(RVC_ROOT, "bin") + os.pathsep + os.environ.get("PATH", "")
  ```
- **Discord Voice Streaming Requirement**: When wiring into Hermes Discord gateway, `discord.py` and the continuous voice mixer (`voice_mixer.decode_to_pcm`) **require** `ffmpeg.exe` to be in PATH or in the Hermes binary directory (`~/.hermes/bin/ffmpeg.exe`). Without it, the bot connects to voice channels but fails to stream audio silently. Copy the bundled ffmpeg:
  ```bash
  cp "<RVC_ROOT>/ffmpeg.exe" "~/.hermes/bin/ffmpeg.exe"
  ```

### 4. Hermes Command TTS Provider Interface Details
- **Placeholders**: Hermes TTS tool passes text via a file at `{input_path}` (alias `{text_path}`) and expects output at `{output_path}`.
- **Script Signature**: Your engine script **must** accept `--input_file <path> --output_file <path>` arguments. Hermes writes the text to a temp file and calls your script; it does NOT pass text as stdin or CLI arguments directly.
- **YAML Config Pitfalls** (Windows `cmd.exe`):
  - Paths containing parentheses or spaces (e.g. `RVC-beta20230416(2)`) **must** be double-quoted in the command string.
  - Use **forward slashes** (`/`) in YAML single-line values to avoid backslash escape issues (`\r` = carriage return).
  - Correct pattern:
    ```yaml
    command: '"C:/path/to/python.exe" "C:/path/to/script.py" --input_file "{input_path}" --output_file "{output_path}"'
    ```

### 5. Debugging Voice Channel vs Chat Attachment Behavior
- **Manual Tool Call vs Auto-Streaming**
  - ...
  - **Rule**: Never prompt or instruct the agent to manually call `text_to_speech` when interacting in live voice channels; let Hermes auto-TTS stream the natural text response.
- **Troubleshooting with Engine Logs**: If voice streaming fails, add explicit file logging in your engine script to a shared path (e.g., `C:/Users/<user>/ayaka_engine_debug.log`) to capture stderr during subprocess execution, as gateway environments often suppress standard error output.
    - **Pitfall (`has_agent_tts` Suppression)**: If the agent's LLM explicitly invokes the `text_to_speech` tool during its turn, Hermes marks `has_agent_tts = True`. This treats the output as a manual media attachment, uploads the `.wav` file directly to the Discord text channel, and **skips live voice-channel streaming** (`_send_voice_reply` is omitted).
    - **Rule**: Never prompt or instruct the agent to manually call `text_to_speech` when interacting in live voice channels; let Hermes auto-TTS stream the natural text response.
- **Inactivity Timeout (300s / 5 mins)**:
  - The Discord adapter enforces a 5-minute idle timeout (`VOICE_TIMEOUT = 300`). If no voice packets or spoken replies occur within 5 minutes, the bot auto-disconnects from the voice channel. Subsequent messages will fallback to delivering audio notes in text chat until re-joined via `/voice join`.
- **Subprocess Execution & Logging**:
  - Add file logging to your engine script at `C:/Users/<user>/ayaka_engine_debug.log` to capture subprocess stderr when run from gateway context.

---

## Wiring into Hermes Agent as a Command TTS Provider

Hermes supports arbitrary CLI voice generators via `type: command` in `~/.hermes/config.yaml` (or profile configs under `profiles/<name>/config.yaml`).

### Configuration
```yaml
tts:
  provider: custom_voice
  providers:
    custom_voice:
      type: command
      command: '"C:/path/to/runtime/python.exe" "C:/path/to/script.py" --input_file "{input_path}" --output_file "{output_path}"'
      output_format: wav
```

### Windows Shell & YAML Pitfalls
1. **Parentheses and Spaces in Paths**: Paths like `RVC-beta20230416(2)` will cause Windows `cmd.exe` to split at `(` if unquoted, resulting in errors like `'...RVC-beta20230416' is not recognized as an internal or external command`. Always enclose the executable and script paths in double quotes.
2. **YAML Escape Sequences**: Avoid raw backslashes like `\runtime` in single-line YAML values which can be parsed as `\r` carriage returns. Use forward slashes (`/`) or escape backslashes.
3. **Discord Voice Channel Streaming (`ffmpeg`)**: `discord.py` voice playback and continuous voice mixers require `ffmpeg.exe` in PATH or in Hermes binary directory (`~/.hermes/bin/ffmpeg.exe`). Without `ffmpeg`, the bot connects to voice channels but fails to stream audio silently.
4. **Unix vs Native Windows Paths in Terminal Tests**: When manually testing command lines in Git-Bash or MSYS (`terminal`), using virtual Unix-style paths like `/tmp/test.txt` as arguments to a native Windows Python executable (e.g. `venv/Scripts/python.exe`) causes `FileNotFoundError`. Native Windows binaries cannot resolve MSYS virtual `/tmp/` mounts. Always use Windows absolute paths (e.g., `C:/Users/name/test.txt`) for inputs/outputs during terminal tests.

**On-demand startup: 180s wait for model load, not 60s.** The Chatterbox model takes ~75-90s to load on first run (loading weights + PerthNet). Always use at least 180s as the timeout for `wait_for_server()`.

### Supported Placeholders
- `{input_path}` / `{text_path}`: Absolute path to UTF-8 file containing text to speak.
- `{output_path}`: Absolute path where synthesized audio must be written.
- `{voice}`, `{model}`, `{speed}`, `{format}`: Optional parameters passed from tool call / config.

### Discord Gateway Voice Commands
- `/voice join` or `/voice channel`: Bot joins the voice channel of the calling user.
- `/voice tts`: Enables full TTS voice playback for all agent responses in voice.
- `/voice leave`: Disconnects from the voice channel.

