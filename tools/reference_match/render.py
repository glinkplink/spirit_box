from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import numpy as np

from tools.reference_match.constants import SAMPLE_RATE
from tools.reference_match.degrade import apply_radio_degrade, bandlimit, fade_edges
from tools.reference_match.radio import apply_step_band_color, static_bed, tuning_chirp


def station_gate(n: int, sample_rate: int, edge_ms: float = 40.0) -> np.ndarray:
    """Linear 0–100% edges; 40 ms edges give ~32 ms 10–90% attack (30–50 ms class)."""
    n = int(n)
    g = np.ones(n, dtype=np.float32)
    if n <= 1:
        return g
    edge = int(round(sample_rate * float(edge_ms) / 1000.0))
    edge = max(1, min(edge, n // 2))
    ramp = np.linspace(0.0, 1.0, edge, dtype=np.float32)
    g[:edge] = ramp
    g[-edge:] = ramp[::-1]
    return g


def mix_station_replace(
    dst: np.ndarray,
    station: np.ndarray,
    at: int,
    gate: np.ndarray,
    noise_duck_db: float = float("-inf"),
) -> None:
    """out = (1-g)*noise + g*station, with optional residual hiss under the gate."""
    if at >= len(dst) or at < 0:
        return
    n = min(len(dst) - at, len(station), len(gate))
    if n <= 0:
        return
    sl = dst[at : at + n]
    g = gate[:n].astype(np.float32, copy=False)
    if np.isfinite(noise_duck_db):
        duck = float(10 ** (float(noise_duck_db) / 20.0))
    else:
        duck = 0.0
    noise_g = (1.0 - g) + g * duck
    sl[:] = noise_g * sl + g * station[:n]


def _make_station(
    voice: np.ndarray,
    bed_slice: np.ndarray,
    sample_rate: int,
    *,
    peak_dbfs: float,
    hf_boost_db: float,
    speech_gain: float,
) -> np.ndarray:
    n = min(len(voice), len(bed_slice))
    voice = voice[:n].astype(np.float32, copy=True)
    v_rms = float(np.sqrt(np.mean(voice * voice)) + 1e-12)
    voice *= 0.072 / v_rms
    v_peak = float(np.max(np.abs(voice)) + 1e-12)
    if v_peak > 0.11:
        voice *= 0.11 / v_peak
    bed_slice = bed_slice[:n].astype(np.float32, copy=False)
    hf = bandlimit(bed_slice, sample_rate, 5500.0, min(16000.0, sample_rate * 0.49))
    hf_rms = float(np.sqrt(np.mean(hf * hf)) + 1e-12)
    hf = np.clip(hf, -3.0 * hf_rms, 3.0 * hf_rms)
    target = hf_rms * (10 ** (float(hf_boost_db) / 20.0))
    hf = hf * (target / (float(np.sqrt(np.mean(hf * hf))) + 1e-12))
    win = max(8, int(0.008 * sample_rate))
    mag = np.abs(voice)
    env = np.convolve(mag, np.ones(win, dtype=np.float32) / win, mode="same")
    env = env / (float(np.max(env)) + 1e-12)
    env = np.maximum(env, 0.55)
    station = voice + hf * env
    ceiling = 10 ** (float(peak_dbfs) / 20.0)
    station = np.clip(station, -ceiling, ceiling)
    return station.astype(np.float32)


def _mix(dst: np.ndarray, src: np.ndarray, at: int, gain: float) -> None:
    if at >= len(dst) or len(src) == 0:
        return
    end = min(len(dst), at + len(src))
    sl = src[: end - at] * gain
    dst[at:end] += sl


def render_session(
    *,
    schedule: dict[str, Any],
    speech_bank: dict[tuple[str, str], np.ndarray],
    wav_path: Path,
    json_path: Path,
    sample_rate: int = SAMPLE_RATE,
) -> dict[str, Any]:
    rng = np.random.default_rng(int(schedule["seed"]))
    n = int(round(float(schedule["duration_s"]) * sample_rate))
    cfg = schedule["synthesis_params"]
    bed = static_bed(
        n,
        sample_rate,
        rng,
        rms=float(cfg["noise_rms"]),
        pink_mix=float(cfg["pink_mix"]),
        brown_mix=float(cfg["brown_mix"]),
        white_hiss_mix=float(cfg["white_hiss_mix"]),
    )
    bed = apply_step_band_color(bed, sample_rate, schedule["scan_steps"])
    mix = bed.copy()
    logged = []
    speech_samples = 0

    for event in schedule["events"]:
        logged_event = dict(event)
        if event["event_type"] == "tuning_tone":
            chirp = tuning_chirp(
                sample_rate,
                float(event["tone_hz"]),
                float(event.get("tone_ms", cfg["tuning_ms"])),
                float(event["gain"]),
                rng,
            )
            at = int(float(event["time"]) * sample_rate)
            _mix(mix, chirp, at, 1.0)
        elif event["event_type"] == "speech":
            key = (event["voice"], event["source_word"])
            src = speech_bank[key]
            window_s = float(event["end_s"]) - float(event["start_s"])
            degraded, meta = apply_radio_degrade(
                src,
                sample_rate,
                rng,
                heavy=bool(event["every_third_word"]),
                hp_hz=float(event["high_pass"]),
                lp_hz=float(event["low_pass"]),
                snr_db=float(event["snr_db"]),
                window_s=window_s,
            )
            at = int(float(event["start_s"]) * sample_rate)
            n_v = min(len(degraded), len(mix) - at, int(round(window_s * sample_rate)))
            if n_v <= 0:
                logged.append(logged_event)
                continue
            voice = degraded[:n_v]
            bed_slice = mix[at : at + n_v].copy()
            edge_ms = float(event.get("edge_ms", cfg.get("station_edge_ms", 40.0)))
            gate = station_gate(n_v, sample_rate, edge_ms=edge_ms)
            station = _make_station(
                voice,
                bed_slice,
                sample_rate,
                peak_dbfs=float(cfg.get("station_peak_dbfs", -15.0)),
                hf_boost_db=float(cfg.get("station_hf_boost_db", 12.0)),
                speech_gain=float(event["gain"]),
            )
            mix_station_replace(
                mix,
                station,
                at,
                gate,
                noise_duck_db=float(cfg.get("station_noise_duck_db", -96.0)),
            )
            speech_samples += n_v
            logged_event.update(
                {
                    "source_crop": {
                        "style": meta["crop_style"],
                        "start_sample": meta["start_sample"],
                        "end_sample": meta["end_sample"],
                    },
                    "pcm_reversed": False,
                }
            )
        logged.append(logged_event)

    mix = fade_edges(mix, sample_rate, float(cfg["click_fade_ms"]))
    peak = float(np.max(np.abs(mix)) + 1e-12)
    if peak > 0.89:
        mix *= 0.89 / peak
    mix = np.clip(mix, -0.98, 0.98)
    pcm_i16 = np.round(mix * 32767.0).astype(np.int16)
    wav_path = Path(wav_path)
    json_path = Path(json_path)
    wav_path.parent.mkdir(parents=True, exist_ok=True)
    import wave

    with wave.open(str(wav_path), "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(sample_rate)
        handle.writeframes(pcm_i16.tobytes())

    occupancy = speech_samples / n
    payload = {
        **{k: v for k, v in schedule.items() if k != "events"},
        "events": logged,
        "wav": str(wav_path),
        "speech_occupancy": occupancy,
        "sample_rate": sample_rate,
        "peak": float(np.max(np.abs(mix))),
        "copied_reference_samples": False,
        "pcm_reversed": False,
    }
    json_path.write_text(json.dumps(payload, indent=2))
    return payload
