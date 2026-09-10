#!/usr/bin/env bash
set -euo pipefail
# 60-second listening tests at the two most useful sweep rates.
# Requires macOS/Xcode. Linux cannot run AVAudioEngine; use the iPhone harness
# Capture final mix (60 sec) at 300 ms then 200 ms instead.
# Prefer scripts/render-short-listening.sh for unique run directories and provenance.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SEED="${1:-12648430}"
"$ROOT/scripts/render-sweep.sh" "$ROOT/ios/Phase1" "$ROOT/build/listening-60s-300ms" 60 300 forward "$SEED"
python3 "$ROOT/tools/check_sweep_render.py" "$ROOT/build/listening-60s-300ms"
"$ROOT/scripts/render-sweep.sh" "$ROOT/ios/Phase1" "$ROOT/build/listening-60s-200ms" 60 200 forward "$SEED"
python3 "$ROOT/tools/check_sweep_render.py" "$ROOT/build/listening-60s-200ms"
echo "Wrote $ROOT/build/listening-60s-300ms/sweep.wav"
echo "Wrote $ROOT/build/listening-60s-200ms/sweep.wav"
echo "Technical checks are not a listening verdict."
