from __future__ import annotations

import sys
from pathlib import Path

MEDIA_EXTENSIONS = {".mp4", ".mkv", ".webm", ".mov", ".wav", ".m4a", ".mp3", ".opus"}


def discover_reference_files(directory: Path) -> list[Path]:
    directory = Path(directory)
    if not directory.is_dir():
        print(f"reference directory missing: {directory}", file=sys.stderr)
        raise SystemExit(2)
    found = []
    for path in sorted(directory.iterdir(), key=lambda p: p.name.lower()):
        if path.name.startswith("."):
            continue
        if not path.is_file():
            continue
        if path.suffix.lower() not in MEDIA_EXTENSIONS:
            continue
        found.append(path)
    if len(found) != 2:
        print("expected exactly two reference media files, found:", file=sys.stderr)
        for path in found:
            print(f"  {path.name}", file=sys.stderr)
        if not found:
            print("  (none)", file=sys.stderr)
        raise SystemExit(2)
    return found
