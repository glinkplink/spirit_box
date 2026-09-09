#!/usr/bin/env python3
"""Technical checks of actual AVAudioEngine PCM and trace, not perceptual approval."""
from array import array
import argparse
import json
from pathlib import Path
import math
import sys
import wave


def check(directory):
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
                  technical_checks='PASS', human_listening='NOT_RUN')
    (directory / 'technical-checks.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path)
    parser.add_argument('--compare-prefix', type=Path, help='Require identical seeded PCM/events over the shorter duration')
    args = parser.parse_args()
    check(args.directory)
    if args.compare_prefix:
        with wave.open(str(args.directory / 'sweep.wav'), 'rb') as first, wave.open(str(args.compare_prefix / 'sweep.wav'), 'rb') as second:
            count = min(first.getnframes(), second.getnframes())
            assert first.getparams()[:3] == second.getparams()[:3]
            assert first.readframes(count) == second.readframes(count), 'Seeded PCM prefix differs: offline scheduling was not reproducible'
        a = (args.directory / 'events.jsonl').read_text().splitlines()
        b = (args.compare_prefix / 'events.jsonl').read_text().splitlines()
        assert a[:min(len(a),len(b))] == b[:min(len(a),len(b))], 'Seeded event prefix differs'
        print('Seeded PCM and event prefix: identical')
