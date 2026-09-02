# EXP-001 — station-gate replace hiss

**Hypothesis:** speech events must share a station-strength gate with the hiss (replace, not mix).

**Branch:** `glink/exp-001-station-gate-replace-hiss-4569` (experiment name: `exp/001-station-gate-replace-hiss`)

**Base:** `feat/reference-audio-20s-prototype` @ CANDIDATE-001 renderer (not `chore/reference-audio-setup`, which has no mixer).

## Parameters used

- Gate length: uniform **100–180 ms**
- Edge: linear **40 ms** 0–100% (~32 ms 10–90%)
- Hold: **1 step**, **1 word**, no back-to-back hits
- Mix: `out = (1-g)*noise + g*station` with noise duck **-96 dB** (replace)
- Station HF: local bed high-passed at 5.5 kHz, boosted **+18 dB**, same gate, env floor 0.55
- Hit peak ceiling: **-15 dBFS** (hard clip, not global scale)
- Crop: mid-utterance only, never >180 ms

## Artifact

`build/reference_match/CANDIDATE-002-exp001-station-gate.wav` (not committed)

## Mechanical numbers (CANDIDATE-002)

- duration 20.000 s, 48 kHz, mono pcm_s16le
- HF Δ min **+8.57 dB** (mean +10.46 dB)
- corr(LF, HF) **0.56**
- max burst **117 ms**
- occupancy **2.48%**


## Non-goals (untouched)

Noise color, scan clock/grain, Kokoro, iOS architecture.
