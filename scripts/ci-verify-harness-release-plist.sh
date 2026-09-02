#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="${ROOT}/ios/SpiritBoxAudioHarness.xcodeproj"
SCHEME="SpiritBoxAudioHarness"
APP_TARGET="SpiritBoxAudioHarness"
CONFIGURATION="${1:-Release}"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild is not available in this environment."
  exit 1
fi

DERIVED_DATA="${RUNNER_TEMP:-/tmp}/SpiritBoxHarnessDerivedData"
rm -rf "${DERIVED_DATA}"

echo "Building ${SCHEME} (${CONFIGURATION}) to verify effective Info.plist file-sharing keys."
xcodebuild build \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "${DERIVED_DATA}" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY=- \
  >/dev/null

APP_PATH="${DERIVED_DATA}/Build/Products/${CONFIGURATION}-iphoneos/${APP_TARGET}.app"
if [[ ! -d "${APP_PATH}" ]]; then
  echo "::error::Built app bundle not found at ${APP_PATH}"
  find "${DERIVED_DATA}/Build/Products" -maxdepth 3 -type d -name '*.app' || true
  exit 1
fi

PLIST_PATH="${APP_PATH}/Info.plist"
if [[ ! -f "${PLIST_PATH}" ]]; then
  echo "::error::Info.plist missing from built app bundle: ${PLIST_PATH}"
  exit 1
fi

python3 - <<'PY' "${PLIST_PATH}"
import plistlib
import sys

path = sys.argv[1]
with open(path, "rb") as handle:
    plist = plistlib.load(handle)

required = {
    "UIFileSharingEnabled": True,
    "LSSupportsOpeningDocumentsInPlace": True,
}

missing = []
for key, expected in required.items():
    actual = plist.get(key)
    if actual is not expected:
        missing.append(f"{key}={actual!r} (expected {expected!r})")

if missing:
    print("::error::SpiritBoxAudioHarness Release Info.plist is missing required Files-app keys:")
    for item in missing:
        print(f"::error::  {item}")
    sys.exit(1)

print("Verified SpiritBoxAudioHarness Info.plist file-sharing keys:")
for key in required:
    print(f"  {key}=YES")
PY

echo "Info.plist verification passed for ${APP_PATH}"
