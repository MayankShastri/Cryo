# Discord Gateway Setup & Reference

## Pre-requisites Checklist
1. **Application & Bot Setup**:
   - Create application in [Discord Developer Portal](https://discord.com/developers/applications).
   - Under **Bot**, reset and copy the Bot Token.
   - Under **Privileged Gateway Intents**, enable **Message Content Intent** (Mandatory), **Server Members Intent**, and **Presence Intent**.
2. **Bot Invite URL**:
   - Go to OAuth2 -> URL Generator.
   - Select scopes: `bot`, `applications.commands`.
   - Select bot permissions: `Send Messages`, `Send Messages in Threads`, `Create Public Threads`, `Create Private Threads`, `Read Message History`, `Embed Links`, `Attach Files`, `Add Reactions`.

## Gateway Configuration
- Run `hermes gateway setup` in the terminal and select Discord.
- When prompted:
  - Input the Bot Token.
  - Optionally set allowed user IDs or leave blank.
  - Optionally specify a Home Channel ID (or set later in chat with `/set-home`).

## Threading & Channel Control
- **Auto-Threading Behavior**: By default, Discord gateway creates a new thread when @mentioned in a channel.
  - Disable globally: `hermes config set discord.auto_thread false` (or `DISCORD_AUTO_THREAD=false`).
  - Disable for specific channels: `hermes config set discord.no_thread_channels <channel_id>` (or `DISCORD_NO_THREAD_CHANNELS=<channel_ids>`).
- **Channel Whitelisting & Filtering**:
  - Restrict bot strictly to specific channels: `hermes config set discord.allowed_channels <channel_id>` (or `DISCORD_ALLOWED_CHANNELS`).
  - Ignore specific channels: `hermes config set discord.ignored_channels <channel_id>` (or `DISCORD_IGNORED_CHANNELS`).
  - Free-response channels (respond without @mention): `hermes config set discord.free_response_channels <channel_id>` (or `DISCORD_FREE_RESPONSE_CHANNELS`).

## Provider Alignment Checklist
When using local proxies or custom providers (e.g. OmniRoute at `localhost:20128`):
- Ensure `model.provider` is explicitly configured:
  ```bash
  hermes config set model.provider omniroute
  hermes config set model.default titan-coding-pool
  ```
- Restart the gateway to apply:
  - **Note**: `hermes gateway restart` cannot be run from inside an active gateway session. Advise the user to run it from their host terminal.
- Verify connection and inference in logs:
  ```bash
  hermes logs --since 2m
  ```
