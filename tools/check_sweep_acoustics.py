#!/usr/bin/env python3
"""Measure actual renderer WAVs; never substitute for the human listening gate.

Requires NumPy and ffmpeg on the validation host, neither is an app dependency.
Envelope percentiles use 2 ms RMS windows inside logged noise-only slots.
"""
import argparse
import json
from pathlib import Path
import subprocess
import wave

import numpy as np


def measure(directory):
    path = directory / 'sweep.wav'
    with wave.open(str(path), 'rb') as wav:
        assert wav.getsampwidth() == 2 and wav.getnchannels() == 1
        rate = wav.getframerate()
        pcm = np.frombuffer(wav.readframes(wav.getnframes()), dtype='<i2').astype(float) / 32768
    events = [json.loads(line) for line in (directory / 'events.jsonl').read_text().splitlines() if line]
    assert pcm.size and np.isfinite(pcm).all()
    # Windowed power spectra, retaining the DC bin in the denominator.
    size = rate
    windows = pcm[:pcm.size // size * size].reshape(-1, size)
    power = np.abs(np.fft.rfft(windows * np.hanning(size), axis=1)) ** 2
    spectrum = power.sum(axis=0)
    hz = np.fft.rfftfreq(size, 1 / rate)
    low = float(spectrum[hz < 250].sum() / spectrum.sum())
    presence = float(spectrum[(hz >= 1000) & (hz <= 3500)].sum() / spectrum.sum())
    envelopes = []
    paired = []
    block = round(rate * .002)
    previous = None
    for event in events:
        if event.get('contains_vocal', True):
            previous = None
            continue
        start = round(event['render_time_seconds'] * rate)
        count = round(event['sweep_rate_ms'] * rate / 1000)
        segment = pcm[start:start + count]
        if len(segment) != count:
            continue
        env = np.sqrt(np.mean(segment[:count // block * block].reshape(-1, block) ** 2, axis=1))
        envelopes.append(env)
        if previous is not None and len(previous) == len(env):
            paired.append((previous, env))
        previous = env
    assert envelopes and paired, 'Need complete adjacent noise-only slots'
    levels = np.concatenate(envelopes)
    spread = float(20 * np.log10(np.percentile(levels, 90) / max(1e-12, np.percentile(levels, 10))))
    first = np.concatenate([p[0] for p in paired])
    second = np.concatenate([p[1] for p in paired])
    correlation = float(np.corrcoef(first, second)[0, 1])
    half = np.concatenate([np.roll(p[1], len(p[1]) // 2) for p in paired])
    half_correlation = float(np.corrcoef(first, half)[0, 1])
    ffmpeg = subprocess.run(['ffmpeg', '-hide_banner', '-nostats', '-i', str(path),
                             '-af', 'loudnorm=I=-17:TP=-1:LRA=11:print_format=json',
                             '-f', 'null', '-'], capture_output=True, text=True, check=True)
    meter = json.loads(ffmpeg.stderr[ffmpeg.stderr.rfind('{'):])
    report = dict(integrated_lufs=float(meter['input_i']), true_peak_dbtp=float(meter['input_tp']),
                  below_250hz_fraction=low, presence_1k_3k5_fraction=presence,
                  noise_envelope_p90_p10_db=spread, dwell_lag_correlation=correlation,
                  half_dwell_lag_correlation=half_correlation, human_listening='NOT_RUN')
    checks = dict(loudness=-18 <= report['integrated_lufs'] <= -16,
                  true_peak=report['true_peak_dbtp'] <= -1,
                  low_energy=low < .05, presence=presence > .35,
                  step_depth=spread > 15,
                  cadence=correlation > .4 and correlation > half_correlation + .3)
    report['checks'] = checks
    report['technical_checks'] = 'PASS' if all(checks.values()) else 'FAIL'
    (directory / 'acoustic-checks.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path)
    args = parser.parse_args()
    report = measure(args.directory)
    raise SystemExit(0 if report['technical_checks'] == 'PASS' else 1)
