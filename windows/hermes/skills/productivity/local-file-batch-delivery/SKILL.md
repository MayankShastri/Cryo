---
name: local-file-batch-delivery
description: Retrieve, sort, and package local files into Discord-safe ZIP batches and deliver them via MEDIA links.
---

# Local File Batch Delivery

Use when the user asks to send a set of local files — screenshots, exports, logs, images — via Discord (or any platform with upload-size limits). Covers finding the files, sorting by recency, packaging, and delivering.

## Trigger conditions
- "Send me the last N screenshots"
- "Zip and send [folder contents]"
- "Send [files] in batches" (implicit: platform has size limits)

## Key Facts
- Discord standard upload limit is **25 MB per file** (without Nitro). Target **22 MB per ZIP** for safety headroom.
- Windows Screenshots folder: `C:\Users\mayan\Pictures\Screenshots\`
  It may also contain an `ALL SCREENSHOTS\` subfolder — target the parent for the numbered `Screenshot (NNNN).png` files.
- Always sort by **modification time (newest first)** to get the truly latest files, not alphabetical/numerical order.
- Use `find . -maxdepth 1 -name "*.png" -printf '%T@ %f\n' | sort -rn | head -N` in bash, or Python `Path.stat().st_mtime`.
- PNG screenshots are already compressed; ZIP_DEFLATED saves little. Compress anyway for grouping convenience.
- Deliver via `MEDIA:/absolute/windows/path/to/file.zip` in the response — one MEDIA line per zip.

## Procedure

### 1. Locate the screenshots folder
```bash
ls '/c/Users/mayan/Pictures/Screenshots/'
```

### 2. Get the N most-recently-modified files (Python — preferred)
```python
from pathlib import Path
d = Path(r"C:\Users\mayan\Pictures\Screenshots")
files = sorted(d.glob("*.png"), key=lambda f: f.stat().st_mtime, reverse=True)[:100]
```

### 3. Measure and batch (target 22 MB uncompressed per batch)
```python
MAX = 22 * 1024 * 1024
batches, current, cur_size = [], [], 0
for f in files:
    sz = f.stat().st_size
    if current and cur_size + sz > MAX:
        batches.append(current); current = []; cur_size = 0
    current.append(f); cur_size += sz
if current:
    batches.append(current)
```

### 4. Write ZIP files to temp directory
```python
import zipfile
from pathlib import Path

out = Path(r"C:\Users\mayan\AppData\Local\hermes\temp_zips")
out.mkdir(parents=True, exist_ok=True)
# Clear old zips first
for old in out.glob("*.zip"):
    old.unlink()

zip_paths = []
for i, batch in enumerate(batches, 1):
    zp = out / f"screenshots_batch_{i}.zip"
    with zipfile.ZipFile(zp, 'w', zipfile.ZIP_DEFLATED) as zf:
        for f in batch:
            zf.write(f, arcname=f.name)
    zip_paths.append(zp)
```

### 5. Deliver
In your response, one MEDIA line per ZIP:
```
MEDIA:C:\Users\mayan\AppData\Local\hermes\temp_zips\screenshots_batch_1.zip
MEDIA:C:\Users\mayan\AppData\Local\hermes\temp_zips\screenshots_batch_2.zip
```

## Pitfalls

- **Wrong path assumption** — The Screenshots folder is at `C:\Users\mayan\Pictures\Screenshots`, NOT `C:\Users\mayan\Screenshots`. Always verify before `cd`-ing.
- **POSIX paths create unusable MEDIA links** — Use Windows-style paths (`r"C:\Users\..."`) in Python when creating files that must be referenced via `MEDIA:`. POSIX `/c/Users/...` paths work for reads but the MEDIA tag needs native Windows paths.
- **Alphabetical sort != recency** — `Screenshot (4864).png` sorts before `Screenshot (999).png` lexicographically in some locales. Always sort by `st_mtime`, not name.
- **Don't hard-code filenames** — always derive the list fresh via mtime sort.
- **Stale zips** — clear the temp dir at the start of each run to avoid delivering old batches.
- **Volume warning** — 100 PNG screenshots can total 200+ MB. At 22 MB per batch that is ~10 ZIPs. Normal.
