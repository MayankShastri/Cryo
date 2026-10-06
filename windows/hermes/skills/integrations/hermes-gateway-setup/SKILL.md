---
name: hermes-gateway-setup
description: Guide for setting up, configuring, and troubleshooting Hermes messaging gateways (Discord, Telegram, Slack, etc.) and resolving provider routing issues.
---

# Hermes Gateway Setup & Troubleshooting

This skill covers end-to-end configuration, verification, and debugging of Hermes Agent messaging gateways across platforms (Discord, Telegram, Slack, etc.), including model provider routing and permission requirements.

## 1. Gateway Lifecycle Commands

- **Setup Platforms**: `hermes gateway setup` (interactive wizard for tokens, allowlists, and home channels).
- **Run in Foreground**: `hermes gateway run` (useful for live debugging / initial startup).
- **Check Status**: `hermes gateway status`
- **Restart**: `hermes gateway restart` (apply config or credential changes).
- **Install Service**: `hermes gateway install` (auto-starts on system boot/login).
- **Check Logs**: `hermes logs --since 5m` or `hermes logs -f`

## 2. Platform Requirements & Intents

### Discord
- **Token Configuration**: Configured securely via `hermes gateway setup` (saves `DISCORD_BOT_TOKEN` to `.env`).
- **Privileged Gateway Intents (Mandatory)**:
  - In the [Discord Developer Portal](https://discord.com/developers/applications) -> Application -> **Bot**:
    - Enable **Message Content Intent** (Required — without this, connection times out or shards invalidate after 30s).
    - Enable **Server Members Intent** (Recommended).
    - Enable **Presence Intent** (Optional).
- **Permissions**: Ensure bot invite URL has permissions to Send Messages, Create Public/Private Threads, Read Message History, and Embed Links.
- **Inbound Documents & Attachments**:
  - When users send attachments (PDF, DOCX, TXT, images) via Discord, the gateway saves them locally under `~/.hermes/cache/documents/` (e.g. `doc_<hash>_<name>.<ext>`) and injects the file path into the turn message.
  - Read cached documents directly using `read_file` (auto-extracts text from DOCX, PDF, XLSX, IPYNB) or python scripts instead of asking the user to re-paste text.
- **Outbound File Attachment Size Limits (CRITICAL)**:
  - Discord enforces a hard **8 MB per-file limit** for bots on non-boosted servers. Exceeding it returns HTTP 413 `error code: 40005: Request entity too large`. The gateway logs this as: `Failed to send document, falling back to base adapter: 413 Payload Too Large`.
  - PNGs/screenshots are already compressed — ZIP deflate gives <5% reduction. **Never estimate zip output size from uncompressed file sizes.** Always measure actual compressed bytes.
  - **Correct batching**: compress each file individually into a `io.BytesIO` buffer to get its real compressed size, accumulate the total, and flush to a new zip when the running total would exceed ~7.5 MB. See `references/discord-file-batching.md` for the exact Python pattern.
  - **Diagnosing delivery failures**: `hermes logs --since 10m | grep -i -E "attach|413|deliver"` — a `413 Payload Too Large` confirms the file was over the cap.
- **Disable Auto-Threading & Channel Restriction**:
  - To prevent creating threads and force direct channel responses: `hermes config set discord.auto_thread false`
  - To restrict responses to specific channels without threads:
    ```bash
    hermes config set discord.allowed_channels <channel_id>
    hermes config set discord.no_thread_channels <channel_id>
    ```

## 3. Provider & Model Routing Configuration

When running gateways with custom or local inference providers (e.g. OmniRoute, Ollama, LM Studio, Custom endpoints):

1. **Explicit Provider Specification**:
   If `model.provider` is omitted or set to `auto`, the gateway runtime may fall back to OpenRouter and fail with `HTTP 401: Missing Authentication header`.
   Always set explicit provider and model keys:
   ```bash
   hermes config set model.provider <provider_name>
   hermes config set model.default <model_name>
   ```
2. **Config File Safety Guard**:
   `~/.hermes/config.yaml` is protected by agent safety guards. Do not use file edit tools (`patch`/`write_file`) on `config.yaml`. Use `hermes config set <key> <value>` or edit manually.

## 4. Common Pitfalls & Diagnostics

| Symptom | Root Cause | Fix |
| :--- | :--- | :--- |
| `Shard ID None session has been invalidated` / `discord connect timed out after 30s` | Missing Message Content Intent in Discord Developer Portal | Enable **Message Content Intent** under Bot -> Privileged Gateway Intents, then `hermes gateway restart`. |
| `HTTP 401: Missing Authentication header` (Provider authentication failed) | Gateway defaulted to OpenRouter because `model.provider` wasn't set | Run `hermes config set model.provider <name>` and `hermes gateway restart`. |
| Modifying `config.yaml` fails with safety guard | Direct file edits on security-sensitive config are blocked | Use `hermes config set <key> <value>`. |
| `Provider authentication failed` | Missing API key in .env or config has redacted placeholder | Ensure OMNI_API_KEY (or relevant) is in .env; check config.yaml for redacted placeholders. |
| `Silent Voice Channel Playback` / `Sends voice note instead of speaking in VC` | (1) Missing `ffmpeg.exe` in Hermes `bin`; (2) Inactivity timeout (300s) auto-disconnected bot from VC; or (3) Agent manually invoked `text_to_speech` tool, which flags `has_agent_tts=True` and redirects output to text channel attachment rather than live streaming. | (1) Copy `ffmpeg.exe` to `~/.hermes/bin/ffmpeg.exe`; (2) Re-join VC with `/voice join`; (3) Allow bot to reply with plain text instead of calling `text_to_speech` tool. |
| `Multi-Profile Persona Leakage` | Main assistant persona mimicking secondary bot persona | Maintain strict separation: keep the default Hermes profile as Hunter's objective technical assistant; secondary profile personalities belong exclusively in their respective profiles. |
| `Blocked: cannot restart...` | Trying to restart gateway from inside the gateway process | Restart the gateway from an external host terminal. |
| `Multi-Profile Setup` | Profiles are fully isolated (no shared skills/memory) | See `references/multi-profile-setup.md` for syncing skills and configuration across profiles. |
| `413 Payload Too Large (error code: 40005)` when sending file | File exceeds Discord's 8 MB bot upload limit | Repack into ≤7.5 MB zips using compressed-size-aware batching (see `references/discord-file-batching.md`). Do NOT estimate from uncompressed size — PNGs compress <5%. |

## Linked Files
- `references/discord-gateway.md` — Detailed setup notes and troubleshooting checklist for Discord gateway.
- `references/discord-file-batching.md` — Compressed-size-aware Python pattern for splitting large files into ≤8 MB Discord-safe zips.
