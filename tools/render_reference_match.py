#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.reference_match.constants import DEFAULT_SEED, DURATION_S, SAMPLE_RATE, VOICES
from tools.reference_match.kokoro_words import synthesize_word
from tools.reference_match.render import render_session
from tools.reference_match.schedule import build_schedule


def _load_wav(path: Path) -> np.ndarray:
    with wave.open(str(path), "rb") as handle:
        pcm = np.frombuffer(handle.readframes(handle.getnframes()), dtype=np.int16)
        pcm = pcm.astype(np.float32) / 32768.0
        if handle.getnchannels() == 2:
            pcm = pcm.reshape(-1, 2).mean(axis=1)
        sr = handle.getframerate()
    if sr != SAMPLE_RATE:
        t_old = np.linspace(0, 1, num=len(pcm), endpoint=False)
        n_new = int(round(len(pcm) * SAMPLE_RATE / sr))
        pcm = np.interp(np.linspace(0, 1, n_new, endpoint=False), t_old, pcm).astype(np.float32)
    return pcm


def _ensure_bank(schedule: dict, cache_dir: Path) -> dict[tuple[str, str], np.ndarray]:
    bank = {}
    needed = {
        (e["voice"], e["source_word"])
        for e in schedule["events"]
        if e["event_type"] == "speech"
    }
    for voice, word in sorted(needed):
        dest = cache_dir / voice / f"{word}.wav"
        synthesize_word(word, voice, dest)
        bank[(voice, word)] = _load_wav(dest)
    return bank


def _write_comparison(path: Path, analysis: dict | None, schedule: dict) -> None:
    lines = [
        "# Reference comparison — 20s prototype",
        "",
        "Human listening is the pass/fail metric. This file records decisions.",
        "",
        "## REFERENCE OBSERVATIONS",
        "",
    ]
    if analysis:
        lines.append(f"- files: {analysis.get('discovered_filenames')}")
        for i, ref in enumerate(analysis.get("references", []), 1):
            m = ref["measured"]
            inf = ref["inferred"]
            lines += [
                f"- ref {i} `{ref['label']}` centroid p50 {m['centroid_hz_p50']:.0f} Hz, RMS {m['rms']:.4f}, inferred noise `{inf['noise_class']}`, dwell `{inf['dwell']}`",
            ]
    else:
        lines.append("- analysis.json was not present; defaults were used.")
    lines += [
        "",
        "## SYNTHESIS DECISIONS",
        "",
        f"- seed `{schedule['seed']}`, duration `{schedule['duration_s']}s`, dwell `{schedule['dwell_s']:.4f}s`",
        f"- voices: {schedule['voices']}",
        "- random mundane isolated words; no sentences; no paranormal vocabulary",
        "- most steps are noise/tuning; speech is intermittent",
        "- all speech is band-limited, cropped, and mixed into static",
        "- every 3rd source word is extra-masked (prototype-only rule, not product behavior)",
        "- scan direction is conceptual forward through source space; PCM is never reversed",
        "",
        "## WHAT WAS MEASURED",
        "",
        "- RMS, crest, spectral centroid, slope, band energy, flux, and flux-ACF dwell candidate",
        "",
        "## WHAT WAS INFERRED",
        "",
        "- noise color class, rumble/hiss labels, speech occupancy proxy (not ASR)",
        "- YouTube presenter voice may inflate speech occupancy; prototype stays conservative",
        "",
        "## KNOWN DIFFERENCES FROM REFERENCES",
        "",
        "- Generated speech is Kokoro TTS, not radio fragments",
        "- No Mel Meter / KII / room tone / camera handling noise",
        "- Two references cannot define every hardware unit or sweep setting",
        "- Tuning chirps are a procedural stand-in for heterodyne/scan artifacts",
        "",
        "## NEXT VARIABLES TO TUNE",
        "",
        "- dwell time",
        "- speech occupancy",
        "- SNR range",
        "- band-limit edges",
        "- tuning chirp level vs band-color movement",
        "- crackle density",
        "",
        "Prototype-only: every-third-word extra masking is a test fixture, not final product behavior.",
        "",
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines))


def main() -> None:
    parser = argparse.ArgumentParser(description="Render a 20s spirit-box reference-match prototype")
    parser.add_argument("--seed", type=int, default=DEFAULT_SEED)
    parser.add_argument("--analysis-json", default="build/reference_audio_analysis/analysis.json")
    parser.add_argument("--wav-out", default="build/reference_match/reference_match_20s.wav")
    parser.add_argument("--json-out", default="build/reference_match/reference_match_20s.json")
    parser.add_argument("--report-out", default="build/reference_match/REFERENCE_COMPARISON.md")
    parser.add_argument("--tts-cache", default="build/reference_match/tts_cache")
    args = parser.parse_args()

    analysis = None
    params = None
    analysis_path = Path(args.analysis_json)
    if analysis_path.exists():
        analysis = json.loads(analysis_path.read_text())
        params = analysis.get("proposed_synthesis_params")

    schedule = build_schedule(seed=args.seed, duration_s=DURATION_S, params=params)
    bank = _ensure_bank(schedule, Path(args.tts_cache))
    render_session(
        schedule=schedule,
        speech_bank=bank,
        wav_path=Path(args.wav_out),
        json_path=Path(args.json_out),
    )
    _write_comparison(Path(args.report_out), analysis, schedule)
    print(f"wrote {args.wav_out}")
    print(f"voices: {[v['id'] for v in VOICES]}")
    print(
        "regenerate: "
        f".venv-kokoro/bin/python tools/render_reference_match.py --seed {args.seed}"
    )


if __name__ == "__main__":
    main()
