#!/usr/bin/env python3
"""Enforce a gain-only comparison against A0, including the plan's primary SNR gate."""
import argparse
import json
import math
from pathlib import Path


def verify(candidate, baseline):
    current = json.loads((candidate / 'engine-diagnostics.json').read_text())
    reference = json.loads((baseline / 'engine-diagnostics.json').read_text())
    gains_and_identity = {'static_gain', 'vocal_gain', 'output_gain', 'preset_identifier', 'preset_version'}
    settings = lambda record: {k: v for k, v in record['renderer_settings'].items() if k not in gains_and_identity}
    assert settings(current) == settings(reference), 'Non-gain renderer settings changed'
    for key in ('seed', 'sweep_rate_ms', 'direction', 'duration_seconds', 'corpus_manifest_sha256'):
        assert current[key] == reference[key], f'Unmatched comparison: {key}'
    assert (candidate / 'events.jsonl').read_bytes() == (baseline / 'events.jsonl').read_bytes(), 'Gain-only event sequence changed'
    acoustic = json.loads((candidate / 'acoustic-checks.json').read_text())
    assert acoustic['technical_checks'] == 'PASS', 'Acoustic gates failed'
    emergence = acoustic['vocal_slot_minus_noise_slot_db']
    assert isinstance(emergence, (float, int)) and math.isfinite(emergence) and 8 <= emergence <= 12, f'Primary vocal-slot contrast {emergence} dB outside 8...12'
    print('Gain-only comparison and primary 8...12 dB contrast: PASS; human listening: NOT_RUN')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('candidate', type=Path)
    parser.add_argument('baseline', type=Path)
    args = parser.parse_args()
    verify(args.candidate, args.baseline)
