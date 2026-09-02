from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import numpy as np

from tools.reference_match.constants import SAMPLE_RATE
from tools.reference_match.degrade import apply_radio_degrade, fade_edges
from tools.reference_match.radio import apply_step_band_color, static_bed, tuning_chirp


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
            degraded, meta = apply_radio_degrade(
                src,
                sample_rate,
                rng,
                heavy=bool(event["every_third_word"]),
                hp_hz=float(event["high_pass"]),
                lp_hz=float(event["low_pass"]),
                snr_db=float(event["snr_db"]),
            )
            at = int(float(event["start_s"]) * sample_rate)
            _mix(mix, degraded, at, float(event["gain"]))
            speech_samples += len(degraded)
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
