#!/usr/bin/env python3
"""Offline pilot preparation/rendering. Requires numpy, soundfile and ffmpeg.
No semantic analysis; output requires human recognition review before shipping.
Reference files are measured separately and never enter the synthesis path.
"""
import argparse
from collections import deque
import hashlib
import json
from pathlib import Path
import subprocess
import numpy as np
import soundfile as sf

SR = 48000

def rms(x):
    return float(np.sqrt(np.mean(np.square(x), dtype=np.float64)))

def fade(x, ms=6):
    x = x.copy()
    n = min(len(x)//2, round(SR*ms/1000))
    ramp = np.linspace(0, 1, n)
    x[:n] *= ramp
    x[-n:] *= ramp[::-1]
    return x

def band(x, low, high):
    # Zero padding isolates FFT filtering from circular wrap at clip boundaries.
    n = 1 << (len(x)*2-1).bit_length()
    f = np.fft.rfftfreq(n, 1/SR)
    response = (1-np.exp(-(f/low)**4))*np.exp(-(f/high)**6)
    return np.fft.irfft(np.fft.rfft(x, n)*response, n)[:len(x)]

def metrics(x):
    peak = float(np.max(np.abs(x)))
    return dict(duration_seconds=len(x)/SR, peak_dbfs=20*np.log10(peak+1e-12),
                rms_dbfs=20*np.log10(rms(x)+1e-12), clipped_samples=int(np.sum(abs(x)>=1)),
                finite=bool(np.all(np.isfinite(x))))

def prepare(source, out):
    corpus = out/'SpiritBoxPhase1Corpus'
    if corpus.exists():
        raise FileExistsError('Use a new output folder; existing corpus is preserved')
    decoded = out/'source-decoded.wav'
    if source.resolve() == decoded.resolve():
        raise ValueError('Decoded output must not overwrite the source')
    pcm = subprocess.run(['ffmpeg','-v','error','-i',str(source),'-ac','1',
                          '-ar',str(SR),'-f','f32le','pipe:1'],
                         check=True,capture_output=True).stdout
    x = np.frombuffer(pcm,dtype='<f4').astype(np.float64)
    if not len(x) or not np.all(np.isfinite(x)):
        raise ValueError('Source must contain finite audio samples')
    sf.write(decoded,x,SR,subtype='FLOAT')
    corpus.mkdir(exist_ok=False)
    # 10ms energy segmentation; no transcript, word matching or recognition claims.
    frames = x[:len(x)//480*480].reshape(-1,480)
    energy = np.sqrt(np.mean(frames*frames,axis=1))
    threshold = max(10**(-30/20), float(np.percentile(energy,10))*2.5)
    active = energy > threshold
    edges = np.diff(np.r_[False,active,False].astype(int))
    spans = list(zip(np.flatnonzero(edges==1)*480,np.flatnonzero(edges==-1)*480))
    merged = []
    for a,b in spans:
        if merged and a-merged[-1][1] < .06*SR:
            merged[-1][1]=b
        else:
            merged.append([a,b])
    assets=[]; audio=[]; provenance=[]
    for a,b in merged:
        if b-a < .14*SR:
            continue
        # Disjoint short source cuts break long trajectories without duplicating takes.
        for start in range(max(0,a-480),b-int(.18*SR),int(.43*SR)):
            end=min(start+int(.34*SR),b+480)
            if end-start < .20*SR:
                continue
            raw=x[start:end]
            if rms(raw)<threshold*.8:
                continue
            y=band(raw-np.mean(raw),100,10000)
            gain=min(3.0, .12/(rms(y)+1e-12), .50/(max(abs(y))+1e-12))
            y=fade(y*gain)
            i=len(assets)+1; aid=f'rec105_{i:04d}'
            path=corpus/f'{aid}.wav'
            sf.write(path,y,SR,subtype='PCM_24')
            assets.append(dict(asset_id=aid,performer_id='REC105',voice_family='recording_105',
                duration_ms=round(len(y)/SR*1000),forward_allowed=True,reverse_allowed=True,
                crop_safe_start_ms=6,crop_safe_end_ms=round(len(y)/SR*1000)-6,
                relative_path=path.name,prep_version='recording-sweep-1'))
            provenance.append(dict(asset_id=aid,source_start_seconds=start/SR,source_end_seconds=end/SR,
                gain=gain,sha256=hashlib.sha256(path.read_bytes()).hexdigest(),recognition_review='NOT_REVIEWED'))
            audio.append(y)
    if len(assets)<16:
        raise ValueError('Insufficient active source material for the pilot')
    manifest=dict(schema_version=1,label='Recording 105 human pilot — recognition review pending',kind='pilot',assets=assets)
    (corpus/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (out/'source-provenance.json').write_text(json.dumps(dict(source=str(source),source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),source_metrics=metrics(x),threshold_dbfs=20*np.log10(threshold),assets=provenance),indent=2)+'\n')
    # Dry separated audition reel makes source review possible without masking.
    sf.write(out/'fragment-audition.wav',np.concatenate([np.r_[a,np.zeros(SR//5)] for a in audio]),SR,subtype='PCM_16')
    return assets,audio

def render(assets, clips, out, name, seconds, seed, dwell=.2, reverse=False):
    rng=np.random.default_rng(seed)
    y=np.zeros(round(seconds*SR),dtype=np.float32)
    events=[]; recent=deque(maxlen=min(96,len(clips)//2)); last_source_start=None
    profiles=[(220,4400),(350,6200),(160,3300),(500,5200)]
    # Traverse a fixed seeded source ordering; no user or environmental input.
    order=rng.permutation(len(clips)).tolist()
    if reverse: order.reverse()
    cursor=0; t=0.; last_voice=False
    while t<seconds:
        start=round(t*SR); size=min(round(dwell*SR),len(y)-start)
        if size<=0: break
        p=int(rng.integers(len(profiles))); lo,hi=profiles[p]
        noise=band(rng.normal(size=size),180,6800)
        noise*=float(rng.uniform(.014,.025))/(rms(noise)+1e-12)
        # Noise remains continuous across ticks with only a tiny join fade.
        noise=fade(noise,1)
        y[start:start+size]+=noise.astype(np.float32)
        vocal=bool(rng.random() < (.48 if last_voice else .67))
        last_voice=vocal
        if vocal:
            for _ in range(len(order)):
                idx=order[cursor%len(order)];cursor+=1
                if idx not in recent and (last_source_start is None or abs(idx-last_source_start)>2): break
            recent.append(idx);last_source_start=idx
            speed=float(rng.uniform(.92,1.08))
            length=min(size-round(.012*SR),round(rng.uniform(.125,.188)*SR))
            consumed=min(len(clips[idx])-2,round(length*speed))
            offset=int(rng.integers(0,len(clips[idx])-consumed+1))
            raw=clips[idx][offset:offset+consumed]
            if reverse:raw=raw[::-1]
            v=np.interp(np.linspace(0,len(raw)-1,length),np.arange(len(raw)),raw)
            v=band(v,lo,hi)
            gain=min(2.5,float(rng.uniform(.065,.115))/(rms(v)+1e-12))
            v=fade(v*gain,6)
            delay=round(rng.uniform(.002,.009)*SR)
            v=v[:len(y)-start-delay]
            y[start+delay:start+delay+len(v)]+=v.astype(np.float32)
            events.append(dict(time_seconds=(start+delay)/SR,asset_id=assets[idx]['asset_id'],
                source_crop_start_ms=offset/SR*1000,source_crop_duration_ms=consumed/SR*1000,
                duration_ms=len(v)/SR*1000,speed=speed,direction='reverse' if reverse else 'forward',
                spectral_profile_hz=[lo,hi],gain=gain,performer_id='REC105'))
        t+=dwell
    # Gentle bounded saturation; fixed attenuation only if required for headroom.
    y=np.tanh(y*1.15)/1.15
    y*=min(1,.84/float(max(abs(y))))
    y=fade(y,15)
    sf.write(out/f'{name}.wav',y,SR,subtype='PCM_24')
    (out/f'{name}.events.jsonl').write_text(''.join(json.dumps(e)+'\n' for e in events))
    result=metrics(y)
    last={}; distances=[]
    for e in events:
        key=e['asset_id']
        if key in last:distances.append(e['time_seconds']-last[key])
        last[key]=e['time_seconds']
    result.update(seed=seed,sweep_ms=dwell*1000,direction='reverse' if reverse else 'forward',
        events=len(events),unique_sources=len(last),minimum_source_repeat_seconds=min(distances) if distances else None,
        vocal_occupancy=sum(e['duration_ms'] for e in events)/1000/seconds,
        human_listening_gate='NOT_RUN', renderer='offline Python pilot, not an iOS engine capture')
    (out/f'{name}.metrics.json').write_text(json.dumps(result,indent=2)+'\n')
    return result

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('source',type=Path);p.add_argument('output',type=Path)
    args=p.parse_args();args.output.mkdir(parents=True,exist_ok=True)
    assets,clips=prepare(args.source.resolve(),args.output)
    reports={}
    for name,seconds,seed,rev in [('sweep-preview-2min',120,1052026,False),('sweep-reverse-2min',120,1052026,True),('sweep-session-20min',1200,1052027,False)]:
        reports[name]=render(assets,clips,args.output,name,seconds,seed,reverse=rev)
        print(name,json.dumps(reports[name]),flush=True)
    print('assets',len(assets),flush=True)

if __name__=='__main__':main()
