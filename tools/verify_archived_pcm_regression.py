#!/usr/bin/env python3
"""Verify archived-continuous-static PCM/event prefix against a committed fixture."""
import argparse
import hashlib
import json
import sys
import wave
from pathlib import Path


def pcm_prefix_sha256(wav_path: Path, duration_seconds: float) -> str:
    with wave.open(str(wav_path), 'rb') as wav:
        if wav.getnchannels() != 1 or wav.getsampwidth() != 2:
            raise SystemExit(f'Expected mono 16-bit PCM in {wav_path}')
        rate = wav.getframerate()
        frames = min(wav.getnframes(), int(duration_seconds * rate))
        return hashlib.sha256(wav.readframes(frames)).hexdigest()


def verify(rendered_dir: Path, fixture_dir: Path) -> None:
    manifest = json.loads((fixture_dir / 'manifest.json').read_text())
    duration = float(manifest['duration_seconds'])
    expected_pcm = (fixture_dir / 'pcm-prefix.sha256').read_text().strip()
    expected_events = (fixture_dir / 'events-prefix.jsonl').read_text().splitlines()

    engine_path = rendered_dir / 'engine-diagnostics.json'
    if not engine_path.is_file():
        raise SystemExit(f'Missing {engine_path}')
    engine = json.loads(engine_path.read_text())
    settings = engine.get('renderer_settings') or engine.get('settings') or {}

    for key in ('preset_identifier', 'seed'):
        expected = manifest.get(key)
        actual = settings.get(key) if key == 'preset_identifier' else engine.get(key)
        if expected is not None and actual != expected:
            raise SystemExit(f'{key} mismatch: rendered {actual!r}, fixture {expected!r}')

    wav_path = rendered_dir / 'sweep.wav'
    if not wav_path.is_file():
        raise SystemExit(f'Missing {wav_path}')
    actual_pcm = pcm_prefix_sha256(wav_path, duration)
    if actual_pcm != expected_pcm:
        raise SystemExit(
            f'PCM prefix hash mismatch: rendered {actual_pcm}, fixture {expected_pcm}'
        )

    events_path = rendered_dir / 'events.jsonl'
    if not events_path.is_file():
        raise SystemExit(f'Missing {events_path}')
    actual_events = events_path.read_text().splitlines()
    if actual_events != expected_events:
        raise SystemExit(
            f'events.jsonl mismatch: {len(actual_events)} rendered lines vs '
            f'{len(expected_events)} fixture lines'
        )

    print(json.dumps({
        'archived_pcm_regression': 'PASS',
        'pcm_prefix_sha256': actual_pcm,
        'event_lines': len(actual_events),
        'fixture_generating_commit': manifest.get('generating_commit'),
    }, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rendered_dir', type=Path)
    parser.add_argument('fixture_dir', type=Path)
    args = parser.parse_args()
    try:
        verify(args.rendered_dir, args.fixture_dir)
    except SystemExit as exc:
        if exc.code not in (None, 0):
            print(exc, file=sys.stderr)
            raise SystemExit(1) from exc
        raise
