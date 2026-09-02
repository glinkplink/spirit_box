# Spirit-Box Audio Engine — Final Architecture Decision

**Decision date:** September 2, 2026  
**Status:** BUILD-GATING DECISION — choose the engine below; do not add a second engine in V1.

## Executive decision

### Recommended engine: **offline, original audio/phoneme bank with a deterministic sweep renderer**

This is **Option B**, but implemented narrowly and honestly:

- an on-device bank of original/licensed short vocal fragments, non-verbal consonant/vowel units, reverse fragments, filtered noise, and radio texture;
- a non-semantic scheduler that continuously scans those fragments at the selected rate and direction;
- no full scripted phrases, speech recognition, prompt-response logic, question analysis, sensor-triggered “answers,” or generated text;
- local recording, MARK timestamps, and replay.

Do **not** build live-radio sweeping in V1. Its authentic-radio story is genuine, but the commercial benefit is unproven while the rights, stream reliability, regional availability, network, support, and review risk are material.

Do **not** build fully procedural/synthetic audio in V1. It is clean technically and legally, but it has the weakest “voice source” story and is already a differentiated product position of SpectraBox—not the reliable way to make a focused, old-school-feeling instrument.

This is a decision about commercial fit and product durability, not proof that any mechanism enables paranormal communication. The app must never claim that it does.

## What the evidence says

### Verified facts

| Finding | Evidence | What it means |
|---|---|---|
| Physical sweep boxes use actual AM/FM tuning, selectable sweep rate, and forward/reverse scanning. | The P-SB7 documentation describes sweeping individual frequency channels and exposes 50–350 ms sweep rates plus forward/reverse directions. [P-SB7 manual](https://device.report/manual/16164096) | Serious users associate **literal RF scanning** with the original device mental model. |
| Internet-radio sweep is an established app mechanism. | GhostTube says VOX uses environmental sensors and online digital broadcasts rather than analog radio; Ghost Talker says it jumps among up to 12 live streams and explicitly contrasts this with prerecorded libraries. [GhostTube explanation](https://ghosttube.com/blogs/ghosttube/ghosttube-vox) · [Ghost Talker listing](https://apps.apple.com/ie/app/ghost-talker-spirit-box-live/id6742842360) | “Live radio / no prerecorded responses” is a visible, intelligible positioning claim. |
| A phoneme-bank implementation is also an established category mechanism. | Necrophonic discloses eight active banks composed of phonemes, partial words, reverse audio, foreign-language material, and says there are no real words or phrases beyond basic phonetic sounds. [Necrophonic listing](https://apps.apple.com/kr/app/necrophonic/id1396698319?l=en) | The mechanism itself is not commercially disqualifying if execution and disclosure are sound. |
| A transparent procedural product exists. | SpectraBox markets procedural on-device sound, no network calls, airplane-mode use, and expressly says it is not a radio scan. [SpectraBox listing](https://apps.apple.com/us/app/spectrabox-spirit-box-evp/id6780213241) | Transparency can support a synthetic model, but this is a different product promise from a radio/voice-fragment instrument. |
| Digital transmission of music generally entails both recording and composition rights. | SoundExchange distinguishes sound-recording royalties from public-performance rights and says a digital audio transmission will usually need both. [SoundExchange licensing overview](https://www.soundexchange.com/service-provider/licensing-101/) | Scraping or proxying arbitrary station streams is not an acceptable V1 assumption. |
| Apple requires accurate metadata and functionality, and prohibits copycat representations. | Apple’s current guidelines require accurate metadata, warn against misleading claims, and forbid copying another app’s identity/UI. [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) | Product language must describe the actual engine precisely; visual/semantic imitation of an SB7 must stop short of trade dress. |

### Repeated user/theme evidence — not a survey

- The physical-radio model is legible enough that users and sellers routinely describe a spirit box as a continuously scanning radio; experienced users discuss AM/FM, sweep direction, and dwell speed. That means literal radio is an authenticity *signal*, especially to equipment-oriented investigators.
- App skepticism is broad. Community discussions often treat “it is an app” or a word database as a reason for doubt. That is a product-trust problem, not evidence that all paying users reject bank audio.
- The most credible anti-bank complaint is not simply “it is prerecorded.” It is **recognition**: repeated voices, repeated clips, overly clean whole words, obvious phrase cadence, and convenient question-to-answer timing make the source feel authored.
- Existing products demonstrate three viable audience narratives: physical/RF (P-SB7), live broadcast (GhostTube/Spirit Box Radio/Ghost Talker), and phoneme bank (Necrophonic). No reliable current evidence establishes that live-radio users convert or retain materially better than well-executed offline-bank users.

**Important limit:** Community discussion is polarized, anecdotal, and not representative of paid users. It establishes likely trust failure modes; it does not establish market share or conversion uplift by engine.

## Why Option B wins

1. **It protects the primary job.** Start, listen, mark, replay must work at a cemetery, basement, rural property, tunnel, or airplane-mode test. The engine always starts immediately and recordings replay exactly.
2. **It uses an accepted category convention.** Necrophonic proves that an explicitly phonetic/multi-bank design can be the product—not a hidden compromise.
3. **It is credible when it has no semantic steering.** A bank can be deterministic enough for a useful session recording while avoiding the strongest “the developer fabricated the response” signal: generated sentences or reaction to questions.
4. **It avoids a business that secretly depends on third parties.** No streams dying, changing region, buffering, transmitting music, or requiring rights analysis for every source.
5. **It is materially faster to tune.** Audio quality, scheduler behavior, filters, levels, and anti-repetition can be tested locally; the product is not blocked on a radio provider or server infrastructure.

### Why A loses: live internet radio

Live radio earns the highest score for literal radio authenticity and variety. It may be an excellent later experiment **only** if direct rights/provider contracts and a resilient stream source are solved first.

For V1 it loses because:

- it is not offline and becomes unreliable precisely in many investigation environments;
- abrupt source changes, music/DJs, buffering, geographic variance, and stream outages create an inferior listening session;
- a random selection of third-party streams is not a rights strategy. The app would be transmitting music to users; the necessary permissions, provider terms, and territory issues are unresolved;
- it creates ongoing operational work and a more complicated App Review explanation;
- “real radio” may improve perceived authenticity, but there is no evidence it raises paid conversion enough to pay for those risks.

### Why C loses: procedural/synthetic audio

Procedural audio is the lowest-maintenance, lowest-rights-burden architecture and SpectraBox shows that complete disclosure can be a differentiator. It loses for this product because:

- it has no externally sourced human-vocal material, making convincing, varied speech-like fragments the hardest audio-design task;
- its honest message is “not a radio scan,” which breaks the old-school instrument mental model this product is designed to preserve;
- it risks sounding like a clever audio effect rather than a field instrument;
- it is already tied to SpectraBox’s very explicit procedural/transcript/AI-adjacent product identity. We should not compete head-on with that framing.

## Decision matrix

Scores are relative commercial-fit judgments, not measured conversion data. **5 = strongest / lowest risk; 1 = weakest / highest risk.**

| Engine | Authenticity perception | Trust | Audio variety | Repetition risk | Offline | Privacy | Legal/licensing | App Review risk | Build complexity | Maintenance | Serious-user appeal | Casual-user appeal | Review risk | App Store clarity | Monetization potential | Overall commercial fit |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| A. Live internet radio | 5 | 4 | 5 | 5 | 1 | 2 | 1 | 2 | 2 | 1 | 5 | 4 | 2 | 5 | 4 | **2** |
| B. Offline audio/phoneme bank | 3 | 4 | 3 | 3 | 5 | 5 | 4 | 4 | 4 | 5 | 3 | 4 | 3 | 4 | 4 | **4** |
| C. Offline procedural/synthetic | 2 | 4 | 4 | 5 | 5 | 5 | 5 | 5 | 2 | 5 | 2 | 3 | 3 | 3 | 3 | **3** |

### Score explanations

- **Authenticity:** A literally scans broadcasts; B is a recognized but non-RF ITC format; C truthfully cannot claim to scan radio.
- **Trust:** A avoids the canned-response accusation but still requires transparent source behavior. B earns 4 only if it discloses the bank and has zero semantic-response logic. C earns 4 because its mechanism can be completely disclosed, not because it is more investigator-authentic.
- **Variety/repetition:** A is naturally broad but depends on what streams happen to carry. C can avoid literal repetition. B is adequate, not automatic: corpus size, transient processing, scheduling, and no full words determine whether it fails.
- **Offline/privacy:** B and C win outright. A needs network access and third-party streams.
- **Legal/App Review:** C is cleanest. B is low risk only with commissioned voices or a written commercial license that covers app distribution and transformation. A’s arbitrary stream/rebroadcast model is materially unresolved.
- **Build/maintenance:** C is difficult in initial sound design but stable after launch. B is technically straightforward and stable. A is the only option with a permanent third-party dependency.
- **Audience/reviews:** A is strongest with serious equipment-oriented users; B gives both audiences a familiar, usable instrument; C appeals to users who value transparent technology but has a lower old-school fit. B’s review risk is controllable; A’s is operational.
- **Marketing/monetization:** A’s “live radio” claim is clearest and might justify a price premium, but no evidence proves it does. B’s offline/no-generated-answers claim communicates value, while C needs more explanation before it makes sense.

## Exact V1 implementation principles

1. **Use only original or clearly app-distribution-licensed source audio.** Keep a source ledger: performer/release, license, territory, modification rights, and whether it can be embedded in a paid app. Commissioned recording with explicit buyout is safest.
2. **No full scripted phrases.** Allow only short phonetic units, partial words, non-linguistic vocal texture, reverse fragments, breaths, consonants, and noise. Avoid a vocabulary that can systematically form common answers.
3. **No question input whatsoever.** Do not request microphone access merely to “listen” to a user; record only when the user starts a session and state that recording is local. The scheduler must not use transcript, microphone features, questions, EMF, time since question, or a “response” state.
4. **No on-screen words, transcript, answer log, or claimed interpretation.** MARK records a timestamp the user can revisit; it never labels an event as an answer.
5. **Make scanning perceptible.** The engine moves through a non-semantic source-position index with continuous noise and short, intentionally incomplete fragments. Rate changes alter fragment dwell time; direction reverses traversal. Controls must change the audible behavior immediately.
6. **Build anti-repetition into the scheduler.** Do not replay the same asset within a short rolling window; separate adjacent clips by voice/register/filter family; randomize start offsets and filtering within bounded ranges. This is implementation behavior, not an authenticity claim.
7. **Ship one carefully tuned “Sweep” mode.** No fake AM/FM modes or named frequency bands. A second “texture” profile is only permissible if it is a plainly named audio profile, not simulated receiver technology.
8. **Record the actual final mix locally.** A replay must include exactly what the user heard plus reliable MARK timecodes.

## Exact UI terminology

### Safe V1 terms

| Element | Use | Reason |
|---|---|---|
| Main action | **START SCAN** / **STOP** | Describes traversal through the app’s source bank, not RF reception. |
| Rate | **SWEEP RATE** (e.g., Slow / Medium / Fast or ms) | “Sweep” accurately describes the engine’s movement through source positions. |
| Direction | **FORWARD** / **REVERSE** | Truthful traversal controls. |
| Visual indicator | **SOURCE POSITION** or unlabelled moving scale | Shows the app’s own index, not a broadcast frequency. |
| Session event | **MARK** | User-authored timestamp; avoids “response” or “evidence.” |
| Replay | **SESSION REPLAY** | Accurate local recording language. |
| Settings | **AUDIO PROFILE** (only if more than one) | Avoids pretending profiles are bands. |

### Terms that V1 must not use

- **AM, FM, MHz, kHz, station, channel, frequency, tuner, airwaves, broadcast, live radio, RF**, or any frequency numbers.
- “Scanning radio,” “radio sweep,” “real broadcasts,” “non-prerecorded responses,” or “no fake responses.” The bank is prerecorded source material, even if it contains no scripted answers.
- “Detect,” “communicate with,” “answers,” “messages,” “spirit response,” “evidence,” “proof,” or claims that the app identifies paranormal activity.

An analog-style meter is allowed only if it is explicitly an audio level or source-position treatment—not a fake frequency display.

## Exact trust and How It Works language

### First-run card

> **How Sweep works**  
> Sweep plays and moves through an on-device collection of short vocal fragments and noise textures. It does not use radio reception, live streams, speech recognition, or generated answers. You decide what you hear; MARK saves a timestamp to review later.

### Recording permission explanation

> Recording is optional. When you start a recording, audio stays on this device in your session history. Sweep does not analyze what you say or use your questions to choose sounds.

### App Store screenshot/support copy

> **Works offline. No live streams. No generated answers.**  
> Start a sweep, mark a moment, and replay the session locally.

### Required product disclaimer

> For entertainment and personal exploration only. This app does not detect, verify, or communicate with paranormal activity. Do not use it for safety, medical, legal, financial, or other important decisions.

This presentation follows Apple’s requirement that metadata accurately describe the core experience; “for entertainment” is a disclaimer, not a substitute for accurate functionality. [Apple guidelines](https://developer.apple.com/app-store/review/guidelines/)

## What must never be claimed

1. That the app receives RF, AM/FM, stations, broadcasts, or live radio.
2. That audio was not prerecorded; the source fragments are preloaded.
3. That the app hears, understands, or responds to questions.
4. That sensor readings cause or confirm a response.
5. That a MARK indicates a paranormal event or evidentiary correlation.
6. That the app detects ghosts, entities, energy, EMF anomalies, or EVP.
7. That any clip proves communication, identity, location, safety, or future events.

## Main technical and legal risk

### Main V1 risk: **the bank sounds recognizably canned**

That—not basic Swift audio playback—is the chief risk. A small or overly linguistic corpus will trigger the exact accusation we are trying to avoid and will destroy repeat use. Solve it before UI polish with blind listening tests and a repetition log.

### Main legal risk: **source-audio rights and provenance**

Every embedded sound must have an explicit commercial right for a paid mobile app, including modification/filtering and worldwide distribution where the app is sold. Do not sample radio, YouTube, podcasts, TV, films, voice libraries with unclear “standalone” restrictions, or competitor audio. Preserve documents.

### Deferred live-radio risk

If A is revisited, stop before engineering and obtain counsel/provider documentation covering stream access, rebroadcast/transmission, catalog rights, territories, attribution, recordings, and service terms. Existing radio apps do not establish that the same integration is permitted for us.

## First prototype and the only pre-build test that matters

### Prototype first

Build a private iPhone audio harness, not the app UI:

- one continuous noise bed;
- 3–4 original voice/register families;
- 80–150 short source fragments initially;
- Sweep Rate: 75 ms, 125 ms, 200 ms, 300 ms;
- Forward/Reverse;
- a basic waveform/level view and local 2-minute capture;
- an internal event log showing asset ID, family, rate, direction, and repeat distance.

Test with headphones and device speaker, at normal and low volume. Ask testers only: “Does this sound like a continuous instrument or like a small set of clips? Did any voice/fragment repeat? Did it sound like it was reacting to you?” Do not frame the expected answer.

### Kill criterion

**Kill Option B—or pivot before any product build—if a 15–20 minute session with the intended V1 corpus produces obvious recognisable repeats, sentence-like assembly, or a tester consensus that it sounds like a clip/randomizer rather than a coherent sweep instrument.**

Do not solve that by adding word generation, question timing, AI interpretation, fake frequency controls, or copyrighted radio. If the bank cannot pass, reassess a rights-cleared live-radio provider or kill the product rather than manufacture authenticity.

## Go / no-go sequence

1. **GO:** commission/license a small clean corpus and build the audio harness.
2. **GO only if prototype passes:** implement Start → Listen → Mark → Replay with the trust language above.
3. **NO:** do not add AI, transcripts, SLS, live radio, or a broad paranormal-tool suite to rescue the product.
4. **Before App Store submission:** verify every sound’s license and test every shown control against its actual audio effect; include the exact engine explanation in review notes.

## Bottom line

The winning V1 is **an offline, disclosed phoneme/audio-bank sweep instrument**, not a counterfeit radio and not an answer machine. Live radio is the more marketable claim but the wrong business architecture under the speed, maintenance, and risk constraints. The product earns trust by being clear about what it does, then making that limited job feel exceptionally tactile and reliable.
