#!/usr/bin/env python3
"""Prepare a continuous recording into a harness-loadable Phase 1 corpus folder."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from tools.corpus_intake.prepare_pipeline import (
    DEFAULT_MAX_EVENT_SEC,
    DEFAULT_MIN_EVENT_SEC,
    DEFAULT_MIN_SILENCE_SEC,
    DEFAULT_NOISE_THRESHOLD_DB,
    DEFAULT_REGION_PAD_SEC,
    DEFAULT_SILENCE_MERGE_GAP_SEC,
    prepare_corpus,
)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Segment a continuous M4A/WAV recording into harness-compatible "
            "SpiritBoxPhase1Corpus assets (local developer tool)."
        )
    )
    parser.add_argument(
        "source",
        type=Path,
        help="Continuous source recording (.m4a or .wav). Never modified.",
    )
    parser.add_argument(
        "--family",
        required=True,
        help="Voice family / performer label used in asset IDs (e.g. me_test).",
    )
    parser.add_argument(
        "--output",
        type=Path,
        required=True,
        help="Output directory for generated corpus and QA report (local only).",
    )
    parser.add_argument(
        "--noise-threshold-db",
        type=float,
        default=DEFAULT_NOISE_THRESHOLD_DB,
        help=f"Silence threshold in dB (default: {DEFAULT_NOISE_THRESHOLD_DB}).",
    )
    parser.add_argument(
        "--min-silence-sec",
        type=float,
        default=DEFAULT_MIN_SILENCE_SEC,
        help=f"Minimum silence duration for segmentation (default: {DEFAULT_MIN_SILENCE_SEC}).",
    )
    parser.add_argument(
        "--silence-merge-gap-sec",
        type=float,
        default=DEFAULT_SILENCE_MERGE_GAP_SEC,
        help=(
            "Merge silence intervals separated by gaps shorter than this "
            f"(default: {DEFAULT_SILENCE_MERGE_GAP_SEC})."
        ),
    )
    parser.add_argument(
        "--min-event-sec",
        type=float,
        default=DEFAULT_MIN_EVENT_SEC,
        help=f"Reject vocal regions shorter than this (default: {DEFAULT_MIN_EVENT_SEC}).",
    )
    parser.add_argument(
        "--max-event-sec",
        type=float,
        default=DEFAULT_MAX_EVENT_SEC,
        help=f"Reject vocal regions longer than this (default: {DEFAULT_MAX_EVENT_SEC}).",
    )
    parser.add_argument(
        "--region-pad-sec",
        type=float,
        default=DEFAULT_REGION_PAD_SEC,
        help=f"Optional leading/trailing pad before trim (default: {DEFAULT_REGION_PAD_SEC}).",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        result = prepare_corpus(
            args.source,
            args.output,
            family=args.family,
            noise_threshold_db=args.noise_threshold_db,
            min_silence_sec=args.min_silence_sec,
            silence_merge_gap_sec=args.silence_merge_gap_sec,
            min_event_sec=args.min_event_sec,
            max_event_sec=args.max_event_sec,
            region_pad_sec=args.region_pad_sec,
        )
    except (RuntimeError, ValueError, FileNotFoundError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    print(f"Prepared {len(result.accepted)} assets into {result.corpus_root}")
    print(f"Rejected {len(result.rejected)} regions")
    print(f"QA report: {result.qa_report_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
