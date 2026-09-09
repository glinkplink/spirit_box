# VCTK renderer experiment

1,200 PCM24 mono 48 kHz windows: 200 each from p225, p226, p227, p230,
p234 and p237. Source: CSTR VCTK 0.92, mic1 only.

Original license and publisher notices are preserved byte-for-byte in
license_text.txt, UPSTREAM_README.txt, speaker-info.txt and ATTRIBUTION.txt.
See ATTRIBUTION.txt for authors, DOI, license link and modifications.

The candidate audio is unchanged: one 200–240 ms interior window per utterance,
DC removal, 100–10000 Hz filtering, bounded gain and 6 ms fades. Runtime adds
narrow-band filtering, fades, bounded gain variation and procedural static.
provenance.json retains original/output hashes and preparation measurements.
manifest.json carries speaker, original utterance/file, crop start/count (48 kHz
frames), duration and unique asset ID into the scheduler and event log.

This is an experimental listening bank, not human audio-quality approval.
Source masters remain in recordings/vctk-0.92; preparation output is under
build/vctk-renderer-integration. No transcripts enter the runtime corpus.
