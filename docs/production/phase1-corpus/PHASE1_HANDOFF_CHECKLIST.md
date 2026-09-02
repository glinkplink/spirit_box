# Phase 1 handoff checklist

Use this when a performer delivery is ready for **technical corpus intake** (segmentation, metadata, harness load).

This checklist does **not** pass the product audio gate.

**Audio gate status remains:** `NOT YET RUN — WAITING FOR REAL PHASE 1 CORPUS`

Do not treat DevFixtures as Phase 1.

---

## Required before intake

Complete for each accepted source that will enter the 30-per-performer set.

| Requirement | Done? |
|---|---|
| Immutable raw master retained **privately** (not overwritten) | |
| Raw SHA-256 generated | |
| `source_recording_id` assigned | |
| `performer_id` assigned (`P01`–`P04` only in public metadata) | |
| Final accepted source selected (part of the 30) | |
| Rights record exists (private ledger row) | |
| `rights_status` is **not** unresolved (`HOLD` / missing / unclear = exclude) | |
| Recognition-risk review completed (`low` / `medium` / `high`) | |
| Filename / `asset_id` assigned (`SBX_V1_...`) | |
| Metadata ready for `manifest.json` (see `docs/engineering/AUDIO_HARNESS.md`) | |
| No high-risk stable word/interjection left in the accepted set | |
| Crop-safe region identified (`crop_safe_start_ms` / `crop_safe_end_ms`) | |
| Final runtime asset exported if applicable (optional 16-bit/48 kHz copy; keep 24-bit master) | |

Shipping-rights fields on the ledger row must match the production plan before any asset is bundled: commercial use, mobile embedding, modification, derivative audio, worldwide, perpetual, royalty-free, marketing (same product), future versions, end-user session recording, store distribution; **`ai_training_permitted` = NO**; **`voice_cloning_permitted` = NO**; `rights_status` = `APPROVED` only when actually approved.

---

## Phase 1 count check

| Item | Required |
|---|---|
| Performers | 4 |
| Accepted assets per performer | 30 |
| Total accepted human sources | **120** |
| Per performer mix | 7 vowel, 8 continuant/sonorant, 10 transition, 5 breath/transient |

Do not count pitch-shifted, reversed, filtered, or time-stretched copies as new assets.

---

## After handoff (engineering — not this pack)

1. Write `manifest.json`.
2. Load via Documents `SpiritBoxPhase1Corpus/` or bundled `ios/Phase1/` per `AUDIO_HARNESS.md`.
3. Confirm corpus label is **not** DEV fixtures.
4. **Then** run the 15–20 minute listening gate.

Do **not** declare the audio gate passed in this folder or in a PR that only adds acquisition templates.
