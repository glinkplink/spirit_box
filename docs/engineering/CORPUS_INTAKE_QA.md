# Corpus intake QA tooling

Developer-only validation for Phase 1 human corpus deliveries **before** loading into the iOS audio harness.

This tool answers:

> Is this delivered Phase 1 corpus technically valid, internally consistent, rights-traceable, and safe to load into the existing harness?

It does **not** answer:

> Does this corpus sound good enough to ship?

Only the human physical-device audio gate can answer that.

## Quick start

### Prepare a continuous recording (new)

Segment a Voice Memos M4A (or WAV) into a harness-loadable `SpiritBoxPhase1Corpus/` folder:

```bash
python3 tools/prepare_corpus.py recordings/me_test.m4a \
  --family me_test \
  --output build/corpus/me_test
```

This writes:

- `build/corpus/me_test/SpiritBoxPhase1Corpus/manifest.json`
- `build/corpus/me_test/SpiritBoxPhase1Corpus/me_test_###.wav`
- `build/corpus/me_test/intake-qa-report.md`

`recordings/`, `build/corpus/`, and `private-corpus/` are gitignored. Never commit source recordings or generated voice assets.

Requires `ffmpeg` and `ffprobe` on PATH. Tunable flags: `--noise-threshold-db`, `--min-silence-sec`, `--min-event-sec`, `--max-event-sec`, `--region-pad-sec`, `--silence-merge-gap-sec`. Run `python3 tools/prepare_corpus.py --help` for defaults.

### Validate an existing corpus

```bash
python3 tools/corpus_intake/validate_corpus.py /path/to/SpiritBoxPhase1Corpus \
  --phase1-strict \
  --rights-ledger /private/path/rights_ledger.csv \
  --report /tmp/corpus-report.md \
  --json-report /tmp/corpus-report.json
```

Exit code `0` = no fatal validation errors. Non-zero = fatal errors present. Warnings alone do not fail unless they are classified as Phase 1 blockers (e.g. orphan WAV in strict mode).

## Corpus directory structure

The validator expects a harness-compatible layout:

```text
SpiritBoxPhase1Corpus/
  manifest.json
  SBX_V1_P01_VOW_AE_001.wav
  ...
```

`manifest.json` uses the same schema as `ios/SweepEngine/SourceAsset.swift` / `CorpusManifest`. Do not invent a competing manifest format.

The existing `CorpusLoader` searches `Documents/SpiritBoxPhase1Corpus/manifest.json` on device, then bundled `Phase1/`, then `DevFixtures/`. A validated directory can be copied directly to any of those locations without modification.

## Modes

### Generic validation

```bash
python3 tools/corpus_intake/validate_corpus.py /path/to/corpus
```

Checks manifest structure, path safety, file existence, WAV format basics, duration/crop consistency, and duplicates. Rights ledger is optional.

### Strict Phase 1 (`--phase1-strict`)

Enforces canonical Phase 1 requirements:

| Requirement | Value |
|---|---|
| Total assets | 120 |
| Performers | P01–P04, 30 each |
| Vowel-core | 28 |
| Continuant/sonorant | 32 |
| Transitions | 40 |
| Breath + transient | 20 combined |
| Source master WAV | 48 kHz, 24-bit, mono PCM |
| `recognition_risk=high` | ERROR (rejected) |
| Rights ledger | **Required** (`--rights-ledger`) |

## Rights ledger

Use the CSV schema from `docs/production/AUDIO-CORPUS-ACQUISITION-AND-PRODUCTION-PLAN.md` §14.

In strict mode every manifest asset must have a `rights_record_id` with a matching ledger row where:

- `rights_status` = `APPROVED` (rows with `HOLD` fail)
- `commercial_use`, `mobile_app_embedding`, `modification`, `derivative_audio`, `worldwide`, `perpetual`, `royalty_free`, `marketing_use`, `future_versions`, `end_user_session_recording_use`, `store_distribution_sublicense` = **YES**
- `ai_training_permitted`, `voice_cloning_permitted` = **NO**
- `final_sha256` (when present) matches the accepted WAV SHA-256

The ledger may live outside the corpus directory. Signed releases and contract PDFs should **not** be committed to the public repository.

## Severity levels

| Level | Meaning |
|---|---|
| **PASS** | Check succeeded (informational) |
| **WARNING** | Advisory production-QC issue; may not block generic validation |
| **ERROR** | Fatal technical or rights problem; fails validation |

There is no aggregate quality score. A single fatal error fails the run.

## Reports

### Markdown (`--report`)

Human-readable summary: corpus stats, errors, warnings, format summary, distribution tables, duplicates, rights traceability, crop checks, audio-QC diagnostics, and **audio gate status**.

### JSON (`--json-report`)

Machine-readable fields for CI: `overall_status`, `errors`, `warnings`, counts, `duplicate_hashes`, `technical_format_failures`, `rights_failures`, `high_recognition_risk_count`, `audio_gate_status`.

## Audio gate status

Every report includes:

```text
AUDIO GATE STATUS: NOT YET RUN — REQUIRES HUMAN PHYSICAL-DEVICE LISTENING TEST
```

**Corpus intake validation PASS ≠ canonical audio gate PASS.**

This tool will never emit `AUDIO GATE PASSED`. Only a human listening session on a physical device with the real Phase 1 corpus can pass the gate described in `docs/engineering/AUDIO_HARNESS.md`.

## What this tool cannot test

- Whether fragments sound believable in a 15–20 minute sweep
- Paranormal efficacy or user perception
- Semantic content (no speech recognition or transcription)
- Whether performers met artistic direction beyond declared metadata
- Legal sufficiency of contracts (ledger field presence only)

## Privacy

Reports use performer IDs (P01–P04) from manifest metadata. They do not print legal names, addresses, or contract paths from the rights ledger by default. Keep real performer audio, releases, and PII out of the public repository.

## Handoff to harness

1. Prepare or validate the corpus locally (see Quick start above).
2. Load it on the TestFlight device with **Upload corpus** (see below) **or** copy into `ios/Phase1/`.
3. Launch `SpiritBoxAudioHarness` and confirm the corpus label is not “DEV fixtures”.
4. Run the manual 15–20 minute physical-device listening gate.

### Linux → TestFlight iPhone (Documents loading)

The harness **Upload corpus** button imports `manifest.json` and WAV files from Files / iCloud into `Documents/SpiritBoxPhase1Corpus`. No ZIP unpacker is built in.

1. Install the private harness through TestFlight and open it once (creates `Documents/SpiritBoxPhase1Corpus/`).
2. From Linux, put the generated files where the iPhone can pick them:
   - **AirDrop / iCloud Drive / Dropbox:** upload `build/corpus/me_test/SpiritBoxPhase1Corpus/` (or its contents).
   - **USB + libimobiledevice:** `pip install ifuse` (or distro package), mount the app container, copy into `SpiritBoxPhase1Corpus/`, then tap **Reload corpus**.
3. In the harness **Corpus** section, tap **Upload corpus** and select the `SpiritBoxPhase1Corpus` folder (or `manifest.json` plus the WAV files).
4. Confirm **Source** is `Documents/SpiritBoxPhase1Corpus` with the expected asset count.
5. Run the 15–20 minute listening gate per `docs/engineering/AUDIO_HARNESS.md`.

Loader precedence: usable Documents Phase 1 → bundled Phase1 → bundled DevFixtures → empty.

## Running tests

```bash
PYTHONPATH=. python3 -m unittest discover -s tools/corpus_intake/tests -v
```

Tests use synthetic WAV fixtures only — no real performer audio is committed. Preparation tests cover segmentation, naming, manifest fields, and source-overwrite guards.

## Private workspace convention

If you store raw masters, signed releases, or private ledgers locally, keep them outside the git repository or in a clearly named private directory. See `.gitignore` for suggested patterns. Do not commit production corpus to the public repo until an explicit delivery strategy is chosen.
