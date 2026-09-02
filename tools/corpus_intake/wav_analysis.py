"""WAV parsing and lightweight PCM diagnostics (stdlib only)."""

from __future__ import annotations

import hashlib
import math
import struct
from pathlib import Path

from .models import WavInfo


class WavParseError(Exception):
    pass


def _read_exact(f, n: int) -> bytes:
    data = f.read(n)
    if len(data) != n:
        raise WavParseError("unexpected end of file")
    return data


WAVE_FORMAT_PCM = 1
WAVE_FORMAT_EXTENSIBLE = 0xFFFE


def _effective_format_tag(data: bytes, chunk_start: int, chunk_size: int, fmt_tag: int) -> int:
    """Normalize WAVE_FORMAT_EXTENSIBLE PCM files produced by modern ffmpeg."""
    if fmt_tag != WAVE_FORMAT_EXTENSIBLE or chunk_size < 40:
        return fmt_tag
    subformat_tag = struct.unpack_from("<H", data, chunk_start + 24)[0]
    if subformat_tag == WAVE_FORMAT_PCM:
        return WAVE_FORMAT_PCM
    return fmt_tag


def parse_wav(path: Path, *, compute_qc: bool = True, compute_hash: bool = True) -> WavInfo:
    """Parse a RIFF/WAVE file and optionally compute QC metrics."""
    data = path.read_bytes()
    if len(data) < 12:
        raise WavParseError("file too small for RIFF header")

    if data[0:4] != b"RIFF" or data[8:12] != b"WAVE":
        raise WavParseError("not a RIFF/WAVE file")

    offset = 12
    fmt_tag = None
    channels = None
    sample_rate = None
    byte_rate = None
    block_align = None
    bits_per_sample = None
    pcm_data = b""

    while offset + 8 <= len(data):
        chunk_id = data[offset : offset + 4]
        chunk_size = struct.unpack_from("<I", data, offset + 4)[0]
        chunk_start = offset + 8
        chunk_end = chunk_start + chunk_size
        if chunk_end > len(data):
            raise WavParseError(f"truncated chunk {chunk_id!r}")

        if chunk_id == b"fmt ":
            if chunk_size < 16:
                raise WavParseError("fmt chunk too small")
            fmt_tag, channels, sample_rate, byte_rate, block_align, bits_per_sample = struct.unpack_from(
                "<HHIIHH", data, chunk_start
            )
            fmt_tag = _effective_format_tag(data, chunk_start, chunk_size, fmt_tag)
        elif chunk_id == b"data":
            pcm_data = data[chunk_start:chunk_end]

        # Chunks are word-aligned
        offset = chunk_end + (chunk_size % 2)

    if fmt_tag is None:
        raise WavParseError("missing fmt chunk")
    if not pcm_data and fmt_tag == 1:
        raise WavParseError("missing data chunk")

    compression = "PCM" if fmt_tag == 1 else f"non-PCM (format {fmt_tag})"
    sample_width_bytes = (bits_per_sample + 7) // 8 if bits_per_sample else 0
    bytes_per_frame = channels * sample_width_bytes if channels and sample_width_bytes else 0
    frame_count = len(pcm_data) // bytes_per_frame if bytes_per_frame else 0
    duration_ms = (frame_count / sample_rate * 1000.0) if sample_rate and frame_count else 0.0

    info = WavInfo(
        sample_rate=sample_rate or 0,
        channels=channels or 0,
        sample_width_bytes=sample_width_bytes,
        frame_count=frame_count,
        duration_ms=duration_ms,
        compression=compression,
        format_tag=fmt_tag or -1,
    )

    if compute_hash:
        info.sha256 = hashlib.sha256(data).hexdigest()

    if compute_qc and fmt_tag == 1 and frame_count > 0 and channels == 1:
        _compute_pcm_qc(info, pcm_data, bits_per_sample or 0)

    return info


def _compute_pcm_qc(info: WavInfo, pcm_data: bytes, bits_per_sample: int) -> None:
    if bits_per_sample == 16:
        samples = struct.unpack(f"<{len(pcm_data) // 2}h", pcm_data)
        max_val = 32767
    elif bits_per_sample == 24:
        n = len(pcm_data) // 3
        samples = []
        for i in range(n):
            b = pcm_data[i * 3 : i * 3 + 3]
            val = b[0] | (b[1] << 8) | (b[2] << 16)
            if val & 0x800000:
                val -= 1 << 24
            samples.append(val)
        max_val = (1 << 23) - 1
    elif bits_per_sample == 8:
        samples = [s - 128 for s in pcm_data]
        max_val = 127
    else:
        return

    if not samples:
        return

    peak = max(abs(s) for s in samples)
    info.peak_sample = peak
    info.peak_dbfs = 20.0 * math.log10(peak / max_val) if peak > 0 else float("-inf")
    info.clipping_count = sum(1 for s in samples if abs(s) >= max_val)
    info.dc_offset = sum(samples) / len(samples)
    rms_sq = sum(s * s for s in samples) / len(samples)
    info.rms = math.sqrt(rms_sq)


def write_synthetic_wav(
    path: Path,
    *,
    sample_rate: int = 48_000,
    sample_width_bytes: int = 3,
    channels: int = 1,
    duration_ms: int = 500,
    frequency_hz: float = 440.0,
) -> str:
    """Write a minimal sine-tone WAV for tests. Returns SHA-256 hex digest."""
    frame_count = int(sample_rate * duration_ms / 1000)
    bits_per_sample = sample_width_bytes * 8
    block_align = channels * sample_width_bytes
    byte_rate = sample_rate * block_align

    fmt_chunk = struct.pack(
        "<HHIIHH",
        1,  # PCM
        channels,
        sample_rate,
        byte_rate,
        block_align,
        bits_per_sample,
    )

    def encode_sample(val_f: float) -> bytes:
        if sample_width_bytes == 3:
            val = int(val_f * ((1 << 23) - 1) * 0.5)
            if val < 0:
                val += 1 << 24
            return struct.pack("<i", val)[:3]
        if sample_width_bytes == 2:
            val = int(val_f * 32767 * 0.5)
            return struct.pack("<h", val)
        if sample_width_bytes == 1:
            val = int((val_f * 0.5 + 0.5) * 255)
            return bytes([val])
        raise ValueError(f"unsupported sample width {sample_width_bytes}")

    frames = bytearray()
    for i in range(frame_count):
        t = i / sample_rate
        val_f = math.sin(2 * math.pi * frequency_hz * t)
        sample = encode_sample(val_f)
        for _ in range(channels):
            frames.extend(sample)

    data_chunk = bytes(frames)
    riff_size = 4 + (8 + len(fmt_chunk)) + (8 + len(data_chunk))
    header = b"RIFF" + struct.pack("<I", riff_size) + b"WAVE"
    file_data = header + b"fmt " + struct.pack("<I", len(fmt_chunk)) + fmt_chunk
    file_data += b"data" + struct.pack("<I", len(data_chunk)) + data_chunk

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(file_data)
    return hashlib.sha256(file_data).hexdigest()


def write_synthetic_extensible_pcm_wav(
    path: Path,
    *,
    sample_rate: int = 48_000,
    sample_width_bytes: int = 3,
    channels: int = 1,
    frame_count: int = 48,
) -> None:
    """Write a minimal WAVE_FORMAT_EXTENSIBLE PCM file (ffmpeg 7 style) for tests."""
    bits_per_sample = sample_width_bytes * 8
    block_align = channels * sample_width_bytes
    byte_rate = sample_rate * block_align

    fmt_chunk = struct.pack(
        "<HHIIHH",
        WAVE_FORMAT_EXTENSIBLE,
        channels,
        sample_rate,
        byte_rate,
        block_align,
        bits_per_sample,
    )
    fmt_chunk += struct.pack(
        "<HHI16s",
        22,
        bits_per_sample,
        0x00000004,
        b"\x01\x00\x00\x00\x00\x00\x10\x00\x80\x00\x00\xaa\x00\x38\x9b\x71",
    )

    pcm_data = b"\x00" * (frame_count * block_align)
    riff_size = 4 + (8 + len(fmt_chunk)) + (8 + len(pcm_data))
    file_data = b"RIFF" + struct.pack("<I", riff_size) + b"WAVE"
    file_data += b"fmt " + struct.pack("<I", len(fmt_chunk)) + fmt_chunk
    file_data += b"data" + struct.pack("<I", len(pcm_data)) + pcm_data

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(file_data)
