"""EXP-001 mechanical metrics on a rendered 20 s candidate."""

from __future__ import annotations

import argparse
import wave
from pathlib import Path

import numpy as np

from tools.reference_match.constants import SAMPLE_RATE


def load_wav(path: Path) -> tuple[np.ndarray, int]:
    with wave.open(str(path), "rb") as handle:
        sr = handle.getframerate()
        nch = handle.getnchannels()
        n = handle.getnframes()
        pcm = np.frombuffer(handle.readframes(n), dtype=np.int16).astype(np.float64) / 32768.0
        if nch == 2:
            pcm = pcm.reshape(-1, 2).mean(axis=1)
    return pcm, sr


def _band_envelope(pcm: np.ndarray, sr: int, lo: float, hi: float, hop: int = 256, frame: int = 1024):
    window = np.hanning(frame)
    n_frames = 1 + (len(pcm) - frame) // hop
    env = np.empty(n_frames, dtype=np.float64)
    freqs = np.fft.rfftfreq(frame, 1.0 / sr)
    mask = (freqs >= lo) & (freqs < hi)
    for i in range(n_frames):
        sl = pcm[i * hop : i * hop + frame] * window
        spec = np.abs(np.fft.rfft(sl)) ** 2
        env[i] = float(np.sqrt(np.mean(spec[mask]) + 1e-20))
    times = (np.arange(n_frames) * hop + frame / 2) / sr
    return times, env


def _vad_bursts(lf_env: np.ndarray, times: np.ndarray, hop_s: float) -> list[tuple[float, float]]:
    floor = float(np.median(lf_env) + 1e-12)
    thresh = floor * 3.2
    voiced = lf_env > thresh
    bursts: list[tuple[float, float]] = []
    i = 0
    while i < len(voiced):
        if not voiced[i]:
            i += 1
            continue
        j = i
        while j < len(voiced) and voiced[j]:
            j += 1
        t0 = float(times[i] - hop_s / 2)
        t1 = float(times[min(j - 1, len(times) - 1)] + hop_s / 2)
        if (t1 - t0) >= 0.080:
            bursts.append((max(0.0, t0), t1))
        i = j
    return bursts


def _band_db(pcm: np.ndarray, sr: int, lo: float, hi: float) -> float:
    spec = np.abs(np.fft.rfft(pcm * np.hanning(len(pcm)))) ** 2
    freqs = np.fft.rfftfreq(len(pcm), 1.0 / sr)
    mask = (freqs >= lo) & (freqs < hi)
    power = float(np.mean(spec[mask]) + 1e-20)
    return 10.0 * np.log10(power)


def measure(path: Path) -> dict:
    pcm, sr = load_wav(path)
    duration = len(pcm) / sr
    hop = 256
    times, lf = _band_envelope(pcm, sr, 200.0, 4000.0, hop=hop)
    _, hf = _band_envelope(pcm, sr, 6000.0, 12000.0, hop=hop)
    corr = float(np.corrcoef(lf, hf)[0, 1])
    hop_s = hop / sr
    bursts = _vad_bursts(lf, times, hop_s)
    hf_deltas = []
    formant_lens = []
    occupied = 0.0
    for t0, t1 in bursts:
        occupied += t1 - t0
        a = int(t0 * sr)
        b = int(t1 * sr)
        pre_a = max(0, a - int(0.200 * sr))
        pre_b = a
        if pre_b - pre_a < int(0.05 * sr) or b <= a:
            continue
        during = _band_db(pcm[a:b], sr, 6000.0, 12000.0)
        pre = _band_db(pcm[pre_a:pre_b], sr, 6000.0, 12000.0)
        hf_deltas.append(during - pre)
        formant_lens.append(1000.0 * (t1 - t0))
    occupancy = occupied / duration if duration else 0.0
    return {
        "path": str(path),
        "duration_s": duration,
        "sample_rate": sr,
        "channels": 1,
        "n_bursts_ge_80ms": len(bursts),
        "hf_delta_db": hf_deltas,
        "hf_delta_db_min": min(hf_deltas) if hf_deltas else None,
        "hf_delta_db_mean": float(np.mean(hf_deltas)) if hf_deltas else None,
        "corr_lf_hf": corr,
        "burst_ms": formant_lens,
        "max_burst_ms": max(formant_lens) if formant_lens else 0.0,
        "occupancy": occupancy,
        "pass_duration": abs(duration - 20.0) <= 0.01 and sr == SAMPLE_RATE,
        "pass_hf_delta": bool(hf_deltas) and min(hf_deltas) >= 8.0,
        "pass_corr": corr >= 0.35,
        "pass_max_burst": (max(formant_lens) if formant_lens else 0.0) <= 180.0,
        "pass_occupancy": 0.02 <= occupancy <= 0.12,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("wav")
    args = parser.parse_args()
    m = measure(Path(args.wav))
    print(f"duration_s={m['duration_s']:.4f} sr={m['sample_rate']}")
    print(f"n_bursts_ge_80ms={m['n_bursts_ge_80ms']}")
    print(f"hf_delta_db={m['hf_delta_db']}")
    print(f"hf_delta_db_min={m['hf_delta_db_min']} mean={m['hf_delta_db_mean']}")
    print(f"corr_lf_hf={m['corr_lf_hf']:.4f}")
    print(f"burst_ms={m['burst_ms']}")
    print(f"max_burst_ms={m['max_burst_ms']:.1f}")
    print(f"occupancy={100.0 * m['occupancy']:.2f}%")
    print(
        "pass",
        {
            "duration": m["pass_duration"],
            "hf_delta": m["pass_hf_delta"],
            "corr": m["pass_corr"],
            "max_burst": m["pass_max_burst"],
            "occupancy": m["pass_occupancy"],
        },
    )


if __name__ == "__main__":
    main()
