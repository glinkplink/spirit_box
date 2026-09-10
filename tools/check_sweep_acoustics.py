#!/usr/bin/env python3
"""Measure actual renderer WAVs; never substitute for the human listening gate.

Requires NumPy and ffmpeg on the validation host, neither is an app dependency.
Envelope percentiles use 2 ms RMS windows inside logged noise-only slots.

noise_envelope_p90_p10_db is a compatibility alias. It is NOT a p90/p10 ratio.
It is 20*log10(p90(2 ms RMS in noise-only slots) / median(min of the first
~10 ms of each noise-only slot)). The explicit name is
noise_envelope_p90_over_early_slot_min_median_db. Do not compare a renamed
metric to historical values as if the definition changed.

vocal_slot_minus_noise_slot_db is median RMS of aligned vocal slots minus
median RMS of aligned noise-only slots, in dB. It is a slot-window proxy,
not a listening score and not automatically the same as a model's
"vocal emergence" figure.

Slot alignment prefers capture_time_seconds (WAV-relative) when present,
else render_time_seconds. Live captures that started after the engine
timeline will mis-align if only engine render time is stored.
"""
import argparse
import json
from pathlib import Path
import subprocess
import wave


def slot_start_seconds(event):
    if event.get('capture_time_seconds') is not None:
        return float(event['capture_time_seconds'])
    return float(event['render_time_seconds'])


def aligned_slot(pcm, rate, event):
    start = round(slot_start_seconds(event) * rate)
    count = round(event['sweep_rate_ms'] * rate / 1000)
    if start < 0 or count <= 0 or start + count > pcm.size:
        return None
    return pcm[start:start + count]


def measure(directory):
    import numpy as np
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
    aligned_events = 0
    vocal_rms = []
    noise_rms = []
    for event in events:
        segment = aligned_slot(pcm, rate, event)
        if segment is None:
            previous = None
            continue
        aligned_events += 1
        rms = float(np.sqrt(np.mean(segment ** 2)))
        if event.get('contains_vocal', True) and event.get('asset_id'):
            vocal_rms.append(rms)
            previous = None
            continue
        noise_rms.append(rms)
        env = np.sqrt(np.mean(segment[:len(segment) // block * block].reshape(-1, block) ** 2, axis=1))
        envelopes.append(env)
        if previous is not None and len(previous) == len(env):
            paired.append((previous, env))
        previous = env
    assert envelopes and paired, (
        'Need complete adjacent noise-only slots aligned to the WAV. '
        'Live captures that store engine render_time_seconds without '
        'capture_time_seconds can start far past the file origin.'
    )
    levels = np.concatenate(envelopes)
    dip_blocks = max(1, round(rate * 0.010 / block))
    dip_level = np.median([np.min(e[:dip_blocks + 2]) for e in envelopes])
    steady_level = np.percentile(levels, 90)
    spread = float(20 * np.log10(steady_level / max(1e-12, dip_level)))
    first = np.concatenate([p[0] for p in paired])
    second = np.concatenate([p[1] for p in paired])
    correlation = float(np.corrcoef(first, second)[0, 1])
    half = np.concatenate([np.roll(p[1], len(p[1]) // 2) for p in paired])
    half_correlation = float(np.corrcoef(first, half)[0, 1])
    ffmpeg = subprocess.run(['ffmpeg', '-hide_banner', '-nostats', '-i', str(path),
                             '-af', 'loudnorm=I=-17:TP=-1:LRA=11:print_format=json',
                             '-f', 'null', '-'], capture_output=True, text=True, check=True)
    meter, _ = json.JSONDecoder().raw_decode(ffmpeg.stderr[ffmpeg.stderr.rfind('{'):])
    emergence = None
    if vocal_rms and noise_rms:
        emergence = float(20 * np.log10(np.median(vocal_rms) / max(1e-12, np.median(noise_rms))))
    sample_peak = float(20 * np.log10(max(1e-12, np.max(np.abs(pcm)))))
    report = dict(integrated_lufs=float(meter['input_i']), true_peak_dbtp=float(meter['input_tp']),
                  sample_peak_dbfs=sample_peak,
                  below_250hz_fraction=low, presence_1k_3k5_fraction=presence,
                  noise_envelope_p90_over_early_slot_min_median_db=spread,
                  noise_envelope_p90_p10_db=spread,
                  noise_envelope_p90_p10_db_definition=(
                      'compatibility alias for noise_envelope_p90_over_early_slot_min_median_db; '
                      '20*log10(p90(2ms RMS in noise-only slots) / median(min of first ~10ms of each noise-only slot)); '
                      'not a p90/p10 ratio'
                  ),
                  vocal_slot_minus_noise_slot_db=emergence,
                  vocal_slot_minus_noise_slot_db_definition=(
                      '20*log10(median RMS of WAV-aligned vocal dwells / median RMS of WAV-aligned noise-only dwells); '
                      'slot windows, not a listening score'
                  ),
                  aligned_slot_events=aligned_events,
                  dwell_lag_correlation=correlation,
                  half_dwell_lag_correlation=half_correlation, human_listening='NOT_RUN')
    checks = dict(loudness=-22 <= report['integrated_lufs'] <= -16,
                  true_peak=report['true_peak_dbtp'] <= -1,
                  low_energy=low < .05, presence=presence > .35,
                  continuous_bed=spread < 12.0)
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
