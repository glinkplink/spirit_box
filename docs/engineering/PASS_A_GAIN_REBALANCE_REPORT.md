# Pass A gain rebalance — historical closeout report

The closeout below records `cad20349`. The later owner-requested correction is tracked in [PR32_AUDIO_REVIEW.md](PR32_AUDIO_REVIEW.md); this is no longer the live-preset description.

**Status:** **NOT ACCEPTED.** Not ship-ready. Section 18 has not advanced. No human listening and no iPhone gate has passed.

**Scope of this closeout:** revert the live preset to verified A0, freeze a true A0 fixture, delete rejected Pass A aliases, and remove dormant Pass B renderer settings. No further gain-tuning candidates. Tuning budget (A1 + optional A2) is exhausted.

## Live preset after closeout

| Field | Value |
|---|---|
| Preset | `listening-test` / `2026-09-10.sparse-exposure-v1` |
| `staticGain` | 0.10 |
| `vocalGain` | 0.48 |
| `outputGain` | 3.5 |
| Bed | `RadioSpeakerShape` only. No `NoiseBedShape`, no bed-wander, no `usesDecoupledBedShape`. |

v5 (`0.054 / 0.63 / 4.05`, `2026-09-10.gain-rebalance-v5`) is **historical only**. It was reverted from `listening-test`. Do not treat it as a candidate.

## Why Pass A was rejected

Evidence: GitHub Actions run [`34469280967`](https://github.com/glinkplink/spirit_box/actions/runs/34469280967) on `742e5b93` (v5).

| Cell | Acoustic | SNR (dB) | LUFS |
|---|---|---:|---:|
| 300 ms FWD 60 s (primary) | FAIL | 7.36 | −22.03 |
| 200 ms FWD 60 s | FAIL | 7.56 | −22.10 |
| 300 ms REV / 125 / 75 | PASS | 7.12 / 8.99 / 8.55 | −21.88 / −21.76 / −21.89 |

Primary SNR is below the 8–12 dB band. Matrix loudness gate (`−22 ≤ LUFS ≤ −16`) failed on two cells. Blinded listening was not run. Pass B was not triggered and is not implemented.

## A0 fixture

**Path:** `tools/fixtures/listening-test-pre-rebalance-gain-ab/`

| Field | Value |
|---|---|
| Gains | **0.10 / 0.48 / 3.5** (every A0 field set in `listeningTestPreRebalance`; `outputGain` is not inherited) |
| Seed | `12648430` |
| Cell | 60 s, 300 ms, forward |
| WAV source | macOS CI [`34461452369`](https://github.com/glinkplink/spirit_box/actions/runs/34461452369) / `2e8e9f8fae3655b32d3411e984c6db41137955af` (last green pre-Pass-A `listening-test` render) |
| Technical / acoustic | **PASS** / **PASS** (re-run on this host against that WAV): LUFS −18.46, SNR 3.30 dB, LRA 0.8 LU |
| `events.jsonl` | Matches that A0 schedule |
| Human listening | **NOT_RUN** |

This Linux host cannot run `render-sweep`. The committed WAV is the last verified macOS A0 mix at those parameters, not a new post-closeout render.

Rejected aliases **removed** (not present, not “accepted”, not “final”): `listening-test-gain-rebalance`, `pass-a-final`, `gain-rebalance`. `tools/fixtures/listening-test-pass-a-final/` does not exist.

## Pass B

Cancelled / deferred. Dormant renderer scope (`NoiseBedShape`, bed-wander settings/diagnostics, `usesDecoupledBedShape`) is removed from production code. Pass A matrix/LRA tooling remains.

## Section 18

Unprimed 15–20 minute physical-iPhone listening across speaker and headphones, all four canonical rates, both directions, is still required. This closeout is not that gate.
