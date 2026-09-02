# EXP-001 — station-gate replace hiss

**Hypothesis:** speech events must share a station-strength gate with the hiss (replace, not mix).

**Branch:** `glink/exp-001-station-gate-replace-hiss-4569` (experiment name: `exp/001-station-gate-replace-hiss`)

**Base:** `feat/reference-audio-20s-prototype` @ CANDIDATE-001 renderer (not `chore/reference-audio-setup`, which has no mixer).

## Parameters used

- Gate length: uniform **100–180 ms** (nominal 125 ms class)
- Edge: linear **40 ms** 0–100% (~32 ms 10–90%)
- Hold: **1 step**, **1 word**
- Mix: `out = (1-g)*noise + g*station` with noise duck **-96 dB** (replace)
- Station HF: local bed high-passed at 5.5 kHz, boosted **+12 dB**, same gate
- Hit peak ceiling: **-15 dBFS**
- Crop: mid-utterance only, never >180 ms

## Non-goals (untouched)

Noise color, scan clock/grain, Kokoro, iOS architecture.
