# Spirit Box Agent Rules

## Source of truth

Before making any product or implementation decision, read:

`docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md`

This is authoritative.

Supporting documents never override canonical scope, pricing, V1 boundaries, or the **current** audio recommendation.

### Document classes

| Class | Path | Role |
|-------|------|------|
| **Authoritative** | `docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md` | Final product source of truth (**CONDITIONAL BUILD** as of 2026-09-10) |
| **Revalidation ledger** | `docs/research/RESEARCH-REVALIDATION-2026-09-10.md` | Why prior assumptions changed |
| **Supporting product research** | `docs/research/` | Evidence |
| **Production execution** | `docs/production/` | VCTK path current; commissioned corpus **fallback only** |
| **Launch / acquisition execution** | `docs/launch/` | ASO + **required** seeding |

Task-specific agents should read the canonical document plus:

- **Audio:** canonical + `SPIRIT-BOX-AUDIO-ENGINE-DECISION.md` + renderer research (do not start performer procurement)
- **Launch / ASO:** canonical + ASO playbook + acquisition plan + indie ASO OS

If any supporting document conflicts with the canonical source of truth, the canonical document wins.

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

**Current recommendation (reopenable):** offline licensed human-speech fragments (VCTK candidate) + non-semantic sweep. Intermittent shards OK. No live radio, STT, semantic answers, AI interpretation, or fake RF.

See `docs/research/SPIRIT-BOX-AUDIO-ENGINE-DECISION.md`.

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

### Do not burn usage on idle waits

- Never sit idle polling CI, GitHub Actions, PR checks, TestFlight processing, App Store Connect, or similar remote jobs.
- After push / PR open: report the PR URL and how to check status, then stop or do other real work.
- Do not sleep-loop, `gh run watch`, or repeatedly re-query until green unless the human explicitly asked you to wait and act on the result.
- Prefer local checks (`xcodebuild`, unit tests, lint) when they unblock the task; remote CI is async by default.

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
