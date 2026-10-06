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
| `Blocked: cannot restart or stop the gateway from inside the gateway process` | Gateway lifecycle commands blocked inside active agent turns to prevent self-termination | Instruct user to run `hermes gateway restart` from an external terminal/host shell. |

## Linked Files
- `references/discord-gateway.md` — Detailed setup notes and troubleshooting checklist for Discord gateway.
- `references/discord-home-channel-troubleshooting.md` — Quick reference for when the gateway doesn't reply despite appearing connected.
