# Phase 1 corpus acquisition — operator start here

**Purpose:** Hire four adult human performers and collect the locked Phase 1 bank: **120 accepted original source assets** (4 × 30).

**Authority:** `docs/production/AUDIO-CORPUS-ACQUISITION-AND-PRODUCTION-PLAN.md`

**Product authority:** `docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md`

**Do not:** redesign the corpus, commission 480 assets, hire AI voices, or use public/broadcast/stock/competitor audio.

**Audio gate:** `NOT YET RUN — WAITING FOR REAL PHASE 1 CORPUS`

Sheet frozen as **CORPUS_SHEET_v1.0**. Do not change phonetic material.

---

## Locked Phase 1 target

| Item | Value |
|---|---|
| Performers | 4 (P01–P04) |
| Raw takes | ~40 per performer |
| Accepted assets | **30 per performer / 120 total** |
| Composition | 28 vowel-core + 32 continuant/sonorant + 40 transition + 20 breath/transient |
| Words / phrases | **0** deliberately recorded |
| AI voices | **0** |
| Noise/static | procedural at runtime |
| Raw masters | 48 kHz / 24-bit / mono PCM WAV / unprocessed |

Voice families:

- **P01** — low / dry
- **P02** — mid / neutral
- **P03** — high / light
- **P04** — distinct / textured / rougher / older-sounding

Procurement: **one Upwork casting job → four separate fixed-price contracts**, target **$50–$90 each**, 10-second raw audition before hire, project-specific rights rider.

---

## Do this in order

### 1. Post the casting job

Copy `UPWORK_JOB_POST.md` into a new Upwork job. Attach or link `RIGHTS_RIDER_TEMPLATE.md` (after counsel review if a trigger in that file applies).

**Stop:** Do not post if you are unwilling to require the rider or the 10-second raw audition.

### 2. Invite candidates

Invite roughly 12–16 adults with audibly different timbres. Cast for register/resonance/breathiness, not demographic novelty.

**Stop:** Do not invite minors. Do not invite candidates who only offer dialogue/character VO.

### 3. Collect 10-second auditions

Paste `AUDITION_REQUEST.md` to each applicant. Same mic/room as production. No processing.

**Stop:** Do not hire from a processed demo reel instead of this raw take.

### 4. Score auditions

Use `AUDITION_SCORECARD.md`. Kill factors override a “nice voice.”

### 5. Select P01–P04

Assign the four families so they are **audibly distinct**. Fill P01–P04 only after you can hear separation.

**Stop:** Do not hire a fifth “maybe.” Do not hire two overlapping mid voices.

### 6. Confirm price

Separate **fixed-price** contract per performer. Planning target **$50–$90**. Confirm turnaround and that they can deliver 48 kHz / 24-bit mono WAV.

**Stop:** Do not start work on a vague hourly “we’ll see” without a take list and rider.

### 7. Execute rights rider

Send `RIGHTS_RIDER_TEMPLATE.md`. Get a signed copy **before or with** the first paid delivery. Store it **privately** (`PRIVATE_RECORDS_POLICY.md`).

**Stop:** Do not hire if they refuse app embedding, chopping, reverse, filter, pitch/formant, time change, mixing, derivatives, or worldwide store distribution. Do not hire if they demand AI-training or voice-cloning rights (we do **not** request those). Do not hire if they refuse the explicit **no AI training / no voice cloning** exclusion.

### 8. Send the performer-specific packet

Send only the matching file:

- P01 → `P01_RECORDING_PACKET.md`
- P02 → `P02_RECORDING_PACKET.md`
- P03 → `P03_RECORDING_PACKET.md`
- P04 → `P04_RECORDING_PACKET.md`

### 9. Receive delivery

Expect ~40 WAVs + one 10-second `ROOMTONE` file, one WAV per take, names matching the packet.

### 10. Freeze raw originals privately

Copy into private immutable storage (`PRIVATE_RECORDS_POLICY.md`). Never overwrite. **Do not commit masters to the public repo.**

### 11. Hash originals

SHA-256 each raw file. Record hashes in the **private** rights ledger (start from `RIGHTS_LEDGER_TEMPLATE.csv`).

### 12. QC

Use `DELIVERY_QC_CHECKLIST.md` immediately.

### 13. Request retakes immediately

Ask for retakes the same working block when the defect is isolated (one take clipped, one word slipped in).

**Stop:** Replace the performer if the **room/mic chain** is bad. Do not spend hours repairing reverb, HVAC, or AGC.

### 14. Select 30 accepted assets per performer

From the 40 raw takes, keep:

- 7 vowel
- 8 continuant/sonorant
- 10 transition
- 5 breath/transient

Unused alternates stay in archived raw masters. They are **not** extra V1 assets.

### 15. Move accepted files into intake

Follow `PHASE1_HANDOFF_CHECKLIST.md`, then the harness steps in `docs/engineering/AUDIO_HARNESS.md`.

### 16. Complete rights ledger

One row per **final accepted asset**. `rights_status` must not be unresolved. `ai_training_permitted` = NO. `voice_cloning_permitted` = NO.

### 17. Load Phase 1 corpus into harness

Real human assets + `manifest.json`. Confirm the label is **not** DEV fixtures.

### 18. Run canonical listening gate

Only after a real Phase 1 corpus is loaded. 15–20 minutes. This pack **does not** declare the gate passed.

---

## Do not hire a candidate if

- room/mic audition is noisy or reverberant;
- HVAC, fan, traffic, hum, or AGC pumping is obvious;
- they cannot or will not deliver 48 kHz / 24-bit / mono PCM WAV unprocessed;
- they will not accept the required product rights;
- they want AI-training or voice-cloning rights, or refuse the exclusion;
- voice overlaps too closely with an already selected family;
- they want to add spooky acting, words, phrases, or “ghost” performance;
- they are under 18;
- source chain is unclear (not their own original human performance);
- they insist on using public datasets, radio, YouTube, stock speech, or someone else’s voice.

## Do not proceed to intake if

- signed rider is missing;
- raw originals were not frozen and hashed;
- filenames/provenance are unclear;
- high-risk stable words remain in the accepted set;
- you are about to commit personal/legal files or raw masters to the public repo.

## Operator next action (today)

1. Optionally have counsel glance at `RIGHTS_RIDER_TEMPLATE.md` if any counsel-review trigger applies.
2. Post `UPWORK_JOB_POST.md` as one casting job.
3. Do **not** hire, pay, or commission until a raw 10-second audition **and** in-principle rider agreement exist.
