"""Shared data models for corpus validation."""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Any


class Severity(str, Enum):
    PASS = "PASS"
    WARNING = "WARNING"
    ERROR = "ERROR"


@dataclass
class Finding:
    severity: Severity
    code: str
    message: str
    asset_id: str | None = None
    relative_path: str | None = None

    def to_dict(self) -> dict[str, Any]:
        d: dict[str, Any] = {
            "severity": self.severity.value,
            "code": self.code,
            "message": self.message,
        }
        if self.asset_id:
            d["asset_id"] = self.asset_id
        if self.relative_path:
            d["relative_path"] = self.relative_path
        return d


@dataclass
class WavInfo:
    sample_rate: int
    channels: int
    sample_width_bytes: int
    frame_count: int
    duration_ms: float
    compression: str
    format_tag: int
    peak_sample: int | None = None
    peak_dbfs: float | None = None
    clipping_count: int | None = None
    dc_offset: float | None = None
    rms: float | None = None
    sha256: str | None = None

    @property
    def is_pcm(self) -> bool:
        return self.format_tag == 1


@dataclass
class ValidationResult:
    corpus_root: str
    manifest_label: str | None
    asset_count: int
    findings: list[Finding] = field(default_factory=list)
    performer_counts: dict[str, int] = field(default_factory=dict)
    source_type_counts: dict[str, int] = field(default_factory=dict)
    voice_family_counts: dict[str, int] = field(default_factory=dict)
    phonetic_family_counts: dict[str, int] = field(default_factory=dict)
    voicing_counts: dict[str, int] = field(default_factory=dict)
    register_counts: dict[str, int] = field(default_factory=dict)
    delivery_counts: dict[str, int] = field(default_factory=dict)
    recognition_risk_counts: dict[str, int] = field(default_factory=dict)
    direction_counts: dict[str, int] = field(default_factory=dict)
    duplicate_hashes: dict[str, list[str]] = field(default_factory=dict)
    wav_summaries: dict[str, WavInfo] = field(default_factory=dict)
    audio_gate_status: str = ""

    @property
    def errors(self) -> list[Finding]:
        return [f for f in self.findings if f.severity == Severity.ERROR]

    @property
    def warnings(self) -> list[Finding]:
        return [f for f in self.findings if f.severity == Severity.WARNING]

    @property
    def overall_status(self) -> str:
        return "FAIL" if self.errors else "PASS"

    @property
    def technical_format_failures(self) -> int:
        return sum(1 for f in self.errors if f.code.startswith("WAV_") or f.code.startswith("FORMAT_"))

    @property
    def rights_failures(self) -> int:
        return sum(1 for f in self.errors if f.code.startswith("RIGHTS_"))

    @property
    def high_recognition_risk_count(self) -> int:
        return self.recognition_risk_counts.get("high", 0)

    def to_json_dict(self) -> dict[str, Any]:
        return {
            "overall_status": self.overall_status,
            "audio_gate_status": self.audio_gate_status,
            "corpus_root": self.corpus_root,
            "manifest_label": self.manifest_label,
            "asset_count": self.asset_count,
            "errors": [f.to_dict() for f in self.errors],
            "warnings": [f.to_dict() for f in self.warnings],
            "performer_counts": self.performer_counts,
            "source_type_counts": self.source_type_counts,
            "voice_family_counts": self.voice_family_counts,
            "phonetic_family_counts": self.phonetic_family_counts,
            "voicing_counts": self.voicing_counts,
            "register_counts": self.register_counts,
            "delivery_counts": self.delivery_counts,
            "recognition_risk_counts": self.recognition_risk_counts,
            "direction_counts": self.direction_counts,
            "duplicate_hashes": self.duplicate_hashes,
            "technical_format_failures": self.technical_format_failures,
            "rights_failures": self.rights_failures,
            "high_recognition_risk_count": self.high_recognition_risk_count,
        }
