# Spirit Box audio run comparison

**Status:** forensic ledger — measurements and attributions, not a shipping verdict

**Date:** 2026-09-10

**Role:** Supporting research record. Does not override `docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md`. Experimental renderer values are not canonical product requirements and are not proof of P-SB7 equivalence.

Fact labels used below:

| Label | Meaning |
|---|---|
| **RECOMPUTED** | Derived in this revision from the named artifact with a documented method |
| **REPORTED_NOT_REPRODUCED** | Stated by a reviewer or earlier note; not independently reproduced here with the documented method |
| **SUBJECTIVE** | Listening opinion, score, or confidence. Not a measurement |
| **UNKNOWN** | Missing from the artifact. Do not infer from a filename or capture date |

Do not edit original run WAVs, `events.jsonl`, or summaries to “correct” history.

Original live captures live under gitignored `recordings/`. Reference files live under gitignored `reference_audio/` and must not be used as application source material.

---

## Metric definitions

### Scheduler vocal density

Vocal events / total logged sweep slots in `events.jsonl`, using `contains_vocal == true`. This is the renderer’s slot occupancy, not reference-file speech detection.

### Exposure

`exposed_duration_ms` / `emitted_frame_count` from vocal events. Frame counts are authoritative when both exist (`ms ≈ frames / 48`).

### Noise-bed modulation / spread

In `tools/check_sweep_acoustics.py`:

`noise_envelope_p90_over_early_slot_min_median_db` = `20 * log10(p90(2 ms RMS in noise-only slots) / median(min of the first ~10 ms of each noise-only slot))`.

The JSON field `noise_envelope_p90_p10_db` is a **compatibility alias for that same value**. It is **not** a p90/p10 ratio. Do not compare a renamed metric to historical numbers as if the definition changed.

The checker requires **WAV-aligned** slot timestamps. It prefers `capture_time_seconds` (capture WAV origin) and falls back to `render_time_seconds`. Live captures that started after the engine timeline, or stereo device taps versus the mono offline checker, can make this metric unmeasurable with the current script.

### Vocal emergence (slot proxy)

`vocal_slot_minus_noise_slot_db` = `20 * log10(median RMS of aligned vocal dwells / median RMS of aligned noise-only dwells)`.

This is a full-dwell RMS ratio. It is not a listening score. It is not automatically the same as a model’s “vocal emergence” figure.

### Vocal exposure fraction of elapsed time

`sum(emitted_frame_count) / (WAV duration × sample rate)`. This is **not** slot occupancy. Run5 is 33.3% slots but only **7.81%** of elapsed samples are vocal PCM.

### Full-mix loudness / LRA

ffmpeg 7.0.2 `loudnorm=I=-17:TP=-1:LRA=11:print_format=json` `input_i` / `input_tp` / `input_lra`.

**Channel treatment:** original live captures are 48 kHz 16-bit **stereo**. BS.1770 stereo integrated loudness of a dual-mono mix is ~3 LU higher than the mean-downmix used by the mono checker. Report **both**. Do not treat reference-file LUFS as an app gain target. Low LRA does not prove compressor causation.

### Sample peak vs true peak

A sample limiter ceiling (here −2.5 dBFS) does not prove a true-peak ceiling or the absence of underruns. True peak requires a reconstruction meter (ffmpeg `loudnorm` `input_tp` in the checker).

---

## Comparison table

| Run | Path | Duration | Rate / dir | Vocal / slots | Density | Events/min | Exposure min/med/max | Integrated LUFS (stereo original) | Sample peak | True peak | Noise spread | Vocal emergence | Preset / build |
|---|---|---:|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---|
| Run3 | `recordings/Run3/` | 120 s **RECOMPUTED** | mixed 75/125/200/300; FWD+REV **RECOMPUTED** | 209 / 812 **RECOMPUTED** | 25.7389% **RECOMPUTED** | 104.5 **RECOMPUTED** | 40 / 54 / 83 ms (40.0 / 54.625 / 83.896 ms from frames) **RECOMPUTED** | −23.98 **RECOMPUTED** (downmix −26.99; LRA 6.5) | −2.50 dBFS **RECOMPUTED** | −2.35 dBTP **RECOMPUTED** | 6.65 dB **RECOMPUTED** (mean-downmix, WAV-aligned) | +15.27 dB **RECOMPUTED** | UNKNOWN |
| Run4 | `recordings/Run4/` | 120 s **RECOMPUTED** | 300 ms FWD only **RECOMPUTED** | 60 / 400 **RECOMPUTED** | 15.0000% **RECOMPUTED** | 30.0 **RECOMPUTED** | 60 / 60 / 60 ms (2880 frames) **RECOMPUTED** | −18.76 **RECOMPUTED** (downmix −21.77; LRA 1.4) | −2.50 dBFS **RECOMPUTED** | −2.30 dBTP **RECOMPUTED** | UNKNOWN (engine timeline starts at 136.96 s; no `capture_time_seconds`) | UNKNOWN | UNKNOWN |
| Run5 | `recordings/Run5/` | 120 s **RECOMPUTED** | 300 ms FWD only **RECOMPUTED** | 133 / 399 **RECOMPUTED** | 33.3333% **RECOMPUTED** | 66.5 **RECOMPUTED** | 66 / 70 / 74 ms (66.0625 / 70.375 / 74.9375 ms from frames) **RECOMPUTED** | −15.37 **RECOMPUTED** (downmix −18.38; LRA 0.7) | −2.50 dBFS **RECOMPUTED** | −2.36 dBTP **RECOMPUTED** | 3.56 dB **RECOMPUTED** (mean-downmix, WAV-aligned) | +1.81 dB **RECOMPUTED** | UNKNOWN |
| Candidate 60 s 300 ms FWD | not rendered on this Linux host | — | 300 ms FWD intended | — | — | — | 120–180 ms configured long-source range **RECOMPUTED** from code | — | — | — | — | — | `listening-test` / `2026-09-10.sparse-exposure-v1`. Artifact: UNKNOWN until macOS/CI render of this PR SHA |
| Matched baseline 60 s | not rendered on this Linux host | — | same seed/rate/duration intended | — | — | — | 150–220 ms archived PR #31 range **RECOMPUTED** from frozen preset | — | — | — | — | — | `archived-continuous-static` / `2026-09-10.pr31`. Do not treat Run4/Run5 as this baseline |

Run5 **vocal exposure fraction of elapsed time** is **7.81% RECOMPUTED** (449728 emitted frames / 5_760_000). That is not 33% audible vocal time. Run4 is 3.00%. Run3 mixed-rate is 9.79%.

Subjective model scores 5.0 / 3.5 / 6.5 for Run3 / Run4 / Run5 are **SUBJECTIVE** only. They are not objective measurements. Reference “10/10” is **not** a calibrated benchmark. This revision did **not** listen to the files.

Independent recompute commands, tool versions, and derivatives: `tools/recompute_audio_review.py` → gitignored `build/run6-review-recompute/` (originals untouched).

---

## Per-run provenance

### Run3 — `recordings/Run3/`

| Field | Value | Label |
|---|---|---|
| Artifact | `engine-output.wav`, `events.jsonl`, `summary.json` | path |
| WAV SHA-256 | `3899260801fafdb3ca1dc31503c7d8e34c51c5d03a427717b73c6383f629bca2` | **RECOMPUTED** |
| WAV format | 48 kHz, 16-bit, **stereo**, 120.0 s | **RECOMPUTED** |
| Run ID | `20260909-234802-86b84c46` | from `summary.json` |
| Started / ended | 2026-09-10T03:48:02Z / 2026-09-10T03:50:02Z | from `summary.json` |
| Build / SHA / effective settings | not present in the bundle | **UNKNOWN** |
| Seed / scheduler init | not present | **UNKNOWN** |
| Corpus | Bundle/Phase1, 1,200 assets, label “VCTK six-speaker renderer experiment — human listening pending” | from `summary.json` |
| Manifest hash | not recorded | **UNKNOWN** |
| Rate/direction changes | observed 75, 125, 200, 300 ms; FWD and REV (started 200 ms FWD) | **RECOMPUTED** from events + summary |
| Repeats / cooldown | 209 unique assets, 0 repeats, 0 relaxations, max consecutive same performer 1, max vocal run 2 | **RECOMPUTED** / summary |
| Reviewer | engineering review in `LISTENING_NOTES.md` | notes file |
| Subjective verdict | mixed instrument vs clip-like; not a §18 pass | **SUBJECTIVE** |
| Hypothesis / change / next | Mixed-rate live smoke of PR #28-era clocked DSP. Next: single-rate captures with recorded settings | — |

This checker could not recompute LUFS/spread on the original stereo live WAV (`check_sweep_acoustics.py` currently requires mono `sweep.wav`). Event `render_time_seconds` starts at 0.2 s, so engine time is near the file origin for this run.

### Run4 — `recordings/Run4/`

| Field | Value | Label |
|---|---|---|
| Artifact | `engine-output.wav`, `events.jsonl`, `summary.json` | path |
| WAV SHA-256 | `63390568f31e61eabf5d80ea86cd8af04580a9154984a9c77e07285d8f4a0d6c` | **RECOMPUTED** |
| WAV format | 48 kHz, 16-bit, **stereo**, 120.0 s | **RECOMPUTED** |
| Run ID | `20260910-014406-de8775a8` | from `summary.json` |
| Started / ended | 2026-09-10T05:44:06Z / 2026-09-10T05:46:06Z | from `summary.json` |
| Build / SHA / effective settings | not present | **UNKNOWN** |
| Seed | not present | **UNKNOWN** |
| Corpus | Bundle/Phase1, 1,200 assets | from `summary.json` |
| Rate/direction | 300 ms FWD only; no mid-capture changes | **RECOMPUTED** |
| Event vs WAV time | first `render_time_seconds` = 136.9613125; last = 256.6613125 | **RECOMPUTED** — engine timeline, **not** WAV origin |
| Exposure | every vocal is exactly 2880 frames / 60 ms | **RECOMPUTED** |
| Density | exactly 15% (60/400) | **RECOMPUTED** |
| Repeats | 0; max vocal run 2 | **RECOMPUTED** |
| Listening notes | template only | — |
| Subjective model score | 3.5 | **SUBJECTIVE** |

Slot-based acoustics against this WAV using raw `render_time_seconds` are invalid without a capture origin offset. That mismatch is recorded, not “fixed” in the original files.

15% occupancy and a fixed 60 ms exposure are **consistent with some non-default or pre-sparse-exposure tuning**, but the bundle does not record which.

### Run5 — `recordings/Run5/`

| Field | Value | Label |
|---|---|---|
| Artifact | `engine-output.wav`, `events.jsonl`, `summary.json` | path |
| WAV SHA-256 | `8bc8665172cc564169aa1a222bc4fc52bf1724d7eff441d24d5fe0dc646703da` | **RECOMPUTED** |
| WAV format | 48 kHz, 16-bit, **stereo**, 120.0 s | **RECOMPUTED** |
| Run ID | `20260910-030859-2fd25bb9` | from `summary.json` |
| Started / ended | 2026-09-10T07:08:59Z / 2026-09-10T07:10:59Z | from `summary.json` |
| Build / SHA / effective settings | not present | **UNKNOWN** |
| Seed | not present | **UNKNOWN** |
| Corpus | Bundle/Phase1, 1,200 assets | from `summary.json` |
| Rate/direction | 300 ms FWD only | **RECOMPUTED** |
| Event vs WAV time | first `render_time_seconds` = 0.3; last = 119.7 | **RECOMPUTED** — near file origin |
| Density | 133/399 = 1/3 exactly | **RECOMPUTED** |
| Exposure | 66.0625–74.9375 ms | **RECOMPUTED** |
| Repeats | 0; max vocal run 2 | **RECOMPUTED** |
| Listening notes | template only | — |
| Subjective model score | 6.5 | **SUBJECTIVE** |

#### Run5 diagnosis (bounded)

**Proven from the artifact**

- Occupancy is exactly one-third of 300 ms slots, with the existing two-vocal-run cap.
- Vocal windows are ~66–75 ms, which matches the older ~75 ms-at-300 ms hard cap, **not** the PR #31 150–220 ms long-source range, and **not** this branch’s 120–180 ms range.

**Not proven**

- Which app version, commit, or `SweepRendererSettings` produced the capture. Those fields were not written.
- That the harness reset control caused it. Reset currently assigns `.listeningTest` (now 7%; on PR #31 it was 8%) while the button text still said “33%” — stale copy, not a demonstrated causal path for this file.
- That UI persistence restored 0.33. No settings sidecar exists to confirm or deny a stepper/preset mismatch.

**Cause of the Run3 vs Run5 settings mismatch: UNRESOLVED.** Reproducibility is fixed going forward by locking one shared preset and writing engine provenance on live and offline artifacts.

### Candidate (this branch)

Intended command (macOS/Xcode):

```sh
./scripts/render-short-listening.sh --preset listening-test --rate 300 --seconds 60 --also-baseline
```

Shared preset `listening-test` / `2026-09-10.sparse-exposure-v1`:

- `vocalEventProbability = 0.07`
- `clusteriness = 0.0` (no extra cluster bias; two-vocal-run cap remains)
- `staticGain = 0.10`, `vocalGain = 0.48`, `outputGain = 3.5`
- `minVocalExposureSeconds = 0.100`, `maxVocalExposureSeconds = 0.180`
- `minExposureFractionOfDwell = 0.40`, `maxExposureFractionOfDwell = 0.65`
- `fadeSeconds = 0.015`, `recentExclusionWindow = 8`

Frame-rounded long-source exposure at 48 kHz (same algorithm as the engine; short sources can crop shorter):

| Rate | Exposure |
|---|---|
| 75 ms | 63.75 ms (3060 frames). Does not force 100 ms into a 75 ms dwell |
| 125 ms | 100 ms |
| 200 ms | 100–130 ms |
| 300 ms | 120–180 ms |

At 300 ms, 120 s is about 400 slots; 7% implies roughly 28 vocals **before** scheduler effects. Do not enforce 14–20 events or a fixed gap.

**This Linux workspace could not emit the candidate WAV.** Treat CI `build/listening-runs/` (or a later macOS unique-dir render) as the artifact. Do not substitute Run4/Run5 as a controlled baseline. The frozen `archived-continuous-static` preset exists only so a matched A/B can be rendered from this revision.

This candidate is a listening experiment, not a proven improvement. Reduced probability does not guarantee −18 LUFS.

---

## Reference recordings

Private files under `reference_audio/`. Not application corpus.

| File | SHA-256 | Bytes | Notes |
|---|---|---:|---|
| `Test #1 P-SB7T (Rev 5.0) Spirit Box with the Active Noise Control (P-ANC) Device..wav` | `e499d440dc4a2ec5e7bd981df40ea4d8c5af0a57f5e4dc297a0e1b315e9304e2` | 162921686 | **RECOMPUTED** hash |
| `The Most Amazing Spirit Box, Ghost Box and best EVP Sessions - P-SB7, Mel Meter, KII Responses!.wav` | `ffb5ff7a002a447b3687d3b2b59f85d3217103a7389aa4e6b141d5fe09d5f78c` | 119627802 | **RECOMPUTED** hash |

Documented analysis method for existing numbers: `build/reference_audio_analysis/analysis.md` (whole-file proxies, not ASR).

| Claim | Exact source | Label |
|---|---|---|
| Speech occupancy proxy 0.141 | Reference 1, whole file, “NOT ASR; host voice may dominate” | recorded in analysis.md |
| Speech occupancy proxy 0.256 | Reference 2, whole file, same caveat | recorded in analysis.md |
| `speech_step_probability = 0.0576` (~5.8%) | **Proposed 20-second synthesis parameters** in analysis.md, not a measured scheduler density of a named segment | **REPORTED_NOT_REPRODUCED** as “reference density ≈ 5.8%” |
| Exposure 80–220 ms / loudness −18 LUFS as reference | not tied in analysis.md to a named file+segment+denominator | **REPORTED_NOT_REPRODUCED** |

Reference speech-detection proxies are **not** equivalent to this app’s logged vocal-slot density.

---

## Attributed subjective assessments (not measurements)

A supplied model reported:

| Item | Run3 | Run4 | Run5 |
|---|---:|---:|---:|
| Overall score | 5.0 | 3.5 | 6.5 |
| Noise spread | 6.65 dB | 27.57 dB | 3.56 dB |
| Vocal emergence | +15.27 dB | +0.01 dB | +1.81 dB |

Scores: **SUBJECTIVE**. Run3/Run5 spread and emergence are now **RECOMPUTED** on a **mean-downmix** with WAV-aligned `render_time_seconds`. Run4 spread/emergence remain **UNKNOWN** (timestamps not WAV-relative). The earlier 27.57 dB / +0.01 dB Run4 figures stay **REPORTED_NOT_REPRODUCED**.

---

## Hypothesis, result, next action

| Run | Hypothesis | Change tested | Result | Next |
|---|---|---|---|---|
| Run3 | Clocked DSP + 0.33-class occupancy, mixed rates | PR #28-era live smoke | Intermittent vocals (25.7% slots, 9.79% elapsed exposure), mixed FWD/REV; settings not in bundle | Do not use mixed-rate LUFS as a gain table |
| Run4 | Post-Run3 listening on a 300 ms FWD capture | UNKNOWN build | 15% slots / 3.00% elapsed exposure / 60 ms; engine time offset ~137 s | Do not treat as PR #31 8%/150–220 ms without settings |
| Run5 | Same as current main / 8% preset | **Not established** | 33.3% slots / **7.81% elapsed exposure** / 66–75 ms / LRA 0.7; **settings provenance missing** | UNRESOLVED historical cause; do not invent a reset/stepper cause |
| Candidate | 7% + 100–180 ms exposure bounds, continuous static unchanged | shared `listening-test` preset | WAV not produced on Linux | GitHub-hosted macOS 60 s 300 ms FWD vs archived baseline, then unprimed device listen |

Concrete Audio DSP & Renderer Fixes (speaker-roulette relaxation, 18 ms fades, gain table, lookahead limiter retune, reverse-PCM change) remain **proposed experiments**, not implemented here. Reverse already uses forward PCM with reverse traversal. The existing limiter already uses 2 ms preview and 40 ms release; inspect actual-engine output before adding latency.

Canonical endurance gate remains 15–20 minutes on physical hardware with unprimed listeners. Audio-model review does not pass that gate.
