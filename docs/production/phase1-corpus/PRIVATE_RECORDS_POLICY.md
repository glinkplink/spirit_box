# Private records policy

The GitHub repository may be **public**. Treat anything that identifies a real person, payment, or contract as **out of git**.

Anonymized IDs **P01–P04** are the only performer identifiers that belong in public docs and shipping metadata.

---

## MUST NOT be committed to the public repo

- performer legal names (unless you later make a deliberate public credit — default is **no**)
- personal addresses
- phone numbers
- email addresses beyond what is already public on a marketplace profile you do not copy in
- tax / payment information
- signed releases containing personal data
- marketplace receipts
- private contract documents
- private messages
- unredacted marketplace screenshots
- raw contractual IDs if sensitive
- raw master corpus unless **explicitly** approved for repository storage
- accepted/runtime WAVs unless explicitly approved
- private rights evidence (signed PDFs, ID scans, tax forms)
- hashes tied to files that are themselves private, if the ledger row would reveal identity (keep full ledger private)

Templates in `docs/production/phase1-corpus/` stay generic. Filled ledgers live privately.

---

## Recommended private storage

Keep a folder **outside this repo** (local disk and/or private cloud), for example:

```text
SpiritBoxCorpusPrivate/
  contracts/
  releases/
  marketplace_terms/
  receipts/
  masters/
    raw/
    accepted/
  rights/
  qc/
```

Suggested private conventions:

- `masters/raw/P0x/` — immutable copies of delivered WAVs
- `masters/accepted/P0x/` — chosen 30 per performer after QC
- `rights/` — filled ledger (copy of template + real rows), hashes, `source_recording_id` map
- `marketplace_terms/` — PDF/HTML snapshot dated on contract day
- `qc/` — scorecards with marketplace handles (still not for git)

Never overwrite `masters/raw/`.

---

## What the public repo should contain

- generic templates (this pack)
- anonymized performer IDs (`P01`–`P04`)
- non-sensitive runtime metadata field names / example `manifest.json` shapes
- developer tooling and the audio harness
- empty or fixture corpus paths — **not** real Phase 1 human masters unless separately approved

---

## Operator rule

If you are unsure whether a file is public-safe, **do not commit it**.
