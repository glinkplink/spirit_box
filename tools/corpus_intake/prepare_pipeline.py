"""Corpus intake pipeline: continuous recording → harness-ready Phase 1 folder."""

from __future__ import annotations

import json
import shutil
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

from tools.corpus_intake.constants import (
    REQUIRED_CHANNELS,
    REQUIRED_SAMPLE_RATE,
    REQUIRED_SAMPLE_WIDTH_BYTES,
)
from tools.corpus_intake.segmentation import (
    SilenceInterval,
    VocalRegion,
    merge_adjacent_silences,
    parse_silencedetect_output,
    vocal_regions_from_silences,
)
from tools.corpus_intake.wav_analysis import WavInfo, parse_wav


CORPUS_DIR_NAME = "SpiritBoxPhase1Corpus"
MANIFEST_NAME = "manifest.json"
PREP_VERSION = "corpus-intake-1"

# Defaults tuned against recordings/me_test.m4a (48 kHz mono Voice Memos, ~1 s gaps).
DEFAULT_NOISE_THRESHOLD_DB = -25.0
DEFAULT_MIN_SILENCE_SEC = 0.4
DEFAULT_SILENCE_MERGE_GAP_SEC = 0.12
DEFAULT_MIN_EVENT_SEC = 0.12
DEFAULT_MAX_EVENT_SEC = 4.0
DEFAULT_REGION_PAD_SEC = 0.02
DEFAULT_FADE_SEC = 0.005
DEFAULT_CROP_MARGIN_MS = 30

QUIET_PEAK_DBFS = -42.0
LOUD_PEAK_DBFS = -1.0


@dataclass
class SourceProbe:
    path: Path
    duration_sec: float
    codec: str
    sample_rate: int
    channels: int


@dataclass
class SegmentationSettings:
    noise_threshold_db: float
    min_silence_sec: float
    silence_merge_gap_sec: float
    min_event_sec: float
    max_event_sec: float
    region_pad_sec: float


@dataclass
class RejectedRegion:
    region: VocalRegion
    reason: str


@dataclass
class AcceptedAsset:
    asset_id: str
    relative_path: str
    region: VocalRegion
    duration_ms: int
    wav_path: Path
    wav_info: WavInfo
    flags: list[str] = field(default_factory=list)


@dataclass
class PrepareResult:
    source: SourceProbe
    settings: SegmentationSettings
    raw_silences: list[SilenceInterval]
    merged_silences: list[SilenceInterval]
    raw_regions: list[VocalRegion]
    accepted: list[AcceptedAsset]
    rejected: list[RejectedRegion]
    output_root: Path
    corpus_root: Path
    qa_report_path: Path
    package_note: str


def require_ffmpeg_tools() -> tuple[str, str]:
    ffmpeg = shutil.which("ffmpeg")
    ffprobe = shutil.which("ffprobe")
    if not ffmpeg or not ffprobe:
        missing = []
        if not ffmpeg:
            missing.append("ffmpeg")
        if not ffprobe:
            missing.append("ffprobe")
        raise RuntimeError(
            f"Required tools not found on PATH: {', '.join(missing)}. "
            "Install ffmpeg/ffprobe and retry."
        )
    return ffmpeg, ffprobe


def assert_source_not_overwritten(source: Path, output_root: Path) -> None:
    source_resolved = source.resolve()
    output_resolved = output_root.resolve()
    if source_resolved == output_resolved:
        raise ValueError("Output directory must not be the source file path")
    if source_resolved.is_dir() and output_resolved.is_relative_to(source_resolved):
        raise ValueError("Output directory must not be inside the source directory")
    if output_resolved == source_resolved.parent and output_resolved.name == "recordings":
        raise ValueError("Refusing to write corpus output directly into recordings/")


def probe_source(ffprobe: str, source: Path) -> SourceProbe:
    if not source.is_file():
        raise FileNotFoundError(f"Source recording not found: {source}")
    cmd = [
        ffprobe,
        "-v",
        "quiet",
        "-print_format",
        "json",
        "-show_format",
        "-show_streams",
        str(source),
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        raise RuntimeError(f"ffprobe failed for {source}: {proc.stderr.strip()}")
    payload = json.loads(proc.stdout)
    streams = payload.get("streams") or []
    audio = next((s for s in streams if s.get("codec_type") == "audio"), None)
    if audio is None:
        raise RuntimeError(f"No audio stream found in {source}")

    duration = float(payload.get("format", {}).get("duration") or audio.get("duration") or 0)
    return SourceProbe(
        path=source,
        duration_sec=duration,
        codec=str(audio.get("codec_name") or "unknown"),
        sample_rate=int(audio.get("sample_rate") or 0),
        channels=int(audio.get("channels") or 0),
    )


def run_silencedetect(
    ffmpeg: str,
    source: Path,
    *,
    noise_threshold_db: float,
    min_silence_sec: float,
) -> list[SilenceInterval]:
    noise = f"{noise_threshold_db}dB"
    cmd = [
        ffmpeg,
        "-hide_banner",
        "-i",
        str(source),
        "-af",
        f"silencedetect=noise={noise}:d={min_silence_sec}",
        "-f",
        "null",
        "-",
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        raise RuntimeError(f"ffmpeg silencedetect failed: {proc.stderr.strip()}")
    return parse_silencedetect_output(proc.stderr)


def make_asset_filename(family: str, index: int) -> str:
    safe_family = "".join(ch if ch.isalnum() or ch in {"_", "-"} else "_" for ch in family)
    return f"{safe_family}_{index:03d}.wav"


def make_asset_id(family: str, index: int) -> str:
    return Path(make_asset_filename(family, index)).stem


def classify_region(
    region: VocalRegion,
    *,
    min_event_sec: float,
) -> str | None:
    duration = region.duration_sec
    if duration < min_event_sec:
        return f"too short ({duration:.3f}s < {min_event_sec:.3f}s minimum)"
    return None


def extract_segment_wav(
    ffmpeg: str,
    source: Path,
    destination: Path,
    region: VocalRegion,
    *,
    fade_sec: float,
) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    duration = region.duration_sec
    fade = min(fade_sec, max(0.0, duration / 4.0))
    af_parts = [
        f"atrim=start={region.start_sec}:end={region.end_sec}",
        "asetpts=PTS-STARTPTS",
    ]
    if fade > 0:
        af_parts.append(f"afade=t=in:st=0:d={fade}")
        af_parts.append(f"afade=t=out:st={max(0.0, duration - fade)}:d={fade}")
    af_parts.append("silenceremove=start_periods=1:start_silence=0.02:start_threshold=-40dB")
    af_parts.append("areverse")
    af_parts.append("silenceremove=start_periods=1:start_silence=0.02:start_threshold=-40dB")
    af_parts.append("areverse")

    cmd = [
        ffmpeg,
        "-hide_banner",
        "-y",
        "-i",
        str(source),
        "-af",
        ",".join(af_parts),
        "-ar",
        str(REQUIRED_SAMPLE_RATE),
        "-ac",
        str(REQUIRED_CHANNELS),
        "-c:a",
        "pcm_s24le",
        str(destination),
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        raise RuntimeError(
            f"ffmpeg extract failed for region {region.index} ({destination.name}): {proc.stderr.strip()}"
        )


def qa_flags_for_wav(info: WavInfo, *, duration_sec: float) -> list[str]:
    flags: list[str] = []
    if info.duration_ms <= 0:
        flags.append("zero_duration")
    if info.peak_dbfs is not None and info.peak_dbfs <= QUIET_PEAK_DBFS:
        flags.append("suspiciously_quiet")
    if info.peak_dbfs is not None and info.peak_dbfs >= LOUD_PEAK_DBFS:
        flags.append("suspiciously_loud")
    if info.clipping_count and info.clipping_count > 0:
        flags.append("clipping_detected")
    if duration_sec > DEFAULT_MAX_EVENT_SEC:
        flags.append("unusually_long_segment")
    if duration_sec < DEFAULT_MIN_EVENT_SEC:
        flags.append("unusually_short_segment")
    return flags


def build_manifest_entry(
    asset_id: str,
    relative_path: str,
    *,
    family: str,
    duration_ms: int,
    crop_margin_ms: int,
) -> dict:
    crop_end = max(crop_margin_ms + 1, duration_ms - crop_margin_ms)
    return {
        "asset_id": asset_id,
        "performer_id": family,
        "voice_family": family,
        "source_type": "vocal_test",
        "duration_ms": duration_ms,
        "forward_allowed": True,
        "reverse_allowed": True,
        "crop_safe_start_ms": crop_margin_ms,
        "crop_safe_end_ms": crop_end,
        "prep_version": PREP_VERSION,
        "relative_path": relative_path,
    }


def write_manifest(corpus_root: Path, *, family: str, assets: list[AcceptedAsset]) -> None:
    manifest = {
        "schema_version": 1,
        "label": f"{family} intake corpus (local test only — not for shipping)",
        "kind": "phase1",
        "assets": [
            build_manifest_entry(
                asset.asset_id,
                asset.relative_path,
                family=family,
                duration_ms=asset.duration_ms,
                crop_margin_ms=DEFAULT_CROP_MARGIN_MS,
            )
            for asset in assets
        ],
    }
    manifest_path = corpus_root / MANIFEST_NAME
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")


def median(values: list[float]) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    mid = len(ordered) // 2
    if len(ordered) % 2:
        return ordered[mid]
    return (ordered[mid - 1] + ordered[mid]) / 2.0


def write_qa_report(result: PrepareResult) -> None:
    source = result.source
    accepted_durations = [a.wav_info.duration_ms / 1000.0 for a in result.accepted]
    total_vocal = sum(accepted_durations)
    lines: list[str] = []
    lines.append("# Corpus intake QA report")
    lines.append("")
    lines.append("## SOURCE")
    lines.append(f"- source filename: `{source.path.name}`")
    lines.append(f"- original duration: {source.duration_sec:.3f} s")
    lines.append(
        f"- original codec/sample rate/channels: {source.codec} / {source.sample_rate} Hz / {source.channels}"
    )
    lines.append("")
    lines.append("## SEGMENTATION")
    settings = result.settings
    lines.append(
        "- silence settings used: "
        f"noise={settings.noise_threshold_db} dB, "
        f"min_silence={settings.min_silence_sec} s, "
        f"merge_gap={settings.silence_merge_gap_sec} s, "
        f"min_event={settings.min_event_sec} s, "
        f"max_event={settings.max_event_sec} s, "
        f"region_pad={settings.region_pad_sec} s"
    )
    lines.append(f"- raw silence intervals detected: {len(result.raw_silences)}")
    lines.append(f"- merged silence intervals: {len(result.merged_silences)}")
    lines.append(f"- raw vocal regions detected: {len(result.raw_regions)}")
    lines.append(f"- accepted clips: {len(result.accepted)}")
    lines.append(f"- rejected clips: {len(result.rejected)}")
    if result.rejected:
        lines.append("- rejected reasons:")
        for item in result.rejected:
            lines.append(
                f"  - region {item.region.index:03d} "
                f"({item.region.start_sec:.3f}s–{item.region.end_sec:.3f}s): {item.reason}"
            )
    lines.append("")
    lines.append("## OUTPUT")
    lines.append(f"- total accepted asset count: {len(result.accepted)}")
    if accepted_durations:
        lines.append(f"- shortest asset: {min(accepted_durations):.3f} s")
        lines.append(f"- longest asset: {max(accepted_durations):.3f} s")
        lines.append(f"- median asset duration: {median(accepted_durations):.3f} s")
    else:
        lines.append("- shortest asset: n/a")
        lines.append("- longest asset: n/a")
        lines.append("- median asset duration: n/a")
    lines.append(f"- total accepted vocal duration: {total_vocal:.3f} s")
    lines.append(
        f"- output format: {REQUIRED_SAMPLE_RATE} Hz, {REQUIRED_SAMPLE_WIDTH_BYTES * 8}-bit, "
        f"{REQUIRED_CHANNELS}-channel PCM WAV"
    )
    lines.append(f"- corpus root: `{result.corpus_root}`")
    lines.append("")
    lines.append("## QUALITY FLAGS")
    flagged = [a for a in result.accepted if a.flags]
    if not flagged:
        lines.append("- none")
    else:
        for asset in flagged:
            lines.append(f"- `{asset.relative_path}`: {', '.join(asset.flags)}")
    lines.append("")
    lines.append("## DEVICE PACKAGE")
    lines.append(result.package_note)
    lines.append("")
    lines.append(
        "AUDIO GATE STATUS: NOT YET RUN — REQUIRES HUMAN PHYSICAL-DEVICE LISTENING TEST"
    )
    result.qa_report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def prepare_corpus(
    source: Path,
    output_root: Path,
    *,
    family: str,
    noise_threshold_db: float = DEFAULT_NOISE_THRESHOLD_DB,
    min_silence_sec: float = DEFAULT_MIN_SILENCE_SEC,
    silence_merge_gap_sec: float = DEFAULT_SILENCE_MERGE_GAP_SEC,
    min_event_sec: float = DEFAULT_MIN_EVENT_SEC,
    max_event_sec: float = DEFAULT_MAX_EVENT_SEC,
    region_pad_sec: float = DEFAULT_REGION_PAD_SEC,
    fade_sec: float = DEFAULT_FADE_SEC,
) -> PrepareResult:
    source = source.resolve()
    output_root = output_root.resolve()
    assert_source_not_overwritten(source, output_root)

    ffmpeg, ffprobe = require_ffmpeg_tools()
    probe = probe_source(ffprobe, source)

    settings = SegmentationSettings(
        noise_threshold_db=noise_threshold_db,
        min_silence_sec=min_silence_sec,
        silence_merge_gap_sec=silence_merge_gap_sec,
        min_event_sec=min_event_sec,
        max_event_sec=max_event_sec,
        region_pad_sec=region_pad_sec,
    )

    raw_silences = run_silencedetect(
        ffmpeg,
        source,
        noise_threshold_db=noise_threshold_db,
        min_silence_sec=min_silence_sec,
    )
    merged_silences = merge_adjacent_silences(raw_silences, max_gap_sec=silence_merge_gap_sec)
    raw_regions = vocal_regions_from_silences(
        merged_silences,
        total_duration_sec=probe.duration_sec,
    )

    corpus_root = output_root / CORPUS_DIR_NAME
    if corpus_root.exists():
        shutil.rmtree(corpus_root)
    corpus_root.mkdir(parents=True, exist_ok=True)

    accepted: list[AcceptedAsset] = []
    rejected: list[RejectedRegion] = []
    asset_index = 1

    for region in raw_regions:
        padded = VocalRegion(
            start_sec=max(0.0, region.start_sec - region_pad_sec),
            end_sec=min(probe.duration_sec, region.end_sec + region_pad_sec),
            index=region.index,
        )
        reject_reason = classify_region(
            padded,
            min_event_sec=min_event_sec,
        )
        if reject_reason:
            rejected.append(RejectedRegion(region=padded, reason=reject_reason))
            continue

        filename = make_asset_filename(family, asset_index)
        asset_id = make_asset_id(family, asset_index)
        wav_path = corpus_root / filename

        extract_segment_wav(ffmpeg, source, wav_path, padded, fade_sec=fade_sec)
        wav_info = parse_wav(wav_path)
        if (
            wav_info.sample_rate != REQUIRED_SAMPLE_RATE
            or wav_info.channels != REQUIRED_CHANNELS
            or wav_info.sample_width_bytes != REQUIRED_SAMPLE_WIDTH_BYTES
            or not wav_info.is_pcm
        ):
            rejected.append(
                RejectedRegion(
                    region=padded,
                    reason=(
                        "output WAV format mismatch "
                        f"({wav_info.sample_rate} Hz, {wav_info.sample_width_bytes * 8}-bit, "
                        f"{wav_info.channels} ch, {wav_info.compression})"
                    ),
                )
            )
            wav_path.unlink(missing_ok=True)
            continue

        flags = qa_flags_for_wav(wav_info, duration_sec=wav_info.duration_ms / 1000.0)
        accepted.append(
            AcceptedAsset(
                asset_id=asset_id,
                relative_path=filename,
                region=padded,
                duration_ms=int(round(wav_info.duration_ms)),
                wav_path=wav_path,
                wav_info=wav_info,
                flags=flags,
            )
        )
        asset_index += 1

    write_manifest(corpus_root, family=family, assets=accepted)

    qa_report_path = output_root / "intake-qa-report.md"
    package_note = (
        "No ZIP is required. Copy the entire `SpiritBoxPhase1Corpus` folder contents "
        "(manifest.json + WAV files) onto the TestFlight device via Files.\n"
        f"Local corpus folder: `{corpus_root}`"
    )

    result = PrepareResult(
        source=probe,
        settings=settings,
        raw_silences=raw_silences,
        merged_silences=merged_silences,
        raw_regions=raw_regions,
        accepted=accepted,
        rejected=rejected,
        output_root=output_root,
        corpus_root=corpus_root,
        qa_report_path=qa_report_path,
        package_note=package_note,
    )
    write_qa_report(result)
    return result
