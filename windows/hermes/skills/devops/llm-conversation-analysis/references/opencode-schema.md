# OpenCode SQLite Schema Reference

Database Location: `~/.local/share/opencode/opencode.db` (Windows: `C:\Users\<user>\.local\share\opencode\opencode.db`)

## Core Tables

### `session`
| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT PK | e.g. `ses_f429b3d90ffexuN79F6eIdOHYN` |
| `project_id` | TEXT | e.g. `global` or repo specific |
| `workspace_id` | TEXT | Optional workspace identifier |
| `parent_id` | TEXT | Parent session if forked |
| `slug` | TEXT | Human-readable name e.g. `stellar-nebula` |
| `directory` | TEXT | Absolute working directory path |
| `path` | TEXT | Relative working directory path |
| `title` | TEXT | Auto-generated or user-assigned title |
| `version` | TEXT | OpenCode version (e.g. `1.18.31`) |
| `share_url` | TEXT | Remote share URL if published |
| `cost` | REAL | Total run cost |
| `tokens_input` | INTEGER | Input tokens used |
| `tokens_output` | INTEGER | Output tokens generated |
| `tokens_reasoning` | INTEGER | Reasoning tokens generated |
| `tokens_cache_read` | INTEGER | Cache read tokens |
| `tokens_cache_write` | INTEGER | Cache write tokens |
| `agent` | TEXT | Agent mode (e.g. `build`, `plan`) |
| `model` | TEXT | JSON string: `{"id": "...", "providerID": "..."}` |
| `time_created` | INTEGER | Epoch millisecond timestamp |
| `time_updated` | INTEGER | Epoch millisecond timestamp |
| `time_compacting` | INTEGER | Timestamp when compacted |
| `time_archived` | INTEGER | Timestamp when archived |

### `message`
| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT PK | e.g. `msg_0bd64c289001hfxtPm1WE4kKg9` |
| `session_id` | TEXT FK | References `session(id)` |
| `time_created` | INTEGER | Epoch millisecond timestamp |
| `time_updated` | INTEGER | Epoch millisecond timestamp |
| `data` | TEXT | JSON: `{"role": "user"|"assistant", ...}` |

### `part`
| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT PK | Part identifier |
| `message_id` | TEXT FK | References `message(id)` |
| `session_id` | TEXT FK | References `session(id)` |
| `time_created` | INTEGER | Epoch millisecond timestamp |
| `time_updated` | INTEGER | Epoch millisecond timestamp |
| `data` | TEXT | JSON: Contains `type`, content, tool params, tokens, etc. |

## Part Types in `part.data`
- `text`: Plain text output (`data.text`)
- `reasoning`: Chain-of-thought (`data.text`)
- `tool_use` / tool: Tool call parameters (`data.name`, `data.input`)
- `step-start`: Step initialization marker
- `step-finish`: Step completion (`data.reason`, `data.tokens`)
