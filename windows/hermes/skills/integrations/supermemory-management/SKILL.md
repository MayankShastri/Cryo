---
name: supermemory-management
description: Procedures for running, diagnosing, querying, and troubleshooting local Supermemory instances and context retrieval.
---

# Supermemory Management & Diagnostics

This skill provides operational procedures for managing local Supermemory instances (self-hosted Bun/encrypted storage on `localhost:6767`), handling process locks, resolving storage path resolution issues, and querying partitioned container tags.

## 1. Process Lifecycle & Working Directory Pitfall

Local Supermemory (`supermemory-server.exe` / Bun bundle) resolves its storage folder as `./.supermemory` relative to the current working directory or `$HOME/.supermemory`.

### Critical Working Directory Rule
- **Never start `supermemory-server.exe` with working directory set to `~/.supermemory`**. Doing so causes the server to resolve `./.supermemory` as `~/.supermemory/.supermemory`, creating an empty nested directory and hiding existing documents/memories.
- **Always launch from the user's home directory (`$HOME` / `C:\Users\<user>`)**:
  ```bash
  export $(grep -v '^#' ~/.supermemory/.env | xargs)
  ~/.supermemory/bin/supermemory-server.exe
  ```

### Handling Process Locks and Exits
If the server fails to start with `Data directory ... is already in use by process <PID>`:
1. Check running processes: `tasklist | grep -i supermemory` (or `pgrep -f supermemory`)
2. Kill stale instances: `taskkill /F /IM supermemory-server.exe`
3. Remove lingering lock file: `rm -f ~/.supermemory/.instance.lock`
4. Verify environment credentials from `.env` are exported prior to startup.

## 2. Document & Memory Inspection Workflow

Supermemory partitions data by **Container Tags** (spaces). Calling global search without matching container tags often yields `0` results even when documents exist.

### Discovery Sequence
1. **List Container Tags:**
   ```bash
   curl -s http://localhost:6767/v3/container-tags/list
   ```
   Inspect the returned tags (e.g., `hunter`, `user_mayank`), document counts, and memory counts.

2. **List Documents:**
   ```bash
   curl -s -X POST "http://localhost:6767/v3/documents/list" \
     -H "Content-Type: application/json" \
     -d '{}'
   ```

3. **Query Memories per Container Tag:**
   ```bash
   curl -s -X POST "http://localhost:6767/v4/memories/list" \
     -H "Content-Type: application/json" \
     -d '{"containerTags": ["<tag_name>"], "limit": 100}'
   ```

4. **Targeted Profile / Hybrid Search:**
   ```bash
   curl -s -X POST "http://localhost:6767/v4/search" \
     -H "Content-Type: application/json" \
     -d '{"q": "<query>", "containerTag": "<tag_name>", "searchMode": "hybrid", "limit": 20}'
   ```

## 3. Pitfalls & Troubleshooting

- **Zombie Process / Port Unbound:** `supermemory-server.exe` appearing in `tasklist` does not guarantee the server is responsive. If port `6767` is not listening in `netstat`, the process may be hung; kill it with `taskkill /F /IM supermemory-server.exe`, verify `~/.supermemory/.instance.lock` is removed, and relaunch from `$HOME`.
- **False "Deleted Files" Alarm:** If `/v4/search` or `/v4/profile` returns empty results, do not assume data is lost. Check `GET /v3/container-tags/list` and `data` file size in `~/.supermemory/data`. If data size is >0, the memories are intact under specific container tags.
- **Nested Directory Recovery:** If a nested `.supermemory/.supermemory` was created due to wrong `cwd`, kill the server, remove the nested subdirectory, and restart with `cwd=$HOME`.

## Reference Files
- [Troubleshooting](references/troubleshooting.md)

