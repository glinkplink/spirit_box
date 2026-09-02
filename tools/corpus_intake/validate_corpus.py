#!/usr/bin/env python3
"""CLI entry point for Phase 1 corpus intake validation."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

# Allow `python3 tools/corpus_intake/validate_corpus.py` without PYTHONPATH.
_REPO_ROOT = Path(__file__).resolve().parents[2]
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from tools.corpus_intake.report import write_json_report, write_markdown_report
from tools.corpus_intake.validator import validate_corpus


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate Spirit Box Phase 1 corpus technical integrity before harness loading.",
    )
    parser.add_argument(
        "corpus_root",
        type=Path,
        help="Path to corpus directory containing manifest.json and WAV files",
    )
    parser.add_argument(
        "--phase1-strict",
        action="store_true",
        help="Enforce canonical Phase 1 counts, format, and rights requirements",
    )
    parser.add_argument(
        "--rights-ledger",
        type=Path,
        default=None,
        help="Path to rights ledger CSV (required for --phase1-strict)",
    )
    parser.add_argument(
        "--report",
        type=Path,
        default=None,
        help="Write human-readable Markdown report to this path",
    )
    parser.add_argument(
        "--json-report",
        type=Path,
        default=None,
        help="Write machine-readable JSON report to this path",
    )
    args = parser.parse_args(argv)

    corpus_root = args.corpus_root
    if not corpus_root.is_dir():
        print(f"error: corpus root is not a directory: {corpus_root}", file=sys.stderr)
        return 2

    result = validate_corpus(
        corpus_root,
        phase1_strict=args.phase1_strict,
        rights_ledger_path=args.rights_ledger,
    )

    if args.report:
        write_markdown_report(result, args.report)
        print(f"Wrote report: {args.report}")
    if args.json_report:
        write_json_report(result, args.json_report)
        print(f"Wrote JSON report: {args.json_report}")

    print(f"Status: {result.overall_status}")
    print(f"Errors: {len(result.errors)}  Warnings: {len(result.warnings)}")
    print(f"Audio gate: {result.audio_gate_status}")

    return 1 if result.errors else 0


if __name__ == "__main__":
    sys.exit(main())
