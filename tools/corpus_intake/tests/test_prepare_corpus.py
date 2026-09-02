"""Unit tests for corpus intake preparation tooling."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.corpus_intake.prepare_pipeline import (
    assert_source_not_overwritten,
    build_manifest_entry,
    classify_region,
    make_asset_filename,
    make_asset_id,
)
from tools.corpus_intake.segmentation import (
    SilenceInterval,
    VocalRegion,
    merge_adjacent_silences,
    parse_silencedetect_output,
    vocal_regions_from_silences,
)


class TestSilenceParsing(unittest.TestCase):
    def test_parse_silencedetect_output(self) -> None:
        stderr = """
        [silencedetect] silence_start: 1.0
        [silencedetect] silence_end: 2.0 | silence_duration: 1.0
        [silencedetect] silence_start: 3.5
        [silencedetect] silence_end: 4.0 | silence_duration: 0.5
        """
        intervals = parse_silencedetect_output(stderr)
        self.assertEqual(len(intervals), 2)
        self.assertEqual(intervals[0].start_sec, 1.0)
        self.assertEqual(intervals[0].end_sec, 2.0)

    def test_merge_adjacent_silences(self) -> None:
        raw = [
            SilenceInterval(1.0, 2.0),
            SilenceInterval(2.05, 3.0),
            SilenceInterval(4.0, 5.0),
        ]
        merged = merge_adjacent_silences(raw, max_gap_sec=0.2)
        self.assertEqual(len(merged), 2)
        self.assertEqual(merged[0].start_sec, 1.0)
        self.assertEqual(merged[0].end_sec, 3.0)

    def test_vocal_regions_from_silences(self) -> None:
        silences = [SilenceInterval(1.0, 2.0), SilenceInterval(4.0, 5.0)]
        regions = vocal_regions_from_silences(silences, total_duration_sec=7.0)
        self.assertEqual(len(regions), 3)
        self.assertEqual(regions[0].start_sec, 0.0)
        self.assertEqual(regions[0].end_sec, 1.0)
        self.assertEqual(regions[1].start_sec, 2.0)
        self.assertEqual(regions[1].end_sec, 4.0)
        self.assertEqual(regions[2].start_sec, 5.0)
        self.assertEqual(regions[2].end_sec, 7.0)


class TestNamingAndThresholds(unittest.TestCase):
    def test_filename_generation(self) -> None:
        self.assertEqual(make_asset_filename("me_test", 1), "me_test_001.wav")
        self.assertEqual(make_asset_id("me_test", 12), "me_test_012")

    def test_reject_short_regions(self) -> None:
        region = VocalRegion(start_sec=0.0, end_sec=0.05, index=1)
        reason = classify_region(region, min_event_sec=0.12)
        self.assertIsNotNone(reason)
        self.assertIn("too short", reason or "")

    def test_accept_normal_region(self) -> None:
        region = VocalRegion(start_sec=0.0, end_sec=0.5, index=1)
        self.assertIsNone(classify_region(region, min_event_sec=0.12))


class TestManifest(unittest.TestCase):
    def test_manifest_entry_fields(self) -> None:
        entry = build_manifest_entry(
            "me_test_001",
            "me_test_001.wav",
            family="me_test",
            duration_ms=500,
            crop_margin_ms=30,
        )
        self.assertEqual(entry["asset_id"], "me_test_001")
        self.assertEqual(entry["voice_family"], "me_test")
        self.assertEqual(entry["relative_path"], "me_test_001.wav")
        self.assertEqual(entry["crop_safe_start_ms"], 30)
        self.assertEqual(entry["crop_safe_end_ms"], 470)


class TestSafety(unittest.TestCase):
    def test_refuse_output_inside_recordings(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            recordings = Path(td) / "recordings"
            recordings.mkdir()
            source = recordings / "voice.m4a"
            source.write_bytes(b"fake")
            with self.assertRaises(ValueError):
                assert_source_not_overwritten(source, recordings)

    def test_refuse_same_path(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            source = Path(td) / "voice.m4a"
            source.write_bytes(b"fake")
            with self.assertRaises(ValueError):
                assert_source_not_overwritten(source, source)


class TestInvalidInput(unittest.TestCase):
    def test_missing_source_raises(self) -> None:
        from tools.corpus_intake.prepare_pipeline import probe_source

        with self.assertRaises(FileNotFoundError):
            probe_source("ffprobe", Path("/tmp/does-not-exist-voice.m4a"))


class TestExtensibleWavParsing(unittest.TestCase):
    def test_extensible_pcm_is_treated_as_pcm(self) -> None:
        import tempfile

        from tools.corpus_intake.wav_analysis import parse_wav, write_synthetic_extensible_pcm_wav

        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / "extensible.wav"
            write_synthetic_extensible_pcm_wav(path)
            info = parse_wav(path)
            self.assertTrue(info.is_pcm)
            self.assertEqual(info.compression, "PCM")
            self.assertEqual(info.sample_rate, 48_000)
            self.assertEqual(info.sample_width_bytes, 3)


if __name__ == "__main__":
    unittest.main()
