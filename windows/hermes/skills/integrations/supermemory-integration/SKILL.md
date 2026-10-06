---
name: supermemory-integration
description: Guide for running, querying, debugging, and ingesting context into local and self-hosted Supermemory instances (port 6767 / OpenAPI v4).
---

# Supermemory Integration & Troubleshooting

This skill covers managing, troubleshooting, and querying a local Supermemory instance (`http://localhost:6767`) to augment agent memory with external persistent storage, vector recall, and profile retrieval.

## 1. Architecture & Local Layout

On Windows / local host environments, Supermemory Lite typically resides in `~/.supermemory/`:
- **Server binary**: `~/.supermemory/bin/supermemory-server.exe` (Bun-compiled standalone server).
- **Storage & PGlite data**: `~/.supermemory/.supermemory/` (contains SQLite/PGlite data, local vector embeddings, and locks).
- **Config & Secrets**: `~/.supermemory/.env` (contains `OPENAI_BASE_URL`, `OPENAI_API_KEY`, `OPENAI_MODEL`).
- **Embedding Models**: Local ONNX models (e.g. `Xenova/bge-base-en-v1.5`) under `models/`.

## 2. Server Lifecycle & Startup

### Health Check
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:6767/ || echo "offline"
```

### Clean Startup (Foreground / Background)
Always export the required environment variables prior to launching the binary:
```bash
cd /c/Users/mayan/.supermemory
export $(grep -v '^#' .env | xargs)
./bin/supermemory-server.exe
```

## 3. Querying & Ingesting via OpenAPI v4

### A. Semantic Search / Recall
Search across ingested memories and documents:
```bash
curl -s -X POST "http://localhost:6767/v4/search" \
  -H "Content-Type: application/json" \
  -d '{
    "q": "query string",
    "threshold": 0.5,
    "limit": 10,
    "containerTag": "TheHunter171",
    "searchMode": "memories"
  }'
```

### B. Retrieve Entity Profile
Fetch long-term static and recent dynamic profile memories:
```bash
curl -s -X POST "http://localhost:6767/v4/profile" \
  -H "Content-Type: application/json" \
  -d '{
    "containerTag": "TheHunter171"
  }'
```

### C. List Memories with Version History
```bash
curl -s -X POST "http://localhost:6767/v4/memories/list" \
  -H "Content-Type: application/json" \
  -d '{
    "containerTags": ["TheHunter171"],
    "limit": 20
  }'
```

### D. Ingest Documents or Notes
Add new plain text, notes, or structured information:
```bash
curl -s -X POST "http://localhost:6767/v3/documents" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Project notes, career updates, or architectural summaries...",
    "containerTag": "TheHunter171",
    "customId": "doc_id_or_title",
    "dreaming": "instant"
  }'
```

## 4. Common Pitfalls & Diagnostics

| Symptom | Root Cause | Fix |
| :--- | :--- | :--- |
| `Data directory ... is already in use by process <PID>` | A previous zombie server or crashed instance is holding the data lock | 1. Terminate old process: `taskkill /F /PID <PID>` (or `taskkill /F /IM supermemory-server.exe`).<br>2. Remove stale lock file: `rm -f ~/.supermemory/.supermemory/.instance.lock`. |
| `No model provider API key configured` | Binary launched without inheriting environment variables | Source `.env` before running: `export $(grep -v '^#' .env \| xargs) && ./bin/supermemory-server.exe`. |
| `{"error": "Unauthorized"}` on search | Bearer token mismatch or local security rule | Local Supermemory Lite runs unauthenticated on localhost; omit the `Authorization` header or verify matching API key. |
| Empty search results (`total: 0`) | Zero documents ingested or high similarity threshold | 1. Verify document count on dashboard (`http://localhost:6767/`).<br>2. Lower threshold to `0.0` or `0.2` when testing queries.<br>3. Check `containerTag` matches the ingested tag. |

## 5. Verification Checklist
1. `curl -I http://localhost:6767/` returns `HTTP/1.1 200 OK`.
2. Memory search `POST /v4/search` responds with valid JSON without authorization errors.
3. Server logs confirm local embedding worker initialized (`bge-base-en-v1.5`).
