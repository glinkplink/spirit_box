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
  python3 "$ROOT/tools/check_sweep_acoustics.py" "$dir"
}

echo "=== Pre-rebalance gain A/B fixture ==="
PRE="$BUILD/pre-rebalance"
render_and_check "$PRE" 60 300 forward "$SEED" listening-test-pre-rebalance
"$ROOT/scripts/capture-listening-fixture.sh" --name listening-test-pre-rebalance-gain-ab --from "$PRE"

echo "=== Pass A final (gain-rebalance only) fixture ==="
PASS_A="$BUILD/pass-a-final"
render_and_check "$PASS_A" 60 300 forward "$SEED" listening-test-gain-rebalance
"$ROOT/scripts/capture-listening-fixture.sh" --name listening-test-pass-a-final --from "$PASS_A"

echo "=== Archived PCM regression fixture ==="
ARCHIVED="$BUILD/archived-30s"
render_and_check "$ARCHIVED" 30 300 forward "$SEED" archived-continuous-static
"$ROOT/scripts/capture-archived-pcm-fixture.sh" --from "$ARCHIVED"

echo "=== Current listening-test candidate (Pass B) ==="
CANDIDATE="$BUILD/listening-test-60s"
render_and_check "$CANDIDATE" 60 300 forward "$SEED" listening-test
cp -a "$CANDIDATE" "$ROOT/build/listening-60s-300ms"
mkdir -p "$ROOT/build/evaluation-matrix-bootstrap"
"$ROOT/scripts/render-evaluation-matrix.sh" --preset listening-test --seed "$SEED" \
  --output-dir "$ROOT/build/evaluation-matrix-bootstrap/listening-test"

echo "Fixtures captured under tools/fixtures/ and build/"
