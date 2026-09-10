import unittest

from tools.check_sweep_acoustics import slot_start_seconds


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
