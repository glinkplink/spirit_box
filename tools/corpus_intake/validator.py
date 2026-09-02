"""Corpus manifest and asset validation."""

from __future__ import annotations

import json
from collections import Counter
from pathlib import Path

from .constants import (
    AUDIO_GATE_STATUS,
    DURATION_ADVISORY_MS,
    DURATION_TOLERANCE_MIN_MS,
    DURATION_TOLERANCE_PCT,
    IGNORED_CORPUS_FILES,
    PHASE1_ASSETS_PER_PERFORMER,
    PHASE1_BREATH_TRANSIENT_COMBINED,
    PHASE1_PERFORMERS,
    PHASE1_SOURCE_TYPE_COUNTS,
    PHASE1_TOTAL_ASSETS,
    RECOGNITION_RISK_VALUES,
    REQUIRED_CHANNELS,
    REQUIRED_SAMPLE_RATE,
    REQUIRED_SAMPLE_WIDTH_BYTES,
    SCHEMA_VERSIONS,
    SOURCE_TYPE_BREATH,
    SOURCE_TYPE_TRANSIENT,
)
from .models import Finding, Severity, ValidationResult, WavInfo
from .rights_ledger import load_rights_ledger, validate_rights_row
from .wav_analysis import WavParseError, parse_wav


def _resolve_relative_path(corpus_root: Path, relative_path: str) -> tuple[Path | None, Finding | None]:
    rel = relative_path.strip()
    if not rel:
        return None, Finding(Severity.ERROR, "PATH_EMPTY", "relative_path is empty")
    if rel.startswith("/") or rel.startswith("\\"):
        return None, Finding(
            Severity.ERROR,
            "PATH_ABSOLUTE",
            f"absolute path not allowed: {rel!r}",
            relative_path=rel,
        )
    parts = Path(rel).parts
    if ".." in parts:
        return None, Finding(
            Severity.ERROR,
            "PATH_TRAVERSAL",
            f"path traversal not allowed: {rel!r}",
            relative_path=rel,
        )
    resolved = (corpus_root / rel).resolve()
    try:
        resolved.relative_to(corpus_root.resolve())
    except ValueError:
        return None, Finding(
            Severity.ERROR,
            "PATH_ESCAPE",
            f"path escapes corpus root: {rel!r}",
            relative_path=rel,
        )
    return resolved, None


def _duration_tolerance_ms(declared_ms: int) -> float:
    return max(DURATION_TOLERANCE_MIN_MS, declared_ms * DURATION_TOLERANCE_PCT)


def _get_path_field(asset: dict) -> str:
    for key in ("relative_path", "filename", "final_filename"):
        val = asset.get(key)
        if isinstance(val, str) and val.strip():
            return val.strip()
    return ""


def validate_corpus(
    corpus_root: Path,
    *,
    phase1_strict: bool = False,
    rights_ledger_path: Path | None = None,
) -> ValidationResult:
    corpus_root = corpus_root.resolve()
    result = ValidationResult(
        corpus_root=str(corpus_root),
        manifest_label=None,
        asset_count=0,
        audio_gate_status=AUDIO_GATE_STATUS,
    )

    manifest_path = corpus_root / "manifest.json"
    if not manifest_path.is_file():
        result.findings.append(
            Finding(Severity.ERROR, "MANIFEST_MISSING", "manifest.json not found in corpus root")
        )
        return result

    try:
        manifest_text = manifest_path.read_text(encoding="utf-8")
        manifest = json.loads(manifest_text)
    except json.JSONDecodeError as exc:
        result.findings.append(
            Finding(Severity.ERROR, "MANIFEST_INVALID_JSON", f"manifest.json is not valid JSON: {exc}")
        )
        return result

    schema_version = manifest.get("schema_version")
    if schema_version not in SCHEMA_VERSIONS:
        result.findings.append(
            Finding(
                Severity.ERROR,
                "MANIFEST_SCHEMA_VERSION",
                f"Unrecognized schema_version: {schema_version!r} (expected {sorted(SCHEMA_VERSIONS)})",
            )
        )

    result.manifest_label = manifest.get("label")
    assets = manifest.get("assets")
    if not isinstance(assets, list):
        result.findings.append(
            Finding(Severity.ERROR, "MANIFEST_ASSETS", "manifest assets must be an array")
        )
        return result

    rights_rows: dict[str, dict[str, str]] = {}
    if phase1_strict:
        if rights_ledger_path is None:
            result.findings.append(
                Finding(
                    Severity.ERROR,
                    "RIGHTS_LEDGER_REQUIRED",
                    "--rights-ledger is required in --phase1-strict mode",
                )
            )
        else:
            rights_rows, ledger_findings = load_rights_ledger(rights_ledger_path)
            result.findings.extend(ledger_findings)
    elif rights_ledger_path is not None:
        rights_rows, ledger_findings = load_rights_ledger(rights_ledger_path)
        result.findings.extend(ledger_findings)

    seen_ids: dict[str, int] = {}
    seen_paths: dict[str, str] = {}
    hash_to_assets: dict[str, list[str]] = {}
    referenced_paths: set[str] = set()

    for idx, asset in enumerate(assets):
        if not isinstance(asset, dict):
            result.findings.append(
                Finding(Severity.ERROR, "ASSET_NOT_OBJECT", f"assets[{idx}] is not an object")
            )
            continue

        asset_id = (asset.get("asset_id") or "").strip()
        rel_path = _get_path_field(asset)

        if not asset_id:
            result.findings.append(
                Finding(Severity.ERROR, "ASSET_ID_EMPTY", f"assets[{idx}] has empty asset_id")
            )
            continue

        if asset_id in seen_ids:
            result.findings.append(
                Finding(
                    Severity.ERROR,
                    "ASSET_ID_DUPLICATE",
                    f"Duplicate asset_id {asset_id!r}",
                    asset_id=asset_id,
                )
            )
        seen_ids[asset_id] = seen_ids.get(asset_id, 0) + 1

        if not rel_path:
            result.findings.append(
                Finding(
                    Severity.ERROR,
                    "PATH_MISSING",
                    f"asset {asset_id!r} has no relative_path/filename/final_filename",
                    asset_id=asset_id,
                )
            )
            continue

        if rel_path in seen_paths:
            result.findings.append(
                Finding(
                    Severity.ERROR,
                    "PATH_DUPLICATE",
                    f"Duplicate relative_path {rel_path!r} (also used by {seen_paths[rel_path]!r})",
                    asset_id=asset_id,
                    relative_path=rel_path,
                )
            )
        else:
            seen_paths[rel_path] = asset_id
        referenced_paths.add(rel_path)

        forward = asset.get("forward_allowed", True)
        reverse = asset.get("reverse_allowed", True)
        if not forward and not reverse:
            result.findings.append(
                Finding(
                    Severity.ERROR,
                    "DIRECTION_NONE",
                    f"asset {asset_id!r}: neither forward_allowed nor reverse_allowed",
                    asset_id=asset_id,
                )
            )

        if phase1_strict:
            _validate_strict_metadata(result, asset, asset_id)

        resolved, path_finding = _resolve_relative_path(corpus_root, rel_path)
        if path_finding:
            path_finding.asset_id = asset_id
            result.findings.append(path_finding)
            continue

        assert resolved is not None
        if not resolved.is_file():
            result.findings.append(
                Finding(
                    Severity.ERROR,
                    "WAV_MISSING",
                    f"Referenced WAV not found: {rel_path!r}",
                    asset_id=asset_id,
                    relative_path=rel_path,
                )
            )
            continue

        wav_findings, wav_info = _validate_wav_file(
            resolved, asset, asset_id, rel_path, phase1_strict=phase1_strict
        )
        result.findings.extend(wav_findings)
        if wav_info:
            result.wav_summaries[asset_id] = wav_info
            if wav_info.sha256:
                hash_to_assets.setdefault(wav_info.sha256, []).append(asset_id)

        if rights_rows or phase1_strict:
            rid = (asset.get("rights_record_id") or "").strip()
            if phase1_strict and not rid:
                result.findings.append(
                    Finding(
                        Severity.ERROR,
                        "RIGHTS_RECORD_ID_MISSING",
                        f"asset {asset_id!r} missing rights_record_id",
                        asset_id=asset_id,
                    )
                )
            elif rid:
                row = rights_rows.get(rid, {})
                sha = wav_info.sha256 if wav_info else None
                result.findings.extend(
                    validate_rights_row(
                        rid, row, asset_id=asset_id, final_sha256=sha, strict=phase1_strict
                    )
                )

    result.asset_count = len(seen_paths)

    for sha, ids in hash_to_assets.items():
        if len(ids) > 1:
            result.duplicate_hashes[sha] = ids
            sev = Severity.ERROR if phase1_strict else Severity.WARNING
            result.findings.append(
                Finding(
                    sev,
                    "DUPLICATE_SHA256",
                    f"Identical WAV content for assets: {', '.join(ids)}",
                )
            )

    _check_orphans(corpus_root, referenced_paths, phase1_strict, result)
    _build_distribution_counts(assets, result)
    if phase1_strict:
        _validate_phase1_counts(result)

    return result


def _validate_strict_metadata(result: ValidationResult, asset: dict, asset_id: str) -> None:
    performer = (asset.get("performer_id") or "").strip()
    if not performer:
        result.findings.append(
            Finding(
                Severity.ERROR,
                "PERFORMER_MISSING",
                f"asset {asset_id!r} missing performer_id",
                asset_id=asset_id,
            )
        )
    elif performer not in PHASE1_PERFORMERS:
        result.findings.append(
            Finding(
                Severity.ERROR,
                "PERFORMER_UNKNOWN",
                f"asset {asset_id!r} has unknown performer_id {performer!r}",
                asset_id=asset_id,
            )
        )

    if not (asset.get("voice_family") or "").strip():
        result.findings.append(
            Finding(
                Severity.ERROR,
                "VOICE_FAMILY_MISSING",
                f"asset {asset_id!r} missing voice_family",
                asset_id=asset_id,
            )
        )

    if not (asset.get("source_type") or "").strip():
        result.findings.append(
            Finding(
                Severity.ERROR,
                "SOURCE_TYPE_MISSING",
                f"asset {asset_id!r} missing source_type",
                asset_id=asset_id,
            )
        )

    risk = (asset.get("recognition_risk") or "").strip().lower()
    if not risk:
        result.findings.append(
            Finding(
                Severity.ERROR,
                "RECOGNITION_RISK_MISSING",
                f"asset {asset_id!r} missing recognition_risk",
                asset_id=asset_id,
            )
        )
    elif risk not in RECOGNITION_RISK_VALUES:
        result.findings.append(
            Finding(
                Severity.ERROR,
                "RECOGNITION_RISK_INVALID",
                f"asset {asset_id!r} has invalid recognition_risk {risk!r}",
                asset_id=asset_id,
            )
        )
    elif risk == "high":
        result.findings.append(
            Finding(
                Severity.ERROR,
                "RECOGNITION_RISK_HIGH",
                f"asset {asset_id!r} has recognition_risk=high (not allowed in Phase 1)",
                asset_id=asset_id,
            )
        )

    if asset.get("duration_ms") is None:
        result.findings.append(
            Finding(
                Severity.ERROR,
                "DURATION_MS_MISSING",
                f"asset {asset_id!r} missing duration_ms",
                asset_id=asset_id,
            )
        )

    if not (asset.get("rights_record_id") or "").strip():
        result.findings.append(
            Finding(
                Severity.ERROR,
                "RIGHTS_RECORD_ID_MISSING",
                f"asset {asset_id!r} missing rights_record_id",
                asset_id=asset_id,
            )
        )


def _validate_wav_file(
    path: Path,
    asset: dict,
    asset_id: str,
    rel_path: str,
    *,
    phase1_strict: bool,
) -> tuple[list[Finding], WavInfo | None]:
    findings: list[Finding] = []
    try:
        wav = parse_wav(path, compute_qc=True, compute_hash=True)
    except WavParseError as exc:
        findings.append(
            Finding(
                Severity.ERROR,
                "WAV_PARSE_ERROR",
                f"{rel_path}: {exc}",
                asset_id=asset_id,
                relative_path=rel_path,
            )
        )
        return findings, None

    if not wav.is_pcm:
        findings.append(
            Finding(
                Severity.ERROR,
                "WAV_NOT_PCM",
                f"{rel_path}: compression={wav.compression}",
                asset_id=asset_id,
                relative_path=rel_path,
            )
        )

    if wav.frame_count <= 0 or wav.duration_ms <= 0:
        findings.append(
            Finding(
                Severity.ERROR,
                "WAV_ZERO_LENGTH",
                f"{rel_path}: zero frames or duration",
                asset_id=asset_id,
                relative_path=rel_path,
            )
        )

    if phase1_strict:
        if wav.sample_rate != REQUIRED_SAMPLE_RATE:
            findings.append(
                Finding(
                    Severity.ERROR,
                    "WAV_SAMPLE_RATE",
                    f"{rel_path}: expected {REQUIRED_SAMPLE_RATE} Hz, got {wav.sample_rate}",
                    asset_id=asset_id,
                    relative_path=rel_path,
                )
            )
        if wav.sample_width_bytes != REQUIRED_SAMPLE_WIDTH_BYTES:
            findings.append(
                Finding(
                    Severity.ERROR,
                    "WAV_BIT_DEPTH",
                    f"{rel_path}: expected 24-bit, got {wav.sample_width_bytes * 8}-bit",
                    asset_id=asset_id,
                    relative_path=rel_path,
                )
            )
        if wav.channels != REQUIRED_CHANNELS:
            findings.append(
                Finding(
                    Severity.ERROR,
                    "WAV_CHANNELS",
                    f"{rel_path}: expected mono, got {wav.channels} channels",
                    asset_id=asset_id,
                    relative_path=rel_path,
                )
            )

    declared = asset.get("duration_ms")
    if declared is not None:
        tol = _duration_tolerance_ms(int(declared))
        delta = abs(wav.duration_ms - int(declared))
        if delta > tol:
            findings.append(
                Finding(
                    Severity.ERROR,
                    "DURATION_MISMATCH",
                    f"{rel_path}: declared {declared} ms, actual {wav.duration_ms:.1f} ms "
                    f"(tolerance {tol:.0f} ms)",
                    asset_id=asset_id,
                    relative_path=rel_path,
                )
            )

    source_type = (asset.get("source_type") or "").strip().lower()
    if source_type in DURATION_ADVISORY_MS:
        lo, hi = DURATION_ADVISORY_MS[source_type]
        if wav.duration_ms < lo or wav.duration_ms > hi:
            findings.append(
                Finding(
                    Severity.WARNING,
                    "DURATION_ADVISORY",
                    f"{rel_path}: {source_type} duration {wav.duration_ms:.0f} ms "
                    f"outside advisory range {lo}–{hi} ms",
                    asset_id=asset_id,
                    relative_path=rel_path,
                )
            )

    crop_start = asset.get("crop_safe_start_ms")
    crop_end = asset.get("crop_safe_end_ms")
    if crop_start is not None or crop_end is not None:
        findings.extend(
            _validate_crop(asset_id, rel_path, crop_start, crop_end, wav.duration_ms)
        )

    if wav.clipping_count and wav.clipping_count > 0:
        findings.append(
            Finding(
                Severity.WARNING,
                "AUDIO_CLIPPING",
                f"{rel_path}: {wav.clipping_count} saturated samples",
                asset_id=asset_id,
                relative_path=rel_path,
            )
        )

    return findings, wav


def _validate_crop(
    asset_id: str,
    rel_path: str,
    crop_start: int | None,
    crop_end: int | None,
    actual_duration_ms: float,
) -> list[Finding]:
    findings: list[Finding] = []
    if crop_start is None or crop_end is None:
        findings.append(
            Finding(
                Severity.WARNING,
                "CROP_INCOMPLETE",
                f"{rel_path}: crop_safe bounds partially missing",
                asset_id=asset_id,
                relative_path=rel_path,
            )
        )
        return findings

    if crop_start < 0:
        findings.append(
            Finding(
                Severity.ERROR,
                "CROP_NEGATIVE_START",
                f"{rel_path}: crop_safe_start_ms={crop_start}",
                asset_id=asset_id,
                relative_path=rel_path,
            )
        )
    if crop_end <= crop_start:
        findings.append(
            Finding(
                Severity.ERROR,
                "CROP_REVERSED",
                f"{rel_path}: crop_safe_end_ms ({crop_end}) <= crop_safe_start_ms ({crop_start})",
                asset_id=asset_id,
                relative_path=rel_path,
            )
        )
    if crop_end > actual_duration_ms + 1:  # 1 ms float slack
        findings.append(
            Finding(
                Severity.ERROR,
                "CROP_EXCEEDS_DURATION",
                f"{rel_path}: crop_safe_end_ms={crop_end} > actual {actual_duration_ms:.1f} ms",
                asset_id=asset_id,
                relative_path=rel_path,
            )
        )
    return findings


def _check_orphans(
    corpus_root: Path,
    referenced: set[str],
    phase1_strict: bool,
    result: ValidationResult,
) -> None:
    for wav_path in corpus_root.rglob("*.wav"):
        rel = wav_path.relative_to(corpus_root).as_posix()
        if rel not in referenced:
            sev = Severity.ERROR if phase1_strict else Severity.WARNING
            result.findings.append(
                Finding(
                    sev,
                    "ORPHAN_WAV",
                    f"WAV not referenced in manifest: {rel!r}",
                    relative_path=rel,
                )
            )


def _build_distribution_counts(assets: list, result: ValidationResult) -> None:
    performers: Counter[str] = Counter()
    source_types: Counter[str] = Counter()
    voice_families: Counter[str] = Counter()
    phonetic: Counter[str] = Counter()
    voicing: Counter[str] = Counter()
    register: Counter[str] = Counter()
    delivery: Counter[str] = Counter()
    risk: Counter[str] = Counter()
    direction: Counter[str] = Counter()

    for asset in assets:
        if not isinstance(asset, dict):
            continue
        aid = (asset.get("asset_id") or "").strip()
        if not aid:
            continue
        p = (asset.get("performer_id") or "").strip() or "(missing)"
        performers[p] += 1
        st = (asset.get("source_type") or "").strip() or "(missing)"
        source_types[st] += 1
        vf = (asset.get("voice_family") or "").strip() or "(missing)"
        voice_families[vf] += 1
        pf = (asset.get("phonetic_family") or "").strip() or "(missing)"
        phonetic[pf] += 1
        vo = (asset.get("voicing") or "").strip() or "(missing)"
        voicing[vo] += 1
        reg = (asset.get("register") or "").strip() or "(missing)"
        register[reg] += 1
        deliv = (asset.get("delivery") or "").strip() or "(missing)"
        delivery[deliv] += 1
        rk = (asset.get("recognition_risk") or "").strip().lower() or "(missing)"
        risk[rk] += 1
        fwd = asset.get("forward_allowed", True)
        rev = asset.get("reverse_allowed", True)
        if fwd and rev:
            direction["both"] += 1
        elif fwd:
            direction["forward_only"] += 1
        elif rev:
            direction["reverse_only"] += 1
        else:
            direction["none"] += 1

    result.performer_counts = dict(performers)
    result.source_type_counts = dict(source_types)
    result.voice_family_counts = dict(voice_families)
    result.phonetic_family_counts = dict(phonetic)
    result.voicing_counts = dict(voicing)
    result.register_counts = dict(register)
    result.delivery_counts = dict(delivery)
    result.recognition_risk_counts = dict(risk)
    result.direction_counts = dict(direction)


def _validate_phase1_counts(result: ValidationResult) -> None:
    total = sum(
        c for p, c in result.performer_counts.items() if p in PHASE1_PERFORMERS
    )
    if result.asset_count != PHASE1_TOTAL_ASSETS:
        result.findings.append(
            Finding(
                Severity.ERROR,
                "PHASE1_TOTAL_COUNT",
                f"Expected {PHASE1_TOTAL_ASSETS} assets, found {result.asset_count}",
            )
        )

    for performer in PHASE1_PERFORMERS:
        count = result.performer_counts.get(performer, 0)
        if count != PHASE1_ASSETS_PER_PERFORMER:
            result.findings.append(
                Finding(
                    Severity.ERROR,
                    "PHASE1_PERFORMER_COUNT",
                    f"Performer {performer}: expected {PHASE1_ASSETS_PER_PERFORMER}, got {count}",
                )
            )

    for stype, expected in PHASE1_SOURCE_TYPE_COUNTS.items():
        actual = result.source_type_counts.get(stype, 0)
        if actual != expected:
            result.findings.append(
                Finding(
                    Severity.ERROR,
                    "PHASE1_SOURCE_TYPE_COUNT",
                    f"source_type {stype!r}: expected {expected}, got {actual}",
                )
            )

    breath = result.source_type_counts.get(SOURCE_TYPE_BREATH, 0)
    transient = result.source_type_counts.get(SOURCE_TYPE_TRANSIENT, 0)
    combined = breath + transient
    if combined != PHASE1_BREATH_TRANSIENT_COMBINED:
        result.findings.append(
            Finding(
                Severity.ERROR,
                "PHASE1_BREATH_TRANSIENT_COUNT",
                f"breath+transient: expected {PHASE1_BREATH_TRANSIENT_COMBINED}, "
                f"got {combined} (breath={breath}, transient={transient})",
            )
        )

    for performer in PHASE1_PERFORMERS:
        if performer not in result.performer_counts:
            result.findings.append(
                Finding(
                    Severity.ERROR,
                    "PHASE1_PERFORMER_MISSING",
                    f"Missing performer {performer}",
                )
            )
