---
name: llm-conversation-analysis
description: Analyze LLM conversation databases (OpenCode, Hermes, etc.) to extract structured knowledge — quiz solutions, debugging transcripts, decision trails, code evolution. Covers SQLite schema inspection, message/part parsing, session filtering, and export to study guides or documentation.
category: devops
tags:
  - opencode
  - hermes
  - sqlite
  - conversation-history
  - knowledge-extraction
  - academic-quizzes
---

# LLM Conversation Analysis

Analyze local LLM conversation databases to extract structured knowledge: quiz answers, debugging sessions, architectural decisions, code evolution traces.

## When to Use

- Extract quiz/exam solutions from study sessions with an LLM
- Reconstruct debugging trails from past conversations
- Audit what decisions were made and why in a coding session
- Export conversation history to Markdown/Notion/Obsidian
- Find "what was the final answer to X?" across many sessions

## Supported Tools

| Tool | Database Location | Key Tables |
|------|-------------------|------------|
| **OpenCode** | `~/.local/share/opencode/opencode.db` | `session`, `message`, `part` |
| **Hermes** | `~/.config/hermes/profiles/<name>/sessions.db` | `messages`, `sessions` |

## OpenCode Schema (v1.18+)

```sql
session (id, project_id, workspace_id, parent_id, slug, directory, path, title, version, share_url, metadata, cost, tokens_*, agent, model, time_created, time_updated, time_compacting, time_archived)

message (id, session_id, time_created, time_updated, data)  -- JSON: {role, type, ...}

part (id, message_id, session_id, time_created, time_updated, data)  -- JSON: {type: 'text'|'tool'|'reasoning'|'step-start'|'step-finish', text, name, input, ...}
```

## Core Workflow

### 1. Discover Sessions
```python
# Find sessions by directory, title, or recency
SELECT id, title, directory, slug, time_updated
FROM session
WHERE directory LIKE '%Coursera%'
ORDER BY time_updated DESC;
```

### 2. Reconstruct Conversation
```python
# Messages in chronological order
SELECT m.id, m.time_created, m.data
FROM message m
WHERE m.session_id = ?
ORDER BY m.time_created ASC;

# Parts for each message
SELECT p.id, p.data
FROM part p
WHERE p.message_id = ?
ORDER BY p.time_created ASC;
```

### 3. Parse Part Types
| Part Type | Meaning | Extract |
|-----------|---------|---------|
| `text` | Assistant/user message | `data.text` |
| `reasoning` | Model's hidden reasoning | `data.text` |
| `tool` / `tool_use` | Tool invocation | `data.name`, `data.input` |
| `step-start` / `step-finish` | Agent step boundaries | `data.reason`, `data.tokens` |

### 4. Filter for Final Answers
- Look for `step-finish` with `reason: 'stop'` (not `tool-calls`)
- The preceding `text` part usually contains the final answer
- Cross-reference with user "try again" / "that was wrong" messages to identify corrected answers

### 5. Export to Markdown
Structure by week/module/topic with:
- Question text (from user messages)
- Final answer (from assistant's last `text` part before `step-finish: stop`)
- Reasoning (optional, from `reasoning` parts)
- Verification status (corrected/verified)

## Headless CLI Interaction (Running Prompts in Existing Sessions)

You can programmatically feed new questions, prompts, or follow-ups into existing OpenCode sessions or continue the active session using the `opencode run` CLI tool without launching the full interactive TUI.

### Key CLI Commands
```bash
# Continue the most recent session with a new prompt
opencode run -c "Your question or prompt here"

# Continue a specific session by ID in a specific working directory
opencode run -s "ses_f429b3d90ffexuN79F6eIdOHYN" "Your question here" --dir "/path/to/project"

# Run non-interactively with auto-approvals for tool calls
opencode run -s "<session_id>" --auto "Run this script and verify output"
```

### Tips for Agent-to-OpenCode Interop
- **Preserve Directory Context**: Always specify the project directory (`--dir` or run from working directory) so OpenCode's tools (grep, bash, file read) resolve relative paths properly.
- **Session Continuity**: Using `-s <session_id>` appends the new message and resulting tool calls directly into the session history in `opencode.db`, keeping full context.
- **Timeout Management**: In terminal/script executions, set a generous timeout (e.g. 120s) to allow OpenCode's backend agent loop to finish multi-step reasoning and tool execution.

## Pitfalls

- **Massive databases**: OpenCode DB can be 2GB+. Use `LIMIT` and indexed columns (`session_id`, `time_created`).
- **JSON in `data` columns**: Always `json.loads()` — never string-search.
- **Truncated output**: `execute_code` truncates at ~50KB. Process in chunks or write to file directly.
- **Session compaction**: Old messages may be summarized. Check `time_compacting` and `summary_*` columns.
- **Multiple projects**: Filter by `directory` or `project_id` to isolate relevant sessions.

## Example: Quiz Solution Extractor

```python
import sqlite3, json, re
from datetime import datetime

DB = r"C:\Users\mayan\.local\share\opencode\opencode.db"

def extract_quiz_solutions(session_id, output_path):
    conn = sqlite3.connect(DB)
    cur = conn.cursor()
    
    # Get all messages with parts
    cur.execute("""
        SELECT m.id, m.time_created, m.data, p.data as part_data, p.type as part_type
        FROM message m
        LEFT JOIN part p ON p.message_id = m.id
        WHERE m.session_id = ?
        ORDER BY m.time_created, p.time_created
    """, (session_id,))
    
    # Group by message, identify final answers
    # (implementation continues...)
    
    conn.close()
```

## References

- `references/opencode-schema.md` — Full schema with column descriptions
- `references/opencode-part-types.md` — Part type reference with examples
- `references/quiz-verification-workflow.md` — Workflow for modeling and verifying technical quiz answers with Python
- `templates/quiz-solution-extractor.py` — Reusable extractor script