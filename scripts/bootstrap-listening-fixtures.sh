#!/usr/bin/env bash
# Render and capture all listening fixtures required by the mix-rebalance plan.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SEED="12648430"
CORPUS="$ROOT/ios/Phase1"
BUILD="$ROOT/build/fixture-capture"
mkdir -p "$BUILD"

if ! python3 -c 'import numpy' 2>/dev/null; then
  python3 -m venv "$BUILD/acoustic-venv"
  "$BUILD/acoustic-venv/bin/pip" install numpy
  export PATH="$BUILD/acoustic-venv/bin:$PATH"
fi
command -v ffmpeg >/dev/null || { echo "FAIL: ffmpeg required for acoustic checks." >&2; exit 1; }

if [[ "$(uname -s)" != Darwin ]]; then
  echo "FAIL: fixture capture requires macOS/Xcode." >&2
  exit 1
fi

render_and_check() {
  local dir="$1"
  shift
  "$ROOT/scripts/render-sweep.sh" "$CORPUS" "$dir" "$@"
  python3 "$ROOT/tools/check_sweep_render.py" "$dir" --manifest "$CORPUS/manifest.json"
  if ! python3 "$ROOT/tools/check_sweep_acoustics.py" "$dir"; then
    echo "WARN: acoustic checks failed for $dir (metrics still written)." >&2
  fi
}

echo "=== Pre-rebalance A0 fixture ==="
PRE="$BUILD/pre-rebalance"
render_and_check "$PRE" 60 300 forward "$SEED" listening-test-pre-rebalance
"$ROOT/scripts/capture-listening-fixture.sh" --name listening-test-pre-rebalance-gain-ab --from "$PRE"

echo "Fixtures captured under tools/fixtures/"
