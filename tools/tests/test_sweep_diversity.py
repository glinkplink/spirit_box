import unittest
from tools.check_sweep_render import diversity


class DiversityTests(unittest.TestCase):
    def setUp(self):
        self.assets = [dict(asset_id=f'a{i}', performer_id=f'p{i % 6}', utterance_id=f'u{i}')
                       for i in range(480)]

    def test_complete_coverage_reports_counts_and_distances(self):
        result = diversity(self.assets + self.assets, self.assets)
        self.assertEqual(result['unique_assets'], 480)
        self.assertEqual(result['corpus_coverage'], 1)
        self.assertEqual(result['repeat_distance']['minimum'], 480)
        self.assertEqual(result['per_speaker_event_counts'], {f'p{i}': 160 for i in range(6)})

    def test_small_cycle_rejected_even_when_cooldowns_allow_it(self):
        # 85 sources can satisfy all three cooldowns yet starve 395 sources.
        self.assets[84]['performer_id'] = 'p2'  # Keep cooldowns across the cycle seam.
        events = (self.assets[:85] * 59)[:5000]
        for i, event in enumerate(events):
            for field, window in [('asset_id', 64), ('utterance_id', 32), ('performer_id', 2)]:
                self.assertNotIn(event[field], [e[field] for e in events[max(0, i-window):i]])
        with self.assertRaisesRegex(AssertionError, 'Corpus starvation'):
            diversity(events, self.assets)

    def test_protection_driven_repeat_is_allowed(self):
        assets = self.assets[:3]
        # Unseen a2 shares the just-used speaker and is legitimately deferred.
        assets = [dict(a) for a in assets]
        assets[2]['performer_id'] = assets[1]['performer_id']
        result = diversity([assets[0], assets[1], assets[0]], assets)
        self.assertEqual(result['unique_assets'], 2)
