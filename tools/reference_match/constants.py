from __future__ import annotations

SAMPLE_RATE = 48_000
DURATION_S = 20.0
DEFAULT_SEED = 20260902

VOICES = (
    {"id": "am_onyx", "lang": "a", "role": "lower_male"},
    {"id": "am_adam", "lang": "a", "role": "mid_male"},
    {"id": "am_michael", "lang": "a", "role": "older_textured_male"},
    {"id": "af_heart", "lang": "a", "role": "female"},
    {"id": "af_sky", "lang": "a", "role": "lighter_female"},
    {"id": "bm_george", "lang": "b", "role": "british_male"},
)

# Conservative defaults until analysis.json overrides them.
DEFAULT_SYNTHESIS = {
    "dwell_s": 0.16,
    "speech_step_probability": 0.06,
    "noise_rms": 0.045,
    "pink_mix": 0.62,
    "brown_mix": 0.22,
    "white_hiss_mix": 0.16,
    "hp_hz": 220.0,
    "lp_hz": 4500.0,
    "tuning_hz_low": 900.0,
    "tuning_hz_high": 2600.0,
    "tuning_ms": 18.0,
    "click_fade_ms": 3.0,
    "ordinary_snr_db": (-8.0, 3.0),
    "heavy_snr_db": (-16.0, -8.0),
    # EXP-001: shared station-strength gate. Does not retune noise color or scan clock.
    "station_gate_ms_min": 100.0,
    "station_gate_ms_max": 180.0,
    "station_edge_ms": 40.0,
    "station_noise_duck_db": -96.0,
    "station_peak_dbfs": -15.0,
    "station_hf_boost_db": 12.0,
}
