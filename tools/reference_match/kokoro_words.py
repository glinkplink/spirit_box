from __future__ import annotations

from pathlib import Path

from tools.reference_match.constants import SAMPLE_RATE, VOICES

VOICE_LANG = {v["id"]: v["lang"] for v in VOICES}
KOKORO_SR = 24_000
_PIPELINES: dict[str, object] = {}
_MODEL = None


def _pipeline(lang: str):
    global _MODEL
    from kokoro import KModel, KPipeline

    if lang not in _PIPELINES:
        if _MODEL is None:
            _MODEL = KModel(repo_id="hexgrad/Kokoro-82M")
        _PIPELINES[lang] = KPipeline(lang_code=lang, model=_MODEL, repo_id="hexgrad/Kokoro-82M", device="cpu")
    return _PIPELINES[lang]


def synthesize_word(word: str, voice: str, dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        return dest
    import numpy as np
    import soundfile as sf

    pipeline = _pipeline(VOICE_LANG[voice])
    chunks = []
    for result in pipeline(word, voice=voice, speed=1.0):
        audio = result.audio
        if audio is None:
            continue
        if hasattr(audio, "detach"):
            audio = audio.detach().cpu().numpy()
        chunks.append(np.asarray(audio, dtype=np.float32).reshape(-1))
    if not chunks:
        raise RuntimeError(f"Kokoro produced no audio for {voice!r} {word!r}")
    pcm = np.concatenate(chunks)
    sr = KOKORO_SR
    if sr != SAMPLE_RATE:
        t_old = np.linspace(0, 1, num=len(pcm), endpoint=False)
        n_new = int(round(len(pcm) * SAMPLE_RATE / sr))
        t_new = np.linspace(0, 1, num=n_new, endpoint=False)
        pcm = np.interp(t_new, t_old, pcm).astype(np.float32)
        sr = SAMPLE_RATE
    try:
        sf.write(str(dest), pcm, sr, subtype="PCM_16")
    except Exception:
        import wave

        pcm_i = np.clip(pcm, -1, 1)
        pcm_i = np.round(pcm_i * 32767).astype(np.int16)
        with wave.open(str(dest), "wb") as handle:
            handle.setnchannels(1)
            handle.setsampwidth(2)
            handle.setframerate(sr)
            handle.writeframes(pcm_i.tobytes())
    return dest
