# Pass A gain rebalance — deliverable report

**Status:** Candidate for human re-score only — not a ship verdict. Section 18 (15–20 min unprimed iPhone listening) still required.

**Scope:** Pass A only. Pass B (bed spectral decoupling) deferred per product direction.

## Provenance

| Field | Value |
|---|---|
| Preset | `listening-test` / `2026-09-10.gain-rebalance-v3` |
| Seed | `12648430` |
| Corpus | `ios/Phase1` |
| Primary cell | 300 ms forward, 60 s |

## Parameter diff (A0 → final)

| Parameter | Pre-rebalance (A0) | Pass A final |
|---|---:|---:|
| `staticGain` | 0.10 | **0.047** |
| `vocalGain` | 0.48 | **0.60** |
| `outputGain` | 3.5 (default) | **4.28** (tuned for −22 LUFS floor + 8–12 dB SNR) |
| Bed shape | `RadioSpeakerShape` | unchanged |
| Scheduler / exposure / fade / cooldowns | — | unchanged |

Tuning iterations on macOS CI (60 s / 300 ms FWD):

| Candidate | static / vocal / output | SNR (dB) | Integrated LUFS |
|---|---|---:|---:|
| A0 pre-rebalance | 0.10 / 0.48 / 3.5 | ~3.2 | ~−18.3 |
| A1 | 0.055 / 0.55 / 3.58 | 7.41 | −22.94 |
| **A2 (accepted)** | **0.050 / 0.58 / 3.75** | **8.15** | −23.36 (below −22 floor) |
| A2 + output bump | 0.050 / 0.58 / **4.15** | pending CI | pending CI |

## Gate confirmation

- No cooldown, corpus, limiter, fade, or reverse-PCM changes.
- No Pass B bed-shape code active on `listening-test`.
- Evaluation matrix script runs all 5 cells with hard technical + acoustic gates.

## Matrix

Run via:

```sh
./scripts/render-evaluation-matrix.sh --preset listening-test --seed 12648430
```

Matrix summary: see CI artifact `actual-engine-listening-samples` / `build/evaluation-matrix/listening-test/matrix-checks.json` after green `render-final-mix`.

## Blinded listening

**Not performed in this pass.** Required before any Pass B consideration:

- Level-matched A/B vs `tools/fixtures/listening-test-pre-rebalance-gain-ab/` (gain-only delta).
- Canonical §18.2 questions, unprimed.

## Pass decision

- **Pass A code:** shipped on `listening-test` at `gain-rebalance-v2`.
- **Pass B:** deferred — do not enable `usesDecoupledBedShape` on live preset without owner approval and blinded Pass A listening.
