# Run6 iPhone handoff

**Status of this document:** preparation record. It is not a listening verdict and does not override `docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md`.

Keep these statuses separate. Do not collapse them.

| Gate | Status now |
|---|---|
| Technically validated (Linux event/hash/corpus + unit tests that this host can run) | Done on this branch; Swift/macOS actual-engine still requires GitHub Actions |
| Ready for upload | After the PR SHA is on GitHub **and** `ios-audio-harness` actual-engine artifacts for **that SHA** are downloaded and reviewed |
| Uploaded | Not requested |
| Apple processing complete | Not started |
| Installed | Not started |
| Physically listened to | **NOT_RUN** |

Run6 is a listening experiment. Automated acoustics do not pass Section 18.

## Starting state (preserved)

| Field | Value |
|---|---|
| Starting branch | `fix/locked-audio-tuning-and-run-provenance` |
| Starting SHA | `17ff067c37dc679bea4e48332dd57be30e28bc50` |
| Dirty at start | clean |
| PR at start | none |
| Task branch | `audio/run6-iphone-prep` |
| Bundled corpus | `ios/Phase1`, 1,200 VCTK assets, label “VCTK six-speaker renderer experiment — human listening pending” |
| Manifest SHA-256 | `6bb5d2221e8d2a88fc98156e90d980a008f6c626cd07d9650a3f09f004b6e92b` |
| Live/offline default preset | `listening-test` / `2026-09-10.sparse-exposure-v1` |
| Run5 build/settings | **UNKNOWN**. Do not invent a reset/stepper cause. |

## What “new audio” is

Run6 needs the **current licensed VCTK bank** plus the locked `listening-test` renderer preset. No corpus replacement is justified from the recomputed files: PCM matches the bundled bank. A final-mix audition WAV is **not** an importable corpus.

**Identity-check archive** (same manifest identity and PCM as `ios/Phase1`; hash/compare only):

- Path: `build/vctk-renderer-integration/SpiritBoxPhase1Corpus.zip`
- Zip SHA-256: `01fff56141d148af6ef1113f946a42a243cd5ae4d1dc125971c595193c2357c6`
- Bytes: 36592205
- Manifest SHA-256: `6bb5d2221e8d2a88fc98156e90d980a008f6c626cd07d9650a3f09f004b6e92b`

The harness picker accepts a **folder**, WAVs, and JSON. It does **not** accept ZIP files. Do not tap Upload corpus on the `.zip`.

To load this bank from the archive:

1. Copy the ZIP onto the iPhone (AirDrop / Files).
2. In **Files**, unzip it.
3. In the harness, tap **Upload corpus** and choose the expanded `SpiritBoxPhase1Corpus` folder (the folder that contains `manifest.json` and the WAV files).

Or skip the archive and tap **Use bundled** when the 1,200-asset VCTK bank is already in the build.

`build/vctk-production-candidate-final/SpiritBoxPhase1Corpus.zip` has the **same PCM** but a **different manifest label/hash**. Do not import that expanded folder if the goal is the bundled identity.

## How the app selects the bank and preset

| Path | What actually happens |
|---|---|
| App startup | `HarnessViewModel` loads corpus; engine default is `.listeningTest`. |
| START | `engine.setRendererSettings(.listeningTest)` then `start(seed: 0xC0FFEE)`. No UI steppers. |
| Bundled bank | Used unless Documents override **matches the current bundled manifest identity**. |
| Upload corpus | Copies into `Documents/SpiritBoxPhase1Corpus` and remembers override for **this** bundle identity. |
| Use bundled | Clears the override (`SpiritBox.documentsCorpusOverrideBundleIdentity`). |
| Leftover Documents copy | Ignored after a new bundle identity. It cannot silently restore an older bank. |
| Renderer settings persistence | None. There is no saved 33% stepper path. |
| `archived-continuous-static` | Frozen PR #31 values for A/B renders only. Not the live default. |
| Offline CLI | `scripts/render-sweep.sh` / `render-short-listening.sh --preset …` |
| TestFlight / Release | Same code default. This branch bakes `SpiritBoxSourceCommit` / `SpiritBoxSourceDirty` into Info.plist at archive time. |

For Run6 on a device that previously imported a corpus: confirm the harness label is the VCTK 1,200-asset bundle, or tap **Use bundled**, or unzip the archive above in Files and choose the expanded `SpiritBoxPhase1Corpus` folder. Then START (forces `listening-test`).

## Actual-engine render (required before claiming candidate audio)

Linux cannot emit AVAudioEngine WAVs. After this branch is on GitHub, dispatch against the **exact SHA** to prove (PR merge SHAs are not that commit):

```sh
gh workflow run ios-audio-harness.yml --ref audio/run6-iphone-prep -f source_sha=<40-character-sha>
```

Every actual-engine render in that workflow must go through `scripts/render-sweep.sh` so `engine-diagnostics.json` records `source_commit`. Invoking `build/render-sweep/render-sweep` directly leaves `source_commit: UNKNOWN`.

A green **skipped** `build-and-test` on Ubuntu is **not** audio validation. A PR-triggered render of GitHub’s merge SHA is not proof of the branch HEAD.

Download artifacts from the **exact tested SHA**:

- `listening-60s-first`
- `actual-engine-listening-samples`

Required files in those artifacts:

- candidate and baseline `sweep.wav`
- `events.jsonl`
- `engine-diagnostics.json` (preset, seed, corpus hash, SHA)
- `technical-checks.json`
- `acoustic-checks.json` when present

Do not substitute Run4/Run5 as the matched baseline.

## TestFlight (approval required; do not run until asked)

Statuses stay **not uploaded** until an explicit approval.

After the tested SHA exists on GitHub:

```sh
gh workflow run testflight.yml --ref audio/run6-iphone-prep -f source_sha=<40-character-sha>
```

`--ref` must be this branch (or `main` only after merge) so the archive step injects the SHA into Info.plist. Signing model is unchanged.

## Run6 capture checklist

Device session. Record all of: device, iOS, app version/build, output route, volume, corpus identity, preset identity/version.

1. Confirm bundled (or imported matching) 1,200-asset VCTK bank.
2. Confirm read-only diagnostics show `listening-test` / `2026-09-10.sparse-exposure-v1`, 7% configured probability, continuous static, 120–180 ms long-source exposure at 300 ms.
3. **Capture A:** 30–60 s at **300 ms Forward**, fixed settings. Export original WAV + events + summary/diagnostics together.
4. If A is acceptable: **Capture B:** 120 s, same fixed settings, separately identified.
5. Rate/direction experiments only in **separately identified** later captures. Do not mix into B.
6. Keep originals. Do not “fix” history in the run folder.

## Proposed DSP experiments (not applied)

Do not relax 64-fragment / 32-utterance / 2-speaker cooldowns. Do not change reverse PCM semantics (already forward PCM + reverse traversal). If the actual-engine candidate still defects after listening, version separately: exposure, fade, filter, gain, or limiter — one change per candidate, against the matched archived baseline.
