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
  startup failure cleanup, asynchronous capture progress that never waits for disk
  on the scheduling queue, and explicit failure on capture-writer overrun.
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

A stable seeded FNV order separates source-file neighbors. Among admissible assets,
the scheduler chooses the least-used source, breaking ties by ring order starting
at the current cursor. Reverse searches the same ring in the opposite direction
and retains reversed-waveform playback. Direction changes reset neither use counts
nor cooldown history. Selection remains entirely technical and deterministic.
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
Decoding and preparation of both directional ring orders occur before starting
audio. Live slots only read the decoded cache. Replacing the corpus stops playback
before clearing that cache. The bundled 1,200 files occupy 50,621,184 bytes (48.28 MiB)
as 48 kHz mono float PCM, excluding allocator/object overhead. This supports the
existing preload strategy without a custom ring buffer. The live regression removes
the source WAV after START and requires a later first-use asset to keep playing.
Actual device cold-start latency and deadline behavior still require measurement.

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
all four rates, Reverse, a 2-minute sample, and a 12-minute/300 ms sample with
source traces and technical checks. `engine-diagnostics.json` reports decoded bytes,
preload time and maximum slot preparation time. Set `SPIRIT_BOX_LEVEL_AUDIT=1` on
the CLI to measure every source through the actual buffer factory at every dwell,
both directions and minimum/midpoint/maximum gain variation. CI saves this as
`listening-2min/level-audit.json`, including RMS distributions, paired reverse level
differences, voice/static balance and peak bounds. Offline output checks cover headroom, uninterrupted 20 ms blocks and
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


## Additional quality audit: coverage regression

At PR commit `4679981a`, iOS run `34376192646` confirmed **85/480** unique assets
in the original 5,000-pick test. The ring cursor was anchored to the last accepted
pick and only moved a bounded stride before rejecting candidates. With direction
changing every 38/39 picks, traversal bounced around a small region. Rejected
regions accrued no priority; a fixed seed did not guarantee exploration.

The repair removes stride variation and adds persistent least-use priority before
directional tie-breaking. The original `>450` assertion is unchanged. Additional
coverage requires all 480 assets across 19 seeds (including zero and UInt64.max),
Forward, Reverse and repeated direction changes. Actual bundled-corpus tests check
four seeds over 4,000 events (20 minutes at 300 ms) and require full coverage by
2,400 events (12 minutes). Two corpus-sized event budgets allow temporary cooldown
deferrals while requiring complete exploration; this is an operational coverage
contract for this balanced bank, not a universal guarantee for arbitrarily
undersized or imbalanced corpora.

The actual-render checker uses a stronger local fairness guard: **a source cannot
repeat while an unseen source is admissible**. This rejects starvation without
choosing a seed-fitted percentage. Unseen assets cannot be fragment-blocked; only
the last two speakers and last 32 utterances can block them. Consequently the
conservative distinct-source bound is the smaller of event count and corpus size
minus the two largest speaker groups and 32 largest utterance groups (overlap only
strengthens the bound). The 12-minute render also requires all 1,200 assets.
A separate 85-source cycle regression satisfies fragment/utterance/speaker cooldowns
and still fails the fairness guard. Diagnostics include coverage/event ratio,
coverage/corpus ratio, per-speaker counts and repeat-distance histogram/min/median/max.

Runtime event-file writes now use the bounded capture writer queue. Slow storage
fails capture instead of accumulating unbounded event writes on the scheduling
queue. Capture start/stop/finalization and actual hardware behavior remain part of
device QA; offline timing does not certify those transitions.

## Spectral/speed audit decision

The Python diagnostic preview uses 0.94–1.06x speed changes, multiple spectral
profiles and another RMS normalization stage. iOS does **not** reproduce that
preview: its actual chain uses one restrained 280–4,200 Hz shape and bounded ±8%
amplitude variation (about -0.72/+0.67 dB), with unchanged sample rate and dwell.
No new normalization or pitch/speed effects are justified by a scheduler failure.
Fixing coverage changes the source diversity directly. Additional spectral/rate
variation is deferred until listening to the corrected actual-engine output shows
it is needed. Customer-facing controls and terminology are unchanged. Technical
level measurements do not establish perceived loudness or a human audio-gate PASS.


## Measured audit results

Actual-engine artifact from run `34378088508`, code `8906b045` (before moving
ring-cache construction into preload):

- 12-minute / 300 ms / seed 1234: 2,400 events, **1,200/1,200 assets**, 398–402
  events per speaker, minimum repeat distance 175. Two-minute / 200 ms: 600/600
  distinct events. The fixed-seed 30/60-second PCM and trace prefixes match.
- Preload: 0.087–0.514 seconds on the macOS CI host; maximum measured slot
  preparation 5.31 ms across the render matrix, against 40 ms live lookahead.
  These are offline host measurements, not an iPhone deadline guarantee.
- Rendered peak at most 0.464 full scale. Exhaustive processed-source peak 0.642;
  conservative mix bound 0.543. No clipping in these measurements.
- At 200 ms, active vocal RMS p05/median/p95 was -30.78/-26.57/-24.27 dBFS;
  voice/static ratio p05/p95 was +7.15/+13.65 dB. At 75 ms these ranges widen:
  -41.98/-27.68/-22.65 dBFS and -4.05/+15.27 dB voice/static. Shorter crops can
  expose low-energy source regions, so consistent perceived level is **not proven**.
- Maximum paired Forward/Reverse RMS difference was 1.361 dB at 75 ms and
  0.309 dB at 200 ms (p95 0.255 and 0.070 dB respectively). The automated level
  audit now rejects a direction-only energy change of 3 dB or more.
- Independent raw WAV measurement found one source below -40 dBFS:
  `vctk_0849_p227`, RMS -55.28 dBFS. Raw corpus p05/median/p95 was
  -23.67/-20.28/-20.01 dBFS. The quiet outlier predates the runtime chain;
  runtime should not amplify it into apparent speech. The audit artifact now
  lists the ten quietest sources. Review the outlier and 75 ms voice/static
  balance during human listening; no corpus replacement or second normalization
  stage was introduced in this scheduler repair.

The automated coverage, headroom and repeatability results do not clear the human
physical-device audio gate. No human listening was performed by this audit.
