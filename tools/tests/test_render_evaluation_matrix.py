"""Exercise matrix orchestration without pretending to render AVAudioEngine on Linux."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class MatrixTests(unittest.TestCase):
    def run_matrix(self, root, fail=False):
        scripts = root / 'scripts'
        scripts.mkdir(exist_ok=True)
        source = Path(__file__).resolve().parents[2]
        shutil.copy(source / 'scripts/render-evaluation-matrix.sh', scripts)
        renderer = scripts / 'render-sweep.sh'
        renderer.write_text('''#!/usr/bin/env bash
if [[ "$1" == --build-only ]]; then exit 0; fi
if [[ "${FAIL_RENDER:-}" == 1 && "$4" == 125 ]]; then exit 1; fi
mkdir "$2"
printf '{"duration_seconds":%s}' "$3" > "$2/invocation.json"
''')
        renderer.chmod(0o755)
        tools = root / 'tools'
        tools.mkdir(exist_ok=True)
        (tools / 'check_sweep_render.py').write_text('')
        (tools / 'check_sweep_acoustics.py').write_text('''import json, sys
from pathlib import Path
(Path(sys.argv[1]) / 'acoustic-checks.json').write_text(json.dumps({'integrated_lufs': -18}))
''')
        bin_dir = root / 'bin'
        bin_dir.mkdir(exist_ok=True)
        for name, body in [('uname', 'echo Darwin'), ('ffmpeg', 'exit 0')]:
            path = bin_dir / name
            path.write_text('#!/bin/sh\n' + body + '\n')
            path.chmod(0o755)
        env = dict(os.environ, PATH=f"{bin_dir}:{os.environ['PATH']}", FAIL_RENDER=str(int(fail)))
        return subprocess.run(['bash', str(scripts / 'render-evaluation-matrix.sh'),
                               '--output-dir', str(root / 'output')],
                              env=env, capture_output=True, text=True)

    def test_complete_matrix_preserves_fixed_durations_and_refuses_overwrite(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            result = self.run_matrix(root)
            self.assertEqual(result.returncode, 0, result.stderr)
            summary_path = root / 'output/matrix-checks.json'
            before = summary_path.read_bytes()
            report = json.loads(before)
            self.assertEqual(report['matrix_checks'], 'PASS')
            self.assertEqual(len(report['cells']), 5)
            for key, cell in report['cells'].items():
                duration = int(key.split(':')[2])
                self.assertEqual(json.loads((Path(cell['directory']) / 'invocation.json').read_text())['duration_seconds'], duration)
            result = self.run_matrix(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('refusing to overwrite', result.stderr)
            self.assertEqual(summary_path.read_bytes(), before)

    def test_render_failure_remains_in_summary_and_other_cells_run(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            result = self.run_matrix(root, fail=True)
            self.assertNotEqual(result.returncode, 0)
            report = json.loads((root / 'output/matrix-checks.json').read_text())
            self.assertEqual(report['matrix_checks'], 'FAIL')
            self.assertEqual(len(report['cells']), 5)
            failed = report['cells']['125:forward:30']
            self.assertEqual(failed['render'], 'FAIL')
            self.assertEqual(failed['technical_checks'], 'NOT_RUN')
            self.assertEqual(failed['acoustic_checks'], 'NOT_RUN')
            self.assertEqual(report['cells']['75:forward:30']['render'], 'PASS')
