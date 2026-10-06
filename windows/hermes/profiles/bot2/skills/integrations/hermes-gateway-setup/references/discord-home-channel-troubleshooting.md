# Discord Gateway Not Replying: Home Channel Configuration

## Symptom
The default Hermes Gateway appears to be running (PID active) but does not reply when tagged in Discord.

## Root Cause
The `discord.home_channel` configuration key is not set. Without this, the gateway cannot route direct mentions reliably, even if `discord.allowed_channels` contains a channel ID.

## Diagnostic Commands
```bash
# Check if home_channel is set
hermes --profile default config get discord.home_channel

# Check allowed_channels (may be set but insufficient)
hermes --profile default config get discord.allowed_channels

# Verify gateway status
hermes --profile default gateway status

# Check recent logs
hermes --profile default logs --since 5m
```

## Fix
1. Set the home_channel to the target channel ID:
   ```bash
   hermes --profile default config set discord.home_channel <channel_id>
   ```

2. Restart the gateway from an external terminal (in-process restart is blocked):
   ```bash
   hernes --profile default gateway restart
   ```

## Related
- `discord.allowed_channels` restricts which channels the bot responds in
- `discord.home_channel` establishes the primary routing channel for mentions