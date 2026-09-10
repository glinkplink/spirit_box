#!/usr/bin/env bash
# Copy a completed render directory into a versioned tools/fixtures bundle.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: scripts/capture-listening-fixture.sh --name <fixture-name> --from <render-dir>

  --name   Fixture directory under tools/fixtures/ (e.g. listening-test-pre-rebalance-gain-ab)
  --from   Completed render output (sweep.wav, events.jsonl, engine-diagnostics.json, …)

Requires acoustic-checks.json in the source dir (run check_sweep_acoustics.py first).
EOF
}

NAME=""
FROM=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --from) FROM="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$NAME" || -z "$FROM" ]]; then
  echo "FAIL: --name and --from are required." >&2
  usage >&2
  exit 2
fi

SRC="$(cd "$FROM" && pwd)"
DEST="$ROOT/tools/fixtures/$NAME"
mkdir -p "$DEST"

for file in sweep.wav events.jsonl engine-diagnostics.json technical-checks.json acoustic-checks.json; do
  if [[ ! -f "$SRC/$file" ]]; then
    echo "FAIL: missing $SRC/$file" >&2
    exit 1
  fi
  cp "$SRC/$file" "$DEST/$file"
done

python3 - "$DEST" "$SRC" "$ROOT" <<'PY'
import hashlib
import json
import subprocess
import sys
from pathlib import Path

dest, src, root = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
engine = json.loads((src / "engine-diagnostics.json").read_text())
settings = engine.get("renderer_settings") or engine.get("settings") or {}
manifest_path = root / "ios" / "Phase1" / "manifest.json"
corpus_manifest_sha256 = hashlib.sha256(manifest_path.read_bytes()).hexdigest() if manifest_path.is_file() else "UNKNOWN"

def file_sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def git_sha(path: Path) -> str:
    try:
        return subprocess.check_output(
            ["git", "-C", str(path), "rev-parse", "HEAD"], text=True
        ).strip()
    except subprocess.CalledProcessError:
        return "UNKNOWN"

def git_dirty(path: Path) -> str:
    try:
        out = subprocess.check_output(["git", "-C", str(path), "status", "--porcelain"], text=True)
        return "dirty" if out.strip() else "clean"
    except subprocess.CalledProcessError:
        return "UNKNOWN"

fixture_manifest = {
    "fixture_name": dest.name,
    "generating_commit": engine.get("source_commit") or git_sha(root),
    "source_dirty": engine.get("source_dirty") or git_dirty(root),
    "preset_identifier": settings.get("preset_identifier"),
    "preset_version": settings.get("preset_version"),
    "seed": engine.get("seed"),
    "rate_ms": engine.get("sweep_rate_ms"),
    "direction": engine.get("direction"),
    "duration_seconds": engine.get("duration_seconds"),
    "corpus_manifest_sha256": corpus_manifest_sha256,
    "checker_acoustics_sha256": file_sha256(root / "tools" / "check_sweep_acoustics.py"),
    "checker_render_sha256": file_sha256(root / "tools" / "check_sweep_render.py"),
    "sweep_wav_sha256": file_sha256(dest / "sweep.wav"),
}
(dest / "manifest.json").write_text(json.dumps(fixture_manifest, indent=2) + "\n")
(dest / "settings-snapshot.json").write_text(json.dumps(settings, indent=2) + "\n")
print(json.dumps(fixture_manifest, indent=2))
PY

echo "Captured fixture: $DEST"
