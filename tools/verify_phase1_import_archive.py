#!/usr/bin/env python3
"""Verify the bundled Phase 1 bank and an importable SpiritBoxPhase1Corpus.zip.

A final-mix audition WAV is not an importable corpus. This checks that a zip
archive contains the same manifest identity and PCM as ios/Phase1.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import zipfile
from pathlib import Path


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def manifest_identity(data: bytes) -> str:
    return sha256_bytes(data)


def bundled_assets(bundle: Path) -> dict:
    manifest_path = bundle / "manifest.json"
    data = manifest_path.read_bytes()
    manifest = json.loads(data)
    assets = manifest.get("assets") or []
    wavs = {p.name: sha256_file(p) for p in sorted(bundle.glob("*.wav"))}
    return {
        "root": str(bundle),
        "label": manifest.get("label"),
        "asset_count": len(assets),
        "wav_count": len(wavs),
        "manifest_sha256": manifest_identity(data),
        "wav_sha256": wavs,
    }


def zip_assets(archive: Path) -> dict:
    with zipfile.ZipFile(archive) as zf:
        names = zf.namelist()
        manifest_names = [n for n in names if n.endswith("manifest.json") and not n.endswith("/")]
        if not manifest_names:
            raise ValueError(f"{archive} has no manifest.json")
        # Prefer a top-level or SpiritBoxPhase1Corpus/manifest.json
        manifest_name = sorted(manifest_names, key=lambda n: (n.count("/"), n))[0]
        data = zf.read(manifest_name)
        prefix = str(Path(manifest_name).parent)
        if prefix == ".":
            prefix = ""
        wavs = {}
        for name in names:
            if not name.lower().endswith(".wav"):
                continue
            wavs[Path(name).name] = sha256_bytes(zf.read(name))
        manifest = json.loads(data)
        return {
            "archive": str(archive),
            "archive_sha256": sha256_file(archive),
            "archive_bytes": archive.stat().st_size,
            "manifest_member": manifest_name,
            "label": manifest.get("label"),
            "asset_count": len(manifest.get("assets") or []),
            "wav_count": len(wavs),
            "manifest_sha256": manifest_identity(data),
            "wav_sha256": wavs,
        }


def compare(bundle: dict, archive: dict) -> dict:
    missing_in_zip = sorted(set(bundle["wav_sha256"]) - set(archive["wav_sha256"]))
    missing_in_bundle = sorted(set(archive["wav_sha256"]) - set(bundle["wav_sha256"]))
    hash_mismatch = sorted(
        name for name, digest in bundle["wav_sha256"].items()
        if name in archive["wav_sha256"] and archive["wav_sha256"][name] != digest
    )
    same_manifest = bundle["manifest_sha256"] == archive["manifest_sha256"]
    same_pcm = not missing_in_zip and not missing_in_bundle and not hash_mismatch
    return {
        "same_manifest_identity": same_manifest,
        "same_pcm": same_pcm,
        "ready_to_import": same_manifest and same_pcm and archive["asset_count"] == 1200,
        "missing_in_zip": missing_in_zip,
        "missing_in_bundle": missing_in_bundle,
        "pcm_hash_mismatch": hash_mismatch,
        "bundle_manifest_sha256": bundle["manifest_sha256"],
        "archive_manifest_sha256": archive["manifest_sha256"],
        "archive_sha256": archive["archive_sha256"],
        "archive_bytes": archive["archive_bytes"],
        "archive_path": archive["archive"],
        "bundle_label": bundle["label"],
        "archive_label": archive["label"],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bundle", type=Path, default=Path("ios/Phase1"))
    parser.add_argument("--zip", type=Path, required=True)
    parser.add_argument("--output", type=Path, default=None)
    args = parser.parse_args()
    bundle = bundled_assets(args.bundle)
    archive = zip_assets(args.zip)
    report = {"bundle": {k: v for k, v in bundle.items() if k != "wav_sha256"},
              "archive": {k: v for k, v in archive.items() if k != "wav_sha256"},
              "comparison": compare(bundle, archive)}
    text = json.dumps(report, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text)
    print(text)
    return 0 if report["comparison"]["ready_to_import"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
