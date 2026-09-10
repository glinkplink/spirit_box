# Listening and regression fixtures

Durable render bundles for mix-rebalance A/B and archived PCM regression.

| Path | Role |
|------|------|
| `listening-test-pre-rebalance-gain-ab/` | Frozen **A0** `listening-test` at **0.10 / 0.48 / 3.5**, seed `12648430`, 60 s / 300 ms forward. Pass A is **not accepted**; this is the reverted baseline, not a Pass A final. Human listening: **NOT_RUN**. |
| `archived-pcm-regression/` | 30 s `archived-continuous-static` PCM/event prefix hashes. Deferred with Pass B (not implemented). |

There is **no** `listening-test-pass-a-final/` fixture. Do not add one until every Pass A gate has actually passed.

Capture on macOS (A0 only):

```sh
./scripts/bootstrap-listening-fixtures.sh
```

Verify archived regression (Pass B only; not wired):

```sh
./scripts/render-sweep.sh ios/Phase1 build/archived-regression-check 30 300 forward 12648430 archived-continuous-static
python3 tools/check_sweep_render.py build/archived-regression-check --manifest ios/Phase1/manifest.json
python3 tools/verify_archived_pcm_regression.py build/archived-regression-check tools/fixtures/archived-pcm-regression/
```
