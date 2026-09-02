"""Rights ledger CSV loading and validation."""

from __future__ import annotations

import csv
from pathlib import Path

from .constants import (
    RIGHTS_REQUIRED_NO,
    RIGHTS_REQUIRED_YES,
    RIGHTS_STATUS_APPROVED,
    RIGHTS_STATUS_HOLD,
)
from .models import Finding, Severity


def _normalize_yes_no(value: str | None) -> str:
    if value is None:
        return ""
    return value.strip().upper()


def load_rights_ledger(path: Path) -> tuple[dict[str, dict[str, str]], list[Finding]]:
    """Load rights ledger CSV keyed by rights_record_id."""
    findings: list[Finding] = []
    rows: dict[str, dict[str, str]] = {}

    if not path.is_file():
        findings.append(
            Finding(
                Severity.ERROR,
                "RIGHTS_LEDGER_MISSING",
                f"Rights ledger not found: {path}",
            )
        )
        return rows, findings

    with path.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        if not reader.fieldnames or "rights_record_id" not in reader.fieldnames:
            findings.append(
                Finding(
                    Severity.ERROR,
                    "RIGHTS_LEDGER_SCHEMA",
                    "Rights ledger CSV must include rights_record_id column",
                )
            )
            return rows, findings

        for line_no, row in enumerate(reader, start=2):
            rid = (row.get("rights_record_id") or "").strip()
            if not rid:
                findings.append(
                    Finding(
                        Severity.ERROR,
                        "RIGHTS_LEDGER_ROW",
                        f"Empty rights_record_id at line {line_no}",
                    )
                )
                continue
            if rid in rows:
                findings.append(
                    Finding(
                        Severity.ERROR,
                        "RIGHTS_LEDGER_DUPLICATE",
                        f"Duplicate rights_record_id {rid!r} at line {line_no}",
                    )
                )
            rows[rid] = {k: (v or "").strip() for k, v in row.items()}

    return rows, findings


def validate_rights_row(
    rights_record_id: str,
    row: dict[str, str],
    *,
    asset_id: str,
    final_sha256: str | None,
    strict: bool,
) -> list[Finding]:
    """Validate a single rights ledger row against shipping requirements."""
    findings: list[Finding] = []
    ctx = {"asset_id": asset_id}

    if not row:
        findings.append(
            Finding(
                Severity.ERROR,
                "RIGHTS_MISSING_ROW",
                f"No rights ledger row for rights_record_id={rights_record_id!r}",
                asset_id=asset_id,
            )
        )
        return findings

    status = (row.get("rights_status") or "").strip().upper()
    if status == RIGHTS_STATUS_HOLD:
        findings.append(
            Finding(
                Severity.ERROR,
                "RIGHTS_STATUS_HOLD",
                f"rights_status=HOLD for {rights_record_id!r}",
                asset_id=asset_id,
            )
        )
    elif strict and status != RIGHTS_STATUS_APPROVED:
        findings.append(
            Finding(
                Severity.ERROR,
                "RIGHTS_STATUS_NOT_APPROVED",
                f"rights_status must be APPROVED, got {status!r} for {rights_record_id!r}",
                asset_id=asset_id,
            )
        )

    for field in RIGHTS_REQUIRED_YES:
        val = _normalize_yes_no(row.get(field))
        if val != "YES":
            findings.append(
                Finding(
                    Severity.ERROR,
                    "RIGHTS_FIELD_REQUIRED_YES",
                    f"{field} must be YES, got {row.get(field)!r} for {rights_record_id!r}",
                    asset_id=asset_id,
                )
            )

    for field in RIGHTS_REQUIRED_NO:
        val = _normalize_yes_no(row.get(field))
        if val != "NO":
            findings.append(
                Finding(
                    Severity.ERROR,
                    "RIGHTS_FIELD_REQUIRED_NO",
                    f"{field} must be NO, got {row.get(field)!r} for {rights_record_id!r}",
                    asset_id=asset_id,
                )
            )

    ledger_asset = (row.get("asset_id") or "").strip()
    if ledger_asset and ledger_asset != asset_id:
        findings.append(
            Finding(
                Severity.WARNING,
                "RIGHTS_ASSET_ID_MISMATCH",
                f"Ledger asset_id {ledger_asset!r} != manifest {asset_id!r}",
                asset_id=asset_id,
            )
        )

    if final_sha256 and row.get("final_sha256"):
        ledger_hash = row["final_sha256"].strip().lower()
        if ledger_hash and ledger_hash != final_sha256.lower():
            findings.append(
                Finding(
                    Severity.ERROR,
                    "RIGHTS_HASH_MISMATCH",
                    f"final_sha256 mismatch for {rights_record_id!r}: "
                    f"ledger={ledger_hash[:16]}… actual={final_sha256[:16]}…",
                    asset_id=asset_id,
                )
            )

    return findings
