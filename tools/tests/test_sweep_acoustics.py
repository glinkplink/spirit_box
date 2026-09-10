import json
import tempfile
import unittest
import wave
from pathlib import Path

from tools.check_sweep_acoustics import parse_loudness_range_lu, slot_start_seconds
from tools.verify_archived_pcm_regression import pcm_prefix_sha256, verify


class SlotAlignmentTests(unittest.TestCase):
    def test_prefers_capture_time_when_present(self):
        event = {
            'render_time_seconds': 136.96,
            'capture_time_seconds': 0.3,
            'sweep_rate_ms': 300,
        }
        self.assertEqual(slot_start_seconds(event), 0.3)

    def test_falls_back_to_render_time_for_historical_events(self):
        event = {'render_time_seconds': 0.3, 'sweep_rate_ms': 300}
        self.assertEqual(slot_start_seconds(event), 0.3)


class LoudnessRangeParsingTests(unittest.TestCase):
    def test_parses_input_lra_from_ffmpeg_stderr(self):
        stderr = (
            'size=       0kB time=00:00:00.00 bitrate=N/A speed=   0x\n'
            '{"input_i" : "-18.2", "input_tp" : "-2.3", "input_lra" : "1.75", '
            '"input_thresh" : "-28.5", "output_i" : "-17.0", "output_tp" : "-1.0"}\n'
        )
        self.assertAlmostEqual(parse_loudness_range_lu(stderr), 1.75)

    def test_missing_input_lra_raises(self):
        stderr = '{"input_i" : "-18.2", "input_tp" : "-2.3"}\n'
        with self.assertRaises(ValueError):
            parse_loudness_range_lu(stderr)


class ArchivedPCMRegressionTests(unittest.TestCase):
    def test_verify_matches_fixture_prefix(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            fixture = root / 'fixture'
            rendered = root / 'rendered'
            fixture.mkdir()
            rendered.mkdir()

            pcm = (b'\x00\x01' * 48000)  # 1 second mono int16
            for directory in (fixture, rendered):
                wav_path = directory / 'sweep.wav'
                with wave.open(str(wav_path), 'wb') as wav:
                    wav.setnchannels(1)
                    wav.setsampwidth(2)
                    wav.setframerate(48000)
                    wav.writeframes(pcm)

            events = ['{"render_time_seconds":0.0,"contains_vocal":false}']
            (fixture / 'events-prefix.jsonl').write_text('\n'.join(events) + '\n')
            (rendered / 'events.jsonl').write_text('\n'.join(events) + '\n')

            digest = pcm_prefix_sha256(fixture / 'sweep.wav', 1.0)
            (fixture / 'pcm-prefix.sha256').write_text(digest + '\n')
            (fixture / 'manifest.json').write_text(json.dumps({
                'duration_seconds': 1.0,
                'preset_identifier': 'archived-continuous-static',
                'seed': 12648430,
            }) + '\n')
            (rendered / 'engine-diagnostics.json').write_text(json.dumps({
                'seed': 12648430,
                'renderer_settings': {'preset_identifier': 'archived-continuous-static'},
            }) + '\n')

            verify(rendered, fixture)
