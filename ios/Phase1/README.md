# Bundled Phase 1 corpus (recording 105 pilot)

`manifest.json` and `rec105_*.wav` are bundled into the harness app so TestFlight builds load the corpus without copying files on device.

This bank is a single-recording human pilot. Isolated-fragment recognition review and the physical-device listening gate have not run.

Regenerate from `recordings/New Recording 105.m4a`:

```bash
.venv-kokoro/bin/python tools/render_recording_sweep.py \
  'recordings/New Recording 105.m4a' build/recording-105-new
cp -a build/recording-105-new/SpiritBoxPhase1Corpus/. ios/Phase1/
```

Loader order: `Documents/SpiritBoxPhase1Corpus` (if manifest + at least one WAV present) → this folder → `DevFixtures`.
If a previous Documents corpus is still on the device, delete the app or use **Upload corpus** / replace that folder, otherwise Documents wins over this bundle.
