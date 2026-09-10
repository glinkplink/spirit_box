#!/usr/bin/env python3
"""Recompute named-run measurements without modifying original recordings.

Writes analysis derivatives into a new directory. Original WAVs, events.jsonl,
and summaries are read-only. This is not a listening verdict and not AVAudioEngine
parity.

Metric definitions:
- scheduled_vocal_slot_occupancy: vocal events / total events in events.jsonl
  using contains_vocal == true (scheduler occupancy, not ASR).
- vocal_exposure_fraction_of_elapsed: sum(emitted_frame_count) / (duration * rate)
  when frame counts exist; otherwise sum(exposed_duration_ms)/1000 / duration.
  This is audible-window occupancy, not slot probability.
- speech_band_energy_fraction: mean FFT power in [low, high] Hz / total power
  on a downmix, whole file.
- full_mix_dynamics: ffmpeg loudnorm input_i / input_tp / input_lra on the
  derivative downmix. LRA is not proof of compressor causation.
- noise_only_bed_modulation: tools.check_sweep_acoustics
  noise_envelope_p90_over_early_slot_min_median_db when slots align to the WAV.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import statistics
import subprocess
import sys
import wave
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

_REPO_ROOT = Path(__file__).resolve().parent.parent
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_events(path: Path) -> list[dict]:
    events = []
    for line in path.read_text().splitlines():
        if line.strip():
            events.append(json.loads(line))
    return events


def wav_info(path: Path) -> dict:
    with wave.open(str(path), "rb") as wav:
        channels = wav.getnchannels()
        rate = wav.getframerate()
        width = wav.getsampwidth()
        frames = wav.getnframes()
        duration = frames / rate if rate else 0.0
        return {
            "path": str(path),
            "channels": channels,
            "sample_rate": rate,
            "sample_width_bytes": width,
            "frames": frames,
            "duration_seconds": duration,
            "sha256": sha256_file(path),
        }


def downmix_to_mono_pcm16(src: Path, dest: Path) -> dict:
    """Mean of all channels → 16-bit mono WAV. Does not touch the source file."""
    import numpy as np

    with wave.open(str(src), "rb") as wav:
        channels = wav.getnchannels()
        rate = wav.getframerate()
        width = wav.getsampwidth()
        frames = wav.getnframes()
        raw = wav.readframes(frames)
        if width != 2:
            raise ValueError(f"{src}: only 16-bit PCM is supported, got {width * 8}-bit")
        pcm = np.frombuffer(raw, dtype="<i2").astype(np.int32)
        if channels > 1:
            pcm = pcm.reshape(-1, channels).mean(axis=1)
        else:
            pcm = pcm.astype(np.int32)
        mono = np.clip(np.rint(pcm), -32768, 32767).astype("<i2")
    dest.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(dest), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(rate)
        out.writeframes(mono.tobytes())
    return {
        "source": str(src),
        "derivative": str(dest),
        "channel_treatment": "mean of all channels, then clip to int16",
        "source_channels": channels,
        "output_channels": 1,
        "sample_rate": rate,
    }


def event_metrics(events: list[dict], duration_seconds: float, sample_rate: int) -> dict:
    total = len(events)
    vocals = [e for e in events if e.get("contains_vocal") and e.get("asset_id")]
    rates = sorted({int(e.get("sweep_rate_ms", 0)) for e in events})
    directions = sorted({e.get("direction") for e in events})
    exposures_ms = []
    exposures_from_frames = []
    emitted_frames = 0
    for event in vocals:
        if event.get("emitted_frame_count") is not None:
            frames = int(event["emitted_frame_count"])
            emitted_frames += frames
            exposures_from_frames.append(frames / sample_rate * 1000.0)
        if event.get("exposed_duration_ms") is not None:
            exposures_ms.append(int(event["exposed_duration_ms"]))
    occupancy = (len(vocals) / total) if total else None
    elapsed_frames = duration_seconds * sample_rate if duration_seconds else 0
    exposure_fraction = (emitted_frames / elapsed_frames) if elapsed_frames else None
    assets = [e.get("asset_id") for e in vocals]
    performers = [e.get("performer_id") for e in vocals if e.get("performer_id")]
    consecutive_performer = 0
    run = 0
    previous = None
    for performer in performers:
        if performer == previous:
            run += 1
        else:
            run = 1
            previous = performer
        consecutive_performer = max(consecutive_performer, run)
    vocal_run = 0
    max_vocal_run = 0
    for event in events:
        if event.get("contains_vocal") and event.get("asset_id"):
            vocal_run += 1
            max_vocal_run = max(max_vocal_run, vocal_run)
        else:
            vocal_run = 0
    first_render = events[0].get("render_time_seconds") if events else None
    last_render = events[-1].get("render_time_seconds") if events else None
    has_capture_time = any(e.get("capture_time_seconds") is not None for e in events)
    return {
        "total_slots": total,
        "vocal_slots": len(vocals),
        "scheduled_vocal_slot_occupancy": occupancy,
        "events_per_minute": (len(vocals) / duration_seconds * 60.0) if duration_seconds else None,
        "observed_sweep_rate_ms": rates,
        "observed_directions": directions,
        "unique_assets": len(set(assets)),
        "repeat_uses": len(assets) - len(set(assets)),
        "max_consecutive_same_performer": consecutive_performer,
        "max_vocal_run": max_vocal_run,
        "exposure_ms_min_median_max": (
            [min(exposures_ms), statistics.median(exposures_ms), max(exposures_ms)]
            if exposures_ms else None
        ),
        "exposure_ms_from_frames_min_median_max": (
            [
                min(exposures_from_frames),
                statistics.median(exposures_from_frames),
                max(exposures_from_frames),
            ]
            if exposures_from_frames else None
        ),
        "vocal_exposure_fraction_of_elapsed": exposure_fraction,
        "sum_emitted_frames": emitted_frames,
        "first_render_time_seconds": first_render,
        "last_render_time_seconds": last_render,
        "has_capture_time_seconds": has_capture_time,
        "performer_counts": dict(Counter(performers)),
    }


def ffmpeg_loudness(path: Path) -> dict:
    proc = subprocess.run(
        [
            "ffmpeg", "-hide_banner", "-nostats", "-i", str(path),
            "-af", "loudnorm=I=-17:TP=-1:LRA=11:print_format=json",
            "-f", "null", "-",
        ],
        capture_output=True, text=True, check=True,
    )
    blob = proc.stderr[proc.stderr.rfind("{") :]
    meter, _ = json.JSONDecoder().raw_decode(blob)
    return {
        "integrated_lufs": float(meter["input_i"]),
        "true_peak_dbtp": float(meter["input_tp"]),
        "lra": float(meter["input_lra"]),
        "threshold": float(meter["input_thresh"]),
        "tool": "ffmpeg loudnorm print_format=json",
        "note": (
            "LRA is a full-mix loudness-range measurement. "
            "Low LRA does not prove compressor causation."
        ),
    }


def speech_band_fraction(path: Path, low_hz: float, high_hz: float) -> dict:
    import numpy as np

    with wave.open(str(path), "rb") as wav:
        assert wav.getnchannels() == 1 and wav.getsampwidth() == 2
        rate = wav.getframerate()
        pcm = np.frombuffer(wav.readframes(wav.getnframes()), dtype="<i2").astype(float) / 32768
    size = rate
    usable = pcm[: pcm.size // size * size]
    if usable.size == 0:
        return {"fraction": None, "reason": "file shorter than 1 second"}
    windows = usable.reshape(-1, size)
    power = np.abs(np.fft.rfft(windows * np.hanning(size), axis=1)) ** 2
    spectrum = power.sum(axis=0)
    hz = np.fft.rfftfreq(size, 1 / rate)
    band = float(spectrum[(hz >= low_hz) & (hz <= high_hz)].sum() / spectrum.sum())
    presence = float(spectrum[(hz >= 1000) & (hz <= 3500)].sum() / spectrum.sum())
    sample_peak = float(20 * np.log10(max(1e-12, np.max(np.abs(pcm)))))
    return {
        "speech_band_hz": [low_hz, high_hz],
        "speech_band_energy_fraction": band,
        "presence_1k_3k5_fraction": presence,
        "sample_peak_dbfs": sample_peak,
        "definition": "mean 1-second windowed rFFT power in band / total power; DC retained in denominator",
    }


def slot_boundary_jumps(pcm, rate, events) -> dict:
    """Inspect sample discontinuities at logged slot starts. Not a click verdict."""
    import numpy as np
    from tools.check_sweep_acoustics import slot_start_seconds

    jumps = []
    aligned = 0
    for event in events:
        start = round(slot_start_seconds(event) * rate)
        if start <= 0 or start >= pcm.size:
            continue
        aligned += 1
        jumps.append(float(abs(pcm[start] - pcm[start - 1])))
    if not jumps:
        return {"aligned_boundaries": 0, "max_abs_sample_jump": None, "median_abs_sample_jump": None}
    return {
        "aligned_boundaries": aligned,
        "max_abs_sample_jump": max(jumps),
        "median_abs_sample_jump": float(statistics.median(jumps)),
        "p95_abs_sample_jump": float(sorted(jumps)[int(0.95 * (len(jumps) - 1))]),
        "note": (
            "Peak adjacent-sample delta at logged slot starts on the downmix. "
            "A large jump is a candidate click, not proof. Short clips alone do not prove clicks."
        ),
    }


def recompute_run(name: str, src: Path, out_root: Path) -> dict:
    wav = src / "engine-output.wav"
    events_path = src / "events.jsonl"
    summary_path = src / "summary.json"
    events = load_events(events_path)
    info = wav_info(wav)
    summary = json.loads(summary_path.read_text()) if summary_path.exists() else {}
    dest = out_root / name
    dest.mkdir(parents=True, exist_ok=True)
    downmix = dest / "sweep.wav"
    treatment = downmix_to_mono_pcm16(wav, downmix)
    shutil.copy2(events_path, dest / "events.jsonl")
    metrics = event_metrics(events, info["duration_seconds"], info["sample_rate"])
    report = {
        "run": name,
        "label": "RECOMPUTED",
        "original_wav": info,
        "summary_run_id": summary.get("run_id"),
        "summary_corpus_label": summary.get("corpus_label"),
        "summary_corpus_source": summary.get("corpus_source"),
        "build_sha_effective_settings_in_bundle": "UNKNOWN",
        "downmix": treatment,
        "event_metrics": metrics,
        "listening": "NOT_RUN",
    }
    try:
        report["loudness"] = ffmpeg_loudness(downmix)
        report["loudness"]["label"] = "RECOMPUTED"
    except (subprocess.CalledProcessError, FileNotFoundError, ValueError) as exc:
        report["loudness"] = {"label": "UNKNOWN", "error": str(exc)}
    try:
        report["speech_band"] = speech_band_fraction(downmix, 400.0, 3500.0)
        report["speech_band"]["label"] = "RECOMPUTED"
    except Exception as exc:  # noqa: BLE001
        report["speech_band"] = {"label": "UNKNOWN", "error": str(exc)}
    acoustic = None
    try:
        from tools.check_sweep_acoustics import measure
        acoustic = measure(dest)
        report["noise_only_bed_modulation_db"] = acoustic.get(
            "noise_envelope_p90_over_early_slot_min_median_db"
        )
        report["vocal_slot_minus_noise_slot_db"] = acoustic.get("vocal_slot_minus_noise_slot_db")
        report["slot_acoustics_label"] = "RECOMPUTED"
    except Exception as exc:  # noqa: BLE001
        report["slot_acoustics_label"] = "UNKNOWN"
        report["slot_acoustics_error"] = str(exc)
        report["slot_acoustics_note"] = (
            "Live stereo captures without WAV-relative capture_time_seconds, "
            "or engine timelines that start far past file origin, cannot use this metric."
        )
    try:
        import numpy as np
        with wave.open(str(downmix), "rb") as wav:
            pcm = np.frombuffer(wav.readframes(wav.getnframes()), dtype="<i2").astype(float) / 32768
        report["slot_boundary_jumps"] = slot_boundary_jumps(pcm, info["sample_rate"], events)
        report["slot_boundary_jumps"]["label"] = "RECOMPUTED"
    except Exception as exc:  # noqa: BLE001
        report["slot_boundary_jumps"] = {"label": "UNKNOWN", "error": str(exc)}
    (dest / "recompute.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


def recompute_reference(path: Path, out_root: Path) -> dict:
    info = wav_info(path)
    dest = out_root / "references"
    dest.mkdir(parents=True, exist_ok=True)
    report = {
        "file": path.name,
        "sha256": info["sha256"],
        "bytes": path.stat().st_size,
        "wav": {k: v for k, v in info.items() if k != "sha256"},
        "hash_label": "RECOMPUTED",
        "whole_file_includes": "narration, room sound, and recording gain may be present",
        "not_an_app_gain_target": True,
        "listening": "NOT_RUN",
        "comparable_segment": "none documented in analysis.md",
        "speech_occupancy_proxy_from_analysis_md": "REPORTED_NOT_REPRODUCED",
    }
    (dest / f"{path.stem[:48]}.hash.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


def versions() -> dict:
    tools = {"python": sys.version}
    for name in ("ffmpeg", "ffprobe"):
        try:
            proc = subprocess.run([name, "-version"], capture_output=True, text=True, check=True)
            tools[name] = proc.stdout.splitlines()[0]
        except (FileNotFoundError, subprocess.CalledProcessError) as exc:
            tools[name] = f"unavailable: {exc}"
    try:
        import numpy
        tools["numpy"] = numpy.__version__
    except ImportError:
        tools["numpy"] = "unavailable"
    return tools


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--recordings-root", type=Path, default=Path("recordings"))
    parser.add_argument("--reference-root", type=Path, default=Path("reference_audio"))
    parser.add_argument("--output", type=Path, default=Path("build/run6-review-recompute"))
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    ledger = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "host": subprocess.check_output(["uname", "-a"], text=True).strip(),
        "tools": versions(),
        "channel_treatment": "live captures downmixed by mean of channels into a new directory; originals preserved",
        "listening": "NOT_RUN",
        "runs": {},
        "references": {},
    }
    for name in ("Run3", "Run4", "Run5"):
        src = args.recordings_root / name
        if not (src / "engine-output.wav").exists():
            ledger["runs"][name] = {"label": "UNKNOWN", "error": f"missing {src}"}
            continue
        ledger["runs"][name] = recompute_run(name, src, args.output)
    if args.reference_root.exists():
        for path in sorted(args.reference_root.glob("*.wav")):
            ledger["references"][path.name] = recompute_reference(path, args.output)
    (args.output / "ledger.json").write_text(json.dumps(ledger, indent=2) + "\n")
    print(json.dumps(ledger, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
