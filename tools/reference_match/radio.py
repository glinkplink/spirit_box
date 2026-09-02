from __future__ import annotations

import numpy as np

from tools.reference_match.degrade import bandlimit, fade_edges


def colored_noise(n: int, sr: int, rng: np.random.Generator, exponent: float) -> np.ndarray:
    white = rng.standard_normal(n)
    spec = np.fft.rfft(white)
    freqs = np.fft.rfftfreq(n, 1.0 / sr)
    spec[1:] /= np.maximum(freqs[1:], 1.0) ** (exponent / 2.0)
    spec[0] = 0
    out = np.fft.irfft(spec, n=n)
    rms = float(np.sqrt(np.mean(out * out)) + 1e-12)
    return (out / rms).astype(np.float32)


def static_bed(
    n: int,
    sr: int,
    rng: np.random.Generator,
    *,
    rms: float,
    pink_mix: float,
    brown_mix: float,
    white_hiss_mix: float,
) -> np.ndarray:
    pink = colored_noise(n, sr, rng, 1.0)
    brown = colored_noise(n, sr, rng, 2.0)
    hiss = colored_noise(n, sr, rng, 0.0)
    hiss = bandlimit(hiss, sr, 2500.0, 11000.0)
    bed = pink_mix * pink + brown_mix * brown + white_hiss_mix * hiss
    # slow gain wander
    lfo_n = max(8, n // 400)
    wander = rng.uniform(0.72, 1.18, size=lfo_n)
    wander = np.interp(np.linspace(0, lfo_n - 1, n), np.arange(lfo_n), wander)
    bed *= wander.astype(np.float32)
    # sparse crackle
    n_clicks = int(n / sr * rng.uniform(8.0, 18.0))
    for _ in range(n_clicks):
        i = int(rng.integers(0, n - 8))
        width = int(rng.integers(2, 7))
        bed[i : i + width] += rng.uniform(-0.9, 0.9) * rng.uniform(0.08, 0.22)
    rms_now = float(np.sqrt(np.mean(bed * bed)) + 1e-12)
    return (bed * (rms / rms_now)).astype(np.float32)


def apply_step_band_color(
    bed: np.ndarray,
    sr: int,
    steps: list[dict],
) -> np.ndarray:
    out = bed.copy()
    for step in steps:
        start = int(step["start_s"] * sr)
        end = int(step["end_s"] * sr)
        if end <= start:
            continue
        center = float(step["bandpass_center_hz"])
        sl = out[start:end]
        colored = bandlimit(sl, sr, max(80.0, center * 0.35), min(12000.0, center * 2.4))
        mix = 0.55
        out[start:end] = (1.0 - mix) * sl + mix * colored
    return out.astype(np.float32)


def tuning_chirp(sr: int, hz: float, ms: float, gain: float, rng: np.random.Generator) -> np.ndarray:
    n = max(8, int(sr * ms / 1000.0))
    t = np.arange(n, dtype=np.float64) / sr
    end_hz = hz * float(rng.uniform(0.92, 1.12))
    phase = 2 * np.pi * (hz * t + 0.5 * (end_hz - hz) / max(t[-1], 1e-6) * t * t)
    env = np.exp(-t / max(ms / 1000.0 * 0.45, 1e-4))
    tone = gain * np.sin(phase) * env
    # narrow noise burst with the tone
    noise = rng.standard_normal(n) * gain * 0.35 * env
    return fade_edges((tone + noise).astype(np.float32), sr, 1.5)
