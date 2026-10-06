# Oh My Pi (`omp`) & Local Router (OmniRoute) Integration Guide

## Overview
Oh My Pi (`omp` / Pi coding agent) is an interactive coding agent CLI. It supports custom models and OpenAI-compatible proxy endpoints via declarative configuration in its agent directory.

## Directory Structure & Key Paths
- **Windows Binary**: `C:\Users\<user>\AppData\Local\omp\omp.exe`
- **Agent Directory**: `~/.omp/agent/` (`C:\Users\<user>\.omp\agent\`)
- **Global Settings**: `~/.omp/agent/config.yml`
- **Model Registry Configuration**: `~/.omp/agent/models.yml`

> **Critical Pitfall**: `models.yml` must be placed in `~/.omp/agent/models.yml`, NOT in the root `~/.omp/models.yml`. The OMP model registry loader specifically locates `models.yml` under `agentDir`.

## Configuring Local OpenAI-Compatible Routers (e.g., OmniRoute)

Create or update `~/.omp/agent/models.yml`:

```yaml
providers:
  omniroute:
    baseUrl: http://localhost:20128/v1
    auth: none
    api: openai-completions
    models:
      - id: titan-coding-pool
        name: Titan Coding Pool
        api: openai-completions
```

### Provider Schema Fields
- `baseUrl`: Endpoint root (e.g. `http://localhost:20128/v1`).
- `auth`: Set to `none` if the local proxy does not enforce bearer authentication, or specify `apiKey: "..."` if secured.
- `api`: Protocol adapter (`openai-completions`, `openai-responses`).
- `models`: List of models with `id` and `name`.

## Running omp in Batch / Non-Interactive Mode (Task Files)

For scaffolding a repo or any large multi-file generation job, write the full spec into a markdown file (e.g. `.omp-task.md`) at the project root, then invoke:

```bash
# Git Bash — note the Windows-style path for --cwd
omp --model omniroute/titan-coding-pool --cwd "C:\\Users\\mayan\\Documents\\MyProject" -p "@.omp-task.md"
```

- The `@` prefix tells omp to load the referenced file as the prompt content.
- `-p` / `--print` disables the TUI and exits when done.
- Run this in a Hermes background terminal (`background=True, notify_on_complete=True`) so you get alerted when it's done without blocking.
- **Do not** shell-background with `command &` in Hermes terminal calls — it can cause "no job control" warnings and makes PID tracking unreliable.

**Critical `--cwd` Pitfall (Windows + MSYS/Git Bash):**
- ✅ `--cwd "C:\\Users\\mayan\\Documents\\Cryo"` — works
- ❌ `--cwd /c/Users/mayan/Documents/Cryo` — omp resolves it as `C:\c\Users\...` and throws `ENOENT`
- Symptom: `Cannot change working directory to /c/...: ENOENT: no such file or directory, chdir ... -> 'C:\c\Users\...'`

---

## Verification & Usage

1. **Verify Model Discovery**:
   ```bash
   omp models ls
   ```
   Output will display the registered provider (e.g., `omniroute (1)`) along with context window and token details.

2. **Test Prompt (Non-Interactive)**:
   ```bash
   omp --model omniroute/titan-coding-pool -p "Reply with exact word: PONG"
   ```

3. **Launch Interactive Agent**:
   ```bash
   omp --model omniroute/titan-coding-pool
   ```

## Common CLI Traps
- **Model Selection Flag**: Use `--model <provider>/<model_id>` (e.g. `--model omniroute/titan-coding-pool`). Do NOT use `-m` (unrecognized flag in `omp`).
- **Non-Interactive Execution**: Use `-p` or `--print` to test model communication or execute a task file without starting a full TUI session. You can pass a task markdown file with `@` (e.g., `omp -p "@.omp-task.md"`).
- **Windows Path Resolution on MSYS Bash**: When launching `omp` under MSYS/Git Bash with the `--cwd` flag, **do not** use UNIX-style paths like `/c/Users/...`. It will result in an `ENOENT` double-concatenation error (e.g., looking for `C:\c\Users\...`). You must supply a native Windows-style path with backslashes or escaped forward slashes (e.g., `--cwd "C:\Users\mayan\Documents\Cryo"`).
