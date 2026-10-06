# Multi-Profile Setup & Isolation Reference

Hermes profiles are completely isolated environments. Each profile has its own:
- `config.yaml` and `.env` (API keys and credentials)
- `SOUL.md` (bot personality and system instructions)
- `skills/` (procedural capabilities)
- `memories/` (factual memory store)
- Discord/gateway instance

## Common Pitfalls & Workarounds

### 1. "Provider authentication failed"
When setting up a new profile with local providers (like OmniRoute), copying `config.yaml` can introduce redacted placeholders (e.g. `«redacted:sk-…»`) into the new profile's config.
- **Fix**: Remove the literal redacted string from `profiles/<profile>/config.yaml`.
- **Fix**: Ensure the valid API key is present in `profiles/<profile>/.env` (e.g., `OMNIROUTE_API_KEY=sk-...`).

### 2. Gateway Restarts
- You cannot restart a running gateway from within an active session (`Blocked: cannot restart or stop the gateway from inside the gateway process`).
- **Fix**: Run `hermes --profile <name> gateway restart` from an external terminal.

### 3. Sharing Skills Across Profiles
Skills are not shared automatically. To replicate custom skills from `default` to a new profile:
```bash
cp -r ~/AppData/Local/hermes/skills/* ~/AppData/Local/hermes/profiles/<profile>/skills/
```

### 4. Integrating Supermemory with Profiles
Supermemory requires native config keys rather than custom top-level namespaces:
```bash
hermes --profile <profile> config set memory.base_url "http://localhost:6767"
hermes --profile <profile> config set memory.api_key "<key>"
```
Remember to restart the gateway afterwards.
