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

Defaults: static 0.10, voice 0.48, master 5.2, clusteriness 0.18. Vocal runs stop
at two slots, including custom density 1. Exposure is at most 85 ms by default
(90 ms hard limit), with a 75 ms hard limit at the 300 ms detent. Shortening a
window cannot guarantee that no listener will recognize a word.

Both layers use identical 500 Hz high-pass and 3600 Hz low-pass Butterworth
biquads and a 2350 Hz, +3.5 dB, Q 1.75 presence filter. Noise filter state persists
between dwells. The slot envelope has a quiet 18% portion with 6 ms transitions:
a 6 ms dip alone cannot satisfy a p10 threshold on a 300 ms dwell.

The master limiter uses a 2 ms anticipatory envelope and 40 ms release with a
conservative sample bound derived from the absolute coefficient sum of a
normalized 32-tap, 4x Lanczos interpolator. Its reconstructed ceiling is -1 dBFS.
This deliberately leaves more sample-peak headroom than a sample clipper; ffmpeg
true-peak measurement remains an independent acceptance check. Limiter state
resets in each quiet slot boundary; it is independent of graph callback size.
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

## Validation status after macOS run 34426367231

The real AVAudioEngine outputs at commit `82774222` passed scheduling,
30/60-second seeded PCM/event prefix identity, all four rates, reverse,
and the 12-minute diversity test. The 60-second acoustic measurements were:

| Metric | 300 ms | 200 ms |
|---|---:|---:|
| Integrated LUFS | -17.51 | -17.58 |
| True peak dBTP | -9.01 | -9.01 |
| Energy below 250 Hz | 0.251% | 0.226% |
| Energy 1–3.5 kHz | 68.76% | 68.30% |
| Empty-slot p90–p10 RMS range | 24.51 dB | 24.54 dB |
| Dwell-lag correlation | 0.859 | 0.860 |

Samples are copied to `build/test-60s-300ms/` and `build/test-60s-200ms/`,
with commit/run provenance. They are actual engine output, not Python previews.

**Remaining correction, local and uncommitted:** the full-corpus level audit
found median pre-limiter voice/static ratios of -4.47 dB at 200 ms and -3.36 dB
at 300 ms despite the requested gain defaults. The factory now balances faded
vocal glimpses toward 0.105 RMS, with maximum 4x lift and the existing 0.65 peak
limit. This targets roughly +6 dB against the measured 0.025 RMS bed; near-silent
windows remain quiet. A new regression covers target RMS, bounded lift and
transient ceilings, and the CLI audit requires median SNR within +4…+8 dB.

This final correction is NOT in the CI samples above and needs fresh macOS
compilation, unit tests, PCM identity, level-audit and acoustic measurements.

No 10/10 rating, release approval or physical-device listening gate is inferred
from these technical results. Live-device versus offline PCM identity has not
been independently captured and compared; only their shared slot path and
seeded offline prefix identity have been established.
