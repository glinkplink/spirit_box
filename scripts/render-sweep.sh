#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ "$(uname -s)" != Darwin ]]; then
  echo 'The actual AVAudioEngine renderer requires macOS/Xcode; use the in-app final-mix capture on iPhone.' >&2
  exit 1
fi
mkdir -p "$ROOT/build/render-sweep"
xcrun swiftc -O -target "$(uname -m)-apple-macosx14.0" -module-name SpiritBoxRenderer -o "$ROOT/build/render-sweep/render-sweep" \
  "$ROOT"/ios/SweepEngine/*.swift "$ROOT/tools/render_sweep/main.swift"
exec "$ROOT/build/render-sweep/render-sweep" "$@"
