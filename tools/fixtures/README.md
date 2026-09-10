# Listening and regression fixtures

Durable render bundles for mix-rebalance A/B and archived PCM regression.

| Path | Role |
|------|------|
| `listening-test-pre-rebalance-gain-ab/` | Frozen A0 gains (0.10 / 0.48) for Pass A blinded listening |
| `listening-test-pass-a-final/` | Pass A accepted gains without bed decoupling (Pass B blinded A/B) |
| `archived-pcm-regression/` | 30 s `archived-continuous-static` PCM/event prefix hashes |

Capture on macOS:

```sh
./scripts/bootstrap-listening-fixtures.sh
```

Verify archived regression:

```sh
./scripts/render-sweep.sh ios/Phase1 build/archived-regression-check 30 300 forward 12648430 archived-continuous-static
python3 tools/check_sweep_render.py build/archived-regression-check --manifest ios/Phase1/manifest.json
python3 tools/verify_archived_pcm_regression.py build/archived-regression-check tools/fixtures/archived-pcm-regression/
```
