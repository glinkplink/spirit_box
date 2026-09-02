# Audio harness

Private developer tool for validating the locked offline, non-semantic sweep architecture **before** building the customer-facing app.

This is not the product UI.

## Purpose

Answer the cheapest remaining product-risk question:

> Can the locked offline spirit-box audio architecture produce a believable continuous sweep without obvious repetition, sentence-like assembly, response-like timing, or a “random clips being played” impression?

The harness exercises:

- start / stop
- 75 / 125 / 200 / 300 ms sweep rates
- Forward / Reverse traversal
- non-semantic fragment scheduling
- anti-repeat rules
- procedural noise / static bed
- debug event logging
- diagnostic **engine output capture**
- empty / tiny / Phase 1 corpus loading

## What it does not do

It does **not** implement:

- MARK / replay / session history
- customer microphone / session recording
- commerce, StoreKit, RevenueCat, paywall
- speech recognition, AI, generated words, semantic answers
- live or terrestrial radio
- fake RF / frequency claims
- EMF, magnetometer, flashlight, SLS
- polished field-instrument UI

Nothing in the engine knows what the user said.

## Canonical kill criterion

Once a realistic Phase 1 human corpus is loaded, do **not** proceed to full product implementation if that corpus cannot survive about 15–20 minutes without:

- obvious recognizable repetition
- sentence-like assembly
- a strong clip-randomizer impression

If the first realistic attempt fails: improve the corpus and scheduler **once**, then retest.

If the failure looks structural: reconsider the rights-cleared live-radio architecture in the research, or kill / reposition the idea.

Do **not** rescue failure with AI, generated answers/words, question detection, response timing, fake frequencies, copyrighted radio, or semantic logic.

**Dev fixtures cannot pass this gate.**

## Audio gate status

`NOT YET RUN — WAITING FOR PHASE 1 CORPUS`

## Project / target structure

| Path | Role |
|---|---|
| `ios/SpiritBoxAudioHarness.xcodeproj` | Native iOS project |
| `ios/SweepEngine/` | Reusable engine: corpus, scheduler, renderer, capture, event log |
| `ios/AudioHarness/` | Thin SwiftUI developer UI + view model |
| `ios/SweepEngineTests/` | Deterministic unit tests |
| `ios/DevFixtures/` | Synthetic DEV / TEST ONLY audio |
| `ios/Phase1/` | Empty drop-in folder for a bundled Phase 1 corpus |

The engine is independent of the harness views so it can later be reused by the real app.

Minimum deployment target: **iOS 17**.

Application Bundle ID: **`com.glinkplink.spiritbox`** (App Store Connect). Test bundle: **`com.glinkplink.spiritbox.tests`**. The Xcode target/scheme may still be named `SpiritBoxAudioHarness`.

## How corpus assets are discovered

`CorpusLoader` searches in this order:

1. `Documents/SpiritBoxPhase1Corpus/manifest.json` on the device / simulator, **only if at least one referenced WAV is present** (a manifest-only folder from a failed Files copy is ignored)
2. bundled `Phase1/manifest.json`
3. bundled `DevFixtures/manifest.json` (DEV / TEST ONLY fallback)

If nothing is found, the harness starts with **zero assets**. START still runs the procedural noise bed and shows that the fragment scheduler is idle.

## Metadata format

`manifest.json`:

```json
{
  "schema_version": 1,
  "label": "Phase 1 human corpus",
  "kind": "phase1",
  "assets": [
    {
      "asset_id": "SBX_V1_P01_VOW_AE_001",
      "performer_id": "P01",
      "voice_family": "low_dry",
      "source_type": "vowel",
      "phonetic_family": "front_vowel",
      "duration_ms": 700,
      "forward_allowed": true,
      "reverse_allowed": true,
      "crop_safe_start_ms": 40,
      "crop_safe_end_ms": 660,
      "relative_path": "SBX_V1_P01_VOW_AE_001.wav"
    }
  ]
}
```

`relative_path`, `filename`, or `final_filename` may locate the WAV (path is relative to the corpus root).

Supported metadata includes the Phase 1 production fields. Optional fields may be omitted. The rights ledger is **not** implemented here.

`kind` of `dev_fixture` / `dev` / `test` marks the bank as unable to pass the product gate.

## How to add the Phase 1 corpus

1. Produce accepted assets per `docs/production/AUDIO-CORPUS-ACQUISITION-AND-PRODUCTION-PLAN.md`.
2. Write `manifest.json` using the fields above.
3. Either:
   - in the harness, tap **Upload corpus** and pick the folder (or `manifest.json` + WAVs), or
   - copy `manifest.json` + WAVs into the simulator/device `Documents/SpiritBoxPhase1Corpus/` folder (no rebuild), or
   - copy them into `ios/Phase1/` and rebuild.
4. Launch the harness. Confirm the corpus label is **not** “DEV fixtures”.
5. Only then run the 15–20 minute listening gate.

Do not download random voice samples. Do not treat DevFixtures as Phase 1.

## Physical iPhone / TestFlight corpus loading

The private harness can import a prepared Phase 1 folder from Files / iCloud via **Upload corpus**. File sharing is still enabled so Files can also see Documents. There is no ZIP unpacker, iCloud entitlement, or backend.

This procedure has **not** been physically verified on a TestFlight iPhone in this change.

1. Install the private harness through TestFlight.
2. Open the app once so it can create `Documents/SpiritBoxPhase1Corpus/` if missing. Directory creation failure is reported as a harness diagnostic; it does not crash.
3. Get `manifest.json` and the WAV files onto the iPhone (AirDrop, iCloud Drive, Files).
4. In the harness **Corpus** section, tap **Upload corpus**.
5. Select the `SpiritBoxPhase1Corpus` folder, or select `manifest.json` plus the WAV files.
6. Confirm **Source** is `Documents/SpiritBoxPhase1Corpus` and the expected asset count appears.

A stale `manifest.json` in Documents with no WAV files does not block the bundled `me_test` corpus.

Optional Files-app copy (same destination):

1. Open **Files** on the iPhone.
2. Under **On My iPhone**, open the harness app. Files should show the app **display name** (`Audio Harness` in the current Info.plist). Do not rely on an internal container UUID path.
3. Open the `SpiritBoxPhase1Corpus` subfolder (not the app Documents root).
4. Copy `manifest.json` and the WAV files **into** `SpiritBoxPhase1Corpus`. Do not leave them only under `On My iPhone → Audio Harness`.
5. Return to the harness and tap **Reload corpus**.

Loader precedence: usable Documents Phase 1 → bundled Phase1 → bundled DevFixtures → empty.

**DEV FIXTURES CANNOT PASS THE CANONICAL AUDIO GATE.** Copying files onto a device only makes a real Phase 1 bank loadable. It does not pass the gate.

Audio gate status remains:

`NOT YET RUN — WAITING FOR PHASE 1 CORPUS`


## Anti-repeat scheduling

The scheduler is non-semantic. It walks eligible assets in a stable `asset_id` order.

When alternatives exist it:

1. never intentionally repeats the same asset consecutively
2. excludes IDs inside a rolling recent-use window (default 8)
3. prefers a different performer / voice family than the last pick
4. prefers a different phonetic family (or `source_type` if phonetic family is missing)

If the bank is too small, constraints relax in that order, after first preferring to skip `recognition_risk = high` when safer assets exist. The event log records what was relaxed. The scheduler never deadlocks.

Runtime crop stays inside `crop_safe_start_ms` / `crop_safe_end_ms` when those fields are present.

## Forward / Reverse

- **FWD:** ascending `asset_id` among `forward_allowed` assets; fragments play forward
- **REV:** descending `asset_id` among `reverse_allowed` assets; fragments play reversed

This is traversal of source material, not radio tuning.

## Sweep rates

Select **75 / 125 / 200 / 300 ms** in the harness. Default is **200 ms**.

The selected value is the scheduler / playback cadence, not a label.

## Start / stop

- **START** begins the continuous renderer (noise bed + fragment ticks).
- **STOP** tears down the audio graph and deactivates the session.

Repeated start/stop should not leave orphaned nodes.

## Engine output capture

This captures the **final mixed engine output** (procedural noise + scheduled fragments).

The diagnostic tap is installed on **`AVAudioEngine.mainMixerNode` bus 0** after both the procedural noise source and the fragment player are connected to that mixer. It therefore records the engine’s audible mix — noise bed + scheduled fragments + their mix timing — not a single pre-mixer node, not microphone input, and not customer session recording.

Buffer ownership: inside the tap callback the engine copies PCM samples into an independent `AVAudioPCMBuffer`, then enqueues **only that copy** onto a bounded capture-writer queue (max 8 pending buffers; extra taps are dropped). File I/O runs off the real-time render callback. Capture failures are published as a failed diagnostic state and do not stop sweep playback.

It is **not** the future customer session-recording feature and does not use the microphone.

In the harness:

- `Capture final mix (2 min)`
- `Capture final mix (20 min, manual gate)`
- `Stop capture`

Files are written to:

`Documents/EngineOutputCaptures/engine-output-capture-YYYYMMDD-HHmmss.wav`

Alongside the WAV:

- `*.events.jsonl` — fragment events recorded while that capture was running
- `*.eventlog.jsonl` — snapshot of the in-memory log at capture stop (sized for a 15–20 minute / 75 ms session)

On Simulator, that Documents folder is inside the app container. Copy the WAV out with Finder, `xcrun simctl`, or Xcode’s Devices window.

For canonical listening evidence, prefer an **audio-gate run bundle** (below) instead of assembling these files by hand.

## Audio-gate run bundles

Private-harness only. One unique folder per evaluation run:

`Documents/AudioGateRuns/<yyyyMMdd-HHmmss>-<short-id>/`

Contents:

| File | Role |
|---|---|
| `engine-output.wav` | Existing final engine mix (noise + scheduled fragments). Not microphone / session recording. |
| `events.jsonl` | Fragment events **from this run only** |
| `summary.json` | Deterministic descriptive metrics |
| `summary.md` | Human-readable copy of the same metrics |
| `LISTENING_NOTES.md` | Neutral listening template |

The folder name includes a short unique ID so two runs in the same second cannot collide. An existing run directory is never overwritten or deleted.

Run-scoped events are collected from the moment the run starts. The longer-lived in-memory event log is **not** dumped into the bundle.

Automated summaries are diagnostic (coverage, repetition distances, family distribution, scheduler relaxation). They do **not** declare the audio convincing, and they do **not** pass the canonical gate.

**DEV FIXTURES CANNOT PASS THE CANONICAL AUDIO GATE.** A 2-minute smoke run with DevFixtures is for plumbing only. A completed 20-minute DevFixtures run is not a canonical gate attempt.

Project gate status remains:

`NOT YET RUN — WAITING FOR PHASE 1 CORPUS`

### How to produce and retrieve a bundle

Physical Files-app retrieval of a gate bundle has **not** been verified in this change.

1. Load corpus (**Upload corpus**, or Reload corpus). For a real evaluation, Source must be Phase 1, not DevFixtures.
2. Start **2-minute smoke run** first to exercise bundle generation.
3. Confirm the bundle appears under:
   **Files → On My iPhone → Audio Harness → AudioGateRuns**
   (Files shows the app display name, not a container UUID.)
4. For a real Phase 1 corpus, start **20-minute evaluation run**.
5. Let it finish naturally when possible. **Stop run early** still finalizes the WAV, closes `events.jsonl`, writes summaries when possible, marks `stopped_early`, and keeps the partial folder.
6. Retrieve:
   - `engine-output.wav`
   - `events.jsonl`
   - `summary.json`
   - `summary.md`
   - `LISTENING_NOTES.md`
7. Listen without being primed. Fill `LISTENING_NOTES.md` using the canonical/QA questions already in that template.
8. Correlate reported timestamps with `events.jsonl`.
9. Automated summaries are not the gate verdict. Human listening remains mandatory.

## Event log

Each scheduled fragment records:

- timestamp
- asset ID
- performer / voice family
- phonetic / source family
- sweep rate
- direction
- events since this asset was previously used
- which anti-repeat constraints were relaxed

Use it to answer: “Did I hear a repeat because the scheduler actually repeated something?” and “Which asset produced that?”

The log does not transcribe or interpret audio.

## Automated tests

From a Mac with Xcode:

```bash
./scripts/ci-ios-test.sh
```

or:

```bash
xcodebuild test \
  -project ios/SpiritBoxAudioHarness.xcodeproj \
  -scheme SpiritBoxAudioHarness \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

Tests cover scheduler behavior, rates, FWD/REV order, corpus edge cases, capture path naming, and capture-writer file output.

They do **not** decide whether the product sounds believable. The canonical 15–20 minute listening gate remains:

`NOT YET RUN — WAITING FOR PHASE 1 CORPUS`

## How to run the harness

1. Open `ios/SpiritBoxAudioHarness.xcodeproj` in Xcode.
2. Select the `SpiritBoxAudioHarness` scheme and an iPhone simulator or device.
3. Run.
4. Use START / STOP, rate, FWD/REV, event log, and engine-output capture.

This environment has no Xcode. Local iOS build/simulator verification is **not** claimed from Linux.

## Manual 15–20 minute evaluation

Only after a realistic Phase 1 human corpus is loaded:

1. Run at least 15–20 continuous minutes.
2. Test iPhone speaker and headphones.
3. Test low and normal volume.
4. Exercise 75 / 125 / 200 / 300 ms and FWD / REV.
5. Listen for recognizable repeats, repeated voices, loops, sentence-like assembly, response-like timing, consistent words, clip-randomizer feel, gaps, clipping, abrupt transitions, obvious asset boundaries, and one overly recognizable performer.
6. Use the event log and a 20-minute engine mix capture to diagnose anything you notice.

Do not claim this test passed unless the Phase 1 human corpus was actually loaded and the full listen was actually performed.
