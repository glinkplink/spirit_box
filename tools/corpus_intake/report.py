"""Human-readable and machine-readable validation reports."""

from __future__ import annotations

import json
from pathlib import Path

from .models import ValidationResult


def write_markdown_report(result: ValidationResult, path: Path) -> None:
    lines: list[str] = []
    lines.append("# Corpus Intake Validation Report")
    lines.append("")
    lines.append("## Corpus Summary")
    lines.append("")
    lines.append(f"- **Root:** `{result.corpus_root}`")
    lines.append(f"- **Manifest label:** {result.manifest_label or '(none)'}")
    lines.append(f"- **Asset count:** {result.asset_count}")
    lines.append(f"- **Performers:** {', '.join(sorted(result.performer_counts)) or '(none)'}")
    st_parts = [f"{k}={v}" for k, v in sorted(result.source_type_counts.items())]
    lines.append(f"- **Source-type composition:** {', '.join(st_parts) or '(none)'}")
    lines.append("")
    lines.append("## Result")
    lines.append("")
    lines.append(f"**{result.overall_status}**")
    lines.append("")
    lines.append("## Errors")
    lines.append("")
    if result.errors:
        for f in result.errors:
            loc = f" (`{f.asset_id}`)" if f.asset_id else ""
            lines.append(f"- **[ERROR]** {f.code}{loc}: {f.message}")
    else:
        lines.append("_None_")
    lines.append("")
    lines.append("## Warnings")
    lines.append("")
    if result.warnings:
        for f in result.warnings:
            loc = f" (`{f.asset_id}`)" if f.asset_id else ""
            lines.append(f"- **[WARNING]** {f.code}{loc}: {f.message}")
    else:
        lines.append("_None_")
    lines.append("")
    lines.append("## Format Summary")
    lines.append("")
    if result.wav_summaries:
        for aid, wav in sorted(result.wav_summaries.items()):
            lines.append(
                f"- `{aid}`: {wav.sample_rate} Hz, {wav.sample_width_bytes * 8}-bit, "
                f"{wav.channels} ch, {wav.duration_ms:.1f} ms, {wav.compression}"
            )
    else:
        lines.append("_No WAV files validated_")
    lines.append("")
    lines.append("## Distribution")
    lines.append("")
    for title, counts in (
        ("Performer", result.performer_counts),
        ("Voice family", result.voice_family_counts),
        ("Source type", result.source_type_counts),
        ("Phonetic family", result.phonetic_family_counts),
        ("Voicing", result.voicing_counts),
        ("Register", result.register_counts),
        ("Delivery", result.delivery_counts),
        ("Recognition risk", result.recognition_risk_counts),
        ("Direction", result.direction_counts),
    ):
        lines.append(f"### {title}")
        for k, v in sorted(counts.items()):
            lines.append(f"- {k}: {v}")
        lines.append("")
    lines.append("## Duplicates")
    lines.append("")
    if result.duplicate_hashes:
        for sha, ids in result.duplicate_hashes.items():
            lines.append(f"- SHA-256 `{sha[:16]}…`: {', '.join(ids)}")
    else:
        lines.append("_No duplicate file hashes detected_")
    lines.append("")
    lines.append("## Rights Traceability")
    lines.append("")
    lines.append(f"- Rights failures: {result.rights_failures}")
    lines.append("")
    lines.append("## Recognition Risk")
    lines.append("")
    lines.append(f"- High-risk count: {result.high_recognition_risk_count}")
    lines.append("")
    lines.append("## Crop-Safe Checks")
    lines.append("")
    crop_errors = [f for f in result.errors if f.code.startswith("CROP_")]
    if crop_errors:
        for f in crop_errors:
            lines.append(f"- {f.message}")
    else:
        lines.append("_No crop-safe errors_")
    lines.append("")
    lines.append("## Audio-QC Diagnostics")
    lines.append("")
    for aid, wav in sorted(result.wav_summaries.items()):
        if wav.peak_dbfs is not None:
            lines.append(
                f"- `{aid}`: peak {wav.peak_dbfs:.1f} dBFS, RMS {wav.rms:.1f}, "
                f"DC offset {wav.dc_offset:.2f}, clipping {wav.clipping_count or 0}"
            )
    if not result.wav_summaries:
        lines.append("_No diagnostics available_")
    lines.append("")
    lines.append("## Audio Gate Status")
    lines.append("")
    lines.append(f"**{result.audio_gate_status}**")
    lines.append("")
    lines.append(
        "> Corpus intake validation PASS does **not** mean the canonical audio gate passed. "
        "Only human physical-device listening can approve audio quality."
    )
    lines.append("")

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def write_json_report(result: ValidationResult, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(result.to_json_dict(), indent=2) + "\n", encoding="utf-8")
