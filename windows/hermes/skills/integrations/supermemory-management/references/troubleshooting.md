# Supermemory Troubleshooting

## Stale Lock Errors
If the server fails to start with "Data directory ... is already in use", remove the lock file:
```bash
rm -f ~/.supermemory/.instance.lock
```

## Zombie Process (Running in Process Table but Port Not Listening)
If `supermemory-server.exe` is present in `tasklist` but `netstat -ano | grep 6767` returns nothing (server hung on startup or socket closed):
1. Force kill the hung instance: `taskkill /F /IM supermemory-server.exe`
2. Remove any lingering lock: `rm -f ~/.supermemory/.instance.lock`
3. Restart from `$HOME`: `cd ~ && ~/.supermemory/bin/supermemory-server.exe`

## "No model provider API key configured"
Ensure your `.env` file (or exported environment) has a valid key:
```bash
export OPENAI_API_KEY="sk-..."
```

## Empty Search Results / "0 documents stored"
Supermemory partitions data by **containerTags**. You MUST specify the correct tag when searching or listing documents.
- Example: `containerTags: ["hunter"]`
- Use `POST /v3/container-tags/list` to find active tags.
