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
if DEST_LINE="$(xcodebuild -project "${PROJECT}" -scheme "${SCHEME}" -showdestinations 2>/dev/null | grep 'platform:iOS Simulator' | grep 'name:iPhone' | head -n 1)"; then
  DEST_ID="$(printf '%s\n' "${DEST_LINE}" | sed -n 's/.*id:\([^,}]*\).*/\1/p' | tr -d ' ')"
  if [[ -n "${DEST_ID}" ]]; then
    DESTINATION="platform=iOS Simulator,id=${DEST_ID}"
  fi
fi

if [[ -z "${DESTINATION}" ]]; then
  DEST_ID="$(xcrun simctl list devices available -j | python3 -c '
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get("devices", {}).items():
    if "iOS" not in runtime:
        continue
    for device in devices:
        if device.get("isAvailable") and "iPhone" in device.get("name", ""):
            print(device["udid"])
            raise SystemExit
')"
  if [[ -n "${DEST_ID}" ]]; then
    DESTINATION="platform=iOS Simulator,id=${DEST_ID}"
  fi
fi

if [[ -z "${DESTINATION}" ]]; then
  echo "No iPhone simulator destination was found."
  xcrun simctl list devices available
  exit 1
fi

echo "Using destination: ${DESTINATION}"

xcodebuild test \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -destination "${DESTINATION}" \
  -skipPackagePluginValidation \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY=-
