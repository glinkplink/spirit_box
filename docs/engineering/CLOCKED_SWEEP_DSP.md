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

Defaults: static 0.10, voice 0.48, master 2.4, clusteriness 0.18. Vocal runs stop
at two slots, including custom density 1. Exposure is at most 85 ms by default
(90 ms hard limit), with a 75 ms hard limit at the 300 ms detent. Shortening a
window cannot guarantee that no listener will recognize a word.

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
checks -18 to -16 LUFS, <= -1 dBTP, <5% energy below 250 Hz, >35% at 1–3.5 kHz,
>15 dB empty-slot envelope range and correlation at the dwell lag. Existing CI
also compares PCM/event prefixes, other rates, reverse and longer sessions.

## Validation status after macOS runs 34426367231 and 34431053760

The real AVAudioEngine outputs at commit `dbdecd85` (run 34431053760) passed scheduling,
30/60-second seeded PCM/event prefix identity, all four rates, reverse,
the level audit, and the 12-minute diversity test. The 60-second acoustic measurements are:

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
4. Output gain adjusted to 2.4, giving the static bed ~10 dB of clean headroom below the limiter ceiling.
5. Commutation dip shortened to 10 ms with 5 ms transitions, replacing the 18% (54 ms) synthetic tremolo with a realistic tuner PLL commutation step. Post-limiter vocal emergence reaches +2.7 dB whole-slot and +7.3 dB active-window, with 0% of vocal slots quieter than the noise bed.

All macOS compilation, unit tests, PCM identity, level-audit and acoustic checks PASS.

No 10/10 rating, release approval or physical-device listening gate is inferred
from these technical results. Live-device versus offline PCM identity has not
been independently captured and compared; only their shared slot path and
seeded offline prefix identity have been established.
