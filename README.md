# Spirit Box

A focused iPhone spirit-box instrument centered on:

**START → LISTEN → MARK → REPLAY**

Spirit Box is an iOS-first product. Implementation is planned in Swift/SwiftUI. V1 is offline-first and has no backend or user accounts.

## Product specification

Canonical product specification:

- [`docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md`](docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md)

Supporting research (evidence only; the canonical document wins on conflict):

- [`docs/research/`](docs/research/)

## Repository workflow

`main` is the stable integration branch. After this bootstrap, do not develop directly on `main`. Each substantive task should use its own branch or worktree, stay tightly scoped, and return to `main` through a pull request.

## Current status

Repository bootstrap. Product research and architecture decisions are complete. The next engineering gate is the private audio-harness prototype defined in the canonical source of truth.
