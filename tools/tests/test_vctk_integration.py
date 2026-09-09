import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from tools.integrate_vctk_candidate import integrate


class VCTKIntegrationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.candidate = self.root / 'candidate'
        self.corpus = self.candidate / 'SpiritBoxPhase1Corpus'
        self.corpus.mkdir(parents=True)
        self.audio = b'unchanged candidate PCM fixture'
        (self.corpus / 'a.wav').write_bytes(self.audio)
        self.manifest = {'schema_version': 1, 'assets': [dict(asset_id='a', performer_id='p225', relative_path='a.wav')]}
        self.write_manifest()
        self.origin = dict(asset_id='a', source_file='wav48_silence_trimmed/p225/p225_001_mic1.flac',
                           source_start_frame=4800, source_frame_count=9600,
                           output_sha256=hashlib.sha256(self.audio).hexdigest())
        (self.candidate / 'provenance.json').write_text(json.dumps([self.origin]))
        for name in ('license_text.txt', 'UPSTREAM_README.txt', 'speaker-info.txt', 'ATTRIBUTION.txt'):
            (self.corpus / name).write_bytes(b'original notice with trailing spaces  \r\n')
        self.output = self.root / 'output'

    def write_manifest(self):
        (self.corpus / 'manifest.json').write_text(json.dumps(self.manifest))

    def test_preserves_pcm_notices_and_exact_source_identity(self):
        result = integrate(self.candidate, self.output)
        asset = result['assets'][0]
        self.assertEqual(asset['utterance_id'], 'p225_001')
        self.assertEqual(asset['source_start_frame'], 4800)
        self.assertEqual(asset['source_frame_count'], 9600)
        dest = self.output / 'SpiritBoxPhase1Corpus'
        self.assertEqual((dest / 'a.wav').read_bytes(), self.audio)
        for name in ('license_text.txt', 'UPSTREAM_README.txt', 'speaker-info.txt', 'ATTRIBUTION.txt'):
            self.assertEqual((dest / name).read_bytes(), (self.corpus / name).read_bytes())
        self.assertNotIn('utterance_id', json.loads((self.corpus / 'manifest.json').read_text())['assets'][0])

    def test_hash_mismatch_fails_before_output_creation(self):
        (self.corpus / 'a.wav').write_bytes(b'changed')
        with self.assertRaises(ValueError):
            integrate(self.candidate, self.output)
        self.assertFalse(self.output.exists())

    def test_missing_notice_fails_before_output_creation(self):
        (self.corpus / 'license_text.txt').unlink()
        with self.assertRaises(ValueError):
            integrate(self.candidate, self.output)
        self.assertFalse(self.output.exists())

    def test_duplicate_id_rejected(self):
        self.manifest['assets'] *= 2
        self.write_manifest()
        with self.assertRaises(ValueError):
            integrate(self.candidate, self.output)
        self.assertFalse(self.output.exists())

    def test_refuses_existing_output(self):
        integrate(self.candidate, self.output)
        before = (self.output / 'SpiritBoxPhase1Corpus.zip').read_bytes()
        with self.assertRaises(FileExistsError):
            integrate(self.candidate, self.output)
        self.assertEqual(before, (self.output / 'SpiritBoxPhase1Corpus.zip').read_bytes())

    def test_rejects_path_traversal(self):
        self.manifest['assets'][0]['relative_path'] = '../a.wav'
        self.write_manifest()
        with self.assertRaises(ValueError):
            integrate(self.candidate, self.output)
        self.assertFalse(self.output.exists())


if __name__ == '__main__':
    unittest.main()
