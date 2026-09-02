"""Offline analysis of local spirit-box reference recordings."""

from __future__ import annotations

import json
import math
import subprocess
import wave
from pathlib import Path
from typing import Any

import numpy as np

from tools.reference_match.constants import SAMPLE_RATE
from tools.reference_match.discover import discover_reference_files

BANDS = (
    ("rumble_20_150", 20.0, 150.0),
    ("low_150_400", 150.0, 400.0),
    ("speech_400_3500", 400.0, 3500.0),
    ("presence_3500_8000", 3500.0, 8000.0),
    ("hiss_8000_16000", 8000.0, 16000.0),
)


def extract_mono_wav(src: Path, dest: Path, sr: int = SAMPLE_RATE) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "ffmpeg",
        "-y",
        "-i",
        str(src),
        "-ac",
        "1",
        "-ar",
        str(sr),
        "-c:a",
        "pcm_s16le",
        str(dest),
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)


def load_wav(path: Path) -> tuple[np.ndarray, int]:
    with wave.open(str(path), "rb") as handle:
        sr = handle.getframerate()
        n = handle.getnframes()
        pcm = np.frombuffer(handle.readframes(n), dtype=np.int16).astype(np.float32) / 32768.0
        if handle.getnchannels() == 2:
            pcm = pcm.reshape(-1, 2).mean(axis=1)
    return pcm, sr


def _frame_signal(pcm: np.ndarray, sr: int, frame: int = 2048, hop: int = 512):
    if len(pcm) < frame:
        raise ValueError("audio too short")
    n_frames = 1 + (len(pcm) - frame) // hop
    window = np.hanning(frame).astype(np.float32)
    rms = np.empty(n_frames, dtype=np.float32)
    centroid = np.empty(n_frames, dtype=np.float32)
    flatness = np.empty(n_frames, dtype=np.float32)
    flux = np.empty(n_frames, dtype=np.float32)
    band_e = {name: np.empty(n_frames, dtype=np.float32) for name, _, _ in BANDS}
    freqs = np.fft.rfftfreq(frame, 1.0 / sr)
    prev = None
    for i in range(n_frames):
        sl = pcm[i * hop : i * hop + frame] * window
        spec = np.abs(np.fft.rfft(sl)) + 1e-12
        power = spec * spec
        rms[i] = float(np.sqrt(np.mean(sl * sl) + 1e-20))
        centroid[i] = float(np.sum(freqs * spec) / np.sum(spec))
        log_mean = float(np.mean(np.log(spec)))
        flatness[i] = float(math.exp(log_mean) / np.mean(spec))
        mag = spec / (np.max(spec) + 1e-12)
        if prev is None:
            flux[i] = 0.0
        else:
            diff = mag - prev
            flux[i] = float(np.sum(diff[diff > 0]))
        prev = mag
        total_power = float(np.sum(power) + 1e-20)
        for name, lo, hi in BANDS:
            mask = (freqs >= lo) & (freqs < hi)
            band_e[name][i] = float(np.sum(power[mask]) / total_power)
    times = (np.arange(n_frames) * hop + frame / 2) / sr
    return {
        "times": times,
        "rms": rms,
        "centroid": centroid,
        "flatness": flatness,
        "flux": flux,
        "bands": band_e,
        "hop": hop,
        "sr": sr,
    }


def _percentile(x: np.ndarray, p: float) -> float:
    return float(np.percentile(x, p))


def _dwell_from_flux(flux: np.ndarray, sr: int, hop: int) -> dict[str, Any]:
    x = flux - np.mean(flux)
    # restrict lag to 50-500 ms
    min_lag = max(1, int(0.05 * sr / hop))
    max_lag = min(len(x) // 3, int(0.50 * sr / hop))
    if max_lag <= min_lag + 2:
        return {"dwell_s": None, "confidence": "low", "method": "acf_failed"}
    ac = np.correlate(x, x, mode="full")
    ac = ac[len(ac) // 2 :]
    region = ac[min_lag:max_lag]
    peaks: list[tuple[float, int]] = []
    for i in range(1, len(region) - 1):
        if region[i] >= region[i - 1] and region[i] >= region[i + 1]:
            peaks.append((float(region[i]), i + min_lag))
    if not peaks:
        return {"dwell_s": None, "confidence": "low", "method": "acf_no_interior_peak"}
    peaks.sort(key=lambda item: item[0], reverse=True)
    peak_val_raw, peak_i = peaks[0]
    peak_val = float(peak_val_raw / (ac[0] + 1e-12))
    dwell = peak_i * hop / sr
    confidence = "high" if peak_val > 0.15 else "medium" if peak_val > 0.08 else "low"
    return {
        "dwell_s": float(dwell),
        "acf_peak_ratio": peak_val,
        "confidence": confidence,
        "method": "spectral_flux_acf_interior_peak",
        "search_range_s": [0.05, 0.50],
    }


def _speech_proxy(frames: dict[str, Any]) -> dict[str, Any]:
    rms = frames["rms"]
    flat = frames["flatness"]
    speech_e = frames["bands"]["speech_400_3500"]
    floor = _percentile(rms, 20)
    rms_db = 20 * np.log10(rms + 1e-12)
    floor_db = 20 * np.log10(floor + 1e-12)
    cand = (
        (rms_db > floor_db + 6.0)
        & (flat < np.median(flat) * 0.92)
        & (speech_e > np.median(speech_e) * 1.35)
    )
    occupancy = float(np.mean(cand))
    # burst lengths
    hop_s = frames["hop"] / frames["sr"]
    bursts = []
    run = 0
    for flag in cand:
        if flag:
            run += 1
        elif run:
            bursts.append(run * hop_s)
            run = 0
    if run:
        bursts.append(run * hop_s)
    gaps = []
    run = 0
    for flag in cand:
        if not flag:
            run += 1
        elif run:
            gaps.append(run * hop_s)
            run = 0
    return {
        "method": "energy_flatness_midband_proxy_not_asr",
        "occupancy": occupancy,
        "noise_floor_rms": float(floor),
        "noise_floor_dbfs": float(floor_db),
        "n_bursts": len(bursts),
        "burst_duration_s_median": float(np.median(bursts)) if bursts else 0.0,
        "burst_duration_s_p90": float(np.percentile(bursts, 90)) if bursts else 0.0,
        "gap_s_median": float(np.median(gaps)) if gaps else 0.0,
        "note": "INFERRED — this proxy cannot separate presenter voice from device speech.",
    }


def analyze_pcm(pcm: np.ndarray, sr: int, label: str) -> dict[str, Any]:
    peak = float(np.max(np.abs(pcm)))
    rms = float(np.sqrt(np.mean(pcm * pcm) + 1e-20))
    frames = _frame_signal(pcm, sr)
    band_rel = {name: float(np.mean(energy)) for name, energy in frames["bands"].items()}
    centroid = frames["centroid"]
    dwell = _dwell_from_flux(frames["flux"], sr, frames["hop"])
    speech = _speech_proxy(frames)
    hop = frames["hop"]
    loud_i = int(np.argmax(frames["rms"]))
    start = max(0, loud_i * hop - 2 * sr)
    stop = min(len(pcm), start + 4 * sr)
    segment = pcm[start:stop]
    slope = 0.0
    if len(segment) >= 2048:
        spec = np.abs(np.fft.rfft(segment * np.hanning(len(segment))))
        freqs = np.fft.rfftfreq(len(segment), 1 / sr)
        mask = (freqs > 80) & (freqs < 12000)
        if np.count_nonzero(mask) > 16:
            slope = float(np.polyfit(np.log(freqs[mask]), np.log(spec[mask] + 1e-12), 1)[0])
    if slope < -1.15:
        noise_class = "brown-ish / strongly low-weighted"
    elif slope < -0.55:
        noise_class = "pink-ish / radio static"
    elif slope < -0.15:
        noise_class = "mixed static, some hiss"
    else:
        noise_class = "whiter / high-frequency hissy"
    hf = band_rel["hiss_8000_16000"]
    lf = band_rel["rumble_20_150"]
    return {
        "label": label,
        "duration_s": len(pcm) / sr,
        "sample_rate": sr,
        "measured": {
            "peak": peak,
            "rms": rms,
            "crest_factor": peak / (rms + 1e-12),
            "rms_p10": _percentile(frames["rms"], 10),
            "rms_p50": _percentile(frames["rms"], 50),
            "rms_p90": _percentile(frames["rms"], 90),
            "centroid_hz_p10": _percentile(centroid, 10),
            "centroid_hz_p50": _percentile(centroid, 50),
            "centroid_hz_p90": _percentile(centroid, 90),
            "spectral_flatness_median": float(np.median(frames["flatness"])),
            "spectral_flux_median": float(np.median(frames["flux"])),
            "spectral_flux_p90": _percentile(frames["flux"], 90),
            "band_energy_relative": band_rel,
            "spectral_slope_loglog": slope,
            "rms_variability": float(np.std(frames["rms"]) / (np.mean(frames["rms"]) + 1e-12)),
        },
        "inferred": {
            "noise_class": noise_class,
            "low_frequency_rumble": "high" if lf > 0.35 else "moderate" if lf > 0.12 else "low",
            "high_frequency_hiss": "high" if hf > 0.25 else "moderate" if hf > 0.08 else "low",
            "midrange_speech_energy": (
                "high"
                if band_rel["speech_400_3500"] > 0.4
                else "moderate"
                if band_rel["speech_400_3500"] > 0.18
                else "low"
            ),
            "dwell": dwell,
            "speech_proxy": speech,
            "scan_character": (
                "rhythmic spectral movement likely"
                if dwell["confidence"] in {"high", "medium"}
                else "scan step timing unclear from flux ACF"
            ),
            "transition_character": (
                "sharp/clicky"
                if frames["flux"].max() > 8 * np.median(frames["flux"])
                else "softer / overlapping"
            ),
            "static_continuity": (
                "continuous noise floor"
                if _percentile(frames["rms"], 10) > 0.15 * _percentile(frames["rms"], 50)
                else "noise floor dips substantially"
            ),
        },
    }


def propose_params(reports: list[dict[str, Any]]) -> dict[str, Any]:
    dwells = []
    for r in reports:
        d = r["inferred"]["dwell"]
        if d.get("dwell_s") is None or d.get("confidence") == "low":
            continue
        if d["dwell_s"] < 0.055:
            continue
        dwells.append(d["dwell_s"])
    if dwells:
        dwell = float(np.median(dwells))
        dwell_note = "MEASURED median of flux-ACF peaks with non-low confidence"
    else:
        dwell = 0.16
        dwell_note = "INFERRED fallback; ACF confidence was low"
    occ = [r["inferred"]["speech_proxy"]["occupancy"] for r in reports]
    occ_med = float(np.median(occ))
    # Host/narration inflates occupancy; the device prototype stays mostly noise.
    speech_p = float(np.clip(min(occ_med, 0.18) * 0.32, 0.045, 0.08))
    noise_rms = float(np.median([r["measured"]["rms_p50"] for r in reports]))
    noise_rms = float(np.clip(noise_rms, 0.03, 0.08))
    centroids = [r["measured"]["centroid_hz_p50"] for r in reports]
    c = float(np.median(centroids))
    hp = 180.0 if c < 1800 else 240.0
    lp = 3800.0 if c < 2500 else 5200.0
    return {
        "dwell_s": dwell,
        "dwell_note": dwell_note,
        "speech_step_probability": speech_p,
        "noise_rms": noise_rms,
        "pink_mix": 0.60,
        "brown_mix": 0.24,
        "white_hiss_mix": 0.16,
        "hp_hz": hp,
        "lp_hz": lp,
        "tuning_hz_low": 850.0,
        "tuning_hz_high": 2700.0,
        "tuning_ms": 16.0,
        "click_fade_ms": 3.0,
        "ordinary_snr_db": [-8.0, 2.5],
        "heavy_snr_db": [-16.0, -8.0],
    }


def write_markdown(path: Path, discovered: list[Path], reports: list[dict[str, Any]], params: dict[str, Any]) -> None:
    lines = [
        "# Reference audio analysis",
        "",
        "Private acoustic references only. No speech was transcribed or copied.",
        "",
        "## Discovered files",
        "",
    ]
    for i, p in enumerate(discovered, 1):
        lines.append(f"{i}. `{p.name}`")
    for i, report in enumerate(reports, 1):
        m = report["measured"]
        inf = report["inferred"]
        lines += [
            "",
            f"## REFERENCE {i} — {report['label']}",
            "",
            "### MEASURED / OBSERVED",
            "",
            f"- duration: {report['duration_s']:.2f}s",
            f"- peak: {m['peak']:.4f}",
            f"- RMS: {m['rms']:.4f}",
            f"- crest factor: {m['crest_factor']:.2f}",
            f"- RMS p10/p50/p90: {m['rms_p10']:.4f} / {m['rms_p50']:.4f} / {m['rms_p90']:.4f}",
            f"- spectral centroid Hz p10/p50/p90: {m['centroid_hz_p10']:.0f} / {m['centroid_hz_p50']:.0f} / {m['centroid_hz_p90']:.0f}",
            f"- spectral slope (log-log): {m['spectral_slope_loglog']:.3f}",
            f"- spectral flatness median: {m['spectral_flatness_median']:.4f}",
            f"- spectral flux median / p90: {m['spectral_flux_median']:.3f} / {m['spectral_flux_p90']:.3f}",
            f"- relative band energy: `{json.dumps(m['band_energy_relative'], indent=None)}`",
            f"- RMS variability (std/mean): {m['rms_variability']:.3f}",
            "",
            "### INFERRED / APPROXIMATED",
            "",
            f"- noise class: {inf['noise_class']}",
            f"- rumble: {inf['low_frequency_rumble']}; hiss: {inf['high_frequency_hiss']}; mid speech energy: {inf['midrange_speech_energy']}",
            f"- dwell estimate: {inf['dwell']}",
            f"- speech occupancy proxy: {inf['speech_proxy']['occupancy']:.3f} (NOT ASR; host voice may dominate)",
            f"- burst median / p90 s: {inf['speech_proxy']['burst_duration_s_median']:.3f} / {inf['speech_proxy']['burst_duration_s_p90']:.3f}",
            f"- gap median s: {inf['speech_proxy']['gap_s_median']:.3f}",
            f"- scan: {inf['scan_character']}",
            f"- transitions: {inf['transition_character']}",
            f"- static: {inf['static_continuity']}",
        ]
    lines += [
        "",
        "## COMMON CHARACTERISTICS",
        "",
        "- Continuous noisy bed with radio-like spectral tilt rather than pure white noise.",
        "- Mid-band energy present; high-frequency hiss is part of the texture.",
        "- Loudness is not a single stable tone; RMS varies.",
        "- Apparent speech-like bursts sit inside noise rather than replacing it.",
        "",
        "## DIFFERENCES",
        "",
        "- The two recordings differ in duration, presenter/device mix, and likely sweep rate.",
        "- Do not treat either file as the universal P-SB7 sound.",
        "",
        "## PROPOSED 20-SECOND SYNTHESIS PARAMETERS",
        "",
        "```json",
        json.dumps(params, indent=2),
        "```",
        "",
        "These parameters match the broad acoustic class. They are not a waveform fit.",
        "",
    ]
    path.write_text("\n".join(lines) + "\n")


def run_analysis(reference_dir: Path, out_dir: Path) -> dict[str, Any]:
    discovered = discover_reference_files(reference_dir)
    print("Discovered reference files:")
    for path in discovered:
        print(f"  {path.name}")
    out_dir.mkdir(parents=True, exist_ok=True)
    reports = []
    extracted = []
    for i, src in enumerate(discovered, 1):
        dest = out_dir / f"ref_{i:02d}.wav"
        extract_mono_wav(src, dest)
        pcm, sr = load_wav(dest)
        report = analyze_pcm(pcm, sr, src.name)
        report["extracted_wav"] = str(dest)
        report["source_path"] = str(src)
        reports.append(report)
        extracted.append(str(dest))
    params = propose_params(reports)
    payload = {
        "discovered_filenames": [p.name for p in discovered],
        "extracted": extracted,
        "references": reports,
        "proposed_synthesis_params": params,
        "reference_audio_not_for_training": True,
    }
    (out_dir / "analysis.json").write_text(json.dumps(payload, indent=2))
    write_markdown(out_dir / "analysis.md", discovered, reports, params)
    return payload
