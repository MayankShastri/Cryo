# Discord File Batching — Compressed-Size-Aware Pattern

## Context
Discord's bot API enforces a hard **8 MB per-file limit** on non-boosted servers (`HTTP 413, error code: 40005`).
PNGs and screenshots are already compressed; ZIP deflate gives < 5% reduction.
**You cannot estimate zip output size from uncompressed file sizes** — always measure actual compressed bytes.

## Diagnosis
```bash
hermes logs --since 10m | grep -i -E "attach|413|deliver"
# Look for: "413 Payload Too Large (error code: 40005): Request entity too large"
```

## Correct Batching Pattern
Compress each file individually into a `BytesIO` buffer to get its real compressed size,
accumulate the running total, and flush to a new zip before the limit is breached.
Target **7.5 MB** per zip (safe buffer below the 8 MB cap).

```python
import io, os, zipfile
from pathlib import Path

def build_discord_zips(files: list[Path], output_dir: Path, prefix: str = "batch", limit_mb: float = 7.5) -> list[Path]:
    """
    Pack `files` into ≤limit_mb zips, measuring actual compressed size per file.
    Returns list of created zip paths.
    """
    LIMIT = int(limit_mb * 1024 * 1024)
    output_dir.mkdir(parents=True, exist_ok=True)

    zip_files = []
    batch_num = 1
    current_files = []
    current_compressed = 0

    def _flush(batch, num):
        out = output_dir / f"{prefix}_{num:02d}.zip"
        with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as zf:
            for f in batch:
                zf.write(f, arcname=f.name)
        print(f"{out.name}: {out.stat().st_size / (1024*1024):.2f} MB ({len(batch)} files)")
        return out

    zf_path, zf = output_dir / f"{prefix}_{batch_num:02d}.zip", None
    current_files, current_compressed = [], 0

    for f in files:
        # Measure this file's compressed footprint
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED) as tmp:
            tmp.write(f, arcname=f.name)
        compressed_size = buf.tell()

        if current_files and (current_compressed + compressed_size > LIMIT):
            zip_files.append(_flush(current_files, batch_num))
            batch_num += 1
            current_files, current_compressed = [], 0

        current_files.append(f)
        current_compressed += compressed_size

    if current_files:
        zip_files.append(_flush(current_files, batch_num))

    return zip_files


# Usage: batch the 100 newest screenshots
screenshot_dir = Path(r"C:\Users\mayan\Pictures\Screenshots")
temp_dir = Path(r"C:\Users\mayan\AppData\Local\hermes\temp_zips")

all_files = sorted(
    [f for f in screenshot_dir.iterdir() if f.suffix.lower() in ('.png', '.jpg', '.jpeg', '.webp')],
    key=lambda x: x.stat().st_mtime, reverse=True
)[:100]

zips = build_discord_zips(all_files, temp_dir, prefix="ss")
print(f"Created {len(zips)} zip files, all ≤7.5 MB")
```

## Notes
- Sending multiple large files in a single message can cause gateway timeouts even if each file is under 8 MB. Send files one at a time or in small batches (e.g., 1 per message) if issues persist.
- The `hermes logs` 413 error appears as `Failed to send document, falling back to base adapter` followed by the HTTPException traceback.
- Boosted servers raise the cap: Level 2 → 50 MB, Level 3 → 100 MB. Adjust `limit_mb` accordingly if the server gets boosted.
