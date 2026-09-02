# Bundled Phase 1 corpus (me_test)

`manifest.json` and `me_test_*.wav` are bundled into the harness app so TestFlight builds load the corpus without copying files on device.

Regenerate from `recordings/me_test.m4a`:

```bash
PYTHONPATH=. python3 tools/prepare_corpus.py recordings/me_test.m4a \
  --family me_test --output build/corpus/me_test
cp -a build/corpus/me_test/SpiritBoxPhase1Corpus/. ios/Phase1/
```

Loader order: `Documents/SpiritBoxPhase1Corpus` → this folder → `DevFixtures`.
