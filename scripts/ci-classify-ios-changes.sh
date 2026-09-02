#!/usr/bin/env bash
# Classify whether changed files can affect the iOS app build or test suite.
# Emits ios_relevant=true|false to GITHUB_OUTPUT when set.
set -euo pipefail

EVENT_NAME="${GITHUB_EVENT_NAME:-}"
BASE_SHA="${BASE_SHA:-}"
HEAD_SHA="${HEAD_SHA:-}"

if [[ -z "${HEAD_SHA}" ]]; then
  echo "HEAD_SHA is required."
  exit 1
fi

resolve_changed_files() {
  if [[ "${EVENT_NAME}" == "pull_request" ]]; then
    if [[ -z "${BASE_SHA}" ]]; then
      echo "BASE_SHA is required for pull_request events."
      exit 1
    fi
    git diff --name-only "${BASE_SHA}" "${HEAD_SHA}"
    return
  fi

  if [[ "${EVENT_NAME}" == "push" ]]; then
    if [[ -z "${BASE_SHA}" || "${BASE_SHA}" == "0000000000000000000000000000000000000000" ]]; then
      # First push or unavailable parent: treat the pushed commit as the change set.
      git diff-tree --no-commit-id --name-only -r "${HEAD_SHA}"
      return
    fi
    git diff --name-only "${BASE_SHA}" "${HEAD_SHA}"
    return
  fi

  echo "Unsupported GITHUB_EVENT_NAME: ${EVENT_NAME}"
  exit 1
}

is_ios_relevant_path() {
  local file="$1"

  case "${file}" in
    ios/*) return 0 ;;
    scripts/ci-ios-test.sh) return 0 ;;
    assets/audio/*) return 0 ;;
    .github/workflows/ios-audio-harness.yml) return 0 ;;
  esac

  if [[ "${file}" == *.xcconfig ]]; then
    return 0
  fi

  return 1
}

mapfile -t CHANGED_FILES < <(resolve_changed_files)

echo "=== Changed files (${#CHANGED_FILES[@]}) ==="
if [[ "${#CHANGED_FILES[@]}" -eq 0 ]]; then
  echo "(none)"
else
  printf '%s\n' "${CHANGED_FILES[@]}"
fi

IOS_RELEVANT="false"
RELEVANT_MATCHES=()

for file in "${CHANGED_FILES[@]}"; do
  if is_ios_relevant_path "${file}"; then
    IOS_RELEVANT="true"
    RELEVANT_MATCHES+=("${file}")
  fi
done

echo "=== Classification ==="
echo "ios_relevant=${IOS_RELEVANT}"
if [[ "${#RELEVANT_MATCHES[@]}" -gt 0 ]]; then
  echo "iOS-relevant matches:"
  printf '  %s\n' "${RELEVANT_MATCHES[@]}"
else
  echo "No iOS-relevant paths matched."
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "ios_relevant=${IOS_RELEVANT}" >> "${GITHUB_OUTPUT}"
fi
