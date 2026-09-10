# PR #32 audio review — 2026-09-10

## Review findings

PR #32 was open at `cf9019ff`; its actual-engine render job failed. The checkout was one commit ahead at `cad20349`, which restored A0. Those were different audio settings, and the PR description still referenced `439faf69`.

The Cursor sweep-mix plan completed the reference fixture, LRA parsing, matrix tooling, gain experiments, rejection report and Pass C warning. It did **not** complete an accepted Pass A freeze, blinded listening, Pass B, or Section 18. Five gain versions exceeded its two-candidate tuning budget. The first purported A0 fixture inherited 4.05 output gain; `cad20349` replaced it with the genuine 3.5 reference.

Additional defects corrected in this review:

- Matrix reruns deleted evidence, render failures disappeared from the summary, and `SECONDS` was Bash's changing elapsed-time variable.
- Short-render acoustic failures returned success. They now fail unless acoustics are explicitly skipped.
- LRA accepted infinity and invalid negative values. These now fail parsing.
- PR CI rendered a merge commit instead of the branch head. It now checks out the exact PR head.
- No executable gate checked the plan's primary 8–12 dB vocal-slot contrast or gain-only event/settings equality. Both now run in CI.
- The level audit implicitly used the live preset despite the named preset argument. It now receives the selected settings; the historical +4...+8 dB active-window contract is retained and runs against frozen A0. It is a different metric from full-slot contrast.

## Owner feedback and focused correction

Owner reported: “just multiple gibberish voices that sounded like they were fast forwarded underneath static that was too loud/ not right”. Recording/build and output route were not identified. This is useful qualitative feedback, not a blinded comparison or completed device gate.

The source path crops native-rate PCM; it does not accelerate or pitch-shift speech. No speed bug was found. The fast-forward impression remains a perceptual concern to re-test.

Under the renewed request to fix the audio, a focused **gain-only** correction is prepared, separately from the rejected/exhausted original Pass A experiment:

| Setting | Frozen A0 | Owner-review mix v2 |
|---|---:|---:|
| staticGain | 0.10 | 0.0515 |
| vocalGain | 0.48 | 0.90 |
| outputGain | 3.5 | 4.2 |
| Preset version | sparse-exposure-v1 | owner-review-mix-v2 |

The pre-limiter static amplitude falls from 0.35 to 0.2163 (about 4.18 dB). Vocal/static gain ratio rises from 4.8 to approximately 17.48. These are gain calculations, not measured loudness or perceptual approval. Actual-engine matrix and primary contrast must pass before delivery as a technically validated candidate.

No corpus, rate, exposure, density, cooldown, reverse-PCM, fade, limiter, or bed-spectrum changes. Pass B remains deferred. Frozen A0 remains available and must reproduce its committed PCM/events. Candidate events and all non-gain settings must match A0. CI also renders a 20-minute endurance sample and checks same-seed 30s/60s PCM prefixes.

## Production status

**NOT READY TO SHIP.** Section 18 requires unprimed physical-iPhone listening for 15–20 minutes across speaker/headphones, rates and directions. Automated renders cannot establish whether the fast-forward impression, recognizable words, repeat motifs or unnatural static are resolved. No TestFlight upload or merge is part of this review.

The first owner-review render at `2c94e2f8` (CI `34498423460`) passed all five matrix cells at −20.83 LUFS primary, but failed the separate contrast gate at 7.10 dB. Frozen A0 PCM and events reproduced exactly. Raising vocal input did not produce the expected contrast because the existing peak limiter bounds the output. The measured correction for v2 holds vocal/output gains fixed and reduces staticGain from 0.060 to 0.0515 (a further 1.33 dB bed reduction). No limiter threshold is changed. V2 must clear the same gates; the failed v1 remains historical evidence.

Final CI and playable artifacts are identified in the task delivery. Physical listening remains NOT_RUN.
