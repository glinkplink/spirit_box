# VCTK Phase 1 candidate (approved path)

**Status:** APPROVED Phase 1 candidate — potentially production-viable after human audio gate  
**Decision date:** September 9, 2026  
**Revalidation:** September 10, 2026 — do not treat recognizable fragments in the **rendered sweep** as automatic defects. Canned phrases and semantic selection remain forbidden.

## What matters

Spirit Box approves or rejects corpus material based on **what survives in the rendered sweep**, not on whether upstream recordings were originally full sentences.

For VCTK, each asset is a **200–240 ms interior crop** from one mic1 utterance, with DC removal, band limiting, bounded gain, and fades. Runtime sweep behavior further breaks lexical context. **Do not run a semantic selector.** Hearing a shard of a word in the mix is compatible with a physical box; assembling answers is not.

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
- `LISTEN-FIRST.mp3` — optional source diagnostic; not renderer acceptance audio
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

## Renderer experiment

The renderer integration task uses the candidate through the actual app engine,
starting with 30–60 seconds, then 2–5 minutes, then eventual endurance. Dry/jumbled
voice listening is not a prerequisite. The integration branch bundles this candidate
for testing; this does not constitute release or human audio-quality approval.
See [renderer workflow and audit](../engineering/VCTK_RENDERER_INTEGRATION.md).

## Release gates

Technical intake PASS does **not** pass the product audio gate.

1. **Rendered recognition review** — listen to the actual sweep mix; trace troublesome moments to source windows. Use the dry audition only to diagnose flagged assets; rebuild if culls are material.
2. **Physical-device gate** — import corpus on iPhone; 15–20 minutes at low/normal volume, multiple sweep rates, forward and reverse; speaker and headphones.
3. **Attribution** — integrate customer-visible CC BY 4.0 attribution before App Store release.
4. **Release decision** — experimental bundling is permitted for this integration; production audio approval still requires the listening gates.

## Commissioned four-performer path

The transition-dominant commissioned plan in `AUDIO-CORPUS-ACQUISITION-AND-PRODUCTION-PLAN.md` remains valid as an alternative or successor if VCTK fails the listening gate. Both paths share the same kill criterion: rendered sweep quality over 15–20 minutes.
