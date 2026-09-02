from __future__ import annotations

from typing import Any

import numpy as np

from tools.reference_match.constants import DEFAULT_SEED, DEFAULT_SYNTHESIS, DURATION_S, VOICES
from tools.reference_match.words import WORD_POOL


def _voice_cycle(rng: np.random.Generator) -> list[str]:
    ids = [v["id"] for v in VOICES]
    rng.shuffle(ids)
    return ids


def build_schedule(
    seed: int = DEFAULT_SEED,
    duration_s: float = DURATION_S,
    params: dict[str, Any] | None = None,
) -> dict[str, Any]:
    cfg = dict(DEFAULT_SYNTHESIS)
    if params:
        cfg.update(params)
    rng = np.random.default_rng(seed)
    dwell = float(cfg["dwell_s"])
    n_steps = int(round(duration_s / dwell))
    dwell = duration_s / n_steps
    voices = _voice_cycle(rng)
    events: list[dict[str, Any]] = []
    steps: list[dict[str, Any]] = []
    word_index = 0
    step = 0
    run_serial = 0
    voice_i = 0

    events.append(
        {
            "time": 0.0,
            "event_type": "noise_bed",
            "scan_dwell_index": None,
            "voice": None,
            "source_word": None,
            "source_word_index": None,
            "every_third_word": False,
            "intelligibility_class": "n/a",
            "gain": float(cfg["noise_rms"]),
            "high_pass": 80.0,
            "low_pass": 12000.0,
            "static_level": float(cfg["noise_rms"]),
            "tone_hz": None,
            "station_run_id": None,
            "rng_seed": seed,
            "pcm_reversed": False,
        }
    )

    while step < n_steps:
        t0 = step * dwell
        t1 = min(duration_s, (step + 1) * dwell)
        in_guard = t0 < 1.15 or t0 > duration_s - 0.7
        prev_speech = bool(steps and steps[-1].get("has_speech"))
        start_run = (not in_guard) and (not prev_speech) and (
            rng.random() < float(cfg["speech_step_probability"])
        )
        if start_run:
            run_serial += 1
            run_len = 1
            n_words = 1
            voice = voices[voice_i % len(voices)]
            voice_i += 1
            word_times = np.linspace(t0 + 0.01, t1 + (run_len - 1) * dwell - 0.03, n_words)
            for local_i, wt in enumerate(word_times):
                word_index += 1
                every_third = word_index % 3 == 0
                word = str(WORD_POOL[int(rng.integers(0, len(WORD_POOL)))])
                hp = float(rng.uniform(160.0, 380.0))
                lp = float(rng.uniform(2800.0, 6200.0))
                gate_ms = float(
                    rng.uniform(
                        float(cfg.get("station_gate_ms_min", 100.0)),
                        float(cfg.get("station_gate_ms_max", 180.0)),
                    )
                )
                if every_third:
                    hp = float(rng.uniform(280.0, 480.0))
                    lp = float(rng.uniform(1600.0, 2800.0))
                    snr = float(rng.uniform(*cfg["heavy_snr_db"]))
                    gain = float(rng.uniform(0.18, 0.42))
                    intel = "heavy"
                else:
                    snr = float(rng.uniform(*cfg["ordinary_snr_db"]))
                    gain = float(rng.uniform(0.28, 0.72))
                    intel = "degraded"
                events.append(
                    {
                        "time": float(wt),
                        "start_s": float(wt),
                        "end_s": float(min(duration_s, wt + gate_ms / 1000.0)),
                        "gate_ms": gate_ms,
                        "edge_ms": float(cfg.get("station_edge_ms", 40.0)),
                        "event_type": "speech",
                        "scan_dwell_index": step + min(local_i, run_len - 1),
                        "voice": voice,
                        "source_word": word,
                        "source_word_id": f"w{word_index:03d}",
                        "source_word_index": word_index,
                        "every_third_word": every_third,
                        "intelligibility_class": intel,
                        "gain": gain,
                        "high_pass": hp,
                        "low_pass": lp,
                        "snr_db": snr,
                        "static_level": float(cfg["noise_rms"]),
                        "tone_hz": None,
                        "station_run_id": f"run_{run_serial:02d}",
                        "station_run_length": run_len,
                        "rng_seed": seed,
                        "pcm_reversed": False,
                    }
                )
            for k in range(run_len):
                sidx = step + k
                st0 = sidx * dwell
                st1 = min(duration_s, (sidx + 1) * dwell)
                tone_hz = float(rng.uniform(cfg["tuning_hz_low"], cfg["tuning_hz_high"]))
                bp_center = float(rng.uniform(900.0, 3800.0))
                steps.append(
                    {
                        "scan_dwell_index": sidx,
                        "start_s": st0,
                        "end_s": st1,
                        "has_speech": True,
                        "station_run_id": f"run_{run_serial:02d}",
                        "station_run_length": run_len,
                        "tone_hz": tone_hz,
                        "bandpass_center_hz": bp_center,
                    }
                )
                events.append(
                    {
                        "time": st0,
                        "event_type": "tuning_tone",
                        "scan_dwell_index": sidx,
                        "voice": None,
                        "source_word": None,
                        "every_third_word": False,
                        "intelligibility_class": "n/a",
                        "gain": float(rng.uniform(0.012, 0.035)),
                        "high_pass": None,
                        "low_pass": None,
                        "static_level": float(cfg["noise_rms"]),
                        "tone_hz": tone_hz,
                        "tone_ms": float(cfg["tuning_ms"]),
                        "bandpass_center_hz": bp_center,
                        "station_run_id": f"run_{run_serial:02d}",
                        "rng_seed": seed,
                        "pcm_reversed": False,
                    }
                )
            step += run_len
            continue

        tone_hz = float(rng.uniform(cfg["tuning_hz_low"], cfg["tuning_hz_high"]))
        bp_center = float(rng.uniform(700.0, 4200.0))
        steps.append(
            {
                "scan_dwell_index": step,
                "start_s": t0,
                "end_s": t1,
                "has_speech": False,
                "station_run_id": None,
                "station_run_length": 0,
                "tone_hz": tone_hz,
                "bandpass_center_hz": bp_center,
            }
        )
        events.append(
            {
                "time": t0,
                "event_type": "tuning_tone",
                "scan_dwell_index": step,
                "voice": None,
                "source_word": None,
                "every_third_word": False,
                "intelligibility_class": "n/a",
                "gain": float(rng.uniform(0.016, 0.04)),
                "high_pass": None,
                "low_pass": None,
                "static_level": float(cfg["noise_rms"]),
                "tone_hz": tone_hz,
                "tone_ms": float(cfg["tuning_ms"]),
                "bandpass_center_hz": bp_center,
                "station_run_id": None,
                "rng_seed": seed,
                "pcm_reversed": False,
            }
        )
        step += 1

    events.sort(key=lambda e: (float(e["time"]), e["event_type"] != "noise_bed"))
    return {
        "seed": seed,
        "duration_s": duration_s,
        "dwell_s": dwell,
        "synthesis_params": cfg,
        "scan_direction": "forward",
        "scan_direction_note": "forward/reverse later maps to source-space order, never PCM reversal",
        "voices": [v["id"] for v in VOICES],
        "events": events,
        "scan_steps": steps,
        "prototype_notes": {
            "every_third_word_rule": (
                "FOR THIS 20-SECOND PROTOTYPE ONLY, every 3rd source word is extra-masked. "
                "IT IS NOT THE FINAL PRODUCT BEHAVIOR."
            ),
            "non_semantic": True,
        },
    }
