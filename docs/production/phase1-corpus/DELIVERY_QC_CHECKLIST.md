# Delivery QC checklist

Use the moment a ZIP (or file set) arrives. QC in the same working block so retakes can happen immediately.

**Default:** replace a bad performer rather than spending hours repairing a fundamentally bad room.

Per-performer accepted target after QC: **30** assets (7 vowel / 8 continuant / 10 transition / 5 breath-transient). Phase 1 total: **120**.

---

## Delivery structure

| Check | Pass? | Disposition if fail |
|---|---|---|
| About **40** raw takes present | | RETAKE missing IDs |
| One WAV per take (not a single concatenated file) | | RETAKE |
| Separate ~10 s room-tone file | | RETAKE |
| Filenames match `SBX_RAW_{P0x}_{ID}_T{nn}_YYYYMMDD.wav` | | RETAKE rename or reject sloppy batch |
| Performer ID matches the packet (P01–P04) | | REJECT / clarify |

---

## Technical

Confirm with a DAW or `ffprobe`/`soxi` (or equivalent). Required raw spec: **WAV / linear PCM / 48 kHz / 24-bit / mono / unprocessed**.

| Check | Pass? | Disposition if fail |
|---|---|---|
| WAV container | | RETAKE |
| Linear PCM (not MP3-in-WAV, not compressed codec) | | RETAKE |
| 48 kHz | | RETAKE |
| 24-bit | | RETAKE if they cannot re-export from the same raw session |
| Mono | | RETAKE or downmix only if dual-mono identical and otherwise clean — prefer RETAKE |
| No clipping | | RETAKE clipped takes |
| No processing (EQ, limiter, NR, de-ess, gate, norm, reverb) | | REJECT / REPLACE PERFORMER if the whole session is processed |
| No obvious AGC pumping | | REJECT / REPLACE PERFORMER |
| No noise-reduction artifacts (swirl/metallic) | | REJECT / REPLACE PERFORMER |

---

## Performance

| Check | Pass? | Disposition if fail |
|---|---|---|
| No words | | RETAKE those takes |
| No phrases / sentences | | RETAKE or REPLACE if habitual |
| No example anchor words spoken (“cat”, “about”, etc.) | | RETAKE |
| No horror / spooky / possessed acting | | RETAKE; REPLACE if they cannot stay neutral |
| No answer cadence / sentence melody | | RETAKE |
| Stable pitch and volume | | RETAKE wild takes |
| Correct consonant/vowel (not “ess” for `/s/`, not “kuh” for `/k/`) | | RETAKE |
| Transitions are one motion, not two letters | | RETAKE |

---

## Room

| Check | Pass? | Disposition if fail |
|---|---|---|
| No obvious HVAC | | REJECT / REPLACE PERFORMER |
| No traffic | | REJECT / REPLACE PERFORMER |
| No fan | | REJECT / REPLACE PERFORMER |
| No strong hum | | REJECT / REPLACE PERFORMER |
| No excessive reflection / reverb | | REJECT / REPLACE PERFORMER |

Room defects on the **audition** should already have blocked hire. If they still appear in delivery, do not “fix in the mix.”

---

## Rights

Keep evidence **privately**. Do not commit it.

| Check | Pass? | Disposition if fail |
|---|---|---|
| Rider/release signed | | HOLD — do not intake |
| Payment/contract traceable | | HOLD |
| Marketplace terms snapshot retained privately | | HOLD |
| Source provenance clear (their original human performance) | | REJECT / REPLACE PERFORMER |

---

## Disposition meanings

### ACCEPT

Take is technically and phonetically usable as a candidate for the 30-asset keep set. Still subject to later recognition-risk review.

### RETAKE

Isolated defect: wrong sound, one clipped file, missing alt, named wrong. Ask immediately. Same session chain.

### REJECT / REPLACE PERFORMER

Session-wide room, processing, AGC, theatrical habit, rights refusal, or unclear source. **Do not** spend hours denoising. Hire a replacement for that family.

---

## After structure/tech/performance pass

1. Freeze raw privately and hash (see `PHASE1_HANDOFF_CHECKLIST.md`).
2. Pick 30 accepted per performer.
3. Tag `recognition_risk`. Drop **high** stable word/interjection assets from the prototype.
4. Do **not** mark the product audio gate as passed here.
