# Spirit Box Agent Rules

## Source of truth

Before making any product or implementation decision, read:

`docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md`

This is authoritative.

Supporting research exists in:

`docs/research/`

If research conflicts with the canonical source of truth, the canonical document wins.

## Product discipline

Do not add features merely because competitors have them.

Do not add anything on the canonical DO-NOT-BUILD list without explicit product-owner approval.

Do not silently alter:
- audio architecture
- pricing
- V1 scope
- trust language
- core workflow
- product positioning

Core workflow:

START → LISTEN → MARK → REPLAY

## V1 audio architecture

Locked architecture:

offline original / explicitly licensed short audio + phoneme corpus
+
non-semantic sweep renderer

No:
- live radio
- speech recognition
- semantic response logic
- generated ghost answers
- AI interpretation
- fake RF/frequency behavior

## Repository workflow

- `main` is the stable integration branch.
- After repository bootstrap, do not develop directly on `main`.
- Every substantive task gets its own branch/worktree.
- Keep changes tightly scoped to the assigned task.
- Do not modify unrelated code while completing a task.
- Run relevant checks before declaring work complete.
- Summarize exactly what changed and any unresolved issues.
- Prefer pull requests back into `main`.
- Do not merge a PR merely because it compiles.

## Commercial objective

Profitability is the primary product objective.

Prefer:
- small scope
- fast shipping
- reliability
- strong App Store conversion
- low maintenance

over:
- technical novelty
- feature count
- architecture complexity
