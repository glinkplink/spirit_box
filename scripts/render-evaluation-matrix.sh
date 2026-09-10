#!/usr/bin/env bash
# Render the canonical evaluation matrix and hard-fail on any technical/acoustic gate miss.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: scripts/render-evaluation-matrix.sh [options]

  --preset listening-test|archived-continuous-static   (default: listening-test)
  --seed N                                             (default: 12648430)
  --corpus PATH                                        (default: ios/Phase1)
  --output-dir PATH                                    (default: build/evaluation-matrix/<utc>-<preset>)
  --help

Matrix cells (all mandatory):
  300ms forward 60s | 300ms reverse 30s | 200ms forward 60s | 125ms forward 30s | 75ms forward 30s
EOF
}

PRESET="listening-test"
SEED="12648430"
CORPUS="$ROOT/ios/Phase1"
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preset) PRESET="$2"; shift 2 ;;
    --seed) SEED="$2"; shift 2 ;;
    --corpus) CORPUS="$2"; shift 2 ;;
    --output-dir) OUTPUT="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ "$(uname -s)" != Darwin ]]; then
  echo "FAIL: AVAudioEngine matrix renders require macOS/Xcode. This host is $(uname -s)." >&2
  exit 1
fi

if ! python3 -c 'import numpy' 2>/dev/null; then
  VENV="$ROOT/build/acoustic-venv"
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install numpy
  export PATH="$VENV/bin:$PATH"
fi
command -v ffmpeg >/dev/null || { echo "FAIL: ffmpeg required for acoustic checks." >&2; exit 1; }

if [[ -z "$OUTPUT" ]]; then
  STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
  OUTPUT="$ROOT/build/evaluation-matrix/${STAMP}-${PRESET}"
fi
if [[ -e "$OUTPUT" ]]; then
  echo "FAIL: refusing to overwrite matrix evidence: $OUTPUT" >&2
  exit 1
fi
mkdir -p "$OUTPUT"

"$ROOT/scripts/render-sweep.sh" --build-only

declare -a CELLS=(
  "300:forward:60"
  "300:reverse:30"
  "200:forward:60"
  "125:forward:30"
  "75:forward:30"
)

SUMMARY="$OUTPUT/matrix-checks.json"
python3 - "$SUMMARY" "$PRESET" "$SEED" <<'PY'
import json, sys
from pathlib import Path
summary = {"preset": sys.argv[2], "seed": int(sys.argv[3]), "cells": {}, "matrix_checks": "PENDING"}
Path(sys.argv[1]).write_text(json.dumps(summary, indent=2) + "\n")
PY

FAILED=0
for cell in "${CELLS[@]}"; do
  IFS=: read -r RATE DIRECTION DURATION_SECONDS <<<"$cell"
  CELL_DIR="$OUTPUT/${RATE}ms-${DIRECTION}-${DURATION_SECONDS}s"
  echo "=== Matrix cell: ${RATE}ms ${DIRECTION} ${DURATION_SECONDS}s ==="
  if ! "$ROOT/scripts/render-sweep.sh" "$CORPUS" "$CELL_DIR" "$DURATION_SECONDS" "$RATE" "$DIRECTION" "$SEED" "$PRESET"; then
    echo "FAIL: render failed for $CELL_DIR" >&2
    FAILED=1
    RENDER=FAIL
  else
    RENDER=PASS
  fi
  TECH=NOT_RUN
  ACOUSTIC=NOT_RUN
  if [[ "$RENDER" == PASS ]]; then
  TECH=PASS
  ACOUSTIC=PASS
  if ! python3 "$ROOT/tools/check_sweep_render.py" "$CELL_DIR" --manifest "$CORPUS/manifest.json"; then
    TECH=FAIL
    FAILED=1
  fi
  if ! python3 "$ROOT/tools/check_sweep_acoustics.py" "$CELL_DIR"; then
    ACOUSTIC=FAIL
    FAILED=1
  fi
  fi
  python3 - "$SUMMARY" "$cell" "$CELL_DIR" "$TECH" "$ACOUSTIC" "$RENDER" <<'PY'
import json, sys
from pathlib import Path
summary_path, cell, cell_dir, tech, acoustic, render = sys.argv[1:7]
summary = json.loads(Path(summary_path).read_text())
acoustic_report = {}
acoustic_path = Path(cell_dir) / "acoustic-checks.json"
if acoustic_path.is_file():
    acoustic_report = json.loads(acoustic_path.read_text())
summary["cells"][cell] = {
    "directory": cell_dir,
    "render": render,
    "technical_checks": tech,
    "acoustic_checks": acoustic,
    "vocal_slot_minus_noise_slot_db": acoustic_report.get("vocal_slot_minus_noise_slot_db"),
    "loudness_range_lu": acoustic_report.get("loudness_range_lu"),
    "integrated_lufs": acoustic_report.get("integrated_lufs"),
}
Path(summary_path).write_text(json.dumps(summary, indent=2) + "\n")
PY
done

python3 - "$SUMMARY" "$FAILED" <<'PY'
import json, sys
from pathlib import Path
summary = json.loads(Path(sys.argv[1]).read_text())
summary["matrix_checks"] = "PASS" if int(sys.argv[2]) == 0 else "FAIL"
Path(sys.argv[1]).write_text(json.dumps(summary, indent=2) + "\n")
PY

echo "Matrix output: $OUTPUT"
echo "Summary: $SUMMARY"
if [[ "$FAILED" -ne 0 ]]; then
  echo "FAIL: one or more matrix cells failed." >&2
  exit 1
fi
echo "Matrix checks: PASS"
