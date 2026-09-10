#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ "$(uname -s)" != Darwin ]]; then
  echo 'The actual AVAudioEngine renderer requires macOS/Xcode; use the in-app final-mix capture on iPhone.' >&2
  exit 1
fi
mkdir -p "$ROOT/build/render-sweep"
BIN="$ROOT/build/render-sweep/render-sweep"
HASHFILE="$ROOT/build/render-sweep/source.sha256"
HASH="$(cat "$ROOT"/ios/SweepEngine/*.swift "$ROOT/tools/render_sweep/main.swift" | sha256sum | awk '{print $1}')"
if [[ ! -x "$BIN" || ! -f "$HASHFILE" || "$(cat "$HASHFILE")" != "$HASH" ]]; then
  xcrun swiftc -O -target "$(uname -m)-apple-macosx14.0" -module-name SpiritBoxRenderer -o "$BIN" \
    "$ROOT"/ios/SweepEngine/*.swift "$ROOT/tools/render_sweep/main.swift"
  printf '%s\n' "$HASH" > "$HASHFILE"
fi
if [[ "${1:-}" == "--build-only" ]]; then
  echo "Built $BIN"
  exit 0
fi
export SPIRIT_BOX_SOURCE_COMMIT="${SPIRIT_BOX_SOURCE_COMMIT:-$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo UNKNOWN)}"
if [[ -z "${SPIRIT_BOX_SOURCE_DIRTY:-}" ]]; then
  if [[ -n "$(git -C "$ROOT" status --porcelain 2>/dev/null || true)" ]]; then
    export SPIRIT_BOX_SOURCE_DIRTY=dirty
  elif git -C "$ROOT" rev-parse HEAD >/dev/null 2>&1; then
    export SPIRIT_BOX_SOURCE_DIRTY=clean
  else
    export SPIRIT_BOX_SOURCE_DIRTY=UNKNOWN
  fi
fi
exec "$BIN" "$@"
