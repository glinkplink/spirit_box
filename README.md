# Spirit Box

A focused iPhone spirit-box instrument centered on:

**START → LISTEN → MARK → REPLAY**

Spirit Box is an iOS-first product. Implementation is planned in Swift/SwiftUI. V1 is offline-first and has no backend or user accounts.

## Project documentation

**Canonical** (authoritative; overrides all supporting documents):

- [`docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md`](docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md)

**Research** (evidence and architecture-decision research):

- [`docs/research/`](docs/research/)

**Production** (operational production inputs):

- [`docs/production/`](docs/production/)

**Launch** (ASO, conversion, and first-user acquisition playbooks):

- [`docs/launch/`](docs/launch/)

**Engineering** (implementation notes for in-progress work):

- [`docs/engineering/AUDIO_HARNESS.md`](docs/engineering/AUDIO_HARNESS.md)

## Repository workflow

`main` is the stable integration branch. After this bootstrap, do not develop directly on `main`. Each substantive task should use its own branch or worktree, stay tightly scoped, and return to `main` through a pull request.

## Current status

The private audio validation harness lives in `ios/SpiritBoxAudioHarness.xcodeproj`. It is a developer tool only. See [`docs/engineering/AUDIO_HARNESS.md`](docs/engineering/AUDIO_HARNESS.md).

**Audio gate status:** `PHASE 1 CANDIDATE BUNDLED (VCTK, 1,200 assets) — CANONICAL 15–20 MINUTE HUMAN GATE NOT YET PASSED`

The bundled VCTK Phase 1 candidate is loaded in the harness. Do not start the full product until that corpus has passed the canonical 15–20 minute human listening gate.
