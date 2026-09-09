# VCTK renderer integration / listening handoff

Branch: `feat/vctk-sweep-renderer`. Audited base: `origin/main` at `6dfd6761`
(September 9, 2026). This experiment follows the attached product-owner direction:
VCTK is an approved candidate and the first decision uses a short **rendered mix**.
A dry/jumbled-voice preview and a 20-minute preliminary listen are not prerequisites.

## Before and after

Already present: 75/125/200/300 ms rate detents, Forward/Reverse UI and engine API,
lexically ordered scheduler with soft repeat/family exclusions, runtime crops and
6 ms fades, waveform reversal, procedural noise, cached decoding, transactional
corpus import, bundle-identity-aware Documents precedence, final-mixer WAV capture,
event JSONL, and 2/20-minute QA runs. The bundled bank was Recording 105 (978 cuts).
The 1,200-window VCTK candidate was a separate local preparation artifact.

Missing: source sentence/file/window provenance in runtime metadata; hard
utterance/speaker protections; less mechanical traversal; runtime spectral shaping;
audio-clock slot scheduling; 30/60-second capture shortcuts; reproducible offline
rendering of the actual app engine. Python previews used different DSP/scheduling.

Implemented in the existing engine and controls, with no product UI redesign:

- `ios/Phase1/`: the verified 1,200 VCTK candidate windows, unchanged PCM, original
  license/attribution, per-window provenance and runtime manifest. The earlier
  bundle is retained in Git history and locally at
  `build/recording-105-bundle-before-vctk-renderer/`.
- `SourceAsset.swift`: optional utterance ID, source file and original start/count
  in 48 kHz frames. Existing non-VCTK manifests remain decodable.
- `SweepScheduler.swift`: seeded source ring, direction-aware bounded traversal,
  strict VCTK history constraints, bounded rolling history and speaker reuse counts.
- `FragmentBufferFactory.swift`: centralized tuning, high/low-pass shaping, bounded
  gain, whole-window peak attenuation, fades, and dwell-sized zero-padded vocal slots.
- `SweepAudioEngine.swift`: predecoded sources, sample-time scheduling, short
  lookahead, shared live/offline render graph, frame-accurate diagnostic offsets,
  startup failure cleanup, and explicit failure on capture-writer overrun.
- `ProceduralNoiseSource.swift`: reproducible reset for offline QA.
- `SweepEventLog.swift`: source provenance, speaker reuse distance, source-relative
  runtime crop/count, and scheduled sample-clock timestamp.
- Harness view/model: 30/60-second and 5-minute final-mix capture buttons alongside
  existing 2/20-minute captures. These are developer capture durations, not audio modes.
- Preparation/integration scripts, macOS CLI, CI render artifacts and regression tests.

## Runtime loading and provenance

The existing loader reads bundled `ios/Phase1/manifest.json`; no import is needed
for this experimental branch. The existing explicit Documents upload path still
works. A stale previous upload cannot hide a changed bundle identity.

Source masters: `recordings/vctk-0.92/wav48_silence_trimmed/`. Speakers:
`p225 p226 p227 p230 p234 p237`, 200 windows each, mic1 only. Candidate build:
`build/vctk-production-candidate-final/`. Integrated copy/archive:
`build/vctk-renderer-integration/SpiritBoxPhase1Corpus{,.zip}`.

To repeat the metadata integration without changing PCM or overwriting originals:

```bash
python3 tools/integrate_vctk_candidate.py build/vctk-production-candidate-final build/vctk-renderer-new
```

It checks all output hashes and rights files before copying. Original start/count,
source/output hashes and preparation measurements remain in `provenance.json`;
the scheduler sees technical identity only. No transcripts are bundled or read.
Future `build_vctk_candidate.py` output includes these runtime fields directly.
Its separate Python preview is now opt-in (`--diagnostic-previews`).

`license_text.txt`, `UPSTREAM_README.txt`, `speaker-info.txt` and `ATTRIBUTION.txt`
are retained byte-for-byte from the candidate. Transformation does not remove
license/attribution obligations. This work makes no additional legal conclusion.

## Scheduling and control semantics

For provenance-bearing banks, the previous **64 fragments**, **32 utterances** and
**2 speakers** are excluded. Those constraints are never relaxed. This blocks
immediate repeats, neighboring-window sentence reconstruction, consecutive voices,
and A-B-A-B alternation. Exhaustion leaves the independent static playing; an
undersized bank can remain exhausted until history reset/reload. Mixed banks cannot
use missing-provenance entries to bypass the protections. Legacy fixture scheduling
retains its earlier soft-fallback behavior.

A stable seeded FNV order separates source-file neighbors. A seeded 1–7-position
advance plus constraint skipping traverses that ring. Reverse traverses the same
ring in the opposite direction **from the current cursor**, and retains the existing
reversed-waveform behavior. It does not reset history or introduce another control.
Fixed seeds reproduce scheduler, crop/gain variation and offline noise.

The existing rate controls write the same `SweepRate` property. Every new slot
uses its current value for exposure length and slot duration. One player schedules
non-overlapping vocal slots at sample times; the noise source runs independently.
Sources shorter than the dwell expose available material then static, without
stretching, looping, or layering voices. Current crops remain 200–240 ms: at 300 ms
some of the dwell is intentionally static-only. Whether that cadence needs longer
source windows is a listening decision.

A 5 ms maintenance timer fills a **40 ms lookahead**, but does not define audio
cadence. Rate/direction changes apply to the next unscheduled slot, normally within
one dwell plus lookahead (maximum approximately **340 ms**, excluding hardware
output latency), with no restart or abrupt truncation of a playing vocal. Late
scheduling logs an underrun and resynchronizes rather than replaying stale slots.
Decoding occurs before starting audio, not in a render callback; cold-start/device
latency still requires measurement.

## Current internal tuning

`SweepTuning` in `FragmentBufferFactory.swift` is the single tuning location:

| Setting | Value |
|---|---|
| Procedural static gain | 0.09 |
| Vocal player gain | 0.88 |
| Final mixer gain | 0.82 |
| High-pass / low-pass | 280 / 4200 Hz, first-order stages |
| Boundary fades | 6 ms each, no vocal overlap |
| Per-window gain variation | ±8% |
| Processed vocal peak ceiling | 0.65, whole-window attenuation |
| Scheduler lookahead | 40 ms |

The existing procedural filtered white/brown noise and sparse crackle continue
between voice windows. No stored static loop, reverb, echo, stacked vocals, pitch
sweeps, semantic selection, microphone analysis, or sensor inputs were added.
Worst-case bounded voice plus noise remains below full scale at these gains.

## First listening sample

**iPhone:** launch this branch's Audio Harness → confirm the VCTK label and 1,200
assets → START → Engine output capture → **Capture final mix (30 sec)** or
**Capture final mix (60 sec)**. Adjust the existing rate/direction while running.
Retrieve the WAV and adjacent `events.jsonl` from
Files → On My iPhone → Spirit Box → EngineOutputCaptures (use the app's displayed
Files location if its display name differs). Stop capture or power off finalizes it.
This captures the actual final mixer, with no microphone permission.

**macOS with Xcode:** from repository root:

```bash
./scripts/render-sweep.sh ios/Phase1 build/first-render-30s 30 200 forward 12648430
python3 tools/check_sweep_render.py build/first-render-30s
./scripts/render-sweep.sh ios/Phase1 build/first-render-60s 60 200 reverse 12648430
```

Listen to `sweep.wav`; inspect adjacent `events.jsonl`. Each command compiles the
same `ios/SweepEngine/*.swift` files and renders the same AVAudioEngine graph,
scheduler, buffer factory and mix. It refuses an existing output directory. Offline mode prepares the complete vocal
slot timeline before fast rendering, because the player's asynchronous scheduling
cannot use wall-time lookahead when the audio clock runs faster than real time.
The slot scheduler, processing and audio graph remain shared with live playback;
CI requires identical PCM/event prefixes for identical seeds.
Use `120` or `300` seconds for the next iteration and `900` or `1200` for eventual
endurance. Linux cannot execute AVAudioEngine; it must not substitute Python audio
and label it the app's renderer.

CI's `actual-engine-listening-samples` artifact includes 30/60-second final mixes,
all four rates, Reverse, and a 2-minute sample with source traces and technical
checks. Offline output checks cover headroom, uninterrupted 20 ms blocks and
scheduler/slot invariants; they do not test device render deadlines or route changes.

## Trace interpretation and outstanding listening decisions

`timestamp` is scheduled render time mapped to the session clock, not queue-enqueue
time. `render_time_seconds` is relative to engine start (or zero in offline output).
`source_start_frame + crop_offset_frames` locates the original utterance window;
`emitted_frame_count` is the exposed source length before padding. The source start
is the low endpoint even for Reverse. Asset/speaker reuse distances are event counts.
Live captures begun mid-sweep use the engine-start timebase, not WAV-relative zero.

Automated success is **not audio validation**. Still UNKNOWN until human listening:
continuous-instrument feel, intelligible words, recognizable speaker cadence,
repetition fatigue, static balance, perceptual clicks, phone/headphone loudness,
live underruns, cold-start latency, control-change smoothness and device stop/routing
behavior. Start with the 30–60-second actual mix, tune, then listen for 2–5 minutes;
only later perform the 15–20-minute physical-device endurance evaluation.
