# 00 — SPIRIT BOX PRODUCT SOURCE OF TRUTH

**Status:** CONDITIONAL BUILD — not BUILD AUTHORIZED  
**Date:** September 2, 2026  
**Revalidated:** September 10, 2026  
**Platform:** iPhone first  
**Canonical role:** This document is the final product, positioning, design, monetization, and V1 implementation source of truth.

> **Precedence rule:** If this file conflicts with any earlier plan or research document, **this file wins**.  
> **Evidence ledger:** `docs/research/RESEARCH-REVALIDATION-2026-09-10.md` records why prior BUILD AUTHORIZED / metadata-only / $9K / clean-slate WPPNT claims were demoted.

Supporting evidence documents:
- `docs/research/RESEARCH-REVALIDATION-2026-09-10.md` — current commercial/ASO/audio revalidation
- `docs/research/GHOST-HUNTER-UI-AUDIENCE-DEEP-DIVE.md` — UI/interaction evidence (positioning updated by revalidation)
- `docs/research/GHOST-APP-FAILURE-FORENSICS-AND-COMPETITIVE-WHITE-SPACE.md` — competitive forensics
- `docs/research/SPIRIT-BOX-AUDIO-ENGINE-DECISION.md` — current audio decision (reopened; not permanently locked)
- `docs/research/SPIRIT-BOX-AUDIO-RENDERER-RESEARCH.md` — renderer experiments
- `docs/launch/APP-STORE-CONVERSION-AND-ASO-PLAYBOOK.md` — ASO after cold-start correction
- `docs/launch/GHOST-SPIRIT-BOX-FIRST-USERS-ACQUISITION-PLAN.md` — required seeding funnel
- `docs/launch/INDIE-IOS-ASO-ZERO-AUDIENCE-LAUNCH-OPERATING-SYSTEM.md` — ASO process mechanics

Do not treat September 2 conclusions as frozen. Reopen a decision only with new evidence that beats the 2026-09-10 ledger.

---

# 1. EXECUTIVE PRODUCT DECISION

**Commercial thesis:** There is real App Store search intent for `spirit box`, and the current #1 listing is a weak, paywalled clone-mill product. That is **not** proof that a founder with no audience can sit on metadata and collect those users.

**Acquisition thesis:** Become eligible for exact-intent queries with truthful metadata, **import the first 100–500 real users** through targeted investigator/micro-creator seeding (not a content career), convert them with a real trial and honest audio, then use downloads/ratings/behavior — which Apple actually names as ranking inputs — to attempt a rank climb.

**Audience:** People who want a pocket spirit-box **session** (hobbyist believers first; hardware investigators as the authenticity bar). Not tarot/astrology users.

**Positioning:** Accessible paranormal **field instrument** — dark, atmospheric, one-thumb, easy to start. Not a male-coded hardware replica, not a witchy lifestyle app, not a horror game.

**Audio architecture (current, reopenable):** Offline licensed **human-speech fragment** sweep (VCTK Phase 1 candidate) with radio-like static and intermittent recognizable shards. Non-semantic. No live internet radio in V1.

**Product wedge:** Still **START → LISTEN → MARK → REPLAY**, but **convincing sweep audio + real trial + no weekly paywall** outrank MARK as the reason the product deserves to exist. MARK remains the listing story versus the current #1.

**Pricing:** Unchanged hypothesis — complete free session, then **$1.99 Tonight Pass** or **$9.99 lifetime**. No ads, no auto-renewing subscription.

**ASO:** Indexing via title/subtitle/keywords; ranking via behavior after seeding; conversion via instrument screenshots. Metadata-only bootstrap is **rejected**.

**Launch:** Required seeding funnel in the acquisition plan. Optional tiny Apple Ads only as a measurement tool.

**Remaining gates:** (1) 60–90s audio A/B then 15–20 min human gate; (2) TestFlight with 20–50 target testers; (3) launch seeding plan staffed before release.

**Exact next action:** Run the smallest audio disproof test in the audio decision doc. Do not commission performers and do not polish App Store creative until that test has a winner.

**Kill criteria:** Section 26.

We are **not** building a paranormal super-app. V1 still does one job:

> **START → LISTEN → MARK → REPLAY**

Still true:

- no account, no backend, no AI, no generated answers, no fake RF claims, no SB7/P-SB7 imitation.

---

# 2. COMMERCIAL THESIS

## 2.1 Why this is only a CONDITIONAL BUILD

**VERIFIED FACT:** On 2026-09-10, iTunes Search still returns **Spirit Box SBX Ghost Talker** (2.86★ / 49 ratings, May 2026) at #1 for `spirit box`.

**VERIFIED FACT:** Apple ranks using text relevance **and** user behavior (downloads, ratings, reviews, and more).

**VERIFIED FACT:** Multiple 2026 apps with `Spirit Box` in the title have 0–16 ratings and do **not** occupy that #1 slot (Jacob Weeces #12 / 4 ratings; SpectraBox 0 ratings; others absent from the top 15).

**INFERENCE:** Demand-shaped intent exists. **Accessible** demand for a new unknown listing does not.

**NOT VERIFIED:** The older “~$9K/month RevenueCat” line for the May leader. Public estimates in that range attach more credibly to **Spirit Talker (Spotted Ghosts)**, a different app. Treat WPPNT revenue as **UNKNOWN**.

**NOT PROVEN:** That WPPNT climbed on metadata alone. Ewregu already shipped adjacent paranormal (and unrelated utility/game) apps. WPPNT LTD (UK) is **dissolved** (5 Aug 2025) while Apple still shows that seller name.

We continue because: exact intent is still typed; the #1 product is hated for paywall and fake/repeated audio; a solo offline app is cheap to finish **if** audio passes; the founder will do bounded launch seeding.

We do **not** continue because success is demonstrated.

## 2.2 What is not a unique differentiator

Recording, replay, no ads, no subscription, offline, EMF, “pro UI,” and even tagging exist in some form (GhostTube EVP, SpectraBox, 2026 clones).

The remaining stack that can still convert against the current #1:

> **A disclosed offline sweep that actually sounds like interrupted radio speech, a complete free session, MARK → exact replay, and no weekly ambush.**

## 2.3 Why it could work

- Searchers still type `spirit box` and land on a 2.9★ paywall.
- Category buyers already pay $4.99–$9.99 when they trust the session (Necrophonic, GhostTube, Bello).
- Solo, offline, no backend.
- Seeding 100–500 users is operationally small compared with “become a YouTuber.”

## 2.4 Why it could fail (take these seriously)

- AppTweak’s historical **94.425** keyword-attributed installs (period unspecified) may mean the head term is **economically thin**.
- Seeding may fail because qualified investigators refuse phone apps.
- Audio may never sound like a box without live radio (which V1 will not ship).
- Halloween may be the only real demand pulse.
- A clone can copy MARK/trial in weeks.

If those hit, **KILL** — do not add marketing theater.

---

# 3. TARGET AUDIENCE

## Primary — Paranormal hobbyist / believer

Someone who actively enjoys paranormal investigation or ITC/spirit-box experimentation but does not necessarily own a large hardware kit.

What they want:

- a convincing session;
- simple controls;
- believable audio behavior;
- an instrument rather than a game;
- recording and review;
- no ads;
- no manipulative subscription;
- a mechanism they can understand;
- something they can keep on their phone and use anywhere.

This is the design center.

## Secondary — Serious investigator / hardware user

Someone familiar with real spirit boxes, EVP recorders, EMF meters, sweep rates, and investigation workflows.

Their likely job:

> “Give me a credible pocket backup / secondary instrument when I do not have or do not want to carry dedicated hardware.”

They care disproportionately about:

- control semantics;
- repeatability;
- dark-room operation;
- audio quality;
- truthful technical language;
- recording persistence;
- export;
- no fake sensor/scientific claims.

We do not need to convince every hardware purist that a phone equals a physical RF device. We need the product to be useful enough that some serious users will keep it as an additional tool.

## Tertiary — Curious / one-night user

Typical contexts:

- Halloween;
- sleepovers;
- hotels;
- ghost tours;
- road trips;
- abandoned/historic places;
- a night with friends;
- casual curiosity.

They want:

- immediate fun;
- no learning curve;
- no $10–$30 commitment just to try it;
- no subscription trap.

This segment is why the **$1.99 Tonight Pass** exists.

## Not the design center — Paranormal creator ecosystem user

Do not optimize V1 around:

- SLS video;
- creator overlays;
- haunted-location databases;
- community evidence feeds;
- social content production;
- AI-generated imagery.

GhostTube is structurally stronger there.

---

# 4. PRODUCT POSITIONING

## One-sentence positioning

> **An accessible pocket spirit-box instrument: start a sweep that sounds like interrupted radio speech, mark what catches your ear, and replay the exact moment — offline, with no generated answers, ads, or weekly subscription.**

Visual tone: dark, atmospheric, high-contrast, one-thumb. **Not** a hardware-replica flex and **not** occult-lifestyle. Women are more likely than men to report ghost/paranormal belief in 2025 Gallup/YouGov data; that is a conversion reason to avoid excluding them, not a reason to become a witch app.

## Category promise

The user should understand in less than one second:

> “This is a spirit box I can use right now.”

## What we are competing against

Most directly:

- Spirit Box SBX Ghost Talker / WPPNT;
- GhostTube VOX as an adjacent audio substitute;
- Necrophonic;
- Bello's live-radio spirit-box products;
- SpectraBox and other transparent recorded-session tools.

## What we are deliberately NOT competing against

GhostTube's strongest territory:

- SLS;
- creator/video workflow;
- community;
- haunted locations;
- AI interpretation;
- broad paranormal toolkits;
- multi-app ecosystem;
- creator-led audience/distribution.

---

# 5. ONE MAIN FEATURE

## The Spirit-Box Session

The product is one instrument.

Core loop:

1. Open the app.
2. Start the sweep.
3. Listen / ask questions if desired.
4. Adjust sweep rate or direction.
5. Start recording if desired.
6. Tap **MARK** whenever something catches the user's ear.
7. Stop the session.
8. Replay the recording.
9. Jump directly between marked moments.
10. Export the original recording if desired.

Everything in V1 must strengthen this loop.

If a feature does not materially improve:

- App Store conversion;
- paid conversion;
- session quality;
- review quality;
- retention;
- trust;

it does not belong in V1.

---

# 6. FINAL AUDIO ARCHITECTURE

## Decision (reopened 2026-09-10 — current, not permanently locked)

Use:

> **Offline licensed human-speech fragments (large corpus, currently VCTK) + continuous radio-like static + a non-semantic sweep renderer that allows intermittent recognizable shards.**

This is architecture **C/G** in the revalidation ledger, not the old isolated-phoneme “never hear a word” doctrine.

Do not build live internet radio in V1 (Apple 5.2.3 + rights + offline investigations).

Do not build fully synthetic/procedural speech-like generation as the V1 hero (SpectraBox already owns that honesty story; it is a weak “old box” sound).

Do not commission a four-performer corpus until a small renderer A/B on **existing** VCTK material fails for **source quality**, not scheduling.

## 6.1 Source material

The bank should contain:

- short original/licensed vocal fragments;
- consonants and vowels;
- partial phonetic fragments;
- breaths and non-verbal vocal texture;
- reverse fragments;
- filtered noise;
- static/radio-like texture.

Do not store scripted paranormal responses.

Do not construct a vocabulary intended to generate common answers.

Do not use competitor audio.

Do not sample:

- terrestrial/internet radio;
- YouTube;
- podcasts;
- movies/TV;
- unclear commercial voice libraries;
- copyrighted material without explicit app-distribution rights.

Maintain an internal source-rights ledger for every audio asset.

**Current Phase-1 candidate (September 2026):** a **1,200-asset VCTK-derived licensed speech corpus** (see `docs/production/VCTK-PHASE1-CANDIDATE.md`). Isolated-phoneme-heavy mixes are superseded. **Intermittent recognizable fragments in the rendered sweep are desirable** (that is how physical boxes sound). **Scripted answers, question-timed output, and repeated canned phrases are defects.** Renderer experiments: `docs/research/SPIRIT-BOX-AUDIO-RENDERER-RESEARCH.md`. Next test: smallest A/B in `docs/research/SPIRIT-BOX-AUDIO-ENGINE-DECISION.md`.

## 6.2 Scheduler behavior

The sweep scheduler must be **non-semantic**.

It must never use:

- speech recognition;
- question timing;
- microphone content;
- transcripts;
- keywords;
- sensor values;
- user location;
- time since the user spoke;
- an internal “response” state;
- AI;
- generated text.

The engine should:

- continuously traverse source material;
- make sweep rate audibly meaningful;
- make forward/reverse audibly meaningful;
- vary start offsets and bounded processing;
- enforce anti-repetition windows;
- avoid adjacent clips from the same voice/register family;
- allow long stretches with nothing interpretable;
- avoid obvious full words/sentences when possible.

## 6.3 Initial sweep rates

Prototype:

- 75 ms
- 125 ms
- 200 ms
- 300 ms

Final shipping values should be selected from listening tests, not because a physical competitor uses specific numbers.

`200 ms` is the recommended initial default.

## 6.4 V1 has one audio mode

Ship one carefully tuned:

**SWEEP**

Do not add:

- AM mode;
- FM mode;
- “radio mode”;
- reverb mode;
- echo mode;
- DR60 mode;
- white-noise mode;
- eight sound banks;
- themes.

A later **Audio Profile** experiment is allowed only after launch data justifies it.

---

# 7. TRUTHFUL TERMINOLOGY

Because V1 is not tuning RF or live radio, the UI and App Store metadata must never pretend that it is.

## Allowed terms

- Spirit Box
- Sweep
- Start Scan / Stop
- Sweep Rate
- Forward / Reverse
- Source Position
- Session
- Record
- MARK
- Session Replay
- Audio Profile — only if a future second profile actually exists
- Offline
- Vocal fragments
- Noise textures

## Do not use in V1

- AM
- FM
- MHz
- kHz
- station
- channel
- frequency
- tuner
- RF
- airwaves
- broadcast
- live radio
- “real radio”
- “radio scan”
- fake frequency numbers

Also do not claim:

- “not prerecorded” — the source fragments are preloaded;
- “ghost detected”;
- “entity detected”;
- “spirit response”;
- “answer”;
- “message”;
- “evidence”;
- “proof”;
- scientifically verified paranormal detection.

---

# 8. UI / VISUAL DIRECTION

## Design direction: FIELD INSTRUMENT

The interface should feel like:

> **Old-school paranormal field-equipment semantics + modern iPhone execution.**

Not a literal radio replica.

Not a generic SwiftUI utility.

Not a horror game.

## 8.1 Material language

Use:

- matte near-black / graphite surface;
- recessed dark display area;
- warm amber-red / red-orange illumination;
- off-white/light-gray labels;
- subtle bevel/recess on important controls;
- restrained glow only around active display/status elements;
- modern spacing and typography;
- tabular/monospaced numbers in the instrument display.

Avoid:

- purple occult gradients;
- neon cyan/magenta;
- fake scratched metal;
- fake screws;
- fake speaker grilles;
- wood/leather;
- skulls;
- pentagrams;
- Ouija imagery;
- ghost silhouettes;
- smoke;
- VHS horror;
- jump scares;
- cartoon haunted-house treatment.

## 8.2 Skeuomorphism

Use **moderate skeuomorphism**.

Controls should look physical enough that the user understands they are fixed instrument controls.

But the screen must not look like:

- a photograph of hardware;
- an SB7 clone;
- an SBox clone;
- a specific commercial device.

The user should identify the category, not a manufacturer.

---

# 9. EXACT MAIN-SCREEN V1

Portrait. No scrolling during an active session.

Suggested hierarchy:

```text
┌────────────────────────────────────┐
│ SESSION 00:07:42        REC 00:03:11│
│                                    │
│  ┌──────────────────────────────┐  │
│  │       FORWARD     200 ms     │  │
│  │                              │  │
│  │       ▸ ▸ ▸ ▸ ▸ ▸            │  │
│  │       SOURCE POSITION        │  │
│  │                              │  │
│  └──────────────────────────────┘  │
│                                    │
│      [ REVERSE ]   [ RATE − + ]   │
│                                    │
│ [  REC  ] [       MARK       ]     │
│                                    │
│              [ POWER ]             │
│                                    │
│              SESSIONS              │
└────────────────────────────────────┘
```

This is structural guidance, not pixel-perfect final art.

## 9.1 Display

Show:

- powered/off state;
- sweep animation;
- direction;
- sweep rate;
- session elapsed time;
- recording state/time when recording;
- marker count when useful.

Do not show a fake radio frequency.

`SOURCE POSITION` can be visually abstract rather than a literal number if a number feels too technical or misleading.

## 9.2 POWER

- visually separated from REC and MARK;
- distinct physical-looking control;
- power-on begins the sweep immediately;
- power-off should require a short hold to prevent accidental termination;
- if recording is active, power-off first finalizes and saves the recording.

## 9.3 FORWARD / REVERSE

A two-state control.

Do not hide direction in settings.

The change must produce an immediate audible and visual difference.

## 9.4 SWEEP RATE

Use discrete detents, not a precision slider.

- `RATE −`
- current value
- `RATE +`

Haptic tick on each detent.

## 9.5 REC

Visible at all times.

When active:

- clear red status lamp;
- clear `REC` state;
- elapsed record time;
- layout does not shift.

Microphone permission is requested only after the user explicitly taps REC.

## 9.6 MARK

The most important session control.

Requirements:

- widest/easiest thumb target;
- works without looking;
- no modal;
- no audible beep;
- instantly saves a timestamp;
- marker count updates;
- distinctive haptic when allowed.

MARK does not mean:

- ghost;
- answer;
- evidence;
- anomaly.

It means only:

> “The user wanted to revisit this moment.”

## 9.7 SESSIONS

A quiet navigation control to local session history.

No dashboard/home grid.

Launch should land directly on the instrument.

---

# 10. DARK-ROOM / ONE-THUMB RULES

- Fixed control locations.
- No swipe-only core actions.
- MARK reachable with one thumb.
- REC and POWER physically separated.
- No tiny buttons.
- No mode carousel.
- No scrolling during session.
- No bright white full-screen flashes.
- Keep the screen readable without destroying dark adaptation.
- Do not move controls when REC starts.
- Core controls use text labels, not mystery icons.
- Headphones must work through normal iOS audio routing.

The user should be able to:

- start;
- change rate;
- reverse;
- record;
- mark;
- stop;

without reading a manual.

---

# 11. HAPTIC LANGUAGE

Haptics are a first-class product layer.

Their purpose is:

> **Make the iPhone controls feel mechanical.**

Their purpose is NOT to manufacture paranormal events.

Provide a global **Instrument Haptics** setting.

## 11.1 Default ON

### Power On

Pattern:

- crisp medium transient;
- short pause;
- lighter confirming transient.

Feel:

> switch click → instrument wakes.

### Power Off

One rounded medium pulse with slightly longer decay.

### Sweep Rate Change

One light crisp detent per step.

### Direction Change

One light selection tick.

### Record Start

Firm haptic immediately **before** the microphone recording boundary starts.

### Record Stop

Firm haptic **after** the recording has finalized.

### MARK

Distinct double transient.

This should be the most recognizable session haptic.

However, it must survive the recording-contamination test in Section 18.

## 11.2 Default OFF

### Tactile Scan

Optional experimental micro-ticks linked to scan activity.

If ever shipped:

- very low intensity;
- hard-capped;
- never at the actual sweep frequency;
- disabled while recording by default.

### Magnetic Event

Not in V1 because the magnetometer feature is not in V1.

## 11.3 Never implement

- random “ghost detected” vibrations;
- haptic on every audio fragment;
- continuous rumble;
- escalating horror vibrations;
- haptic “entity types”;
- haptics during replay;
- repeated alerts pretending that a sensor reading is paranormal.

---

# 12. RECORDING / MARK / REPLAY

Recording is table stakes.

**MARK-centered replay is the hero workflow.**

## 12.1 Recording

Recording is optional.

When the user taps REC:

- request microphone permission if necessary;
- begin capturing the actual session;
- record the user’s spoken questions/environment plus the final sweep experience as implemented;
- save locally;
- show clear recording state.

No microphone permission at app launch.

No microphone analysis when not recording.

No speech recognition.

## 12.2 MARK

During recording:

- tap MARK;
- save exact timestamp;
- no dialog;
- no beep;
- visual confirmation;
- haptic if clean enough.

If MARK haptic creates audible/mechanical artifacts in recordings, disable it while recording and keep only visual confirmation.

## 12.3 Session finalization

If the user:

- stops REC;
- powers off;
- leaves the session normally;

the recording must finalize safely.

Never silently discard an active recording.

## 12.4 Session history

Each session row contains:

- date/time;
- duration;
- number of marks.

No AI-generated title.

No generated paranormal interpretation.

## 12.5 Replay

Replay must include:

- waveform;
- play/pause;
- scrubber;
- visible MARK ticks;
- previous MARK;
- next MARK;
- current time / total duration;
- system Share/Export;
- delete with confirmation.

The key experience is:

> “I heard something → I marked it → now I am instantly back at that exact moment.”

## 12.6 Recording ownership

Recordings stay usable even after:

- the free trial ends;
- the Tonight Pass expires.

Do not hold the user's existing recordings hostage behind the paywall.

Paid access controls the ability to start new full sessions, not ownership of already-created local recordings.

---

# 13. TRUST / HOW IT WORKS

Trust is part of the product.

Do not oversell paranormal efficacy.

## First-run explanation

Use a single compact first-run card, not an onboarding carousel.

Recommended copy:

> **How Sweep works**  
> Sweep plays and moves through an on-device collection of short vocal fragments and noise textures. It does not use radio reception, live streams, speech recognition, or generated answers. You decide what you hear; MARK saves a timestamp to review later.

Then land on the powered-off instrument.

## Recording permission copy

> **Microphone**  
> Recording is optional. When you press REC, the microphone captures your session so you can replay it later. Sweep does not analyze what you say or use your questions to choose sounds.

## Product disclaimer

> **Experimental tool**  
> Paranormal communication has not been scientifically established. This app is designed for spirit-box / ITC experimentation and entertainment. Interpret what you hear for yourself.

## Privacy / offline copy

If implementation remains fully local as intended:

> **Private by design**  
> The sweep runs on-device. Your session recordings stay on this iPhone unless you choose to share them.

Do not claim this until implementation and analytics SDK behavior have been verified.

## What not to say

Never use:

- 100% real ghost detection;
- scientifically proven;
- professional ghost detector;
- spirits control this app;
- real paranormal responses;
- entity detected;
- evidence captured.

---

# 14. V1 FEATURE SCOPE

## MUST SHIP

### Core instrument
- offline audio/phoneme-bank sweep engine;
- power/start/stop;
- forward/reverse;
- discrete sweep-rate control;
- sweep activity display;
- session timer.

### Session capture
- local recording;
- MARK timestamps;
- safe recording finalization;
- session history;
- waveform replay;
- next/previous MARK;
- local export/share.

### Feel
- field-instrument UI;
- dark-room readability;
- one-thumb operation;
- Core Haptics implementation;
- headphones / standard iOS audio routing.

### Trust
- first-run How Sweep Works card;
- microphone explanation;
- privacy explanation;
- paranormal disclaimer.

### Commerce
- real free trial;
- paywall only after actual use;
- Tonight Pass;
- Lifetime;
- purchase restore;
- entitlement persistence;
- purchase analytics.

### Quality
- anti-repetition logic;
- interruption handling;
- audio-route changes;
- recording persistence;
- graceful permission denial;
- no-loss session handling.

## EXPLICITLY OUT OF V1

- AM/FM modes;
- fake frequencies;
- live internet radio;
- multiple sound banks exposed as user modes;
- procedural AI/generated speech;
- generated words;
- ghost dictionary;
- chatbot;
- AI interpretation;
- transcript;
- auto-EVP detection;
- SLS;
- LiDAR;
- AR ghosts;
- camera filters;
- ghost radar;
- haunted-location map;
- community;
- social feed;
- accounts;
- cloud sync;
- backend;
- flashlight;
- temperature;
- magnetometer/“EMF” meter;
- echo/reverb/distortion mixer;
- waveform editing suite;
- playback-speed tools;
- marker notes;
- themes/skins;
- subscriptions;
- ads.

If someone wants to add one of these during development, this document says **NO** unless new evidence is presented and the product owner explicitly changes the canonical source of truth.

---

# 15. PRICING / PAYWALL

Pricing is an initial experiment.

## 15.1 Free download

The App Store download is free.

The user must be able to experience the real product before paying.

## 15.2 Free trial session

Initial V1:

> **One complete 3-minute session.**

The trial includes:

- real sweep audio;
- sweep-rate control;
- forward/reverse;
- recording;
- MARK;
- replay.

Do not give the user a fake demo or crippled audio.

After the free session, they can still replay/export that session.

Starting another full session requires paid access.

## 15.3 Tonight Pass — $1.99

Initial hypothesis:

> **24 hours of full access. No renewal.**

Designed for:

- Halloween;
- sleepovers;
- a hotel/ghost tour;
- a one-night investigation;
- casual curiosity.

Clearly label:

**24 HOURS — DOES NOT RENEW**

## 15.4 Lifetime — $9.99

Initial launch price:

> **Permanent access. No subscription.**

Clearly label:

**LIFETIME — ONE-TIME PURCHASE**

## 15.5 Do not launch the 7-day tier

The previous $4.99 / 7-day proposal is removed.

Reasons:

- half the lifetime price;
- resembles the category's hated $4.99/week subscriptions;
- complicates the clean choice;
- no evidence it materially improves monetization.

Launch paywall:

> **Use it tonight — $1.99**  
> **Own it forever — $9.99**

## 15.6 Pricing iteration

After enough real purchase data:

Possible tests:

- $14.99 lifetime;
- different free-session length;
- Tonight Pass removal;
- Tonight Pass price change.

Do not add an auto-renewing subscription merely because competitors extract more money with one.

A subscription requires evidence that its LTV improvement outweighs:

- rating damage;
- refund risk;
- trust damage;
- lower conversion.

## 15.7 Paywall principles

- no fake countdown;
- no fake “50% off”;
- no “special offer” trap;
- no surprise renewal;
- no paywall before the user hears the product;
- no blocking existing recordings;
- restore purchases visible;
- exact product duration visible.

---

# 16. APP STORE / ASO DIRECTION

ASO is **indexing + ranking + conversion + cold start + iteration**. It is not “fill metadata and wait.” Full process: `docs/launch/APP-STORE-CONVERSION-AND-ASO-PLAYBOOK.md` and `docs/launch/INDIE-IOS-ASO-ZERO-AUDIENCE-LAUNCH-OPERATING-SYSTEM.md`.

## 16.1 Search target

Primary phrase in the **app name:** `Spirit Box`.

Secondary coverage (subtitle/keyword field; not a second business): ghost, box, talker, hunting, EVP, paranormal. Historical AppTweak scores (2026-09-02) are **dated**; `ITC` is a contaminated query.

Title remains provisional (`Spirit Box: Sweep & Replay` baseline) until one cheap Apple Ads / ASO-tool popularity pass. Do not delay audio work on that pass.

## 16.2 Cold start (required)

Do not ship assuming organic `spirit box` rank appears from metadata. Import testers then 100–500 launch users per the acquisition plan **before** judging ranking failure.

## 16.2 Working name

Previous working name `Spirit Box: Ghost Radio` is **retired** because V1 is not a radio receiver.

Current internal working title:

> **Spirit Box: Ghost Sweep**

This is a placeholder until final App Store title/keyword availability is locked.

Do not use `SB7`, `P-SB7`, or another manufacturer's device name.

## 16.3 Icon

Recommended direction:

- near-black / graphite icon;
- abstract instrument face;
- central amber/red display;
- simple sweep bars / directional indicator;
- one small status light;
- no text;
- no skull;
- no ghost;
- no pentagram;
- no exact commercial hardware silhouette.

The icon must read as **instrument**, not horror game.

## 16.4 Screenshot order

### Screenshot 1

**SPIRIT BOX. SWEEP. LISTEN.**

Show the main instrument almost full-screen.

The user should understand the app category without reading a paragraph.

### Screenshot 2

**HEAR SOMETHING? MARK IT.**

Show the MARK interaction prominently.

This is the product wedge.

### Screenshot 3

**REPLAY THE MOMENT.**

Show waveform and marker navigation.

### Screenshot 4

**WORKS OFFLINE. NO GENERATED ANSWERS.**

Only use this exact claim if final implementation remains fully local and non-semantic.

Supporting claims:

- no speech recognition;
- no live streams;
- microphone only when recording.

### Screenshot 5

**TRY A REAL SESSION FIRST.**

Show:

- free real session;
- Tonight $1.99;
- Lifetime $9.99;
- no subscription;
- no ads.

Do not market magnetometer, flashlight, AI, SLS, or a long feature checklist.

---

# 17. COMPETITIVE GUARDRAILS

## 17.1 GhostTube

Do not try to build a better GhostTube.

GhostTube's moat includes:

- creator distribution;
- Amy's Crypt;
- brand recognition;
- multiple specialized apps;
- community;
- haunted locations;
- localization;
- accounts;
- bundle monetization;
- educational/SEO content;
- years of ratings and maintenance.

We do not need any of those to win the `spirit box` job.

## 17.2 WPPNT / current SBX leader

This is the closest commercial target.

Its weaknesses are our opportunity:

- hard paywall;
- poor rating quality;
- trust complaints;
- no strong record/mark/replay workflow;
- simplistic experience.

Do not copy its:

- visual layout;
- device silhouette;
- terminology implying SB7 association;
- price/discount tactics.

## 17.3 SpectraBox / Bello / emerging entrants

These products mean:

> No-subscription + offline + recording is not enough.

Our visible differentiation must remain:

**instrument feel + MARK-centered review + exceptional audio execution.**

Monitor competitors after launch, not through another pre-build research marathon.

---

# 18. THE REMAINING AUDIO GATE: HUMAN LISTENING

The private audio harness exists (`docs/engineering/AUDIO_HARNESS.md`). **Broad commercial research is not finished in the BUILD AUTHORIZED sense** — see CONDITIONAL BUILD status. Audio is still the product gate.

**First:** the smallest 60–90s A/B in `docs/research/SPIRIT-BOX-AUDIO-ENGINE-DECISION.md` (longer sparse speech windows vs current preset).  
**Then:** 15–20 minute endurance on device.

Do not start full product UI until the small A/B has a direction and the endurance gate is at least scheduled.

## 18.1 Harness requirements

The harness exercises:

- one continuous noise/static bed;
- the Phase-1 licensed speech corpus (currently 1,200 VCTK-derived assets; corpus and renderer tuning details in renderer research);
- 75 / 125 / 200 / 300 ms sweep rates;
- Forward / Reverse;
- simple play/stop;
- basic local two-minute capture;
- internal debug event log:
  - asset ID;
  - voice family;
  - rate;
  - direction;
  - previous-use distance.

No polished UI.

No paywall.

No sessions database.

No haptic polish.

## 18.2 Test

Run at least 15–20 minutes continuously.

Test:

- device speaker;
- headphones;
- low volume;
- normal volume;
- multiple sweep rates;
- forward/reverse.

Listen for:

- recognizable repeats;
- obvious loops;
- accidental sentence construction;
- repeated voices;
- unnatural response-like timing;
- clipping;
- excessive overlapping fragments;
- whether it sounds like a clip randomizer instead of a continuous instrument.

Ask testers:

- “Does this sound like a continuous instrument or a small set of clips?”
- “Did you recognize anything repeating?”
- “Did it sound like it was deliberately reacting to what you said?”

Do not prime them with the desired answer.

## 18.3 Audio kill criterion

**Do not build the full product if the renderer cannot produce a sweep that unprimed listeners accept as “like a spirit box” — sparse interrupted speech fragments in static — without obvious clip-randomizer cadence, canned phrases, or dead silence.**

If it fails:

1. change **scheduler/windowing** on existing VCTK once (small A/B);
2. retest;
3. if still structural, try the rights-cleared radio-like fallback or **KILL**. Do not scrape live streams.

Do not “fix” failed audio by adding:

- AI;
- generated words;
- question timing;
- fake frequencies;
- copyrighted radio;
- sensor-triggered answers.

---

# 19. BUILD ORDER AFTER AUDIO PASSES

## Phase 1 — Instrument

Build:

- final sweep engine;
- field-instrument shell;
- power/start/stop;
- forward/reverse;
- rate controls;
- scan visualization;
- core control haptics.

Acceptance:

> It feels substantially better to operate than the current #1 product.

## Phase 2 — Session loop

Build:

- REC;
- microphone permission;
- MARK;
- session persistence;
- safe finalization;
- history;
- waveform replay;
- previous/next MARK;
- export.

Acceptance:

> A user can hear something, mark it without looking, and reach it again in replay in seconds.

## Phase 3 — Commerce

Build:

- one free 3-minute session;
- $1.99 Tonight Pass;
- $9.99 Lifetime;
- restore purchases;
- entitlement state;
- paywall;
- purchase analytics.

Acceptance:

> No user encounters a paywall before experiencing the real sweep.

## Phase 4 — Trust / QA

Build and verify:

- How Sweep Works;
- privacy copy;
- microphone copy;
- disclaimer;
- interruption handling;
- route changes;
- AirPods/headphones;
- phone calls;
- background/foreground;
- low-storage behavior;
- record saving;
- haptic contamination;
- no-loss sessions.

## Phase 5 — Store launch

Create:

- final name/subtitle;
- icon;
- screenshots;
- description;
- keywords;
- review notes;
- privacy disclosures;
- pricing products;
- launch analytics.

---

# 20. TECHNICAL DIRECTION

Preferred:

- SwiftUI
- AVAudioEngine / AVFoundation
- Core Haptics
- StoreKit 2
- RevenueCat if it materially improves entitlement/paywall analytics
- local file storage
- no backend
- no account

## Minimum permissions

Microphone:

- only request when user starts REC.

No location permission.

No contacts.

No camera.

No unnecessary tracking.

## Offline expectation

The core sweep and saved sessions should work offline.

Purchase verification behavior must be implemented in a way that does not unnecessarily prevent an already-entitled user from using the app offline.

## Audio ownership

Maintain a repo/private documentation file recording:

- source;
- performer;
- license;
- commercial app distribution rights;
- modification rights;
- territory;
- date acquired;
- proof/license file location.

Do not ship until this ledger is complete.

---

# 21. ANALYTICS / POST-LAUNCH LEARNING

We are done guessing once real users exist.

Track the smallest set of useful commercial events:

## Acquisition
- App Store impressions;
- product-page views;
- installs;
- search rank for `spirit box` and important secondary terms.

## Activation
- first app open;
- free session start;
- free session completion;
- REC used;
- MARK used;
- replay opened.

## Monetization
- paywall view;
- Tonight Pass purchase;
- Lifetime purchase;
- restore;
- refund data where available;
- revenue per install;
- payer conversion.

## Product quality
- crash-free sessions;
- recording-save failures;
- average session length;
- percentage of recorded sessions with at least one MARK;
- percentage of recordings replayed;
- number of repeat sessions after purchase.

## Reputation
- average rating;
- rating volume;
- review themes;
- repeated complaints.

Do not collect more user data than required to answer product/business questions.

---

# 22. POST-LAUNCH ITERATION PRIORITIES

Only iterate from evidence.

Priority order:

1. audio quality / repetition;
2. crashes / lost recordings;
3. App Store conversion;
4. free-session → paid conversion;
5. MARK/replay usage;
6. paywall pricing;
7. UI friction;
8. haptic tuning.

Potential later experiments:

- lifetime price $14.99;
- different Tonight Pass pricing;
- longer/shorter free trial;
- alternate audio texture;
- marker notes;
- replay improvements;
- carefully scoped raw magnetometer readout.

Do not add a major paranormal feature simply because competitors have one.

---

# 23. V1 DO-NOT-BUILD LIST

This list is intentionally redundant.

Do not build:

- AI ghost chat;
- AI interpretation;
- generated answers;
- generated paranormal sentences;
- word dictionary;
- random scary phrases;
- SLS;
- LiDAR;
- AR ghosts;
- ghost radar;
- camera filters;
- haunted map;
- community;
- social feed;
- accounts;
- backend;
- cloud storage;
- creator feed;
- streaming radio;
- AM/FM simulation;
- fake frequency display;
- fake ambient temperature;
- EMF/ghost detection claims;
- magnetometer in V1;
- flashlight in V1;
- audio mixer;
- reverb/echo controls;
- themes;
- progression;
- achievements;
- daily rewards;
- ads;
- auto-renewing subscription;
- 7-day purchase tier.

The fastest route to ruining this opportunity is turning it into a paranormal feature checklist.

---

# 24. IP / TRADE-DRESS GUARDRAILS

Create an original field instrument.

Never:

- use `SB7` or `P-SB7` in the product name;
- imply official relationship with a hardware manufacturer;
- copy a physical product's exact case silhouette;
- reproduce its button grid;
- reproduce its display proportions;
- copy speaker grille placement;
- copy competitor icons/screenshots;
- use competitor audio;
- use trademark-adjacent names such as GhostTube/Necrophonic/Necrometer in our branding.

Generic functional ideas are allowed:

- sweep;
- sweep rate;
- forward/reverse;
- power;
- recording;
- markers;
- illuminated display;
- fixed controls.

The product should make users say:

> “That looks like paranormal field equipment.”

Not:

> “That is an SB7.”

---

# 25. ACCEPTANCE CRITERIA FOR V1

V1 is not ready to ship until all of these are true.

## Audio
- no obvious short-loop behavior in extended testing;
- no repeat pattern that makes the corpus feel tiny;
- rate changes are audible;
- direction changes are audible;
- no full scripted paranormal phrases;
- no semantic response logic;
- source rights documented.

## Instrument
- first-time user can start a session immediately;
- user can change rate/reverse without tutorial;
- controls remain fixed;
- dark-room readability is strong;
- interface does not look like a specific commercial hardware clone.

## Haptics
- Power / Rate / Direction / MARK feel distinct;
- haptics are not annoying in extended use;
- no continuous/random paranormal haptics;
- MARK does not materially contaminate recordings or is disabled during recording.

## Recording
- no recording is lost during normal stop/power-off;
- app handles interruptions safely;
- waveform replay is stable;
- marker timestamps are accurate;
- export works;
- recordings remain available after entitlement expiry.

## Trust
- microphone requested only when needed;
- no false AM/FM/radio claims;
- How Sweep Works is technically accurate;
- privacy claims match the actual SDK/network behavior;
- App Store metadata matches functionality.

## Monetization
- real free session works before paywall;
- Tonight Pass does not renew;
- Lifetime is clearly one-time;
- restore works;
- no fake discount/urgency.

## Store conversion
- first screenshot reads unmistakably as a spirit-box instrument;
- second screenshot clearly communicates MARK;
- third screenshot clearly communicates replay;
- icon reads as instrument, not horror game.

---

# 26. KILL / REDESIGN CRITERIA

Do not preserve the product because we have already researched or built it.

## Kill or materially pivot if:

### Audio failure
Unprimed listeners still do not hear a spirit-box sweep after one renderer A/B and one corpus/scheduler retry.

### Seeding failure
We cannot recruit ~20 qualified testers or ~100 launch users with bounded outreach (not a creator career).

### Conversion failure
After **seeded** impressions, the page cannot convert.

### Ranking failure
90 days after launch **with** seeding + iteration, App Store Search still cannot show a path toward ≥~$1k/mo at observed conversion. Do not “fix” this by becoming a full-time marketer.

### Product differentiation failure
Users say it is interchangeable junk and do not use MARK/replay **or** the audio.

### Rating failure
Reviews attack the mechanism as deceptive despite accurate disclosure.

### Competitive invalidation
A strong top-ranking entrant ships the same trial + honest sweep + MARK + one-time price and closes the gap before we have rank.

### Economics failure
Reachable organic + seeded traffic cannot support $1k/mo after a fair test. Historical AppTweak 94.425 is **not** a revenue forecast.

### Wrong-business failure
The only remaining path is live unlicensed radio, weekly subscriptions, or tarot/astrology.

No sunk-cost argument overrides these conditions.

---

# 27. WHAT WE KNOW / INFER / DO NOT KNOW

## VERIFIED / STRONG EVIDENCE

- People still search `spirit box`; WPPNT remains API #1 with 2.86★ / 49 ratings (2026-09-10).
- Apple uses metadata **and** downloads/ratings/reviews for search.
- 2026 title-clone apps with almost no ratings do not reproduce that #1.
- Users hate surprise weekly paywalls, canned repeated phrases, and also hate **unintelligible** / empty audio.
- Physical boxes produce interrupted radio speech fragments, not a pure phoneme wash.
- Live stream catalogs have App Review 5.2.3 risk.
- GhostTube’s moat is creator distribution, not an unbeatable sweep.

## INFERENCES WE ARE BUILDING AROUND

- Seeding 100–500 users is the realistic cold start.
- Honest trial + better audio can convert against the current #1.
- MARK still helps the listing vs WPPNT; it is not a monopoly.
- Accessible (not replica, not witchy) positioning matches mixed-gender belief data without changing the job.
- $1.99 / $9.99 remains the pricing **hypothesis**.
- VCTK + renderer retune is cheaper than commissioning voices.

## STILL UNKNOWN

- WPPNT revenue and ads; our conversion; true 2026 keyword TAM; whether VCTK can sound like a box; whether seeding works.

These are answered by the **audio A/B**, then testers, then a seeded launch — not by more desk research.

---

# 28. FINAL PRODUCT PRINCIPLE

When making any implementation decision, ask:

> **Does this make START → LISTEN → MARK → REPLAY more convincing, tactile, trustworthy, or profitable?**

If the answer is no, leave it out.

The opportunity is not to build the most feature-rich ghost app.

The opportunity is to build:

> **the best small spirit-box instrument on iPhone.**
