import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest

from tools.verify_mix_candidate import verify


class MixCandidateTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.candidate = Path(self.temp.name) / 'candidate'
        self.baseline = Path(self.temp.name) / 'baseline'
        self.record = dict(seed=1, sweep_rate_ms=300, direction='FWD', duration_seconds=60,
                           corpus_manifest_sha256='same', renderer_settings={'static_gain': .1, 'fade_seconds': .015})
        for path in (self.candidate, self.baseline):
            path.mkdir()
            (path / 'engine-diagnostics.json').write_text(json.dumps(self.record))
            (path / 'events.jsonl').write_text('same\n')
        self.report = {'technical_checks': 'PASS', 'vocal_slot_minus_noise_slot_db': 9.0}

    def check(self):
        (self.candidate / 'acoustic-checks.json').write_text(json.dumps(self.report))
        with contextlib.redirect_stdout(io.StringIO()):
            verify(self.candidate, self.baseline)

    def test_accepts_only_primary_contrast_band(self):
        for value in (8, 9, 12):
            self.report['vocal_slot_minus_noise_slot_db'] = value
            self.check()
        for value in (None, 7.99, 12.01, float('nan'), float('inf')):
            self.report['vocal_slot_minus_noise_slot_db'] = value
            with self.subTest(value=value), self.assertRaises(AssertionError):
                self.check()

    def test_rejects_event_change(self):
        (self.candidate / 'events.jsonl').write_text('changed\n')
        with self.assertRaisesRegex(AssertionError, 'event sequence'):
            self.check()

    def test_rejects_non_gain_setting_change(self):
        self.record['renderer_settings']['fade_seconds'] = .02
        (self.candidate / 'engine-diagnostics.json').write_text(json.dumps(self.record))
        with self.assertRaisesRegex(AssertionError, 'Non-gain'):
            self.check()

    def test_gain_only_change_is_allowed(self):
        self.record['renderer_settings']['static_gain'] = .0515
        (self.candidate / 'engine-diagnostics.json').write_text(json.dumps(self.record))
        self.check()

    def test_rejects_failed_acoustics(self):
        self.report['technical_checks'] = 'FAIL'
        with self.assertRaisesRegex(AssertionError, 'Acoustic gates'):
            self.check()
