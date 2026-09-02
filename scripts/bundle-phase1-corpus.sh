#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="${1:-${ROOT}/recordings/me_test.m4a}"
FAMILY="${2:-me_test}"
OUTPUT="${ROOT}/build/corpus/${FAMILY}"

if [[ ! -f "${SOURCE}" ]]; then
  echo "error: source recording not found: ${SOURCE}" >&2
  exit 1
fi

cd "${ROOT}"
PYTHONPATH=. python3 tools/prepare_corpus.py "${SOURCE}" --family "${FAMILY}" --output "${OUTPUT}"
cp -a "${OUTPUT}/SpiritBoxPhase1Corpus/." "${ROOT}/ios/Phase1/"
echo "Bundled $(find "${ROOT}/ios/Phase1" -name '*.wav' | wc -l) WAVs into ios/Phase1/"
