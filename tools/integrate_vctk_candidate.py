#!/usr/bin/env python3
"""Preserve candidate PCM and rights while carrying source provenance into runtime."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import zipfile


def integrate(candidate: Path, output: Path):
    corpus = candidate / 'SpiritBoxPhase1Corpus'
    manifest = json.loads((corpus / 'manifest.json').read_text())
    provenance = json.loads((candidate / 'provenance.json').read_text())
    origins = {row['asset_id']: row for row in provenance}
    if len(origins) != len(provenance):
        raise ValueError('Duplicate provenance asset IDs')
    assets = manifest['assets']
    if len({a['asset_id'] for a in assets}) != len(assets):
        raise ValueError('Duplicate runtime asset IDs')
    for asset in assets:
        origin = origins[asset['asset_id']]
        relative = Path(asset['relative_path'])
        if relative.is_absolute() or '..' in relative.parts:
            raise ValueError('Unsafe source path')
        path = corpus / relative
        if hashlib.sha256(path.read_bytes()).hexdigest() != origin['output_sha256']:
            raise ValueError(f'Candidate PCM hash mismatch: {path}')
        source = Path(origin['source_file'])
        if not source.name.endswith('_mic1.flac'):
            raise ValueError('Expected one consistent microphone (mic1)')
        utterance = source.stem.removesuffix('_mic1')
        if not utterance.startswith(asset['performer_id'] + '_'):
            raise ValueError('Speaker / utterance mismatch')
        asset.update(utterance_id=utterance, source_file=origin['source_file'],
                     source_start_frame=origin['source_start_frame'],
                     source_frame_count=origin['source_frame_count'])
        if asset['source_start_frame'] < 0 or asset['source_frame_count'] <= 0:
            raise ValueError('Invalid source window')
    # Validate everything before creating output; originals are never mutated.
    for name in ('license_text.txt', 'UPSTREAM_README.txt', 'speaker-info.txt', 'ATTRIBUTION.txt'):
        if not (corpus / name).is_file():
            raise ValueError(f'Missing source rights material: {name}')
    output.mkdir(parents=True, exist_ok=False)
    destination = output / 'SpiritBoxPhase1Corpus'
    shutil.copytree(corpus, destination)
    manifest['label'] = 'VCTK six-speaker renderer experiment — human listening pending'
    (destination / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    shutil.copy2(candidate / 'provenance.json', destination / 'provenance.json')
    (destination / 'README.md').write_text('''# VCTK renderer experiment

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
''')
    with zipfile.ZipFile(output / 'SpiritBoxPhase1Corpus.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(destination.iterdir()):
            archive.write(path, path.relative_to(output))
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('candidate', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    result = integrate(args.candidate, args.output)
    print(f"Integrated {len(result['assets'])} verified assets into {args.output}")
