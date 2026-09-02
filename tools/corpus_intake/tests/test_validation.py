"""Unit tests for corpus intake validation."""

from __future__ import annotations

import json
import struct
import unittest
from pathlib import Path

from tools.corpus_intake.constants import AUDIO_GATE_STATUS
from tools.corpus_intake.models import Severity
from tools.corpus_intake.validator import validate_corpus
from tools.corpus_intake.wav_analysis import write_synthetic_wav

from tools.corpus_intake.tests.fixtures_helper import (
    build_minimal_corpus,
    build_phase1_strict_corpus,
    default_rights_row,
    make_asset,
    write_manifest,
    write_rights_row,
    write_wav_at,
)


class TestValidCases(unittest.TestCase):
    def test_valid_small_generic_corpus(self) -> None:
        with self.subTest("generic"):
            import tempfile

            with tempfile.TemporaryDirectory() as td:
                root, _ = build_minimal_corpus(Path(td))
                result = validate_corpus(root, phase1_strict=False)
                self.assertEqual(result.overall_status, "PASS")
                self.assertEqual(result.errors, [])
                self.assertEqual(result.audio_gate_status, AUDIO_GATE_STATUS)

    def test_audio_gate_never_passes_on_technical_pass(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root, _ = build_minimal_corpus(Path(td))
            result = validate_corpus(root)
            self.assertEqual(result.overall_status, "PASS")
            self.assertNotIn("PASSED", result.audio_gate_status.upper())
            self.assertIn("NOT YET RUN", result.audio_gate_status)

    def test_valid_strict_phase1_counts(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root, ledger = build_phase1_strict_corpus(Path(td))
            result = validate_corpus(root, phase1_strict=True, rights_ledger_path=ledger)
            self.assertEqual(result.overall_status, "PASS", [f.message for f in result.errors])
            self.assertEqual(result.asset_count, 120)

    def test_matching_rights_row(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            asset_id = "SBX_TEST_001"
            rel = "SBX_TEST_001.wav"
            sha = write_wav_at(root / rel)
            asset = make_asset(asset_id, rel, rights_record_id="RGT_001")
            write_manifest(root, [asset])
            ledger = root / "ledger.csv"
            write_rights_row(ledger, [default_rights_row(asset_id, "RGT_001", sha)])
            result = validate_corpus(root, rights_ledger_path=ledger)
            self.assertEqual(result.overall_status, "PASS")


class TestManifestFailures(unittest.TestCase):
    def test_missing_manifest(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            result = validate_corpus(Path(td))
            self.assertEqual(result.overall_status, "FAIL")
            self.assertTrue(any(f.code == "MANIFEST_MISSING" for f in result.errors))

    def test_invalid_json(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / "manifest.json").write_text("{not json", encoding="utf-8")
            result = validate_corpus(root)
            self.assertTrue(any(f.code == "MANIFEST_INVALID_JSON" for f in result.errors))

    def test_duplicate_asset_id(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            write_wav_at(root / "a.wav")
            write_wav_at(root / "b.wav")
            assets = [
                make_asset("DUP", "a.wav", write_wav=False),
                make_asset("DUP", "b.wav", write_wav=False),
            ]
            write_manifest(root, assets)
            result = validate_corpus(root)
            self.assertTrue(any(f.code == "ASSET_ID_DUPLICATE" for f in result.errors))

    def test_duplicate_relative_path(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            write_wav_at(root / "same.wav")
            assets = [
                make_asset("A1", "same.wav", write_wav=False),
                make_asset("A2", "same.wav", write_wav=False),
            ]
            write_manifest(root, assets)
            result = validate_corpus(root)
            self.assertTrue(any(f.code == "PATH_DUPLICATE" for f in result.errors))


class TestPathAndFileFailures(unittest.TestCase):
    def test_path_traversal(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            asset = make_asset("BAD", "../escape.wav", write_wav=False)
            write_manifest(root, [asset])
            result = validate_corpus(root)
            self.assertTrue(any(f.code == "PATH_TRAVERSAL" for f in result.errors))

    def test_missing_wav(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            asset = make_asset("MISSING", "nope.wav", write_wav=False)
            write_manifest(root, [asset])
            result = validate_corpus(root)
            self.assertTrue(any(f.code == "WAV_MISSING" for f in result.errors))

    def test_orphan_wav_strict(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root, _ = build_minimal_corpus(Path(td))
            write_wav_at(root / "orphan.wav")
            result = validate_corpus(root, phase1_strict=False)
            self.assertTrue(any(f.code == "ORPHAN_WAV" for f in result.warnings))

    def test_duplicate_sha256_strict(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            write_wav_at(root / "a.wav", frequency=440.0)
            write_wav_at(root / "b.wav", frequency=440.0)
            assets = [
                make_asset("A1", "a.wav", write_wav=False),
                make_asset("A2", "b.wav", write_wav=False),
            ]
            write_manifest(root, assets)
            result = validate_corpus(root, phase1_strict=True)
            self.assertTrue(any(f.code == "DUPLICATE_SHA256" for f in result.errors))


class TestWavFormatFailures(unittest.TestCase):
    def _write_stereo_wav(self, path: Path) -> None:
        write_synthetic_wav(path, channels=2, duration_ms=500)

    def test_stereo_file(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self._write_stereo_wav(root / "stereo.wav")
            asset = make_asset("ST", "stereo.wav", write_wav=False, duration_ms=500, crop_end=460)
            write_manifest(root, [asset])
            result = validate_corpus(root, phase1_strict=True)
            self.assertTrue(any(f.code == "WAV_CHANNELS" for f in result.errors))

    def test_wrong_sample_rate(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            write_wav_at(root / "bad.wav", sample_rate=44100)
            asset = make_asset("SR", "bad.wav", write_wav=False)
            write_manifest(root, [asset])
            result = validate_corpus(root, phase1_strict=True)
            self.assertTrue(any(f.code == "WAV_SAMPLE_RATE" for f in result.errors))

    def test_16_bit_strict(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            write_wav_at(root / "16bit.wav", sample_width=2)
            asset = make_asset("BD", "16bit.wav", write_wav=False)
            write_manifest(root, [asset])
            result = validate_corpus(root, phase1_strict=True)
            self.assertTrue(any(f.code == "WAV_BIT_DEPTH" for f in result.errors))

    def test_zero_length_audio(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            path = root / "empty.wav"
            write_synthetic_wav(path, duration_ms=1)
            path.write_bytes(b"RIFF" + struct.pack("<I", 4) + b"WAVE")
            asset = make_asset("Z", "empty.wav", write_wav=False)
            write_manifest(root, [asset])
            result = validate_corpus(root)
            self.assertTrue(any(f.code in ("WAV_PARSE_ERROR", "WAV_ZERO_LENGTH") for f in result.errors))

    def test_duration_mismatch(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            write_wav_at(root / "dur.wav", duration_ms=700)
            asset = make_asset("DM", "dur.wav", write_wav=False, duration_ms=200)
            write_manifest(root, [asset])
            result = validate_corpus(root)
            self.assertTrue(any(f.code == "DURATION_MISMATCH" for f in result.errors))


class TestCropAndDirection(unittest.TestCase):
    def test_invalid_crop(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            write_wav_at(root / "crop.wav", duration_ms=500)
            asset = make_asset("C", "crop.wav", write_wav=False, duration_ms=500, crop_start=400, crop_end=200)
            write_manifest(root, [asset])
            result = validate_corpus(root)
            self.assertTrue(any(f.code == "CROP_REVERSED" for f in result.errors))

    def test_crop_exceeds_duration(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            write_wav_at(root / "crop.wav", duration_ms=500)
            asset = make_asset("C", "crop.wav", write_wav=False, duration_ms=500, crop_start=0, crop_end=900)
            write_manifest(root, [asset])
            result = validate_corpus(root)
            self.assertTrue(any(f.code == "CROP_EXCEEDS_DURATION" for f in result.errors))

    def test_no_eligible_direction(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            write_wav_at(root / "dir.wav")
            asset = make_asset("D", "dir.wav", write_wav=False, forward=False, reverse=False)
            write_manifest(root, [asset])
            result = validate_corpus(root)
            self.assertTrue(any(f.code == "DIRECTION_NONE" for f in result.errors))


class TestPhase1Strict(unittest.TestCase):
    def test_missing_rights_ledger(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root, _ = build_minimal_corpus(Path(td))
            result = validate_corpus(root, phase1_strict=True)
            self.assertTrue(any(f.code == "RIGHTS_LEDGER_REQUIRED" for f in result.errors))

    def test_high_recognition_risk(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sha = write_wav_at(root / "risk.wav")
            asset = make_asset("R", "risk.wav", write_wav=False, recognition_risk="high")
            write_manifest(root, [asset])
            ledger = root / "ledger.csv"
            write_rights_row(ledger, [default_rights_row("R", "RGT_TEST_001", sha)])
            result = validate_corpus(root, phase1_strict=True, rights_ledger_path=ledger)
            self.assertTrue(any(f.code == "RECOGNITION_RISK_HIGH" for f in result.errors))

    def test_unknown_performer(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sha = write_wav_at(root / "p.wav")
            asset = make_asset("P", "p.wav", write_wav=False, performer_id="P99")
            write_manifest(root, [asset])
            ledger = root / "ledger.csv"
            write_rights_row(ledger, [default_rights_row("P", "RGT_TEST_001", sha)])
            result = validate_corpus(root, phase1_strict=True, rights_ledger_path=ledger)
            self.assertTrue(any(f.code == "PERFORMER_UNKNOWN" for f in result.errors))

    def test_wrong_total_count(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root, ledger = build_phase1_strict_corpus(Path(td))
            manifest = json.loads((root / "manifest.json").read_text())
            manifest["assets"] = manifest["assets"][:119]
            (root / "manifest.json").write_text(json.dumps(manifest))
            result = validate_corpus(root, phase1_strict=True, rights_ledger_path=ledger)
            self.assertTrue(any(f.code == "PHASE1_TOTAL_COUNT" for f in result.errors))


class TestRightsLedger(unittest.TestCase):
    def test_missing_rights_row(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sha = write_wav_at(root / "a.wav")
            asset = make_asset("A", "a.wav", write_wav=False, rights_record_id="RGT_MISSING")
            write_manifest(root, [asset])
            ledger = root / "ledger.csv"
            write_rights_row(ledger, [])
            result = validate_corpus(root, phase1_strict=True, rights_ledger_path=ledger)
            self.assertTrue(any(f.code == "RIGHTS_MISSING_ROW" for f in result.errors))

    def test_rights_status_hold(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sha = write_wav_at(root / "a.wav")
            asset = make_asset("A", "a.wav", write_wav=False)
            write_manifest(root, [asset])
            row = default_rights_row("A", "RGT_TEST_001", sha)
            row["rights_status"] = "HOLD"
            ledger = root / "ledger.csv"
            write_rights_row(ledger, [row])
            result = validate_corpus(root, phase1_strict=True, rights_ledger_path=ledger)
            self.assertTrue(any(f.code == "RIGHTS_STATUS_HOLD" for f in result.errors))

    def test_commercial_use_not_yes(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sha = write_wav_at(root / "a.wav")
            asset = make_asset("A", "a.wav", write_wav=False)
            write_manifest(root, [asset])
            row = default_rights_row("A", "RGT_TEST_001", sha)
            row["commercial_use"] = "NO"
            ledger = root / "ledger.csv"
            write_rights_row(ledger, [row])
            result = validate_corpus(root, phase1_strict=True, rights_ledger_path=ledger)
            self.assertTrue(any(f.code == "RIGHTS_FIELD_REQUIRED_YES" for f in result.errors))

    def test_ai_training_not_no(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sha = write_wav_at(root / "a.wav")
            asset = make_asset("A", "a.wav", write_wav=False)
            write_manifest(root, [asset])
            row = default_rights_row("A", "RGT_TEST_001", sha)
            row["ai_training_permitted"] = "YES"
            ledger = root / "ledger.csv"
            write_rights_row(ledger, [row])
            result = validate_corpus(root, phase1_strict=True, rights_ledger_path=ledger)
            self.assertTrue(any(f.code == "RIGHTS_FIELD_REQUIRED_NO" for f in result.errors))

    def test_hash_mismatch(self) -> None:
        import tempfile

        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            sha = write_wav_at(root / "a.wav")
            asset = make_asset("A", "a.wav", write_wav=False)
            write_manifest(root, [asset])
            row = default_rights_row("A", "RGT_TEST_001", "deadbeef" * 8)
            ledger = root / "ledger.csv"
            write_rights_row(ledger, [row])
            result = validate_corpus(root, phase1_strict=True, rights_ledger_path=ledger)
            self.assertTrue(any(f.code == "RIGHTS_HASH_MISMATCH" for f in result.errors))


class TestReports(unittest.TestCase):
    def test_json_report_fields(self) -> None:
        import tempfile

        from tools.corpus_intake.report import write_json_report, write_markdown_report

        with tempfile.TemporaryDirectory() as td:
            root, _ = build_minimal_corpus(Path(td))
            result = validate_corpus(root)
            jpath = Path(td) / "out.json"
            mpath = Path(td) / "out.md"
            write_json_report(result, jpath)
            write_markdown_report(result, mpath)
            data = json.loads(jpath.read_text())
            self.assertIn("overall_status", data)
            self.assertIn("audio_gate_status", data)
            self.assertEqual(data["audio_gate_status"], AUDIO_GATE_STATUS)
            md = mpath.read_text()
            self.assertIn("Audio Gate Status", md)
            self.assertNotIn("AUDIO GATE PASSED", md)


if __name__ == "__main__":
    unittest.main()
