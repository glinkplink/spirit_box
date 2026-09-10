# Pass A gain rebalance — deliverable report

**Status:** **Not accepted.** Candidate for human re-score only — not a ship verdict. Section 18 (15–20 min unprimed iPhone listening) still required.

**Scope:** Pass A only. Pass B (bed spectral decoupling) is not triggered.

**Evidence:** GitHub Actions run [`34469280967`](https://github.com/glinkplink/spirit_box/actions/runs/34469280967) on `audio/run6-iphone-prep` @ `742e5b937d9007bd1f0a143f0f65fb2f21c284a3`. `build-and-test` passed. `render-final-mix` failed the evaluation-matrix acoustic gate.

## Provenance

| Field | Value |
|---|---|
| Branch HEAD | `742e5b937d9007bd1f0a143f0f65fb2f21c284a3` |
| CI run | [34469280967](https://github.com/glinkplink/spirit_box/actions/runs/34469280967) |
| Preset | `listening-test` / `2026-09-10.gain-rebalance-v5` |
| Seed | `12648430` |
| Corpus | `ios/Phase1` (`6bb5d2221e8d2a88fc98156e90d980a008f6c626cd07d9650a3f09f004b6e92b`) |
| Primary cell | 300 ms forward, 60 s |
| Bed shape | `RadioSpeakerShape` (`uses_decoupled_bed_shape: false`) |

CI `engine-diagnostics.json` recorded an ephemeral PR-merge `source_commit` (`ca860533…`) and `source_dirty: dirty` because the workflow writes fixtures before the matrix. The evaluated preset/gains match HEAD.

## Parameter diff (A0 → v5)

| Parameter | Pre-rebalance (A0 intent) | v5 on `listening-test` |
|---|---:|---:|
| `staticGain` | 0.10 | **0.054** |
| `vocalGain` | 0.48 | **0.63** |
| `outputGain` | 3.5 | **4.05** |
| `vocalPeakLimit` | 0.65 | 0.65 |
| Bed shape | `RadioSpeakerShape` | unchanged |
| Scheduler / exposure / fade / cooldowns | — | unchanged |

`events.jsonl` at seed `12648430` is byte-identical between the committed pre-rebalance fixture and the v5 300 ms FWD render (gain-only scheduler delta).

**Fixture caveat:** `listeningTestPreRebalance` only overrides `staticGain` / `vocalGain`, so it inherits the current init default `outputGain` **4.05**, not A0’s 3.5. The committed A/B fixture is therefore `0.10 / 0.48 / 4.05`. Limiter sample ceiling is identical on both clips (`0.749894`, −2.5 dBFS).

## Tuning ledger (plan budget was A1 + optional A2; five versions were cut)

Primary cell = 60 s / 300 ms FWD, seed `12648430`. SNR = `vocal_slot_minus_noise_slot_db`. Loudness gate is `−22 ≤ integrated LUFS ≤ −16`.

| Version | static / vocal / output | SNR (dB) | Integrated LUFS | Source |
|---|---|---:|---:|---|
| A0 fixture | 0.10 / 0.48 / **4.05** (see caveat) | 2.91 | −17.23 | committed fixture |
| v1 | 0.062 / 0.52 / 3.5 | — | — | first gain hypothesis; no matrix numbers kept here |
| v2a | 0.055 / 0.55 / 3.58 | 7.41 | −22.94 | earlier CI (below floor) |
| v2b | 0.050 / 0.58 / 4.15 | — | — | loudness bump; not the accepted cut |
| v3 | 0.047 / 0.60 / 4.28 | — | — | `88f4c07e` |
| v4 | 0.054 / 0.62 / 3.95 | 7.45 | −22.24 | [34468789277](https://github.com/glinkplink/spirit_box/actions/runs/34468789277) |
| **v5 (current)** | **0.054 / 0.63 / 4.05** | **7.36** | **−22.03** | [34469280967](https://github.com/glinkplink/spirit_box/actions/runs/34469280967) |

v5 moved LUFS 0.21 LU closer to the floor than v4 and missed the 8–12 dB SNR band by 0.64 dB (v4 missed by 0.55 dB).

## Matrix (v5, hard gate)

All five cells rendered. Technical checker (`check_sweep_render.py`) passed every cell. Acoustic checker (`check_sweep_acoustics.py`) failed two cells on the −22 LUFS floor.

| Cell | Tech | Acoustic | SNR (dB) | LUFS | LRA (LU) |
|---|---|---|---:|---:|---:|
| 300 ms FWD 60 s (primary) | PASS | **FAIL** (`loudness`) | 7.36 | −22.03 | 2.4 |
| 300 ms REV 30 s | PASS | PASS | 7.12 | −21.88 | 3.2 |
| 200 ms FWD 60 s | PASS | **FAIL** (`loudness`) | 7.56 | −22.10 | 1.9 |
| 125 ms FWD 30 s | PASS | PASS | 8.99 | −21.76 | 1.9 |
| 75 ms FWD 30 s | PASS | PASS | 8.55 | −21.89 | 1.3 |

**Matrix: FAIL.** True-peak, sub-250 Hz, presence, and continuous-bed checks passed on every cell.

## Blinded listening

**Not performed.** Required before any Pass B consideration:

- Level-matched A/B vs `tools/fixtures/listening-test-pre-rebalance-gain-ab/` (gain-only delta; see outputGain caveat).
- Canonical §18.2 questions, unprimed.

## Pass decision

| Check | Result |
|---|---|
| SNR 8–12 dB at 300 ms FWD | **FAIL** (7.36 dB) |
| `events.jsonl` vs pre-rebalance fixture | **PASS** (identical) |
| Evaluation matrix (5 cells) | **FAIL** |
| Blinded listening vs pre-rebalance | **not run** |
| Limiter vs pre-rebalance | **PASS** (same sample ceiling) |
| Pass B trigger (SNR + matrix + listening + slab) | **not met** |

- **Pass A is not accepted.** Do not treat v5 as a frozen Pass A final. Do not commit `tools/fixtures/listening-test-pass-a-final/` until a later cut clears the matrix and SNR band.
- **Pass B:** do not enable `usesDecoupledBedShape` on live `listening-test`. LRA rose from 0.7 LU (A0 fixture) to 2.4 LU (v5 primary) — still low vs the P-SB7 reference, but low LRA alone does not mandate Pass B.
- **Pass A code** remains on `listening-test` at `gain-rebalance-v5` (`0.054 / 0.63 / 4.05`) as the last attempted cut. Further gain nudges are out of this close-out.

## Gate confirmation

- No cooldown, corpus, limiter, fade, or reverse-PCM changes.
- No Pass B bed-shape code active on `listening-test`.
- Evaluation matrix script runs all 5 cells with hard technical + acoustic gates.
- Plan tuning budget (A1 + optional A2) was exceeded (v1–v5).

## Section 18 reminder

A passing matrix would still not advance the Section 18 production gate. Required remaining evidence after any accepted candidate: unprimed 15–20 minute physical-iPhone listening across speaker and headphones, all four canonical rates, both directions.
