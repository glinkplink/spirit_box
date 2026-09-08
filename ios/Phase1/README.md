# Bundled Phase 1 corpus (recording 105 pilot)

`manifest.json` and `rec105_*.wav` are bundled into the harness app so TestFlight builds load the corpus without copying files on device.

This bank is a single-recording human pilot. Isolated-fragment recognition review and the physical-device listening gate have not run.

Regenerate from `recordings/New Recording 105.m4a`:

```bash
.venv-kokoro/bin/python tools/render_recording_sweep.py \
  'recordings/New Recording 105.m4a' build/recording-105-new
cp -a build/recording-105-new/SpiritBoxPhase1Corpus/. ios/Phase1/
```

Loader order: Documents corpus uploaded for the current bundled identity → this folder → leftover Documents only if no bundle → `DevFixtures`.
A leftover Documents copy from an older bank is ignored after this bundle ships. Upload corpus still overrides this bundle until the next bundled bank change.
