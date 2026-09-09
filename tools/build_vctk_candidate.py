#!/usr/bin/env python3
"""Build traceable human microclips and diagnostic previews, never release approval."""
import argparse
import csv
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import zipfile
import numpy as np
import soundfile as sf
from render_recording_sweep import SR, band, fade, rms, metrics


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def write_json(p, value):
    p.write_text(json.dumps(value, indent=2) + '\n')


def prepare(source, out):
    expected = {f['path']: f['sha256'] for f in json.loads((source/'download-manifest.json').read_text())['files']}
    rng = np.random.default_rng(20260909)
    speakers = sorted(p.name for p in (source/'wav48_silence_trimmed').iterdir() if p.is_dir())
    assert len(speakers) == 6
    selected = {}
    for speaker in speakers:
        choices = []
        files = sorted((source/'wav48_silence_trimmed'/speaker).glob('*_mic1.flac'))
        rng.shuffle(files)
        for path in files:
            rel = str(path.relative_to(source))
            sha = digest(path)
            assert sha == expected[rel], f'Source hash mismatch: {rel}'
            x, sr = sf.read(path)
            assert sr == SR and x.ndim == 1 and np.all(np.isfinite(x))
            # One short interior cut per distinct utterance. No transcripts or semantic selection.
            n = int(rng.integers(200, 241))*48
            candidates = []
            for start in range(4800, len(x)-n-4800, 960):
                raw = x[start:start+n]
                level = rms(raw)
                if level < .018 or np.max(np.abs(raw)) >= .99:
                    continue
                chunks = raw[:len(raw)//480*480].reshape(-1,480)
                energy = np.sqrt(np.mean(chunks**2,axis=1))
                # Prefer changing articulation energy, reject nearly silent / held-energy cuts.
                movement = float(np.std(energy)/(np.mean(energy)+1e-12))
                if .18 < movement < 1.1 and np.mean(energy > .009) > .75:
                    candidates.append((start, movement))
            if not candidates:
                continue
            start, movement = candidates[int(rng.integers(len(candidates)))]
            y = band(x[start:start+n]-np.mean(x[start:start+n]), 100, 10000)
            gain = min(4., .10/(rms(y)+1e-12), .48/(np.max(np.abs(y))+1e-12))
            y = fade(y*gain, 6)
            choices.append((y, dict(source_file=rel, source_sha256=sha, source_start_frame=start,
                source_frame_count=n, gain=gain, energy_variation=movement)))
            if len(choices) == 200:
                break
        if len(choices) != 200:
            raise ValueError(f'Insufficient candidates for {speaker}: {len(choices)}')
        selected[speaker] = choices
        print(speaker, len(choices), flush=True)
    corpus = out/'SpiritBoxPhase1Corpus'
    corpus.mkdir()
    assets, clips, provenance = [], [], []
    previous_speaker = None
    for i in range(200):
        block = list(rng.permutation(speakers))
        if block[0] == previous_speaker:
            block[0], block[1] = block[1], block[0]
        previous_speaker = block[-1]
        for j, speaker in enumerate(block):
            y, origin = selected[speaker][i]
            aid = f'vctk_{i*6+j:04d}_{speaker}'
            path = corpus/f'{aid}.wav'
            sf.write(path, y, SR, subtype='PCM_24')
            duration = len(y)//48
            assets.append(dict(asset_id=aid, performer_id=speaker, voice_family=speaker,
                utterance_id=Path(origin['source_file']).stem.removesuffix('_mic1'),
                source_file=origin['source_file'], source_start_frame=origin['source_start_frame'],
                source_frame_count=origin['source_frame_count'],
                duration_ms=duration, forward_allowed=True, reverse_allowed=True,
                crop_safe_start_ms=6, crop_safe_end_ms=duration-6, relative_path=path.name,
                prep_version='vctk-candidate-1', rights_record_id='VCTK-0.92-CCBY4'))
            provenance.append(dict(asset_id=aid, performer=speaker, **origin,
                output_sha256=digest(path), recognition_review='NOT_REVIEWED', license='CC BY 4.0'))
            clips.append(y)
    write_json(corpus/'manifest.json', dict(schema_version=1, kind='pilot',
        label='VCTK six-speaker release candidate — listening review pending', assets=assets))
    write_json(out/'provenance.json', provenance)
    for name in ('license_text.txt','UPSTREAM_README.txt','speaker-info.txt'):
        shutil.copy2(source/name, corpus/name)
    (corpus/'ATTRIBUTION.txt').write_text('Derived from CSTR VCTK Corpus 0.92, Yamagishi, Junichi; Veaux, Christophe; MacDonald, Kirsten (2019), University of Edinburgh, CSTR. Copyright (c) 2019 Junichi Yamagishi. https://doi.org/10.7488/ds/2645\nCC BY 4.0: https://creativecommons.org/licenses/by/4.0/\nModifications: one 200–240 ms interior crop per source utterance, DC removal, 100–10000 Hz filtering, bounded gain, 6 ms fades, 48 kHz mono 24-bit WAV conversion. No endorsement implied. Full license and publisher notices included.\n')
    with (out/'recognition-review.csv').open('w') as f:
        w = csv.writer(f); w.writerow(['asset_id','audition_seconds','reviewer','word_or_phrase','repeat_or_voice_issue','decision'])
        for i, a in enumerate(assets):
            w.writerow([a['asset_id'], round(sum(len(c)/SR+.20 for c in clips[:i]),3),'','','','PENDING'])
    sf.write(out/'fragment-audition.wav', np.concatenate([np.r_[c,np.zeros(9600)] for c in clips]), SR, subtype='PCM_16')
    return assets, clips


def render(assets, clips, out, name, seconds, seed, dwell=.2, reverse=False):
    rng = np.random.default_rng(seed)
    y = np.zeros(round(seconds*SR), dtype=np.float32)
    # Continuous filtered noise bed; no per-tick silence seams.
    for start in range(0,len(y),SR*10):
        end = min(len(y),start+SR*10)
        z = band(rng.normal(size=end-start),180,6800)
        y[start:end] = z*(.018/(rms(z)+1e-12))
    order = list(range(len(clips)))
    if reverse: order.reverse()
    events = []; cursor=0; previous=False
    for tick in range(int(seconds/dwell)):
        vocal = rng.random() < (.48 if previous else .67)
        previous = vocal
        if not vocal: continue
        idx = order[cursor % len(order)]; cursor += 1
        length = min(round((dwell-.012)*SR), int(rng.integers(6000,9025)))
        speed = float(rng.uniform(.94,1.06))
        consumed = min(len(clips[idx])-576, round(length*speed))
        offset = int(rng.integers(288,len(clips[idx])-consumed-287))
        raw = clips[idx][offset:offset+consumed]
        if reverse: raw=raw[::-1]
        v = np.interp(np.linspace(0,len(raw)-1,length),np.arange(len(raw)),raw)
        lo,hi = [(220,4400),(350,6200),(160,3300),(500,5200)][int(rng.integers(4))]
        v=band(v,lo,hi); v=fade(v*min(2.5,.085/(rms(v)+1e-12)),6)
        start=round(tick*dwell*SR)+240
        y[start:start+length] += v
        events.append(dict(time_seconds=start/SR,asset_id=assets[idx]['asset_id'],performer_id=assets[idx]['performer_id'],
            source_crop_start_ms=offset/48,source_crop_duration_ms=consumed/48,duration_ms=length/48,
            speed=speed,direction='reverse' if reverse else 'forward',spectral_profile_hz=[lo,hi]))
    y=fade(np.tanh(y*1.15)/1.15,15)
    sf.write(out/f'{name}.wav',y,SR,subtype='PCM_16')
    subprocess.run(['ffmpeg','-v','error','-i',str(out/f'{name}.wav'),'-codec:a','libmp3lame','-b:a','192k',str(out/f'{name}.mp3')],check=True)
    (out/f'{name}.events.jsonl').write_text(''.join(json.dumps(e)+'\n' for e in events))
    last={}; distances=[]
    for e in events:
        if e['asset_id'] in last: distances.append(e['time_seconds']-last[e['asset_id']])
        last[e['asset_id']]=e['time_seconds']
    result=dict(**metrics(y), seed=seed, sweep_ms=dwell*1000, events=len(events),unique_assets=len(last),
        minimum_repeat_seconds=min(distances) if distances else None,
        consecutive_same_performer=sum(a['performer_id']==b['performer_id'] for a,b in zip(events,events[1:])),
        renderer='Diagnostic Python preview, NOT iOS engine capture', human_audio_gate='NOT_RUN')
    write_json(out/f'{name}.metrics.json',result)
    print(name,result,flush=True)


def main():
    p=argparse.ArgumentParser(); p.add_argument('source',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--diagnostic-previews', action='store_true', help='Optional old Python previews, not app renderer acceptance audio')
    a=p.parse_args(); a.output.mkdir(parents=True,exist_ok=False)
    assets,clips=prepare(a.source,a.output)
    shutil.copy2(a.output/'provenance.json', a.output/'SpiritBoxPhase1Corpus'/'provenance.json')
    if a.diagnostic_previews:
        render(assets,clips,a.output,'LISTEN-FIRST',60,20260909)
    with zipfile.ZipFile(a.output/'SpiritBoxPhase1Corpus.zip','w',zipfile.ZIP_DEFLATED) as z:
        for path in sorted((a.output/'SpiritBoxPhase1Corpus').iterdir()):
            z.write(path,str(path.relative_to(a.output)))

if __name__=='__main__': main()
