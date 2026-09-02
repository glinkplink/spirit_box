# AUDIO CORPUS ACQUISITION AND PRODUCTION PLAN

**Project:** iPhone Spirit-Box Instrument  
**Date:** September 2, 2026  
**Status:** Phase 1 corpus production plan  
**Locked architecture:** Offline original/explicitly licensed human vocal corpus + phoneme bank + non-semantic sweep renderer

> **Decision rule:** optimize for the cheapest, fastest corpus that can survive a 15–20 minute blind listening test without sounding canned, repetitive, semantically steered, or like a small clip randomizer.

> **Legal note:** The rights language in this document is a practical drafting starting point, not legal advice. Have counsel review the final form if material money is involved, if a performer is union-represented, if a performer is outside the United States, or if use expands beyond the app/product scope described here.

---

# 1. EXECUTIVE RECOMMENDATION

## Recommendation

**Commission four original human performers directly for Phase 1, preferably through four separate fixed-price Upwork contracts, and require a project-specific performer release/rider in addition to marketplace terms.** Record roughly 40 raw takes per performer, retain **30 accepted source assets per performer**, and build a **120-asset prototype bank**.

Do **not** buy a generic speech corpus, scrape public-domain speech, use radio clips, or use AI voices for the prototype. Those routes save little money at this scale and add provenance, license, consistency, or credibility risk.

The Phase 1 corpus should contain:

- **28 vowel-core assets** — short, sustained, non-word monophthong-like vocal material;
- **32 continuant/sonorant assets** — sibilants, fricatives, hums and nasal texture;
- **40 coarticulated transition assets** — short CV/VC/cluster fragments built around neutral vowels, designed to sound human without forming a vocabulary;
- **20 breath/transient assets** — breaths plus a few human plosive releases;
- **0 required stored static/hiss/crackle assets** — synthesize those procedurally at runtime.

The 120 count refers to **genuinely distinct human recordings**, not pitch-shifted, reversed, filtered or time-stretched derivatives. Reverse playback, random cropping, radio-band filtering, gain variation and modest pitch/formant variation can be runtime transformations, but they do not count as new corpus assets.

### Why this route wins

**VERIFIED FACT:** Upwork’s current default optional service-contract terms state that, after full payment, work product is the client’s sole/exclusive property and automatically assign remaining intellectual-property rights worldwide unless the engagement terms say otherwise. Upwork’s definition of IP rights includes publicity rights. [S01]

**VERIFIED FACT:** Current voice-data jobs on Upwork commonly require **48 kHz, 24-bit WAV**, raw/unprocessed audio, quiet/treated rooms, consistent mic position/levels and signed releases. [S03]

**VERIFIED FACT:** Fiverr’s general commercial-use license expressly includes integration into products and software, but its voice-over licensing language and gig-specific rights can differ; therefore it is a viable fallback only with explicit written confirmation of permanent, modifiable paid-app embedding. [S05][S06]

**AUDIO-DESIGN INFERENCE:** Concatenative/unit-selection speech work consistently shows that natural variation comes from having multiple real recorded instances and phonetic/prosodic contexts, not merely from post-processing one small set. [S11][S12][S13]

**RECOMMENDATION:** Four performers is the right prototype number. Three can work, but the marginal cost of the fourth voice is small relative to the risk we are testing: users recognizing recurring performer identity/cadence over 15–20 minutes.

## Procurement hierarchy

1. **Recommended:** Upwork, four fixed-price human performers, custom release attached to the contract.
2. **Cheapest if immediately available:** self + friends/local adults through one decent recording setup, using the exact same signed release.
3. **Fast fallback:** Fiverr custom offers, only after written confirmation of exact app-embedding/transformation rights.
4. **Premium fallback:** Voices or Voice123 if remote-home-studio quality is repeatedly poor.
5. **Do not use without written confirmation:** stock speech corpora, Common Voice-derived fragments, stock SFX whose license limits redistribution when sound itself is core output.

---

# 2. PHASE 1 CORPUS SPEC

## Exact prototype target

| Item | Phase 1 decision |
|---|---|
| Human performers | **4** |
| Raw takes requested | **40 per performer / 160 total** |
| Accepted source assets | **30 per performer / 120 total** |
| Voice families | Low/dry; mid/neutral; high/light; textured/rougher or older-sounding |
| Full words | **0 deliberately recorded** |
| Full phrases/sentences | **0** |
| Languages | No deliberate multilingual material in Phase 1 |
| Strong accents | Not recruited as a feature; mild natural accent is fine |
| Whisper bank | No. Use breaths/unvoiced textures and limited breathier delivery instead |
| Reverse recordings | Do not ask performers to record backwards; reverse is processing/runtime behavior |
| Artificial pitch takes | No; obtain natural alternate takes instead |
| Stored static/hiss/crackle | Not required; generate procedurally |
| Raw master format | **48 kHz / 24-bit / mono WAV, PCM, unprocessed** |
| Runtime copy | Prefer 48 kHz / 16-bit mono PCM if the engine does not benefit from 24-bit playback; retain 24-bit masters |

## Composition rationale

### VERIFIED FACT

Diphone/concatenative synthesis literature emphasizes transitions and coarticulation: a speech unit that crosses a phoneme boundary captures natural spectral movement that isolated phonemes do not. Unit-selection systems improved naturalness by selecting from larger databases containing multiple real examples and contexts. [S11][S12][S13]

### AUDIO-DESIGN INFERENCE

For this product, that argues against a bank made entirely from isolated vowels or consonants. It also argues against long partial words. The best middle ground is:

- **short vowel cores** for voiced human texture;
- **continuants/fricatives/nasals** for speech-like energy without lexical content;
- **short CV/VC coarticulation fragments** for natural articulation;
- **breath and plosive transients** to break cadence;
- **procedural noise** to provide continuous radio-like glue.

### What we intentionally exclude

- complete `yes`, `no`, `hello`, `help`, `dead`, `leave`, `run`, `here`, names, pronouns, numbers or paranormal vocabulary;
- long diphthongs that are easily heard as English words/interjections, especially isolated `/aɪ/` (“I”), `/eɪ/` (“A”), `/oʊ/` (“oh”), or `/ju/` (“you”);
- scripted sentences;
- acted ghost whispers;
- laughter, screams, crying or horror performance;
- deliberate question/answer cadence;
- “radio DJ” impressions;
- intentionally backwards speech;
- content sourced from existing broadcasts or other apps.

---

# 3. VOICE DIVERSITY

## Prototype casting: exactly four performers

The goal is **audible timbral separation**, not demographic novelty for its own sake.

| Performer | Target voice family | Delivery target | Why it exists |
|---|---|---|---|
| **P01** | Lower register / grounded | Dry, neutral, stable pitch | Anchors low-frequency voiced material without theatrical bass |
| **P02** | Mid register | Clean/neutral, low breath | Provides least-colored reference voice |
| **P03** | Higher/lighter register | Lightly breathy but natural | Maximizes contrast with P01/P02 without “ghost whisper” acting |
| **P04** | Distinct resonance; textured, rougher, or older-sounding | Soft/neutral, no fake rasp | Adds identity separation and less predictable cadence |

A practical cast can include different masculine/feminine-presenting voices, but **register, resonance, breathiness and cadence are more important than the label**.

## Should every performer record the same material?

**No.** Use a **shared core + performer-specific transition subset**.

- Every performer records the same vowel/continuant/breath core so runtime can substitute timbres for similar source classes.
- Each performer gets eight unique transition targets.
- About three quarters of prompt *types* are shared in Phase 1, while a quarter are unique. The actual recordings remain independent.
- Production expansion should reduce overlap further.

### Why not fully identical sheets?

Identical phonetic content across performers is not automatically repetitive because the recordings are different, but it wastes a chance to increase source-space diversity. A partial common core is useful for scheduler flexibility; a fully duplicated sheet is not.

## Accents and languages

**Recommendation:** do not deliberately recruit strong accents or additional languages for Phase 1.

Reasons:

- The source units are intended to be non-semantic, so language diversity contributes less than timbral diversity.
- Strong accent markers can make a performer easier to recognize.
- Suddenly switching among obviously different languages can make the corpus feel curated or “bank-like.”
- It creates semantic and QA work we do not need yet.

If Phase 1 passes but production still sounds overly homogeneous, add one naturally accented/non-English performer as a **measured production experiment**, not as a required V1 premise.

## Production performer count

**Recommended final bank: 6 performers.** Keep the four Phase 1 performers if their recordings pass, then add two genuinely different voices. Do not jump to 10–20 performers unless testing proves performer identity remains the limiting factor.

---

# 4. EXACT PHASE 1 RECORDING SHEET

## Performer-wide rules

- The text in quotation marks below is an **anchor for the sound only**. Never speak the example word.
- Each file/take should begin with roughly **100–200 ms of quiet room tone**, make the target sound, then leave roughly **150–250 ms of quiet tail**.
- No dramatic intonation, emotion, spooky delivery, sentence melody or “answer” cadence.
- Use a comfortable pitch. Do not force very low/high pitch.
- Vowels/continuants should be steady, not sung.
- Transition fragments should be one smooth articulatory motion, not two clearly separated letters.
- Do not whisper words. Do not insert an extra vowel to name a consonant (for example, do not say “ess” for `/s/`).
- Keep the same mic, distance, room and input gain for the entire session.

## A. Shared core — every performer records this

| ID | Exact source | Plain-language intention | Raw takes | Target sound duration | Voicing | Delivery | Reverse/pitch plan |
|---|---|---|---:|---:|---|---|---|
| C01 | `/æ/` | vowel only from “cat” | 2 | 0.6–0.9 s | Voiced | steady, neutral | reverse allowed; no recorded pitch alt |
| C02 | `/ɛ/` | vowel only from “bed” | 2 | 0.6–0.9 s | Voiced | steady, neutral | reverse allowed |
| C03 | `/ɪ/` | vowel only from “bit” | 2 | 0.6–0.9 s | Voiced | steady, neutral | reverse allowed |
| C04 | `/ʊ/` | vowel only from “book” | 2 | 0.6–0.9 s | Voiced | steady, neutral | reverse allowed |
| C05 | `/ʌ/` | vowel only from “strut” | 2 | 0.6–0.9 s | Voiced | steady, neutral | reverse allowed |
| C06 | `/ə/` | unstressed vowel at start of “about” | 2 | 0.6–0.9 s | Voiced | very neutral | reverse allowed |
| C07 | `/s/` | continuous unvoiced hiss made by tongue/teeth; not “ess” | 1 + alt | 0.5–0.8 s | Unvoiced | steady | reverse allowed |
| C08 | `/ʃ/` | continuous “sh” only | 1 + alt | 0.5–0.8 s | Unvoiced | steady | reverse allowed |
| C09 | `/f/` | continuous “f” airflow only | 1 | 0.5–0.8 s | Unvoiced | steady | reverse allowed |
| C10 | `/θ/` | unvoiced “th” as in “thin,” held; do not say a word | 1 | 0.5–0.8 s | Unvoiced | steady | reverse allowed |
| C11 | `/h/` | soft breathy “h” airflow, no following vowel | 1 | 0.4–0.7 s | Unvoiced | natural | reverse allowed |
| C12 | `/v/` | continuous voiced “v” only | 1 | 0.5–0.8 s | Voiced | steady | reverse allowed |
| C13 | `/m/` | closed-mouth hum on comfortable pitch; not “em” | 1 + alt | 0.5–0.8 s | Voiced | neutral | reverse allowed |
| C14 | `/ŋ/` | sustained “ng” from end of “sing”; no preceding vowel | 1 | 0.5–0.8 s | Voiced | neutral | reverse allowed |
| C15 | `/k/` release | one soft unvoiced K release, no “kuh” | 1 | 0.15–0.30 s | Unvoiced | light | normally forward; reverse optional |
| C16 | `/p/` release | one soft P release, no “puh” | 1 | 0.15–0.30 s | Unvoiced | light, use pop filter | normally forward |
| C17 | quiet exhale | open-mouth natural exhale; no vocal pitch | 1 + alt | 0.35–0.8 s | Unvoiced | relaxed | reverse allowed |
| C18 | short inhale | natural small inhale; not gasp/horror breath | 1 | 0.25–0.6 s | Unvoiced | relaxed | forward preferred |

`+ alt` means record a second natural take after finishing the main sheet. The alternate must be a **new performance**, not a louder copy.

## B. Performer-specific transition sheet

### P01 — low/dry family

| ID | Sound | Intention | Takes | Duration | Style |
|---|---|---|---:|---:|---|
| A01 | `/sə/` | smooth S into neutral schwa; not a word | 1 + alt | 0.30–0.45 s | dry/neutral |
| A02 | `/fə/` | F into neutral schwa | 1 + alt | 0.30–0.45 s | dry/neutral |
| A03 | `/kə/` | soft K into schwa, minimal emphasis | 1 | 0.25–0.40 s | dry |
| A04 | `/mə/` | M into schwa | 1 | 0.30–0.45 s | neutral |
| A05 | `/əs/` | schwa moving into S | 1 + alt | 0.30–0.45 s | neutral |
| A06 | `/əf/` | schwa moving into F | 1 | 0.30–0.45 s | neutral |
| A07 | `/ək/` | schwa ending in a light K closure/release | 1 + alt | 0.25–0.40 s | neutral |
| A08 | `/əm/` | schwa closing into M | 1 | 0.30–0.45 s | neutral |

### P02 — mid/neutral family

| ID | Sound | Intention | Takes | Duration | Style |
|---|---|---|---:|---:|---|
| B01 | `/və/` | V into schwa | 1 + alt | 0.30–0.45 s | clean/neutral |
| B02 | `/lə/` | light L into schwa, no word-like stress | 1 | 0.30–0.45 s | neutral |
| B03 | `/gə/` | soft G into schwa | 1 | 0.25–0.40 s | neutral |
| B04 | `/ʒə/` | “zh” sound from “measure” into schwa | 1 + alt | 0.30–0.45 s | neutral |
| B05 | `/əv/` | schwa into V | 1 + alt | 0.30–0.45 s | neutral |
| B06 | `/əl/` | schwa into light L | 1 | 0.30–0.45 s | neutral |
| B07 | `/əg/` | schwa ending with soft G | 1 + alt | 0.25–0.40 s | neutral |
| B08 | `/əʒ/` | schwa into “zh” | 1 | 0.30–0.45 s | neutral |

### P03 — higher/light family

| ID | Sound | Intention | Takes | Duration | Style |
|---|---|---|---:|---:|---|
| C19 | `/pə/` | soft P into schwa | 1 + alt | 0.25–0.40 s | light, slightly airy |
| C20 | `/bə/` | soft B into schwa | 1 | 0.25–0.40 s | light |
| C21 | `/də/` | soft D into schwa | 1 | 0.25–0.40 s | light |
| C22 | `/ʃə/` | SH into schwa | 1 + alt | 0.30–0.45 s | lightly breathy |
| C23 | `/əp/` | schwa ending in soft P | 1 + alt | 0.25–0.40 s | light |
| C24 | `/əb/` | schwa ending in B | 1 | 0.25–0.40 s | light |
| C25 | `/əd/` | schwa ending in D | 1 + alt | 0.25–0.40 s | light |
| C26 | `/əʃ/` | schwa into SH | 1 | 0.30–0.45 s | lightly breathy |

### P04 — distinct/textured family

| ID | Sound | Intention | Takes | Duration | Style |
|---|---|---|---:|---:|---|
| D01 | `/tʃə/` | “ch” into schwa; not “cha” | 1 + alt | 0.25–0.40 s | soft/textured |
| D02 | `/dʒə/` | “j” sound into schwa | 1 + alt | 0.25–0.40 s | soft/textured |
| D03 | `/krə/` | compact K-R-schwa motion; no dramatic R | 1 | 0.30–0.45 s | neutral |
| D04 | `/frə/` | F-R-schwa motion | 1 | 0.30–0.45 s | neutral |
| D05 | `/ətʃ/` | schwa ending in CH | 1 + alt | 0.25–0.40 s | neutral |
| D06 | `/ədʒ/` | schwa ending in J sound | 1 | 0.25–0.40 s | neutral |
| D07 | `/əŋ/` | schwa closing into NG | 1 + alt | 0.30–0.45 s | neutral |
| D08 | `/əh/` | short schwa releasing into H-airflow | 1 | 0.30–0.45 s | neutral |

## C. Second-take instruction

Every performer records alternate takes for:

- `/s/`
- `/ʃ/`
- `/m/`
- quiet exhale
- the four performer-specific transitions marked `+ alt`

This creates **40 raw takes per performer**. The editor keeps only the best **30 accepted assets per performer** for the Phase 1 bank:

- 7 vowel assets;
- 8 continuant/sonorant assets;
- 10 transition assets;
- 5 breath/transient assets.

The unused alternates remain in the archived raw masters but are not counted as V1 assets.

## Recognition-risk review

After segmentation, each asset gets `recognition_risk = low | medium | high`.

A clip is **high** if a normal listener can consistently label it as a complete ordinary word/interjection when heard alone. High-risk assets are removed from the prototype unless shortening/cropping turns them back into clearly non-word material.

---

# 5. PERFORMER BRIEF — READY TO SEND

## Project description

We are creating source audio for a paid iPhone audio instrument. We need short, **non-word human vocal sounds**: individual vowels, consonant textures, very short phonetic transitions and natural breaths. These recordings will be chopped into much smaller fragments and combined with procedural noise in the app.

This is **not traditional voice-over**. You will not record dialogue, character lines, ghost phrases, names, answers or sentences.

## Performance direction

Please sound like your normal voice in a neutral recording session.

**Do:**

- use your natural register;
- keep pitch and volume stable;
- make clean, relaxed phonetic sounds;
- keep transitions compact and non-expressive;
- leave short room tone before/after each take;
- record true alternate takes where requested.

**Do not:**

- act scared, haunted, sinister or possessed;
- whisper recognizable words;
- add echo/reverb/distortion;
- growl, scream, laugh or cry;
- use dramatic rising/falling sentence intonation;
- say the example anchor words;
- improvise extra words or phrases;
- process the audio.

## Technical delivery

- 48,000 Hz sample rate;
- 24-bit PCM;
- mono WAV;
- raw/unprocessed;
- no compression, limiter, EQ, noise reduction, de-essing, gate, normalization or reverb;
- no clipping;
- quiet room with no obvious HVAC, traffic, computer fan or room echo;
- same microphone, room, distance and gain for all files;
- one WAV per take using the supplied filename list;
- include one separate 10-second `ROOMTONE` file;
- deliver raw files, not MP3.

## Audition before hire

Before the full job, provide a **10-second raw sample from the same mic/room** containing:

1. 2 seconds room tone;
2. one `/ə/` schwa for about 0.8 s;
3. one `/ʃ/` SH texture for about 0.6 s;
4. one natural quiet exhale;
5. remaining room tone.

Do not process it.

## Rights summary to put in the job post

The paid deliverables must be eligible for permanent commercial use inside a paid mobile application, including editing, chopping, filtering, reversing, pitch/time modification, mixing, embedding and worldwide App Store distribution. No additional royalties or credit obligation. Same-app trailers/previews/marketing are included. **No AI-training or voice-cloning rights are requested or granted.** Full release language is provided separately.

---

# 6. SOURCE / VENDOR SHORTLIST

## 6.1 Upwork — recommended

**Why:** strongest combination of low cost, current talent supply, fixed-price contracting and favorable default work-product assignment. [S01][S02]

Current platform evidence:

- Upwork publishes typical historical voice-actor rates around **$40–$85/hour**. [S02]
- A current August 29, 2026 game voice job is posted at **$90 fixed price** and expressly treats the performance as work made for hire with client ownership/edit/distribution rights. [S04]
- Current voice-dataset work requires 48 kHz/24-bit raw WAV, quiet rooms and signed releases, confirming that this delivery spec is normal for remote talent. [S03]

**Prototype procurement recommendation:** post one casting job, then open **four separate fixed-price contracts at a target budget of $50–$90 each** after audition/QC. The amount is a planning target inferred from current platform rates/listings, not an actual quote.

**Rights status:** strongest default, but still use our rider because voice/performance/marketing/AI exclusions should be explicit.

## 6.2 Fiverr — cheapest marketplace fallback

Current examples found during this pass include:

- **Alex Lynn Ward** — American female voice-over listing, current page advertises fast delivery and commercial/broadcast rights options. [S07]
- **Charles Pro Voice** — deep male voice-over listing with 24-hour positioning. [S08]
- **Demetrius Hazel** — deep/powerful male voice-over listing. [S09]

These are **examples to contact, not pre-approved performers**. Their demos, actual custom quote, mic quality and willingness to record phonetic/non-word material must be checked.

Fiverr’s general commercial license states that permitted commercial use includes integration into products/software. But voice-over rights can be gig-specific and standard “commercial rights” wording is not a sufficiently precise proof of permanent modifiable embedded-audio distribution for this unusual use. [S05][S06]

**Status:** `DO NOT USE WITHOUT WRITTEN CONFIRMATION` of the exact rights rider.

## 6.3 Voices — professional fallback

Voices’ terms contemplate commercial use/editing of work product and can transfer broad rights when a job agreement has no limitations. Its licensing guidance recognizes video-game/non-broadcast uses. [S15]

**Use when:** Upwork/Fiverr auditions repeatedly fail noise/room/performance QC.

**Downside:** likely higher cost for a task that does not need premium advertising VO.

## 6.4 Voice123 — professional/open-market fallback

Voice123’s rate guide gives a reference budget of roughly **$50–$200 for <=1 finished minute** of non-broadcast voice work, before usage considerations, and its marketplace model leaves the actual contract directly between buyer and talent. [S16][S17]

**Use when:** we need more casting control and are willing to negotiate rights directly.

**Status:** viable, not the cheapest.

## 6.5 Self / friends / local performers

Legally this can be the cleanest and cheapest route if four genuinely distinct adult voices are available immediately.

Requirements do not change:

- same signed release;
- same technical spec;
- raw files and rights ledger;
- no assumption that friendship substitutes for permission;
- no minors for Phase 1.

**Best use:** supplement one missing voice family or replace a marketplace performer who cannot deliver clean audio.

## 6.6 Commercial speech corpora / public datasets

### Mozilla Common Voice

The dataset is presented under CC0 in current dataset materials, but current Mozilla terms around dataset access/re-hosting create enough ambiguity for embedding extracted clips in a distributed app that it is not worth using here. [S20]

**Status:** `DO NOT USE WITHOUT WRITTEN CONFIRMATION`.

### Freesound / random CC material

CC0 can be legally permissive in the abstract, but user-uploaded provenance, inconsistent rooms, accents, compression and microphones make it poor source material for a coherent vocal bank. [S19]

**Recommendation:** do not use for production vocals.

### Stock SFX libraries

Some game-oriented libraries permit synchronization in games/apps but prohibit redistributing the sounds themselves or using them where sound files are the core supplied output. That distinction is uncomfortable for a spirit-box instrument whose primary function is audio. [S18]

**Recommendation:** do not use stock SFX for the core sweep. Procedural noise is cleaner.

---

# 7. RIGHTS REQUIREMENTS

## Rights that need to be explicit

For every performer, obtain language covering:

- perpetual commercial use;
- worldwide territory;
- paid/free mobile applications;
- Apple App Store and other software-store distribution;
- permanent embedding in compiled/distributed software;
- reproduction and storage of raw/edited source material;
- editing, chopping and cropping;
- reversing;
- filtering/EQ;
- pitch shifting;
- formant adjustment;
- time stretching/compression;
- gain changes;
- mixing with noise and other performers;
- creation of derivative audio assets;
- local recording/replay by app users as a normal consequence of using the instrument;
- marketing use in App Store previews, trailers, website/social/paid ads for the same product;
- future versions, updates and ports of the same product/product line;
- no ongoing royalties/residuals;
- no required attribution unless intentionally agreed;
- right to use third-party distribution/service providers as needed for app-store delivery;
- right to preserve masters and documentation;
- performer warranty that the recording is their own human performance and contains no third-party material.

## Rights we should **not** request

Do **not** ask for a general right to clone/model the performer’s identity or train AI on the recordings. It is unnecessary and creates performer-trust/legal complexity.

NAVA’s current AI rider exists specifically to make synthetic-voice consent and scope explicit, and recent performer-industry guidance emphasizes clear consent around digital replicas. [S21]

Use the opposite here: a clear exclusion.

## Marketplace terms are not the entire file

Even on Upwork, keep:

1. the job post;
2. accepted proposal/custom offer;
3. marketplace terms snapshot/PDF on the contract date;
4. signed project-specific performer release;
5. payment receipt/contract ID;
6. raw delivery;
7. rights ledger row linking all of the above.

---

# 8. SAMPLE RELEASE / RIGHTS LANGUAGE

> **NOT LEGAL ADVICE.** This is a practical starting draft for attorney review and marketplace attachment.

## AUDIO PERFORMANCE ASSIGNMENT AND RELEASE — STARTING DRAFT

**Parties.** This Audio Performance Assignment and Release (“Release”) is between **[Company/Developer legal name]** (“Company”) and **[Performer legal name]** (“Performer”), effective **[date]**.

**1. Services and Recordings.** Performer will create and deliver the original human vocal recordings described in the attached recording sheet, including raw takes, alternates and room tone (collectively, “Recordings”). Performer represents that the Recordings are Performer’s own original performance, that Performer is at least 18 years old and has authority to enter this Release, and that no third-party recording, music, dialogue, sample or other protected material is incorporated in the Recordings.

**2. Compensation.** In exchange for **[amount]** and other good and sufficient consideration, receipt of which is acknowledged after payment, Performer grants the rights below. No additional royalty, residual, reuse fee or other compensation will be due for uses authorized by this Release.

**3. Ownership / Assignment.** To the fullest extent permitted by law, Performer irrevocably assigns to Company all right, title and interest Performer may own in the Recordings and deliverables, including applicable copyright, neighboring/performance rights and rights necessary to exploit the recorded performance. To the extent any such right cannot legally be assigned, Performer grants Company an exclusive, perpetual, irrevocable, worldwide, fully paid, royalty-free, transferable and sublicensable license to exercise that right for the authorized uses below.

**4. Authorized transformations.** Company may reproduce, copy, archive, edit, trim, chop, crop, segment, reverse, filter, equalize, denoise where necessary, pitch shift, formant shift, time stretch/compress, change level, layer, mix, combine with noise/other recordings, and create derivative audio assets from the Recordings. Performer understands that the resulting fragments may be extremely short, may be played nonlinearly, and may no longer sound like Performer’s original delivery.

**5. Product use and distribution.** Company may permanently embed the Recordings and derivatives in compiled mobile/software applications and distribute, sell, license and make those applications available worldwide through the Apple App Store and other software distribution channels. Authorized use includes updates, upgrades, successor versions and ports of the same application/product line.

**6. Marketing.** Company may use excerpts and derivatives from the Recordings in App Store previews, trailers, screenshots-with-audio, demonstrations, websites, social posts and paid or unpaid advertising solely to market or demonstrate the same application/product line.

**7. End-user operation.** Performer authorizes normal output and recording consequences of the application, including that an end user may hear the embedded/derived fragments during a session and may locally record, replay, export or share the user’s own session recording when the product provides those functions. This does not grant end users a license to extract or resell the standalone source bank.

**8. Name, credit and publicity.** Company is not required to identify or credit Performer. Performer consents to use of Performer’s recorded voice as embodied in the Recordings and authorized derivatives. No right is granted to falsely claim Performer endorses paranormal claims or personally uses the product. Company receives no general right to use Performer’s name, photograph or likeness unless separately agreed.

**9. No AI training or voice clone.** **No right is granted to use the Recordings to train, fine-tune or evaluate a machine-learning model intended to reproduce Performer’s voice or identity; create a digital replica/voice clone; build a general-purpose text-to-speech voice; or synthesize new semantic speech in Performer’s voice.** Any such use requires a separate written agreement signed by Performer.

**10. No semantic-performance promise.** Performer understands that the product uses non-semantic fragments as an audio instrument. Company does not require Performer to record specific paranormal answers or make claims about paranormal communication.

**11. Moral rights.** To the extent permitted by applicable law, Performer waives and agrees not to assert moral or similar rights that would prevent the modifications and product uses expressly authorized above. Where waiver is not permitted, Performer gives the broadest lawful consent to those acts.

**12. No conflicting grants.** Performer represents that Performer has not granted and will not grant rights that conflict with this Release with respect to the delivered Recordings.

**13. Confidentiality [optional].** Until Company publicly releases or announces the product, Performer will not post the recording sheet, raw files, app name/code name or confidential product details without written permission.

**14. Marketplace terms.** If the engagement occurs through Upwork/Fiverr/Voices/Voice123, this Release supplements the applicable marketplace contract. If a conflict exists, the parties intend the broader lawful rights needed for the authorized uses above to control between Company and Performer to the extent the marketplace permits.

**15. Governing law / signatures.** **[Counsel to insert jurisdiction, dispute language and signature mechanics.]** Electronic signatures and counterparts may be used.

**Company:** __________________ / Date: ______  
**Performer:** _________________ / Date: ______

### Counsel review triggers

Get attorney review before relying on this draft if:

- performer is SAG-AFTRA/union or covered by a collective agreement;
- performer is a minor (not recommended here);
- performer lives in a jurisdiction with non-waivable performer/moral rights you do not understand;
- app use expands to unrelated products;
- voice will be a recognizable marketing identity;
- AI/synthetic use is later contemplated;
- paid advertising uses the performer as a recognizable spokesperson rather than incidental fragments.

---

# 9. RECORDING SPECS

## Required raw delivery

| Spec | Requirement | Rationale |
|---|---|---|
| Sample rate | **48 kHz** | Standard current production/data capture rate; ample headroom for filtering/resampling |
| Bit depth | **24-bit** | Preserves editing headroom in masters |
| Channels | **Mono** | Source is a single human voice; stereo adds no useful information |
| Format | **WAV / linear PCM** | Uncompressed, broadly supported |
| Processing | **None** | We need consistent raw material; artifacts from denoise/limiting become recognizable after chopping |
| Room | Treated or genuinely quiet/dead | Avoid room signature and noise pumping |
| Noise floor | Aim for **<= -60 dBFS** in quiet sections; audible HVAC/hum/reverb is a reject | ACX uses -60 dB RMS as a finished-audio ceiling; we use it only as a cleanliness benchmark, not audiobook mastering [S22] |
| Peak level | Prefer ordinary speech peaks around **-12 to -6 dBFS**, never clipped | Leaves headroom; this is our production target, not a platform rule |
| Mic | Quality XLR or good USB condenser/dynamic; no phone/laptop mic | Low-noise consistent capture matters more than premium brand |
| Distance | About **15–25 cm / 6–10 in**, consistent | Reduces proximity variability |
| Pop control | Pop filter/windscreen; 10–20° off-axis if needed | Especially for P/K transients |
| Room tone | Separate 10-second file + short head/tail per take | QC and repair reference |

**VERIFIED FACT:** Current Upwork voice-data jobs specify 48 kHz, 24-bit WAV, treated/quiet rooms, no compression/EQ/noise reduction/de-essing/normalization, no clipping and consistent levels. [S03]

**RECOMMENDATION:** do not pay for a studio solely to hit these specs. A competent home voice-over setup is enough because the material is short and will later be filtered/chopped. Reject bad room recordings instead of trying to rescue them aggressively.

---

# 10. PROCESSING PIPELINE — RAW TO IN-APP ASSET

## A. Asset-preparation time

### 1. Ingest and freeze originals

- Copy raw WAV into immutable `/masters/raw/` storage.
- Generate SHA-256 hash.
- Create `source_recording_id`.
- Attach performer/contract/rights record before editing.
- Never overwrite raw delivery.

### 2. QC before processing

Reject/retake when there is:

- clipping;
- obvious room reverb;
- fan/HVAC/traffic;
- phone-style automatic gain pumping;
- strong electrical hum;
- plosive blast that cannot be cleanly cropped;
- performer drifting into words;
- theatrical spooky delivery;
- inconsistent mic distance/gain across the session.

Do **not** make heavy denoising the default. A denoiser can leave swirly/metallic signatures that become more obvious after narrow-band filtering.

### 3. Segment

Retain enough internal duration for runtime random start offsets:

- vowels/continuants: generally **0.50–0.90 s** source asset;
- transitions: **0.25–0.45 s**;
- breaths: **0.25–0.80 s**;
- plosive transients: **0.15–0.30 s**.

The runtime renderer may consume only a smaller slice of that source.

### 4. Boundary cleanup

- trim unnecessary silence while retaining crop headroom;
- remove DC offset if present;
- use very short fades (roughly **3–10 ms**) only where necessary to prevent clicks;
- manually repair isolated click/plosive artifacts if trivial;
- avoid audible fade-envelope fingerprints.

### 5. Level balance

Do not master every microclip to a broadcast loudness target. LUFS is unstable/less meaningful on extremely short fragments.

Use class-relative RMS/peak balancing with headroom. A practical starting point is to keep final clean-source peaks around **-6 dBFS**, then let runtime mix gain control overall intensity.

### 6. Recognition-risk pass

Listen to every isolated final source file and tag:

- `low`: clearly non-word / generic texture;
- `medium`: could be interpreted multiple ways but not a stable word;
- `high`: repeatedly heard as one ordinary word/interjection.

High-risk assets are rejected or recut shorter before prototype inclusion.

### 7. Export

Keep:

- **24-bit/48 kHz clean master**;
- optional **16-bit/48 kHz runtime copy** if that is the engine’s chosen playback representation.

Do not create dozens of pre-rendered filter/pitch variants in the asset folder.

## B. Runtime transformations

These operations can create useful *presentation variation* without pretending to create new sources:

- random crop/start offset within a source-safe range;
- short crossfades;
- radio-band/band-pass filtering;
- moderate gain variation;
- forward/reverse when tagged safe;
- modest pitch shift, initially around **±1–2 semitones maximum**;
- very occasional restrained formant adjustment if listening tests show it helps;
- procedural static/hiss/crackle/noise bursts;
- sparse tuning-like transients;
- rate/direction effects already defined by the locked renderer.

### Transformations that genuinely help recognition resistance

Ranked roughly by value:

1. **new real performer / genuinely new take**;
2. **different phonetic context**;
3. **random crop/start location inside a longer natural source**;
4. **reverse of a source where articulation does not create an obvious gimmick**;
5. **small combined pitch/formant variation**;
6. **filter/EQ/noise masking**;
7. **simple pitch-only or time-stretch-only copies**.

Filtering a memorable clip does not make it a new clip. Large pitch shifts usually make repetition temporarily less obvious but increase artificiality. Extreme reverb, horror effects and aggressive formant shifting are specifically contrary to the product’s trust goal.

---

# 11. NON-VOCAL TEXTURES

## Generate rather than license

For V1, create these at runtime:

- white noise;
- pink/brown-leaning filtered noise as needed;
- moving band-pass hiss;
- sparse impulse crackle;
- low-level amplitude flutter;
- short broadband noise bursts;
- tuning-like chirps/transient ticks generated from oscillators/noise;
- micro-silence gaps.

This gives:

- no third-party rights ledger;
- effectively unbounded variation;
- tiny app-size burden;
- precise response to sweep settings;
- no risk of accidentally embedding an identifiable broadcast.

If a physical click/relay texture later proves valuable, record it ourselves and ledger it exactly like any other source. Do not add a stock-SFX dependency merely for realism.

---

# 12. AI / SYNTHETIC VOICES AS SOURCE MATERIAL

## Verdict: do not use for Phase 1 or initial production

Synthetic voice is not inherently impossible to license. Some current TTS providers grant commercial rights to paid-plan outputs, subject to their terms and the user’s rights in inputs/voice models. [S23]

But it is the wrong trade here.

### Why human recording is commercially preferable

**RECOMMENDATION / INFERENCE:**

- Four tiny human sessions are cheap enough that synthetic generation does not materially unlock the project.
- Human micro-articulations/coarticulation are exactly the variation we need.
- A product positioned around “no generated answers” has an avoidable credibility problem if its entire voice bank later turns out to be synthetic, even though the claim technically refers to runtime behavior.
- Voice-cloning/model provenance adds a class of rights questions that does not exist with direct human recording plus a clear release.
- We can make the performer agreement more trustworthy by explicitly excluding AI training/clone rights.

### App/privacy implication

If synthetic clips were pre-generated and embedded, there would be no necessary runtime AI/network data flow from those clips alone. That does **not** solve the credibility/provenance issue, and it is not a reason to prefer synthetic source material.

**V1 decision:** original human recordings only for vocal content.

---

# 13. NAMING / METADATA STANDARD

## File naming

### Raw take

`SBX_RAW_{performer}_{sheetID}_T{take}_{date}.wav`

Examples:

- `SBX_RAW_P01_C01_T01_20260903.wav`
- `SBX_RAW_P03_C22_T02_20260903.wav`

### Accepted clean master

`SBX_V1_{performer}_{type}_{phoneticCode}_{sequence}.wav`

Examples:

- `SBX_V1_P01_VOW_AE_001.wav`
- `SBX_V1_P02_CONT_V_001.wav`
- `SBX_V1_P03_TR_SH_SCHWA_001.wav`
- `SBX_V1_P04_BR_EXH_001.wav`

Do not encode human names in shipping filenames.

## Minimum runtime metadata

| Field | Example / allowed values | Purpose |
|---|---|---|
| `asset_id` | `SBX_V1_P03_TR_SH_SCHWA_001` | Immutable unique ID |
| `performer_id` | `P03` | Avoid same voice too soon |
| `voice_family` | `low_dry`, `mid_neutral`, `high_light`, `textured` | Timbre balancing |
| `source_type` | `vowel`, `continuant`, `transition`, `breath`, `transient` | Class balancing |
| `phonetic_family` | `schwa_sh`, `front_vowel`, `fricative`, etc. | Avoid family repeats |
| `voicing` | `voiced`, `unvoiced`, `mixed` | Texture control |
| `register` | `low`, `mid`, `high` | Voice distribution |
| `delivery` | `dry`, `neutral`, `light_breathy` | Avoid repetitive texture |
| `duration_ms` | integer | Crop/playback constraints |
| `recognition_risk` | `low`, `medium`, `high` | Restrict speechy material |
| `forward_allowed` | bool | Processing safety |
| `reverse_allowed` | bool | Processing safety |
| `crop_safe_start_ms` | integer | Runtime random crop |
| `crop_safe_end_ms` | integer | Runtime random crop |
| `prep_version` | `prep_1.0` | Reproducibility |
| `rights_record_id` | `RGT_P03_20260903` | Traceability |

## Performer-level metadata

Store accent/language/recording-chain notes at performer level rather than repeating them on every file:

- `performer_id`
- `voice_family`
- `declared_age_band` if voluntarily supplied for casting/QC
- `accent_region` if relevant
- `mic_model`
- `interface_model`
- `room_notes`
- `recording_date`

Do not ship unnecessary personal data inside the app bundle.

---

# 14. CORPUS RIGHTS LEDGER SCHEMA

Use one row per **final accepted asset** plus separate performer/contract tables if desired.

## Spreadsheet-ready column header

```text
rights_record_id,asset_id,source_recording_id,raw_filename,final_filename,performer_id,contract_party_name,recording_date,recording_country,source_vendor,order_contract_id,agreement_version,agreement_signed_date,agreement_file_path,marketplace_terms_snapshot_path,license_url,license_terms_accessed_date,copyright_owner,performance_rights_granted,commercial_use,mobile_app_embedding,modification,derivative_audio,worldwide,perpetual,royalty_free,attribution_required,marketing_use,future_versions,end_user_session_recording_use,store_distribution_sublicense,ai_training_permitted,voice_cloning_permitted,expiration_date,raw_sha256,final_sha256,qc_status,rights_status,notes
```

## Required values before shipping

| Field | Ship requirement |
|---|---|
| `commercial_use` | YES |
| `mobile_app_embedding` | YES |
| `modification` | YES |
| `derivative_audio` | YES |
| `worldwide` | YES, unless storefronts are explicitly territory-limited |
| `perpetual` | YES |
| `royalty_free` | YES |
| `attribution_required` | NO preferred |
| `marketing_use` | YES for same product |
| `future_versions` | YES for same product/product line |
| `end_user_session_recording_use` | YES |
| `store_distribution_sublicense` | YES / sufficient to distribute app |
| `ai_training_permitted` | **NO** |
| `voice_cloning_permitted` | **NO** |
| `rights_status` | `APPROVED` |

Any row with unclear app embedding, derivative rights, performer consent or source provenance gets `rights_status = HOLD` and is excluded from the shipping bank.

---

# 15. NUMBER OF CLIPS AND DIMINISHING RETURNS

## Phase 1

**120 accepted human source assets.** This is intentionally inside the canonical 80–150 range and gives a clean 30-assets-per-performer target.

## Production recommendation if Phase 1 passes

**Target: ~480 accepted original human-source assets from 6 performers.**

Suggested expansion arithmetic:

- Phase 1: 4 performers × 30 = **120**;
- existing 4 performers add 45 genuinely new accepted assets each = **+180**;
- add 2 new performers × 90 accepted assets each = **+180**;
- total = **480**.

### Why not 1,000–2,000 immediately?

**VERIFIED FACT:** speech/unit-selection work supports larger, varied real databases as a path to naturalness, while database selection/reduction research shows that smart coverage matters rather than unbounded size. [S11][S12][S14]

**AUDIO-DESIGN INFERENCE:** For this non-semantic sweep, the first large gains should come from:

1. 4 → 6 genuinely distinct performers;
2. more real coarticulation contexts;
3. multiple real takes;
4. longer crop-safe source windows;
5. then runtime variation.

Going from ~120 to ~480 multiplies source-ID space fourfold and increases voice families by 50% without creating a rights/QA project of its own. Going from 480 to 2,000 multiplies manual segmentation/listening/ledger work again, while many additional phonetic clips will be acoustically redundant.

### Production size decision

- **250:** probably viable but still thin if the renderer exposes source identity often.
- **400–600:** recommended V1 production zone.
- **1,000:** only record if testing at 400–600 still identifies exact-source repetition.
- **2,000+:** overkill without measured evidence.

These thresholds are **audio-design recommendations, not published scientific standards for spirit-box banks**.

## App-size burden

Uncompressed 48 kHz / 16-bit / mono PCM is about 96 KB/sec.

At an average accepted runtime-source duration of 0.30 s:

- 120 clips ≈ **3.5 MB**;
- 480 clips ≈ **13.8 MB**;
- 600 clips ≈ **17.3 MB**;
- 1,000 clips ≈ **28.8 MB**;
- 2,000 clips ≈ **57.6 MB**.

At 24-bit these figures are 1.5× larger. Therefore **app size is not the primary reason to stop at 480–600**. The real costs are recording, rights tracking, QC and diminishing acoustic novelty.

---

# 16. COST ESTIMATE

All figures below are planning ranges. They are not freelancer quotes.

## Current evidence anchors

- Upwork publishes historical voice-actor rates around **$40–$85/hour**. [S02]
- A current game-demo voice job is **$90 fixed price**. [S04]
- Voice123’s current reference guide is roughly **$50–$200** for <=1 finished minute of non-broadcast voice work before usage specifics. [S16]
- Upwork audio-editor rates are commonly listed around **$15–$40/hour**. [S24]
- Current recording-studio listings commonly start around **$30–$90/hour**, with some city averages/listings materially higher and minimum bookings. [S25]

## Prototype — cheapest acceptable

### Self/local group route

- talent: **$0–$150 total honoraria** if willing adults are already available;
- recording space: **$0** if one adequate quiet room/mic already exists;
- editing: self;
- releases: self-drafted + marketplace-independent signatures;
- total: **approximately $0–$150 out of pocket**.

**Caveat:** this is only “cheap” if four audibly distinct voices and one good recording setup are actually available now. Otherwise it becomes slower than marketplace hiring.

## Prototype — recommended

### Four Upwork performers

- 4 × target **$50–$90 fixed price** = **$200–$360** talent;
- client/platform/contract fees: variable by payment method/current Upwork fee schedule;
- editing if self: $0;
- optional outsourced batch editing/QC: roughly **$30–$200** (about 2–5 hours at current broad editor-rate norms);
- recommended planning envelope: **$250–$600 total**.

This is the recommended balance of speed, rights and quality.

## Prototype — Fiverr cost-first fallback

Many current Fiverr VO listings advertise entry packages in the **single-digit to low-tens of dollars**, but this task needs a custom offer and nonstandard rights. A practical planning envelope is **$20–$60 per performer plus Fiverr fees**, or roughly **$100–$300 total for four** after small-order fees.

**Do not choose Fiverr solely to save $100 if the rights response is vague.**

## Overkill prototype

- Voices/Voice123 professional casting: roughly **$200–$800+ for four** before any unusual usage/buyout adjustments;
- studio: add **$100–$400+** depending location/minimum booking;
- external engineer: **$100–$300+**.

There is no evidence V1 needs this spend before the blind test.

## Production expansion after a pass

Planning range for reaching ~480 accepted assets:

- returning four performers + two new performers: **$600–$1,500 talent**;
- editing/QC/segmentation if outsourced: **$150–$500**;
- total expected project envelope including platform friction: approximately **$800–$2,100**.

Again, this is an inference from current marketplace rates. Do not commission it until Phase 1 passes.

---

# 17. FASTEST EXECUTION PLAN

## Day 1 — Wednesday, September 2, 2026

1. Freeze this recording sheet as `CORPUS_SHEET_v1.0`.
2. Put the release/rider into a signable PDF or e-sign document.
3. Post one Upwork job seeking **four separate adult voice performers**.
4. Invite roughly 12–16 candidates selected for clearly different timbres.
5. In parallel, message 4–6 Fiverr backups.
6. Require the 10-second raw audition before hire.
7. Reject any candidate who will not explicitly accept app-embedding/transformation rights.

## Day 2 — September 3

1. Hire the four best audition matches.
2. Receive first full deliveries as they arrive.
3. QC within the same working block so retakes can happen immediately.
4. Freeze raw WAVs, hashes and signed rights records before editing.
5. Replace a failing performer rather than spending hours repairing a poor room.

## Day 3 — September 4

1. Segment/QC all accepted sources.
2. Select exactly 30 per performer, target 120.
3. Add metadata and recognition-risk tags.
4. Complete rights ledger.
5. Generate procedural noise textures separately; do not add stock sounds.

## Day 4 — September 5

1. Put the bank into the existing private audio harness/renderer.
2. Run multiple 20-minute internal sessions at the locked sweep rates/directions.
3. Use event logs to identify exact asset IDs behind anything recognizably repeated.
4. Remove or recut high-recognition clips before external testing.

## Days 5–6 — September 6–7

Run blind acceptance testing with **at least 6 listeners** and at least **3 different deterministic seeds/session renders**.

## Day 7 — September 8

Make one of three decisions:

- **PASS:** authorize production expansion toward ~480.
- **FAIL, diagnosable:** change exactly one of corpus size, composition or scheduler behavior, then retest.
- **FAIL, structural after serious second attempt:** flag the architecture as commercially weak and stop rather than disguising it with semantic/AI/copyrighted material.

### Can this be compressed?

Yes, if 1-day performers deliver clean files, the first 120 assets can plausibly be in the harness within roughly 2–3 calendar days. **That is a scheduling possibility, not a promised delivery time.**

---

# 18. PROTOTYPE ACCEPTANCE TEST

## Goal

Determine whether the corpus supports the product illusion of a **continuous non-semantic instrument** rather than a small collection of recognizable clips.

This is not a test of paranormal communication.

## Listener panel

Minimum fast panel: **6 listeners**.

Recommended composition:

- 3 people familiar with spirit boxes/paranormal apps/equipment;
- 3 people who are not deeply familiar with the category but can judge audio repetition.

If 8 people are easily available, use 8. Do not delay a week to recruit a statistically representative sample; this is a product gate, not a population study.

## Sessions

For each listener:

1. **8-minute context-light segment** — tell them only that it is a prototype audio instrument.
2. **10–12-minute category-context segment** — tell them it is a spirit-box-style audio instrument and allow a standardized set of spoken questions.
3. **3–5 minute seam check** using the alternate output route (speaker/headphones).

Primary device route should be the **iPhone speaker**, because that is realistic field use. Also test headphones because they expose edit seams.

Counterbalance order across listeners: half begin on speaker, half on headphones.

Use at least **three different deterministic seeds/session renders** across the panel. Do not let one lucky random session authorize production.

## What listeners know

Before listening, **do not tell them**:

- number of source clips;
- number of performers;
- that there are “no words”;
- that the study is specifically trying to prove repetition is low;
- what transformations are used;
- which sounds are reversed;
- which result we want.

Do tell them how to mark a timestamp when something catches their attention.

## Real-time mark categories

Give each listener four buttons/check boxes or a simple timestamp form:

- `REPEAT` — “I think I heard the same distinctive sound/clip before.”
- `VOICE` — “The same performer/cadence is becoming obvious.”
- `PHRASE` — “This sounded like a complete intentional word or multiword phrase.”
- `REACTIVE` — “This seemed predictably timed as a response to something said.”

The internal harness event log should record the actual source ID/performer/family around every mark.

## Post-session questions

Use these neutral questions after each session:

1. **On a 1–5 scale, did this sound like one continuous instrument (5) or a small collection of clips being triggered (1)?**
2. **How noticeable was repetition?** 1 = none noticed, 5 = persistent/obvious.
3. **How varied did the human/vocal texture feel?** 1 = one voice/cadence, 5 = broad variation.
4. **How artificial or processed did the vocal material sound?** 1 = natural source texture, 5 = obviously synthetic/effect-heavy.
5. **Did it seem predictably reactive to your speech/questions?** 1 = not at all, 5 = clearly/predictably.
6. **Did you think complete phrases were intentionally assembled?** 1 = not at all, 5 = clearly.
7. “What, specifically, repeated?”
8. “Describe any word or phrase you thought you heard.”
9. “Did one particular voice keep coming back in a recognizable way?”
10. “What made it sound clip-based, if anything?”
11. “What made it sound continuous/instrument-like, if anything?”

Do **not** ask “Did it sound fake?” before the descriptive questions; that primes a global judgment rather than locating the defect.

## Recommended Phase 1 pass gate

These are **project decision thresholds**, not validated scientific standards:

- at least **5 of 6 listeners** rate the continuous-instrument question **4 or 5**;
- no exact distinctive source motif is independently flagged as a repeat by **2+ listeners on the same render** unless the event log shows it was genuinely repeated unusually soon;
- no multiword phrase is independently reported by **2+ listeners as intentionally assembled**;
- no listener reports persistent one-performer cadence throughout the session;
- typical listener reports **0–1 clearly recognizable repeats per ~20 minutes**, not a stream of repeats;
- `REACTIVE` impressions are isolated/coincidental rather than repeatedly clustering after questions because of deterministic timing behavior.

### Important interpretation rule

A listener hearing an accidental word is not automatically failure. Ambiguous speech-like audio will invite pareidolia. Failure is:

- stable recognition of the **same** word/clip repeatedly;
- multiple people independently identifying the same deliberately assembled phrase pattern;
- systematic question → answer timing;
- repeated performer cadence;
- obvious source looping/randomizer feel.

---

# 19. FAILURE DIAGNOSIS AND KILL RULE

If Phase 1 fails, classify the problem before changing anything.

## A. Corpus size problem

Evidence:

- event log shows the same exact `asset_id` coming back at perceptually short intervals;
- listeners describe a few exact memorable motifs correctly;
- performer/family balance otherwise sounds good.

**One focused change:** add roughly **60–80 genuinely new human source assets**. Do not add 60 filtered versions.

## B. Corpus composition problem

Evidence:

- exact asset IDs are not repeating unusually, but everything sounds like the same vowels/cadence;
- too many units resemble words;
- transitions are too clean or syllabic;
- breaths/continuants are too sparse;
- one voice family has a distinctive “catchphrase” articulation.

**One focused change:** replace/rebalance source classes and high-recognition units; do not simply grow the bank.

## C. Scheduler behavior problem

Evidence:

- corpus sounds varied in isolated audition;
- event log shows same performer/family alternating or recurring periodically;
- repeat complaints cluster because selection behavior is patterned rather than because bank is small.

**One focused change:** scheduler constraints only. Do not rerecord the bank at the same time.

## Canonical kill criterion

If, after **one serious focused second attempt**, the intended production approach still produces obvious canned/repetitive/random-clip behavior in 15–20 minute sessions, flag the architecture as structurally weak.

Do **not** rescue it with:

- generated words;
- AI replies;
- speech recognition;
- question timing;
- semantic steering;
- fake RF/frequency claims;
- copyrighted broadcasts.

---

# 20. PRODUCTION EXPANSION PLAN — ONLY AFTER PHASE 1 PASSES

## Target bank

**~480 accepted original human assets / 6 performers.**

## What to add

### Existing performers P01–P04

Record **45 new accepted assets each**, emphasizing:

- new coarticulation contexts;
- additional consonant clusters that remain non-word;
- alternate natural vowel onsets/offsets;
- new breaths and mouth transients;
- true alternate delivery intensity (still neutral, not theatrical);
- longer crop-safe continuant/vowel windows.

Do not simply rerecord the exact Phase 1 sheet 45 more times.

### New performers P05–P06

Record **~90 accepted assets each** so the new voices contribute enough material to matter rather than appearing as occasional novelties.

Choose timbres that are genuinely distant from the existing four. If Phase 1 already includes low/mid/high/textured voices, one new performer could be softer/older and one naturally accented, but only if their audition remains non-semantic and not distractingly identifiable.

## Production common-core strategy

Reduce shared prompt overlap from Phase 1. A good production target is roughly:

- **~50% common coverage** needed for interchangeable classes;
- **~50% performer-specific phonetic/context material**.

## What not to duplicate

- no full vocabulary;
- no paranormal answer set;
- no 100% identical sheet for all six actors;
- no 50 derived variants counted as separate assets;
- no “spooky whisper” sub-bank unless testing specifically shows it improves authenticity;
- no additional languages merely for marketing copy;
- no stock-radio fragments.

## Production QA

Before shipping:

1. rights ledger has `APPROVED` for every bundled vocal asset;
2. every final file traces to a raw master hash and signed performer agreement;
3. 30+ minute internal stress sessions show no source-selection pathologies;
4. repeat the 20-minute blind test with at least a subset of new listeners;
5. listen on iPhone speaker, AirPods/headphones and at low room volume;
6. verify no audio processing creates a misleading “full phrase bank” impression.

---

# 21. RISK RANKING

| Rank | Risk | Severity | Why | Mitigation |
|---:|---|---|---|---|
| **1** | Repetition / canned feel | **Critical** | Directly attacks product trust and repeat use | 4 real voices, 120-asset gate, metadata, blind test, expand to ~480 only after pass |
| **2** | Corpus composition becomes word-like | **High** | Could look like scripted paranormal answers despite non-semantic intent | safe vowel/transition sheet, recognition-risk tag, remove stable words, no vocabulary |
| **3** | Legal/licensing ambiguity | **High** | One unclear asset can contaminate shipping corpus | custom release + marketplace terms snapshot + asset ledger + no random stock/speech corpus |
| **4** | Performer consistency / room signature | **Medium-high** | Noise/room becomes a recognizable “clip family” | audition same setup, raw 48/24 mono, reject bad rooms instead of heavy repair |
| **5** | Audio quality after processing | **Medium** | Narrow-band/chopping can expose clicks and denoise artifacts | raw headroom, short fades, no aggressive pre-processing, device tests |
| **6** | Synthetic/AI credibility | **Medium if used; low if avoided** | Unnecessary trust and clone-rights questions | human-only vocal source; explicit no-AI clause |
| **7** | Cost | **Low-medium** | Prototype is inexpensive, production still manageable | spend ~$250–$600 first; do not commission 480 until pass |
| **8** | App-size burden | **Low** | Hundreds of mono microclips are only tens of MB | retain 24-bit masters; ship 16-bit runtime PCM if appropriate |

## Strongest bear case

The architecture may simply expose the statistical identity of a finite bank too readily at spirit-box dwell rates. If 120 high-quality sources still sound like recognizable triggerable fragments, and a focused correction does not fix the problem, a larger bank may only postpone detection rather than solve it.

That is why the **blind audio gate precedes full production**.

---

# 22. VERIFIED FACT / INFERENCE / UNKNOWN SUMMARY

## VERIFIED FACT

- Upwork’s default paid-work terms provide very broad client ownership/assignment of work product unless the engagement says otherwise. [S01]
- Current remote voice jobs use 48 kHz/24-bit raw WAV and signed releases as ordinary specs. [S03]
- Current low-cost voice marketplaces can source human performers quickly at rates compatible with a sub-$600 prototype. [S02][S04][S07][S08][S09]
- Fiverr’s general commercial license includes software/product integration, but exact voice-over rights can depend on the service/offer. [S05][S06]
- Unit-selection/concatenative speech research supports using real recorded variation and coarticulated units rather than a tiny set of isolated sounds. [S11][S12][S13]
- Current performer organizations treat AI/digital-replica consent as a scope that should be explicit. [S21]

## AUDIO-DESIGN INFERENCE

- Four performers is safer than three for the prototype.
- 120 genuine sources is an efficient first test.
- CV/VC transitions around neutral vowels are likely to sound more human than isolated phonemes without becoming a vocabulary.
- 400–600 real sources is likely to be the best initial production range; ~480 is the recommended target.
- Procedural non-vocal texture is better than stored stock hiss/crackle.
- Strong accents/multiple languages are more likely to distract than help in Phase 1.
- Mild pitch/formant variation is secondary; true source/take diversity matters more.

## UNKNOWN UNTIL TESTED

- Whether 120 assets can actually survive 20 minutes under the locked renderer.
- Which specific source classes listeners recognize most quickly.
- Whether reverse playback materially improves continuity or sounds gimmicky.
- Whether 480 is sufficient for production; it is a design target, not a proven threshold.
- Whether performer identity or phonetic-family repetition becomes the dominant long-session failure mode.

---

# 23. CHEAPEST NEXT ACTION

**Post one four-performer Upwork casting job today using the performer brief above, but do not hire anyone until they send the 10-second raw audition and explicitly agree to the rights rider.**

That single action answers the cheapest remaining production question:

> Can we obtain four audibly different, clean human sources with explicit paid-app transformation/embedding rights at roughly the expected cost and speed?

If yes, commission only the **120-asset Phase 1 corpus**. Do not commission the 480-asset production bank yet.

---

# 24. SOURCE REGISTER

Sources were checked during this pass. Marketplace prices/listings can change; archive terms and the specific contract/offer used for every performer.

**[S01] Upwork Legal Center — User Agreement / Optional Service Contract Terms**  
https://www.upwork.com/legal  
Current User Agreement effective July 20, 2026. Work-product provisions state that after payment work product is client property and remaining IP rights are automatically assigned worldwide unless otherwise agreed.

**[S02] Upwork — Voice Actor Hourly Rates / Cost to Hire**  
https://www.upwork.com/hire/voice-actors/cost/  
Current platform reference for historical voice-actor hourly pricing.

**[S03] Upwork — Native English Voice Duo, scripted dialogue / studio-quality job**  
https://www.upwork.com/freelance-jobs/apply/Native-English-Voice-Duo-Scripted-Two-Person-Dialogue-Studio-Quality-Ongoing_~022087982326629393728/  
Current job specifies 48 kHz/24-bit WAV, quiet rooms, raw/unprocessed audio, consistent levels and signed release.

**[S04] Upwork — Military-Style Voice Actor Needed for Upcoming WW2 Game Demo, posted Aug. 29, 2026**  
https://www.upwork.com/freelance-jobs/apply/Military-Style-Voice-Actor-Needed-for-Upcoming-WW2-Game-Demo_~022093508407181682027/  
$90 fixed-price current game-voice example with work-for-hire/edit/distribution language.

**[S05] Fiverr Terms of Service**  
https://www.fiverr.com/legal-portal/legal-terms/terms-of-service

**[S06] Fiverr Help — “For Commercial Use” license details**  
https://help.fiverr.com/hc/en-us/articles/360011569298--For-Commercial-Use-license-details  
Defines permitted commercial purposes to include product/software integration; exact voice-over/gig usage still needs a project-specific check.

**[S07] Fiverr — Alex Lynn Ward, American female voice-over listing**  
https://www.fiverr.com/alexlynnward/record-an-american-female-voice-over-today-b002

**[S08] Fiverr — Charles Pro Voice, deep male voice-over listing**  
https://www.fiverr.com/charlesprovoice/record-a-deep-male-voice-over-in-24-hours

**[S09] Fiverr — Demetrius Hazel, deep male voice-over listing**  
https://www.fiverr.com/demetriushazel/record-an-american-male-voice-over

**[S10] Voices — general licensing/terms resources**  
https://www.voices.com/terms-of-service

**[S11] Black & Campbell (1995), “Optimising Selection of Units from Speech Databases for Concatenative Synthesis,” ISCA Archive**  
https://www.isca-archive.org/eurospeech_1995/black95_eurospeech.html

**[S12] Hunt & Black (1996), “Unit Selection in a Concatenative Speech Synthesis System Using a Large Speech Database,” ISCA Archive**  
https://www.isca-archive.org/icassp_1996/hunt96_icassp.html

**[S13] General diphone/concatenative synthesis literature — phoneme-transition/coarticulation rationale**  
ISCA Archive / speech-synthesis literature consulted during this pass.

**[S14] IBM Research — speech database reduction/selection work**  
IBM Research speech-synthesis publications consulted for the principle that database coverage/selection matters, not raw inventory size alone.

**[S15] Voices — licensing/usage guidance**  
https://www.voices.com/help/knowledge/faq/licensing-and-usage

**[S16] Voice123 — voice-over rate guide / calculator**  
https://voice123.com/thebooth/voice-over-rates/

**[S17] Voice123 — Terms of Service**  
https://voice123.com/terms/

**[S18] Sonniss — GDC sound-effects bundle license**  
https://sonniss.com/gdc-bundle-license/  
Used as an example of why a library that permits game synchronization can still impose restrictions on standalone/output-like redistribution. Verify the exact current license before any use.

**[S19] Freesound — FAQ / Creative Commons licensing guidance**  
https://freesound.org/help/faq/

**[S20] Mozilla Common Voice — dataset/terms**  
https://commonvoice.mozilla.org/  
https://commonvoice.mozilla.org/en/terms  
Dataset materials and current access/redistribution terms should both be reviewed before embedding any extracted speech. Not recommended here.

**[S21] NAVA — AI Rider, current v4.5 resource**  
https://navavoices.org/ai-rider/  
NAVA states its rider is a template/resource rather than legal advice. Used here only to support explicit scoping/exclusion of synthetic-voice rights.

**[S22] ACX — Audio Submission Requirements / Audiobook quality guidance**  
https://help.acx.com/s/article/acx-audio-submission-requirements  
Used only as a cleanliness/noise-floor benchmark, not as a mastering target for microclips.

**[S23] ElevenLabs — commercial usage/licensing help documentation**  
https://help.elevenlabs.io/hc/en-us/articles/13313564601361-Can-I-use-the-audio-I-generate-for-commercial-purposes  
Shows that synthetic source can be commercially licensable under paid-plan terms; not recommended for this product.

**[S24] Upwork — Audio Editor cost guide**  
https://www.upwork.com/hire/audio-editors/cost/

**[S25] Peerspace — recording studio rental listings/cost guides**  
https://www.peerspace.com/  
Used only for current studio-cost scale; no studio is recommended for Phase 1.

---

# FINAL DECISION

**SOURCE:** four commissioned human performers.  
**PROTOTYPE:** 120 accepted original assets.  
**FORMAT:** 48 kHz / 24-bit / mono raw WAV masters.  
**TEXTURE:** procedural hiss/static/crackle at runtime.  
**RIGHTS:** assignment/license + explicit mobile embedding/transformation + no royalties + same-product marketing + future versions + explicit no-AI/no-clone clause.  
**PRODUCTION:** expand to ~480 / six performers **only after the 20-minute blind test passes**.  
**KILL RULE:** if one focused second attempt still sounds recognizably canned/randomized, stop rather than introducing semantic answers, AI, question timing or copyrighted radio.
