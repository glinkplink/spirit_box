"""Automated QA for the offline 20s reference-match prototype.

Perceptual success is a human listen. These checks only cover
mechanical renderer contracts.
"""

from __future__ import annotations

import json
import subprocess
import sys
import wave
from pathlib import Path

import numpy as np
import pytest

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.reference_match.constants import DEFAULT_SEED, DURATION_S, SAMPLE_RATE
from tools.reference_match.degrade import apply_radio_degrade, crop_word_window
from tools.reference_match.discover import MEDIA_EXTENSIONS, discover_reference_files
from tools.reference_match.render import mix_station_replace, render_session, station_gate
from tools.reference_match.schedule import build_schedule
from tools.reference_match.words import BANNED_SUBSTRINGS, WORD_POOL, is_allowed_word


def _sine_word(freq: float, seconds: float = 0.38) -> np.ndarray:
    n = int(seconds * SAMPLE_RATE)
    t = np.arange(n, dtype=np.float64) / SAMPLE_RATE
    env = np.hanning(n)
    return (0.35 * np.sin(2 * np.pi * freq * t) * env).astype(np.float32)


def _bank_for_schedule(schedule) -> dict[tuple[str, str], np.ndarray]:
    bank = {}
    for event in schedule["events"]:
        if event["event_type"] != "speech":
            continue
        key = (event["voice"], event["source_word"])
        if key not in bank:
            bank[key] = _sine_word(220 + 17 * (hash(key[1]) % 40))
    return bank


def test_word_pool_is_mundane_and_non_paranormal():
    assert len(WORD_POOL) >= 80
    for word in WORD_POOL:
        assert is_allowed_word(word)
        lowered = word.lower()
        for banned in BANNED_SUBSTRINGS:
            assert banned not in lowered


def test_discover_requires_exactly_two_media_files(tmp_path: Path):
    (tmp_path / "ignore.txt").write_text("nope")
    (tmp_path / ".hidden.wav").write_bytes(b"x")
    with pytest.raises(SystemExit):
        discover_reference_files(tmp_path)

    (tmp_path / "a.wav").write_bytes(b"RIFF")
    (tmp_path / "b.mp3").write_bytes(b"ID3")
    found = discover_reference_files(tmp_path)
    assert [p.name for p in found] == ["a.wav", "b.mp3"]
    assert MEDIA_EXTENSIONS

    (tmp_path / "c.m4a").write_bytes(b"x")
    with pytest.raises(SystemExit):
        discover_reference_files(tmp_path)


def test_schedule_is_deterministic_and_tags_every_third_word():
    a = build_schedule(seed=DEFAULT_SEED, duration_s=DURATION_S)
    b = build_schedule(seed=DEFAULT_SEED, duration_s=DURATION_S)
    assert a == b

    speech = [e for e in a["events"] if e["event_type"] == "speech"]
    assert speech
    assert all(e["source_word_index"] >= 1 for e in speech)
    heavy = [e for e in speech if e["every_third_word"]]
    assert heavy
    for event in heavy:
        assert event["source_word_index"] % 3 == 0
        assert event["intelligibility_class"] == "heavy"
    ordinary = [e for e in speech if not e["every_third_word"]]
    assert ordinary
    assert all(e["intelligibility_class"] == "degraded" for e in ordinary)
    assert all(e["source_word_index"] % 3 != 0 for e in ordinary)

    note = a["prototype_notes"]["every_third_word_rule"]
    assert "NOT THE FINAL PRODUCT" in note


def test_schedule_has_noise_only_and_partial_speech_occupancy():
    schedule = build_schedule(seed=DEFAULT_SEED, duration_s=DURATION_S)
    steps = schedule["scan_steps"]
    noise_only = [s for s in steps if s["has_speech"] is False]
    with_speech = [s for s in steps if s["has_speech"] is True]
    assert noise_only
    assert with_speech
    speech_time = sum(
        e["end_s"] - e["start_s"]
        for e in schedule["events"]
        if e["event_type"] == "speech"
    )
    assert 0.4 < speech_time < 8.0
    holds = [s["station_run_length"] for s in with_speech]
    assert max(holds) <= 3
    words_per_run = {}
    for event in schedule["events"]:
        if event["event_type"] != "speech":
            continue
        words_per_run.setdefault(event["station_run_id"], []).append(event["source_word"])
    assert all(1 <= len(ws) <= 5 for ws in words_per_run.values())


def test_heavy_degradation_is_materially_stronger_than_ordinary():
    rng_a = np.random.default_rng(3)
    rng_b = np.random.default_rng(3)
    src = _sine_word(440.0, 0.45)

    def tone_bin(x: np.ndarray) -> float:
        spec = np.abs(np.fft.rfft(x * np.hanning(len(x))))
        freqs = np.fft.rfftfreq(len(x), 1.0 / SAMPLE_RATE)
        idx = int(np.argmin(np.abs(freqs - 440.0)))
        return float(spec[idx] + 1e-12)

    ordinary, _ = apply_radio_degrade(
        src, SAMPLE_RATE, rng_a, heavy=False, hp_hz=220, lp_hz=4200, snr_db=-2.0
    )
    heavy, _ = apply_radio_degrade(
        src, SAMPLE_RATE, rng_b, heavy=True, hp_hz=400, lp_hz=2200, snr_db=-12.0
    )
    assert tone_bin(heavy) < tone_bin(ordinary) * 0.85


def test_crops_are_forward_windows_not_reversed():
    src = np.linspace(-0.2, 0.8, 8000, dtype=np.float32)
    cropped, meta = crop_word_window(src, SAMPLE_RATE, rng=np.random.default_rng(9))
    assert meta["start_sample"] < meta["end_sample"]
    assert np.allclose(cropped, src[meta["start_sample"] : meta["end_sample"]])
    assert cropped[0] <= cropped[-1] + 1e-6 or meta["end_sample"] - meta["start_sample"] < 64


def test_render_duration_pcm_and_no_reference_paths(tmp_path: Path):
    schedule = build_schedule(seed=DEFAULT_SEED, duration_s=DURATION_S)
    wav_path = tmp_path / "out.wav"
    json_path = tmp_path / "out.json"
    result = render_session(
        schedule=schedule,
        speech_bank=_bank_for_schedule(schedule),
        wav_path=wav_path,
        json_path=json_path,
    )
    with wave.open(str(wav_path), "rb") as handle:
        assert handle.getframerate() == SAMPLE_RATE
        assert handle.getnchannels() == 1
        frames = handle.getnframes()
        pcm = np.frombuffer(handle.readframes(frames), dtype=np.int16).astype(np.float32)
    duration = frames / SAMPLE_RATE
    assert abs(duration - DURATION_S) <= 0.02
    assert np.isfinite(pcm).all()
    peak = float(np.max(np.abs(pcm))) / 32767.0
    assert peak <= 0.99
    payload = json.loads(json_path.read_text())
    assert payload["seed"] == DEFAULT_SEED
    blob = json.dumps(payload)
    assert payload["copied_reference_samples"] is False
    assert "reference_audio/" not in blob
    assert all(e.get("pcm_reversed", False) is False for e in payload["events"])
    speech_events = [e for e in payload["events"] if e["event_type"] == "speech"]
    assert any(e["every_third_word"] for e in speech_events)
    assert result["speech_occupancy"] < 0.5
    # Identical seed must match exactly.
    wav2 = tmp_path / "out2.wav"
    json2 = tmp_path / "out2.json"
    render_session(
        schedule=build_schedule(seed=DEFAULT_SEED, duration_s=DURATION_S),
        speech_bank=_bank_for_schedule(schedule),
        wav_path=wav2,
        json_path=json2,
    )
    assert wav_path.read_bytes() == wav2.read_bytes()


def test_gitignore_covers_local_and_generated_paths():
    gitignore = (ROOT / ".gitignore").read_text()
    for pattern in (
        "reference_audio/",
        "build/",
        ".venv-kokoro/",
    ):
        assert pattern in gitignore
    samples = [
        "reference_audio/example.wav",
        "build/reference_audio_analysis/ref_01.wav",
        "build/reference_match/reference_match_20s.wav",
        ".venv-kokoro/lib/foo",
    ]
    for sample in samples:
        proc = subprocess.run(
            ["git", "check-ignore", "-q", sample],
            cwd=ROOT,
            check=False,
        )
        assert proc.returncode == 0, sample


def test_crop_word_window_is_mid_utterance_100_to_180ms():
    src = np.linspace(-0.4, 0.9, int(0.80 * SAMPLE_RATE), dtype=np.float32)
    n = len(src)
    for seed in range(24):
        cropped, meta = crop_word_window(src, SAMPLE_RATE, np.random.default_rng(seed))
        dur_ms = 1000.0 * (meta["end_sample"] - meta["start_sample"]) / SAMPLE_RATE
        assert 100.0 <= dur_ms <= 180.0
        mid = n / 2
        crop_mid = 0.5 * (meta["start_sample"] + meta["end_sample"])
        assert abs(crop_mid - mid) <= 0.08 * n


def test_schedule_speech_is_one_step_one_word():
    schedule = build_schedule(seed=DEFAULT_SEED, duration_s=DURATION_S)
    speech = [e for e in schedule["events"] if e["event_type"] == "speech"]
    assert speech
    assert all(int(e["station_run_length"]) == 1 for e in speech)
    by_run: dict[str, list] = {}
    for event in speech:
        by_run.setdefault(event["station_run_id"], []).append(event)
    assert all(len(ws) == 1 for ws in by_run.values())
    for event in speech:
        gate_ms = 1000.0 * (event["end_s"] - event["start_s"])
        assert 100.0 <= gate_ms <= 180.0


def test_station_gate_has_40ms_class_edges():
    n = int(0.125 * SAMPLE_RATE)
    gate = station_gate(n, SAMPLE_RATE, edge_ms=40.0)
    assert gate[0] == 0.0
    assert gate[-1] == 0.0
    assert float(np.max(gate)) == pytest.approx(1.0)
    tenth = float(np.argmax(gate >= 0.1)) / SAMPLE_RATE
    ninetieth = float(np.argmax(gate >= 0.9)) / SAMPLE_RATE
    attack_ms = 1000.0 * (ninetieth - tenth)
    assert 30.0 <= attack_ms <= 50.0


def test_mix_station_replace_ducks_hiss_under_the_gate():
    n = int(0.40 * SAMPLE_RATE)
    noise = np.ones(n, dtype=np.float32)
    station = np.full(n, 0.2, dtype=np.float32)
    gate = station_gate(int(0.125 * SAMPLE_RATE), SAMPLE_RATE, edge_ms=40.0)
    at = int(0.10 * SAMPLE_RATE)
    mix_station_replace(noise, station[: len(gate)], at, gate, noise_duck_db=-np.inf)
    center = at + len(gate) // 2
    assert noise[center] == pytest.approx(0.2, abs=0.02)
    assert noise[10] == pytest.approx(1.0)
    assert noise[at + len(gate) + 10] == pytest.approx(1.0)


def test_render_speech_hit_peak_stays_at_or_below_minus_15_dbfs(tmp_path: Path):
    schedule = build_schedule(seed=DEFAULT_SEED, duration_s=DURATION_S)
    wav_path = tmp_path / "out.wav"
    json_path = tmp_path / "out.json"
    render_session(
        schedule=schedule,
        speech_bank=_bank_for_schedule(schedule),
        wav_path=wav_path,
        json_path=json_path,
    )
    with wave.open(str(wav_path), "rb") as handle:
        pcm = np.frombuffer(handle.readframes(handle.getnframes()), dtype=np.int16).astype(
            np.float32
        ) / 32768.0
    speech = [e for e in schedule["events"] if e["event_type"] == "speech"]
    assert speech
    limit = 10 ** (-15.0 / 20.0) + 0.02
    for event in speech:
        a = int(event["start_s"] * SAMPLE_RATE)
        b = int(event["end_s"] * SAMPLE_RATE)
        peak = float(np.max(np.abs(pcm[a:b])))
        assert peak <= limit
