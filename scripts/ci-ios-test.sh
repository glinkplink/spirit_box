#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="${ROOT}/ios/SpiritBoxAudioHarness.xcodeproj"
SCHEME="SpiritBoxAudioHarness"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild is not available in this environment."
  exit 1
fi

echo "Xcode:"
xcodebuild -version

DESTINATION=""
DEST_ID=""

# Prefer simctl: xcodebuild -showdestinations can take ~60s on CI runners.
if DEST_ID="$(xcrun simctl list devices available -j | python3 -c '
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get("devices", {}).items():
    if "iOS" not in runtime:
        continue
    for device in devices:
        if device.get("isAvailable") and "iPhone" in device.get("name", ""):
            print(device["udid"])
            raise SystemExit
')"; then
  :
fi

if [[ -n "${DEST_ID}" ]]; then
  DESTINATION="platform=iOS Simulator,id=${DEST_ID}"
  echo "Resolved simulator via simctl: ${DESTINATION}"
fi

if [[ -z "${DESTINATION}" ]]; then
  echo "simctl did not find an available iPhone simulator; falling back to xcodebuild -showdestinations."
  if DEST_LINE="$(xcodebuild -project "${PROJECT}" -scheme "${SCHEME}" -showdestinations 2>/dev/null | grep 'platform:iOS Simulator' | grep 'name:iPhone' | head -n 1)"; then
    DEST_ID="$(printf '%s\n' "${DEST_LINE}" | sed -n 's/.*id:\([^,}]*\).*/\1/p' | tr -d ' ')"
    if [[ -n "${DEST_ID}" ]]; then
      DESTINATION="platform=iOS Simulator,id=${DEST_ID}"
      echo "Resolved simulator via xcodebuild: ${DESTINATION}"
    fi
  fi
fi

if [[ -z "${DESTINATION}" ]]; then
  echo "No iPhone simulator destination was found."
  echo "=== simctl devices (available) ==="
  xcrun simctl list devices available
  echo "=== xcodebuild destinations ==="
  xcodebuild -project "${PROJECT}" -scheme "${SCHEME}" -showdestinations || true
  exit 1
fi

echo "Using destination: ${DESTINATION}"

SOURCE_COMMIT="${SPIRIT_BOX_SOURCE_COMMIT:-}"
if [[ -z "${SOURCE_COMMIT}" ]]; then
  SOURCE_COMMIT="$(git -C "${ROOT}" rev-parse HEAD 2>/dev/null || echo UNKNOWN)"
fi
SOURCE_DIRTY="${SPIRIT_BOX_SOURCE_DIRTY:-}"
if [[ -z "${SOURCE_DIRTY}" ]]; then
  if [[ -n "$(git -C "${ROOT}" status --porcelain 2>/dev/null || true)" ]]; then
    SOURCE_DIRTY=dirty
  elif git -C "${ROOT}" rev-parse HEAD >/dev/null 2>&1; then
    SOURCE_DIRTY=clean
  else
    SOURCE_DIRTY=UNKNOWN
  fi
fi
echo "SPIRIT_BOX_SOURCE_COMMIT=${SOURCE_COMMIT}"
echo "SPIRIT_BOX_SOURCE_DIRTY=${SOURCE_DIRTY}"

xcodebuild test \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -destination "${DESTINATION}" \
  -skipPackagePluginValidation \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY=- \
  SPIRIT_BOX_SOURCE_COMMIT="${SOURCE_COMMIT}" \
  SPIRIT_BOX_SOURCE_DIRTY="${SOURCE_DIRTY}"
