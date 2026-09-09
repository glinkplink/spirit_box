#!/usr/bin/env python3
"""Technical checks of actual AVAudioEngine PCM and trace, not perceptual approval."""
from array import array
from collections import Counter
import argparse
import json
from pathlib import Path
import math
import sys
import wave


def diversity(events, assets):
    """Enforce an unseen admissible source before repeats, without relaxing safety.

    This is a fairness contract, not a percentage fitted to a particular seed.
    Any repeat while an unseen source is admissible is a coverage failure.
    """
    unseen = {a['asset_id']: a for a in assets}
    available = len(unseen)
    recent_speakers, recent_utterances = [], []
    speakers, last, distances = Counter(), {}, []
    for index, event in enumerate(events):
        aid = event['asset_id']
        assert any(a['asset_id'] == aid for a in assets), f'Unknown asset: {aid}'
        if aid in last:
            distances.append(index - last[aid])
            blocked_speakers = set(recent_speakers[-2:])
            blocked_utterances = set(recent_utterances[-32:])
            # Unseen assets cannot be in the fragment cooldown window.
            assert not any(a['performer_id'] not in blocked_speakers and
                           a['utterance_id'] not in blocked_utterances for a in unseen.values()), \
                f'Corpus starvation at event {index}: repeated {aid} with admissible unseen sources'
        unseen.pop(aid, None)
        last[aid] = index
        speakers[event['performer_id']] += 1
        recent_speakers.append(event['performer_id'])
        recent_utterances.append(event['utterance_id'])
    # A general conservative bound: at most two speaker groups and 32
    # utterance groups can block unseen sources. Overlap only strengthens it.
    speaker_sizes = sorted(Counter(a['performer_id'] for a in assets).values(), reverse=True)
    utterance_sizes = sorted(Counter(a['utterance_id'] for a in assets).values(), reverse=True)
    lower_bound = min(len(events), max(0, available - sum(speaker_sizes[:2]) - sum(utterance_sizes[:32])))
    unique = len(last)
    assert unique >= lower_bound, (unique, lower_bound)
    if len(events) >= 2 * available:
        assert unique == available, 'Two corpus passes must reach every bundled source'
    ordered = sorted(distances)
    return dict(available_assets=available, unique_assets=unique,
                unique_assets_per_event=unique / len(events), corpus_coverage=unique / available,
                conservative_unique_lower_bound=lower_bound,
                per_speaker_event_counts=dict(sorted(speakers.items())),
                repeat_distance=dict(minimum=min(distances) if distances else None,
                                     median=ordered[len(ordered)//2] if ordered else None,
                                     maximum=max(distances) if distances else None,
                                     histogram=dict(sorted(Counter(distances).items()))))


def check(directory, manifest_path=None):
    with wave.open(str(directory / 'sweep.wav'), 'rb') as wav:
        assert wav.getsampwidth() == 2
        sample_rate, channels = wav.getframerate(), wav.getnchannels()
        pcm = array('h', wav.readframes(wav.getnframes()))
        duration = wav.getnframes() / sample_rate
    if sys.byteorder != 'little':
        pcm.byteswap()
    peak = max(abs(x) for x in pcm) / 32768
    assert 0.001 < peak < 0.99, f'Silent or clipped output: peak={peak}'
    block = round(sample_rate * channels * .02)
    levels = [math.sqrt(sum(v*v for v in pcm[i:i+block]) / len(pcm[i:i+block])) / 32768
              for i in range(0, len(pcm), block)]
    assert min(levels) > .0001, f'Silent 20ms block: {min(levels)}'
    events = [json.loads(line) for line in (directory / 'events.jsonl').read_text().splitlines() if line]
    assert events, 'No vocal events'
    manifest_path = manifest_path or Path(__file__).resolve().parents[1] / 'ios/Phase1/manifest.json'
    assets = json.loads(manifest_path.read_text())['assets']
    direction = events[0]['direction'].lower()
    assets = [a for a in assets if a.get(direction + '_allowed', True)]
    diversity_report = diversity(events, assets)
    engine_diagnostics = json.loads((directory / 'engine-diagnostics.json').read_text())
    assert engine_diagnostics['available_assets'] == len(assets)
    assert engine_diagnostics['decoded_source_count'] >= len(assets)
    last_asset, last_speaker, last_utterance = {}, {}, {}
    source_ids = set()
    for index, event in enumerate(events):
        aid, speaker, utterance = event['asset_id'], event['performer_id'], event['utterance_id']
        for key, history, minimum in [(aid, last_asset, 64), (speaker, last_speaker, 2), (utterance, last_utterance, 32)]:
            if key in history:
                assert index - history[key] > minimum, (event, minimum)
            history[key] = index
        assert event['source_start_frame'] >= 0
        assert event['emitted_frame_count'] > 0
        assert event['emitted_frame_count'] <= event['sweep_rate_ms'] * 48
        assert event['crop_offset_frames'] + event['emitted_frame_count'] <= event['source_frame_count']
        assert not event['relaxed_constraints']
        if index:
            previous = events[index-1]
            delta = event['render_time_seconds'] - previous['render_time_seconds']
            assert abs(delta - previous['sweep_rate_ms']/1000) < 1/sample_rate, (delta, previous)
        source_ids.add(aid)
    result = dict(duration_seconds=duration, sample_rate=sample_rate, channels=channels,
                  peak=peak, minimum_20ms_rms=min(levels), events=len(events),
                  unique_assets=len(source_ids), speakers=sorted(last_speaker),
                  diversity=diversity_report, engine=engine_diagnostics,
                  technical_checks='PASS', human_listening='NOT_RUN')
    (directory / 'technical-checks.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path)
    parser.add_argument('--manifest', type=Path)
    parser.add_argument('--compare-prefix', type=Path, help='Require identical seeded PCM/events over the shorter duration')
    args = parser.parse_args()
    check(args.directory, args.manifest)
    if args.compare_prefix:
        with wave.open(str(args.directory / 'sweep.wav'), 'rb') as first, wave.open(str(args.compare_prefix / 'sweep.wav'), 'rb') as second:
            count = min(first.getnframes(), second.getnframes())
            assert first.getparams()[:3] == second.getparams()[:3]
            assert first.readframes(count) == second.readframes(count), 'Seeded PCM prefix differs: offline scheduling was not reproducible'
        a = (args.directory / 'events.jsonl').read_text().splitlines()
        b = (args.compare_prefix / 'events.jsonl').read_text().splitlines()
        assert a[:min(len(a),len(b))] == b[:min(len(a),len(b))], 'Seeded event prefix differs'
        print('Seeded PCM and event prefix: identical')
