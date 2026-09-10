import json
import subprocess
import sys
import tempfile
import unittest
import wave
from pathlib import Path

from tools.recompute_audio_review import event_metrics, wav_info
from tools.verify_phase1_import_archive import compare, sha256_bytes

REPO_ROOT = Path(__file__).resolve().parents[2]


class EventMetricTests(unittest.TestCase):
    def test_occupancy_is_not_exposure_fraction(self):
        events = []
        for i in range(10):
            if i == 0:
                events.append({
                    "contains_vocal": True,
                    "asset_id": "a",
                    "emitted_frame_count": 4800,
                    "exposed_duration_ms": 100,
                    "sweep_rate_ms": 300,
                    "direction": "FWD",
                    "render_time_seconds": 0.3,
                    "performer_id": "p225",
                })
            else:
                events.append({
                    "contains_vocal": False,
                    "asset_id": "",
                    "sweep_rate_ms": 300,
                    "direction": "FWD",
                    "render_time_seconds": 0.3 * (i + 1),
                })
        metrics = event_metrics(events, duration_seconds=3.0, sample_rate=48_000)
        self.assertEqual(metrics["vocal_slots"], 1)
        self.assertEqual(metrics["scheduled_vocal_slot_occupancy"], 0.1)
        self.assertAlmostEqual(metrics["vocal_exposure_fraction_of_elapsed"], 4800 / (3.0 * 48_000))
        self.assertLess(metrics["vocal_exposure_fraction_of_elapsed"], metrics["scheduled_vocal_slot_occupancy"])


class CorpusCompareTests(unittest.TestCase):
    def test_same_manifest_and_pcm_is_ready(self):
        digest = sha256_bytes(b"pcm")
        bundle = {
            "label": "VCTK",
            "wav_sha256": {"a.wav": digest},
            "manifest_sha256": "abc",
        }
        archive = {
            "label": "VCTK",
            "wav_sha256": {"a.wav": digest},
            "manifest_sha256": "abc",
            "archive_sha256": "zip",
            "archive_bytes": 1,
            "archive": "x.zip",
            "asset_count": 1200,
        }
        result = compare(bundle, archive)
        self.assertTrue(result["ready_to_import"])
        self.assertTrue(result["same_pcm"])

    def test_audition_mismatch_is_not_ready(self):
        bundle = {
            "label": "VCTK",
            "wav_sha256": {"a.wav": "aa"},
            "manifest_sha256": "abc",
        }
        archive = {
            "label": "VCTK",
            "wav_sha256": {"a.wav": "bb"},
            "manifest_sha256": "abc",
            "archive_sha256": "zip",
            "archive_bytes": 1,
            "archive": "x.zip",
            "asset_count": 1200,
        }
        result = compare(bundle, archive)
        self.assertFalse(result["ready_to_import"])
        self.assertEqual(result["pcm_hash_mismatch"], ["a.wav"])


class WavInfoTests(unittest.TestCase):
    def test_reads_mono_fixture_without_changing_it(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "x.wav"
            with wave.open(str(path), "wb") as wav:
                wav.setnchannels(1)
                wav.setsampwidth(2)
                wav.setframerate(48000)
                wav.writeframes(b"\x00\x00" * 48)
            before = path.read_bytes()
            info = wav_info(path)
            self.assertEqual(info["channels"], 1)
            self.assertEqual(info["sample_rate"], 48000)
            self.assertEqual(path.read_bytes(), before)


def _write_pcm16_wav(path: Path, *, channels: int, rate: int, frames: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(channels)
        wav.setsampwidth(2)
        wav.setframerate(rate)
        wav.writeframes(b"\x00\x00" * channels * frames)


class DirectInvocationTests(unittest.TestCase):
    def test_documented_script_invocation_imports_sweep_acoustics(self):
        with tempfile.TemporaryDirectory() as tmp:
            recordings = Path(tmp) / "recordings"
            run = recordings / "Run3"
            run.mkdir(parents=True)
            _write_pcm16_wav(run / "engine-output.wav", channels=2, rate=48_000, frames=48_000)
            (run / "events.jsonl").write_text(
                json.dumps({
                    "contains_vocal": False,
                    "asset_id": "",
                    "sweep_rate_ms": 300,
                    "direction": "FWD",
                    "render_time_seconds": 0.3,
                })
                + "\n"
                + json.dumps({
                    "contains_vocal": True,
                    "asset_id": "a",
                    "emitted_frame_count": 4800,
                    "exposed_duration_ms": 100,
                    "sweep_rate_ms": 300,
                    "direction": "FWD",
                    "render_time_seconds": 0.6,
                    "performer_id": "p225",
                })
                + "\n"
            )
            (run / "summary.json").write_text("{}\n")
            output = Path(tmp) / "out"
            proc = subprocess.run(
                [
                    sys.executable,
                    str(REPO_ROOT / "tools" / "recompute_audio_review.py"),
                    "--recordings-root",
                    str(recordings),
                    "--reference-root",
                    str(Path(tmp) / "missing-refs"),
                    "--output",
                    str(output),
                ],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(proc.returncode, 0, proc.stderr)
            report = json.loads((output / "Run3" / "recompute.json").read_text())
            acoustics_error = report.get("slot_acoustics_error", "")
            boundary = report.get("slot_boundary_jumps", {})
            boundary_error = boundary.get("error", "") if isinstance(boundary, dict) else str(boundary)
            self.assertNotIn("No module named 'tools'", acoustics_error)
            self.assertNotIn("No module named 'tools'", boundary_error)
            self.assertEqual(boundary.get("label"), "RECOMPUTED")


class RenderProvenanceInvocationTests(unittest.TestCase):
    def test_harness_workflow_does_not_invoke_renderer_binary_directly(self):
        text = (REPO_ROOT / ".github/workflows/ios-audio-harness.yml").read_text()
        self.assertNotIn("build/render-sweep/render-sweep", text)
        self.assertIn("scripts/render-sweep.sh", text)

    def test_listening_tests_script_does_not_invoke_renderer_binary_directly(self):
        text = (REPO_ROOT / "scripts/render-listening-tests.sh").read_text()
        self.assertNotIn("build/render-sweep/render-sweep", text)
        self.assertIn("scripts/render-sweep.sh", text)


if __name__ == "__main__":
    unittest.main()
