from __future__ import annotations

import math
from typing import Any

import numpy as np


def _biquad_coeffs_lowpass(sr: int, cutoff: float, q: float = 0.72) -> tuple[float, ...]:
    w0 = 2 * math.pi * cutoff / sr
    alpha = math.sin(w0) / (2 * q)
    cosw = math.cos(w0)
    b0 = (1 - cosw) / 2
    b1 = 1 - cosw
    b2 = (1 - cosw) / 2
    a0 = 1 + alpha
    a1 = -2 * cosw
    a2 = 1 - alpha
    return b0, b1, b2, a0, a1, a2


def _biquad_coeffs_highpass(sr: int, cutoff: float, q: float = 0.72) -> tuple[float, ...]:
    w0 = 2 * math.pi * cutoff / sr
    alpha = math.sin(w0) / (2 * q)
    cosw = math.cos(w0)
    b0 = (1 + cosw) / 2
    b1 = -(1 + cosw)
    b2 = (1 + cosw) / 2
    a0 = 1 + alpha
    a1 = -2 * cosw
    a2 = 1 - alpha
    return b0, b1, b2, a0, a1, a2


def biquad_filter(x: np.ndarray, coeffs: tuple[float, ...]) -> np.ndarray:
    b0, b1, b2, a0, a1, a2 = coeffs
    b0, b1, b2 = b0 / a0, b1 / a0, b2 / a0
    a1, a2 = a1 / a0, a2 / a0
    y = np.empty_like(x, dtype=np.float64)
    z1 = 0.0
    z2 = 0.0
    for i, xn in enumerate(x.astype(np.float64, copy=False)):
        yn = b0 * xn + z1
        z1 = b1 * xn - a1 * yn + z2
        z2 = b2 * xn - a2 * yn
        y[i] = yn
    return y.astype(np.float32)


def bandlimit(pcm: np.ndarray, sr: int, hp_hz: float, lp_hz: float) -> np.ndarray:
    y = biquad_filter(pcm, _biquad_coeffs_highpass(sr, hp_hz))
    return biquad_filter(y, _biquad_coeffs_lowpass(sr, lp_hz))


def fade_edges(pcm: np.ndarray, sr: int, fade_ms: float) -> np.ndarray:
    n = max(1, int(sr * fade_ms / 1000.0))
    n = min(n, max(1, len(pcm) // 2))
    out = pcm.astype(np.float32, copy=True)
    ramp = np.linspace(0.0, 1.0, n, dtype=np.float32)
    out[:n] *= ramp
    out[-n:] *= ramp[::-1]
    return out


def soft_clip(pcm: np.ndarray, drive: float = 1.35) -> np.ndarray:
    return np.tanh(pcm * drive).astype(np.float32) / float(np.tanh(drive))


def compress(pcm: np.ndarray, threshold: float = 0.18, ratio: float = 2.6) -> np.ndarray:
    mag = np.abs(pcm) + 1e-12
    gain = np.ones_like(pcm, dtype=np.float32)
    over = mag > threshold
    gain[over] = (threshold + (mag[over] - threshold) / ratio) / mag[over]
    # 2 ms-ish smoothing via cumulative moving average of gain
    kernel = min(96, max(8, len(pcm) // 40))
    box = np.ones(kernel, dtype=np.float32) / kernel
    smooth = np.convolve(gain, box, mode="same")
    return (pcm * smooth).astype(np.float32)


def spectral_dropout(pcm: np.ndarray, sr: int, rng: np.random.Generator) -> np.ndarray:
    n = len(pcm)
    spec = np.fft.rfft(pcm.astype(np.float64))
    freqs = np.fft.rfftfreq(n, 1.0 / sr)
    lo = float(rng.uniform(700.0, 1600.0))
    hi = float(rng.uniform(lo + 400.0, 3200.0))
    mask = (freqs >= lo) & (freqs <= hi)
    spec[mask] *= float(rng.uniform(0.05, 0.25))
    out = np.fft.irfft(spec, n=n)
    return out.astype(np.float32)


def crop_word_window(
    pcm: np.ndarray,
    sr: int,
    rng: np.random.Generator,
    heavy: bool = False,
    window_s: float | None = None,
) -> tuple[np.ndarray, dict[str, Any]]:
    n = int(len(pcm))
    min_n = min(n, max(32, int(round(0.100 * sr))))
    max_n = min(n, max(min_n, int(round(0.180 * sr))))
    if window_s is None:
        length = int(rng.integers(min_n, max_n + 1))
    else:
        length = int(round(float(window_s) * sr))
        length = max(min_n, min(length, max_n))
    start = max(0, (n - length) // 2)
    end = start + length
    return pcm[start:end].copy(), {
        "crop_style": "middle",
        "start_sample": start,
        "end_sample": end,
        "pcm_reversed": False,
        "heavy": heavy,
    }


def apply_radio_degrade(
    pcm: np.ndarray,
    sr: int,
    rng: np.random.Generator,
    *,
    heavy: bool,
    hp_hz: float,
    lp_hz: float,
    snr_db: float,
    window_s: float | None = None,
) -> tuple[np.ndarray, dict[str, Any]]:
    cropped, crop_meta = crop_word_window(pcm, sr, rng, heavy=heavy, window_s=window_s)
    voice = bandlimit(cropped, sr, hp_hz, lp_hz)
    if heavy:
        voice = spectral_dropout(voice, sr, rng)
        voice = bandlimit(voice, sr, min(hp_hz + 80.0, 500.0), max(1400.0, lp_hz * 0.55))
    voice = compress(voice, threshold=0.14 if not heavy else 0.11, ratio=2.8 if not heavy else 3.6)
    voice = soft_clip(voice, drive=1.25 if not heavy else 1.55)
    # EXP-001: do not bake a second hiss layer under the crop; the mixer gate replaces the bed.
    peak = float(np.max(np.abs(voice)) + 1e-12)
    if peak > 0.9:
        voice = voice * (0.9 / peak)
    meta = {
        **crop_meta,
        "heavy": heavy,
        "hp_hz": hp_hz,
        "lp_hz": lp_hz,
        "snr_db": snr_db,
        "pcm_reversed": False,
        "added_noise_layer": False,
    }
    return voice.astype(np.float32), meta
