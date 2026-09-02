"""Test helpers for synthetic corpus fixtures."""

from __future__ import annotations

import csv
import json
from pathlib import Path

from tools.corpus_intake.wav_analysis import write_synthetic_wav

RIGHTS_HEADER = [
    "rights_record_id",
    "asset_id",
    "commercial_use",
    "mobile_app_embedding",
    "modification",
    "derivative_audio",
    "worldwide",
    "perpetual",
    "royalty_free",
    "marketing_use",
    "future_versions",
    "end_user_session_recording_use",
    "store_distribution_sublicense",
    "ai_training_permitted",
    "voice_cloning_permitted",
    "rights_status",
    "final_sha256",
]


def write_manifest(root: Path, assets: list[dict], **extra) -> None:
    manifest = {"schema_version": 1, "label": "test corpus", "kind": "phase1", "assets": assets}
    manifest.update(extra)
    (root / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")


def make_asset(
    asset_id: str,
    rel_path: str,
    *,
    performer_id: str = "P01",
    voice_family: str = "low_dry",
    source_type: str = "vowel",
    duration_ms: int = 700,
    recognition_risk: str = "low",
    rights_record_id: str = "RGT_TEST_001",
    crop_start: int = 40,
    crop_end: int = 660,
    forward: bool = True,
    reverse: bool = True,
    write_wav: bool = True,
    frequency: float = 440.0,
) -> dict:
    root = Path(rel_path).parent
    if write_wav and root != Path("."):
        pass  # caller ensures directory exists
    asset = {
        "asset_id": asset_id,
        "performer_id": performer_id,
        "voice_family": voice_family,
        "source_type": source_type,
        "phonetic_family": "front_vowel",
        "voicing": "voiced",
        "register": "low",
        "delivery": "neutral",
        "duration_ms": duration_ms,
        "recognition_risk": recognition_risk,
        "forward_allowed": forward,
        "reverse_allowed": reverse,
        "crop_safe_start_ms": crop_start,
        "crop_safe_end_ms": crop_end,
        "prep_version": "prep_1.0",
        "rights_record_id": rights_record_id,
        "relative_path": rel_path,
    }
    return asset


def write_wav_at(path: Path, *, duration_ms: int = 700, sample_rate: int = 48000, sample_width: int = 3, channels: int = 1, frequency: float = 440.0) -> str:
    return write_synthetic_wav(
        path,
        sample_rate=sample_rate,
        sample_width_bytes=sample_width,
        channels=channels,
        duration_ms=duration_ms,
        frequency_hz=frequency,
    )


def write_rights_row(path: Path, rows: list[dict]) -> None:
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=RIGHTS_HEADER, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def default_rights_row(asset_id: str, rights_id: str, sha256: str) -> dict:
    return {
        "rights_record_id": rights_id,
        "asset_id": asset_id,
        "commercial_use": "YES",
        "mobile_app_embedding": "YES",
        "modification": "YES",
        "derivative_audio": "YES",
        "worldwide": "YES",
        "perpetual": "YES",
        "royalty_free": "YES",
        "marketing_use": "YES",
        "future_versions": "YES",
        "end_user_session_recording_use": "YES",
        "store_distribution_sublicense": "YES",
        "ai_training_permitted": "NO",
        "voice_cloning_permitted": "NO",
        "rights_status": "APPROVED",
        "final_sha256": sha256,
    }


def build_minimal_corpus(tmp: Path) -> tuple[Path, str]:
    """Single valid asset corpus for generic validation."""
    asset_id = "SBX_TEST_001"
    rel = "SBX_TEST_001.wav"
    sha = write_wav_at(tmp / rel, duration_ms=700)
    asset = make_asset(asset_id, rel, duration_ms=700, crop_end=660)
    write_manifest(tmp, [asset])
    return tmp, sha


def build_phase1_strict_corpus(tmp: Path) -> tuple[Path, Path]:
    """Build a minimal 120-asset Phase 1 corpus with matching rights ledger."""
    assets: list[dict] = []
    rights_rows: list[dict] = []
    # Per performer: 7 vowel + 8 continuant + 10 transition + 3 breath + 2 transient = 30
    per_performer_slots = (
        ["vowel"] * 7
        + ["continuant"] * 8
        + ["transition"] * 10
        + ["breath"] * 3
        + ["transient"] * 2
    )
    idx = 0
    for performer in ("P01", "P02", "P03", "P04"):
        voice = {"P01": "low_dry", "P02": "mid_neutral", "P03": "high_light", "P04": "textured"}[performer]

        for stype in per_performer_slots:
            idx += 1
            asset_id = f"SBX_V1_{performer}_{stype.upper()[:3]}_{idx:03d}"
            rel = f"{asset_id}.wav"
            dur = {"vowel": 700, "continuant": 700, "transition": 350, "breath": 400, "transient": 200}[stype]
            freq = 200.0 + idx  # unique content per file
            sha = write_wav_at(tmp / rel, duration_ms=dur, frequency=freq)
            rid = f"RGT_{performer}_{idx:03d}"
            assets.append(
                make_asset(
                    asset_id,
                    rel,
                    performer_id=performer,
                    voice_family=voice,
                    source_type=stype,
                    duration_ms=dur,
                    rights_record_id=rid,
                    crop_end=dur - 40,
                )
            )
            rights_rows.append(default_rights_row(asset_id, rid, sha))

    write_manifest(tmp, assets, label="Phase 1 test corpus")
    ledger = tmp / "rights_ledger.csv"
    write_rights_row(ledger, rights_rows)
    return tmp, ledger
