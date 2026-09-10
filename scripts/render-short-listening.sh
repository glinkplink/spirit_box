#!/usr/bin/env bash
# Unique-directory short listening render of the actual Swift/AVAudioEngine mixer.
# Does not overwrite prior results. Does not substitute a Python DSP renderer.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: scripts/render-short-listening.sh [options]

  --preset listening-test|archived-continuous-static   (default: listening-test)
  --rate 75|125|200|300                                (default: 300)
  --direction forward|reverse                          (default: forward)
  --seconds N                                          (default: 60)
  --seed N                                             (default: 12648430)
  --corpus PATH                                        (default: ios/Phase1)
  --also-baseline                                      also render archived-continuous-static
  --skip-acoustics                                     skip loudness/true-peak checker
  --help

Writes into build/listening-runs/<utc>-<preset>-<rate>ms-<direction>-<seconds>s/
EOF
}

PRESET="listening-test"
RATE="300"
DIRECTION="forward"
SECONDS_N="60"
SEED="12648430"
CORPUS="$ROOT/ios/Phase1"
ALSO_BASELINE=0
SKIP_ACOUSTICS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preset) PRESET="$2"; shift 2 ;;
    --rate) RATE="$2"; shift 2 ;;
    --direction) DIRECTION="$2"; shift 2 ;;
    --seconds) SECONDS_N="$2"; shift 2 ;;
    --seed) SEED="$2"; shift 2 ;;
    --corpus) CORPUS="$2"; shift 2 ;;
    --also-baseline) ALSO_BASELINE=1; shift ;;
    --skip-acoustics) SKIP_ACOUSTICS=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ "$(uname -s)" != Darwin ]]; then
  echo "FAIL: AVAudioEngine short renders require macOS/Xcode. This host is $(uname -s)." >&2
  echo "Use the harness Capture final mix (60 sec) on iPhone, or macOS CI." >&2
  exit 1
fi

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUNS="$ROOT/build/listening-runs"
mkdir -p "$RUNS"

render_one() {
  local preset="$1"
  local pointer="$2"
  local out="$RUNS/${STAMP}-${preset}-${RATE}ms-${DIRECTION}-${SECONDS_N}s"
  if [[ -e "$out" ]]; then
    echo "FAIL: refusing to overwrite $out" >&2
    return 1
  fi
  echo "Rendering preset=$preset rate=${RATE}ms direction=$DIRECTION seconds=$SECONDS_N seed=$SEED"
  echo "Output: $out"
  if ! "$ROOT/scripts/render-sweep.sh" "$CORPUS" "$out" "$SECONDS_N" "$RATE" "$DIRECTION" "$SEED" "$preset"; then
    echo "FAIL: render-sweep failed for $preset → $out" >&2
    return 1
  fi
  if ! python3 "$ROOT/tools/check_sweep_render.py" "$out" --manifest "$CORPUS/manifest.json"; then
    echo "FAIL: technical checks failed for $out" >&2
    return 1
  fi
  if [[ "$SKIP_ACOUSTICS" -eq 0 ]]; then
    if python3 -c 'import numpy' 2>/dev/null && command -v ffmpeg >/dev/null; then
      if ! python3 "$ROOT/tools/check_sweep_acoustics.py" "$out"; then
        echo "FAIL: acoustic checks failed for $out." >&2
        return 1
      fi
    else
      echo "FAIL: acoustic checks require numpy and ffmpeg; use --skip-acoustics only for explicit diagnostic renders." >&2
      return 1
    fi
  fi
  echo "WAV: $out/sweep.wav"
  echo "Events: $out/events.jsonl"
  echo "Settings/provenance: $out/engine-diagnostics.json"
  echo "Technical: $out/technical-checks.json"
  if [[ -f "$out/acoustic-checks.json" ]]; then
    echo "Acoustics: $out/acoustic-checks.json"
  fi
  printf '%s\n' "$out" > "$pointer"
}

"$ROOT/scripts/render-sweep.sh" --build-only

render_one "$PRESET" "$RUNS/latest-candidate.txt"
CANDIDATE_DIR="$(cat "$RUNS/latest-candidate.txt")"
BASELINE_DIR=""
if [[ "$ALSO_BASELINE" -eq 1 ]]; then
  if [[ "$PRESET" == "archived-continuous-static" ]]; then
    echo "WARN: --also-baseline ignored because --preset is already archived-continuous-static." >&2
  else
    render_one archived-continuous-static "$RUNS/latest-baseline.txt"
    BASELINE_DIR="$(cat "$RUNS/latest-baseline.txt")"
  fi
fi

echo
echo "Candidate ($PRESET): $CANDIDATE_DIR"
if [[ -n "$BASELINE_DIR" ]]; then
  echo "Baseline (archived-continuous-static): $BASELINE_DIR"
else
  echo "Controlled baseline: not rendered in this invocation. Do not treat an older live capture as a matched baseline."
fi
echo "Technical checks are not a listening verdict."
