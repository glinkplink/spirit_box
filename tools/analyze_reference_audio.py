#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.reference_match.analyze import run_analysis


def main() -> None:
    parser = argparse.ArgumentParser(description="Analyze local spirit-box reference audio")
    parser.add_argument("--reference-dir", default="reference_audio")
    parser.add_argument("--out-dir", default="build/reference_audio_analysis")
    args = parser.parse_args()
    run_analysis(Path(args.reference_dir), Path(args.out_dir))


if __name__ == "__main__":
    main()
