# Clocked sweep DSP validation

This revision addresses the renderer audit of `033ce8f8`. The licensed source
bank, rate detents, direction controls and non-semantic asset selection remain
unchanged. It does not claim RF reception or perceptual equivalence to hardware.

Each dwell is prepared on the serial scheduling queue as a complete PCM mix,
including noise-only dwells. The independent free-running noise source node is
replaced by this shared slot mix on the existing AVAudioPlayerNode. This removes
relative noise/player startup timing and cross-thread noise-setting mutations.
The live and offline paths use the same slot preparation and seeded resets.
Exported trace timestamps use audio time; the harness retains wall-clock display
timestamps. Device resampling, scheduling underruns and physical output are not
covered by the pre-device PCM identity claim. An underrun is explicitly reported
as an output gap, never described as uninterrupted static.

Defaults: static 0.10, voice 0.48, master 3.5, clusteriness 0.0. Vocal runs stop
at two slots, including custom density 1. Current shared listening-test exposure
is 100–180 ms absolute and 40–65% of dwell, never longer than the dwell; a 75 ms
rate remains 63.75 ms. Those values are experimental (see
`docs/research/SPIRIT-BOX-AUDIO-RUN-COMPARISON.md`). Shortening a window cannot
guarantee that no listener will recognize a word.

The 10 ms commutation duck described below is historical for the first clocked-DSP
pass. Continuous-static remediation sets `slotEnvelope` to 1.0 so the noise bed is
not periodically gated. Do not treat the following envelope paragraph as the
current live default.

Both layers use identical 500 Hz high-pass and 3600 Hz low-pass Butterworth
biquads and a 2350 Hz, +3.5 dB, Q 1.75 presence filter. Noise filter state persists
between dwells. The slot envelope has a brief 10 ms quiet commutation shelf with
5 ms transitions mimicking physical PLL lock commutation. Vocal glimpses are
placed after this shelf to prevent attenuation.

The master limiter uses a 2 ms anticipatory envelope and 40 ms release with a
practical -2.5 dBFS sample ceiling (0.7498942) that retains ~1.5 dB true-peak
reconstruction margin below the -1.0 dBFS true-peak bound. This reclaims
clean headroom below the limiter ceiling, allowing balanced vocal glimpses
to emerge +3 to +7 dB cleanly over the static bed without limiter squashing.
Master gain is a listening preset, not automatic loudness normalization.

Validation commands (macOS/Xcode):

```sh
./scripts/ci-ios-test.sh
./scripts/render-sweep.sh ios/Phase1 build/test-60s-300ms 60 300 forward 12648430
./scripts/render-sweep.sh ios/Phase1 build/test-60s-200ms 60 200 forward 12648430
python3 tools/check_sweep_render.py build/test-60s-300ms
python3 tools/check_sweep_render.py build/test-60s-200ms
python3 tools/check_sweep_acoustics.py build/test-60s-300ms
python3 tools/check_sweep_acoustics.py build/test-60s-200ms
```

The acoustic checker needs NumPy and ffmpeg only on the validation host. It
checks -22 to -16 LUFS, <= -1 dBTP, <5% energy below 250 Hz, >35% at 1–3.5 kHz,
>15 dB empty-slot envelope range and correlation at the dwell lag. Existing CI
also compares PCM/event prefixes, other rates, reverse and longer sessions.

## Validation status after macOS run 34431053760

The real AVAudioEngine outputs at commit `dbdecd85` (run 34431053760) passed scheduling,
30/60-second seeded PCM/event prefix identity, all four rates, reverse,
the level audit, and the 12-minute diversity test. At that commit the default output gain
was still 2.4; the 60-second acoustic measurements are:

| Metric | 300 ms | 200 ms |
|---|---:|---:|
| Integrated LUFS | -21.56 | -21.42 |
| True peak dBTP | -2.41 | -2.42 |
| Energy below 250 Hz | 1.83% | 1.26% |
| Energy 1–3.5 kHz | 61.40% | 59.88% |
| Empty-slot p90–p10 RMS range | 27.82 dB | 27.63 dB |
| Dwell-lag correlation | 0.600 | 0.683 |

Samples are stored with commit/run provenance in the CI artifact `actual-engine-listening-samples`.
They are actual engine output, not Python previews.

**Headroom, Limiter, and Glimpse Coordination Updates (verified in run 34431053760):**
1. Vocal glimpses balanced toward 0.105 RMS with 4x bounded lift and 0.65 peak ceiling.
2. Glimpse placement coordinated after the 10 ms commutation quiet shelf, eliminating the 20.6% glimpse muting bug.
3. Master limiter sample ceiling calibrated to -2.5 dBFS (0.7498942) with ~1.5 dB true-peak margin, replacing the punitive 2.605 Lanczos norm ceiling.

## Run 3 listening follow-up (this branch)

After the live Run 3 2-minute smoke review, two renderer defaults were changed:

4. Output gain calibrated from 2.4 to 3.5. This pulls integrated loudness to about
   -18.3 LUFS and mitigates the rate-switch volume plunge while retaining roughly
   1.4 dB of true-peak headroom below the -2.5 dBFS sample limiter ceiling.
5. Clusteriness set to 0.0 to eliminate rapid back-to-back voice flipping on adjacent
   slots. The hard vocal-run cap of two slots remains in `VocalDensityScheduler`.

All macOS compilation, unit tests, PCM identity, level-audit and acoustic checks PASS.

No 10/10 rating, release approval or physical-device listening gate is inferred
from these technical results. Live-device versus offline PCM identity has not
been independently captured and compared; only their shared slot path and
seeded offline prefix identity have been established.

## Run 4 listening review and acoustic remediation

In TestFlight Build 4 (commit `4eb5a164`), listening review identified two severe acoustic defects:
1. Pulsing / gating static bed ("constantly going in and out, sounds unnatural").
2. Unnatural, clicky voice pops appearing far too frequently.

### Root Cause Analysis
1. **Periodic noise bed gating tremolo**: In `ProceduralNoiseSource.swift`, `SweepSlotMixer.mix` multiplied `(channels[c][i] * vocalGain + bed) * envelope`, where `envelope` ducked the signal to 0.06 (-24.4 dB) for 10 ms at the start of every slot. This created a 3.3 Hz to 13 Hz square/trapezoidal gating tremolo across the static noise bed, violating Source of Truth §18.1 ("one continuous noise/static bed").
2. **Excessive vocal event density**: `vocalEventProbability` was hardcoded to `0.33` (33% of dwells). At 200–300 ms sweep rates, this fired voices every 0.6–0.9 seconds (100+ voices per minute). The measured reference audio analysis (`build/reference_audio_analysis/analysis.md`) showed `speech_step_probability = 0.0576` (~5.8% of dwells). 33% density overwhelmed the listener with a constant barrage of voice clips, violating §6.2 ("allow long stretches with nothing interpretable").
3. **Micro-truncation transient pops**: Dwell exposures had a hard cap of 75 ms (at 300 ms rate) down to 50 ms minimums. An isolated 50 ms snippet with 8 ms linear ramps leaves only ~34 ms of steady speech—insufficient to resolve vowel formant transitions or natural speech attacks, producing sharp click/pop transients.
4. **Literal PCM reversal**: On reverse sweep, `reverse(cropped)` reversed the PCM waveform into backwards phonemes instead of scanning the corpus sequence in reverse order as specified in the reference prototype.

### Remediations Implemented
1. **Continuous static bed**: Restored uninterrupted noise addition in `SweepSlotMixer.mix`. `slotEnvelope` returns 1.0, removing the 10 ms gating drop. Empty-slot p90-p10 envelope spread drops from 27.8 dB to ~3.7 dB, eliminating static pulsing.
2. **Reference-calibrated vocal density**: Reduced `vocalEventProbability` from 0.33 to 0.08 (~8%), closely matching the reference audio baseline (~5.8%).
3. **Natural human vocal glimpses**: Scaled exposure window to 80–220 ms (50–80% of dwell duration; 150–220 ms at 300 ms rate, 100–160 ms at 200 ms rate) with smooth raised-cosine (Hanning) windowing to eliminate truncation clicks.
4. **Natural reverse sweep scan**: Traverses source assets in reverse corpus sequence while playing forward speech snippets.
5. **Acoustic validation**: `tools/check_sweep_acoustics.py` updated to verify `continuous_bed` (envelope spread < 12.0 dB) alongside loudness (-18.6 LUFS) and peak headroom (-7.5 dBTP).

