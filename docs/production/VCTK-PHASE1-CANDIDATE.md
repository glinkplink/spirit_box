# VCTK Phase 1 candidate (approved path)

**Status:** APPROVED Phase 1 candidate — potentially production-viable after human audio gate  
**Decision date:** September 9, 2026  
**Authority:** Product owner approval supersedes the generic “no stock speech corpora” caution for this dataset.

## What matters

Spirit Box approves or rejects corpus material based on **what survives in the rendered sweep**, not on whether upstream recordings were originally full sentences.

For VCTK, each asset is a **200–240 ms interior crop** from one mic1 utterance, with DC removal, band limiting, bounded gain, and fades. Runtime sweep behavior (additional cropping, filtering, speed jitter, reverse, scheduling, noise bed) further breaks lexical context. **Recognizable words in the dry audition are a defect to remove; absence of sentence-level source intent is not a blocker.**

## Corpus spec

| Item | Value |
|---|---|
| Source | CSTR VCTK Corpus 0.92 (CC BY 4.0) |
| Speakers | 6 (`p225`, `p226`, `p227`, `p230`, `p234`, `p237`) |
| Assets | **1,200** distinct cuts (200 per speaker) |
| Selection | One interior crop per utterance; energy-movement heuristic; **no transcript reads, no speech recognition, no semantic selection** |
| Format | 48 kHz mono PCM24 WAV + `manifest.json` |
| Rights record | `VCTK-0.92-CCBY4` — publisher license + `ATTRIBUTION.txt` in import archive |
| Strict commissioned template (`--phase1-strict`) | **Not applicable** — use generic intake validation |

## Build output (local, gitignored)

Reproducible builds land under `build/vctk-production-candidate-*/` (never committed). Typical contents:

- `SpiritBoxPhase1Corpus.zip` — import into harness via **Upload corpus**
- `LISTEN-FIRST.mp3` — 2-minute diagnostic preview (start here)
- `session-20min-*.mp3` — three 20-minute preview seeds
- `fragment-audition.wav` + `recognition-review.csv` — dry asset review
- `provenance.json`, `rights-ledger.json`, `validation.json`

Python diagnostic previews are **not** iOS engine captures. They help triage; only the physical-device gate authorizes ship.

## Rebuild

From repo root, using the project Python env (`.venv-kokoro`):

```bash
python3 tools/build_vctk_candidate.py /path/to/vctk/source /path/to/new/output
```

Refuses to overwrite an existing output folder. Source FLACs remain untouched.

## Release gates (unchanged)

Technical intake PASS does **not** pass the product audio gate.

1. **Recognition review** — audit `fragment-audition.wav`; mark `REMOVE` in `recognition-review.csv` for reliably recognizable words/phrases; rebuild if culls are material.
2. **Physical-device gate** — import corpus on iPhone; 15–20 minutes at low/normal volume, multiple sweep rates, forward and reverse; speaker and headphones.
3. **Attribution** — integrate customer-visible CC BY 4.0 attribution before App Store release.
4. **Bundle decision** — replace `ios/Phase1/` only after gates pass.

## Commissioned four-performer path

The transition-dominant commissioned plan in `AUDIO-CORPUS-ACQUISITION-AND-PRODUCTION-PLAN.md` remains valid as an alternative or successor if VCTK fails the listening gate. Both paths share the same kill criterion: rendered sweep quality over 15–20 minutes.
