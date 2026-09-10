#!/usr/bin/env bash
# Build tools/fixtures/archived-pcm-regression/ from a 30s archived-continuous-static render.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: scripts/capture-archived-pcm-fixture.sh --from <render-dir>

  --from   30s / 300ms / forward / archived-continuous-static render directory
EOF
}

FROM=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$FROM" ]]; then
  echo "FAIL: --from is required." >&2
  exit 2
fi

SRC="$(cd "$FROM" && pwd)"
DEST="$ROOT/tools/fixtures/archived-pcm-regression"
mkdir -p "$DEST"

for file in sweep.wav events.jsonl engine-diagnostics.json; do
  if [[ ! -f "$SRC/$file" ]]; then
    echo "FAIL: missing $SRC/$file" >&2
    exit 1
  fi
done

cp "$SRC/events.jsonl" "$DEST/events-prefix.jsonl"

python3 - "$SRC" "$DEST" "$ROOT" <<'PY'
import hashlib
import json
import subprocess
import sys
import wave
from pathlib import Path

src, dest, root = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
engine = json.loads((src / "engine-diagnostics.json").read_text())
settings = engine.get("renderer_settings") or engine.get("settings") or {}
duration = float(engine.get("duration_seconds") or 30)

with wave.open(str(src / "sweep.wav"), "rb") as wav:
    assert wav.getnchannels() == 1 and wav.getsampwidth() == 2
    rate = wav.getframerate()
    frames = min(wav.getnframes(), int(duration * rate))
    pcm = wav.readframes(frames)

(dest / "pcm-prefix.sha256").write_text(hashlib.sha256(pcm).hexdigest() + "\n")

def git_sha(path: Path) -> str:
    try:
        return subprocess.check_output(["git", "-C", str(path), "rev-parse", "HEAD"], text=True).strip()
    except subprocess.CalledProcessError:
        return "UNKNOWN"

def git_dirty(path: Path) -> str:
    try:
        out = subprocess.check_output(["git", "-C", str(path), "status", "--porcelain"], text=True)
        return "dirty" if out.strip() else "clean"
    except subprocess.CalledProcessError:
        return "UNKNOWN"

manifest_path = root / "ios" / "Phase1" / "manifest.json"
renderer_hash = hashlib.sha256(
    b"".join(p.read_bytes() for p in sorted((root / "ios" / "SweepEngine").glob("*.swift")))
).hexdigest()

manifest = {
    "fixture_name": "archived-pcm-regression",
    "generating_commit": engine.get("source_commit") or git_sha(root),
    "source_dirty": engine.get("source_dirty") or git_dirty(root),
    "preset_identifier": settings.get("preset_identifier", "archived-continuous-static"),
    "preset_version": settings.get("preset_version"),
    "seed": engine.get("seed"),
    "rate_ms": engine.get("sweep_rate_ms", 300),
    "direction": engine.get("direction", "forward"),
    "duration_seconds": duration,
    "corpus_manifest_sha256": hashlib.sha256(manifest_path.read_bytes()).hexdigest(),
    "renderer_source_sha256": renderer_hash,
    "pcm_prefix_sha256": (dest / "pcm-prefix.sha256").read_text().strip(),
    "event_line_count": len((dest / "events-prefix.jsonl").read_text().splitlines()),
}
(dest / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
print(json.dumps(manifest, indent=2))
PY

echo "Captured archived PCM regression fixture: $DEST"
