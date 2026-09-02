# Bundled Phase 1 corpus

This folder is empty on purpose.

To bundle a Phase 1 human corpus into the harness app:

1. Add `manifest.json` here using the production metadata fields.
2. Add the accepted WAV files referenced by `relative_path` or `final_filename`.
3. Rebuild the `SpiritBoxAudioHarness` target.

The loader prefers `Documents/SpiritBoxPhase1Corpus` over this folder, so you can also drop a corpus onto a device without rebuilding.

See `docs/engineering/AUDIO_HARNESS.md`.
