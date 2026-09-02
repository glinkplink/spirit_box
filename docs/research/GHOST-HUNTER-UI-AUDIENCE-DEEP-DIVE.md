# GHOST HUNTER UI / AUDIENCE DEEP DIVE

**Product:** focused iPhone spirit-box instrument  
**Research date:** September 2, 2026  
**Decision scope:** UI, audio interaction, physical-instrument feel, haptics, recording/session workflow, trust, and App Store visual conversion.  
**Commercial premise:** already build-authorized by the project. This pass does **not** reopen market viability or pricing economics.

---

# 1. EXECUTIVE PRODUCT VERDICT

## Recommended direction: **FIELD RADIO INSTRUMENT**

Build the app as a **purpose-built paranormal field instrument translated into native iPhone interaction** — not as a literal replica of a P-SB7/SB7, not as a neon haunted-house app, and not as a generic black utility.

The evidence favors a **hybrid**:

- recognizable radio-instrument semantics: POWER, sweep direction, sweep rate in milliseconds, AM/FM *only if truthful to the engine*, a strong scan display, REC, and MARK;
- dark-room-first presentation: matte charcoal/black, restrained warm amber/red display light, high-contrast labels;
- physical affordances: large tactile-looking controls, button press states, crisp haptic confirmation;
- modern iPhone discipline: clear hierarchy, one-thumb controls, no fake screws, no faux scratched metal, no eight-button replica grid, no unnecessary radar/camera/oracle modes;
- evidence-preservation workflow: record, mark timestamps, replay on a waveform, jump between marks, and export the recording;
- explicit mechanism transparency: no claims that the phone “detects ghosts,” no hidden speech recognition, no fake ambient-temperature claim, and no generic “EMF” label when the phone is actually exposing magnetometer data.

### Why this direction survives the research

**VERIFIED FACT:** Physical spirit boxes repeatedly expose sweep rate, forward/reverse sweep, AM/FM, volume, a lit numeric display, and direct start/stop/power controls. The P-SB7 family and SBox are recognizable examples. [S23][S24][S32][S33]

**REPEATED USER THEME:** Hardware users praise equipment that is compact, easy to understand, clear in the dark, and direct to operate. They also value recording and headphone support. The same audience criticizes button-learning friction when controls are dense in a dark location. [S23][S32][S25][S27]

**REPEATED USER THEME:** App users are suspicious of canned phrases, repetitive voices, unexplained word databases, fake-looking sensor behavior, and microphone/privacy ambiguity. [S02][S03][S08][S35][S36][S37]

**REPEATED USER THEME:** App users explicitly praise products that feel more like investigation equipment and that do not “overdo” the horror treatment. Recording/review is repeatedly described as a high-value feature. [S10][S12][S16][S20][S39]

**VERIFIED FACT:** Successful current paranormal apps do not all use heavy skeuomorphism. GhostTube VOX uses a modern dark mobile interface with a waveform, large record control, and audio sliders while maintaining a 4.4 rating across roughly 2.8K U.S. ratings. [S07][S08][S52]

**INFERENCE:** The strongest design is therefore not “old UI versus new UI.” It is **old-school instrument semantics + modern mobile execution**.

---

# 2. RESEARCH METHOD AND EVIDENCE RULES

This pass reviewed:

- current Apple App Store listings and review pages;
- Google Play where an Android comparator added useful evidence;
- current and historical spirit-box / paranormal apps;
- current paranormal hardware listings, manuals, and retailer reviews;
- Reddit ghost-hunting/paranormal discussions;
- manufacturer field guides and enthusiast material;
- Apple documentation for Core Haptics, magnetometer data, microphone permissions, and haptics during recording;
- skeptical community material when it exposed credibility risks that believers and serious hobbyists also care about.

### Evidence labels used throughout

**VERIFIED FACT** — directly stated by a primary listing/manual/API document or visible current rating/review page.  
**REPEATED USER THEME** — multiple independent users express materially similar praise/complaint.  
**INFERENCE** — design conclusion drawn from evidence.  
**SPECULATION** — plausible but not validated; should not drive V1 without testing.

### Important research boundary

This report does **not** adjudicate whether spirit communication is scientifically real. The product can respect paranormal users without making false scientific claims. Credibility here means: the app behaves consistently, explains what it actually does, does not secretly manipulate responses, and does not mislabel phone sensors.

---

# 3. STRONGEST FINDINGS — WHAT ACTUALLY MATTERS

## 3.1 “Feels like equipment” is a real signal; “looks like a replica” is not required

A recent Spirit Box EVP Ghost Detector reviewer explicitly praised that the app “doesn’t overdo things” and feels closer to paranormal investigation equipment than a fake horror game. Other reviewers in the same small but current review set praised use of real phone hardware and the ability to record/review later. [S10]

Physical-tool reviews repeatedly praise:

- one-button or immediately understandable operation;
- compact form factor;
- readable illuminated displays;
- clear LED/tone feedback;
- direct recording;
- headphone connectivity;
- controls that can be learned and operated in the dark. [S23][S25][S27][S28][S32][S34]

But an exact hardware-style button matrix is not automatically superior. An SBox reviewer specifically reports a learning curve with the buttons “on location and in the dark.” [S32]

**Conclusion:** use the *interaction grammar* of field equipment, not its industrial design.

## 3.2 Audio authenticity is mostly about avoiding obvious manipulation

Across App Store and community sources, the strongest negative credibility triggers are:

- complete or suspiciously specific canned phrases;
- repeated identical voices/phrases;
- multiple overlapping voices that become unintelligible;
- output that appears to react too neatly to common questions;
- hidden or unexplained word banks;
- heavy echo/reverb/distortion that masks the source audio;
- unclear microphone use. [S02][S03][S08][S35][S36][S37][S58]

A Spirit Box EMF reviewer who paid for a week without a demo complained about many voices speaking at once and hearing the same thing repeatedly after restarting. [S02]

Necrophonic reviews provide a similar practical signal: users praise the scan-rate control, but one reviewer says echo made already-overlapping voices harder to understand. [S58]

GhostTube VOX reviews contain a repeated complaint that echo makes output harder to hear; another user specifically values that VOX is not constrained to a fixed vocabulary. [S08]

**Conclusion:** “spooky” audio is not the same as credible audio. The V1 default should be **dry enough to parse, ambiguous enough to feel like a sweep, and allowed to produce nothing interesting**.

## 3.3 Recording is not a nice-to-have

The case for recording is much stronger than the case for almost any other secondary feature.

- SBox hardware owners repeatedly praise built-in recording and direct playback. [S32][S33]
- A GhostTube EVP product guide is explicitly centered on recording short sessions and reviewing them with tagging and a scrubbable visualizer. [S21]
- Spirit Entities Talker reviews call recording useful for later analysis. [S16]
- Spirit Box EVP Ghost Detector users cite recording/replay as one of the best parts. [S10]
- An experienced Reddit investigator tells beginners to “100% record” spirit-box sessions because potential voices are easy to miss live. [S39]
- Spirit Talker users complain sharply when investigation files are lost after reinstalling. [S03]

**Conclusion:** the current belief that V1 needs recording + MARK + replay is basically right, but it is missing two low-cost trust/usability pieces: **waveform scrubbing and export/share of the original recording**.

## 3.4 Trust is improved by explaining mechanism, not by pretending certainty

GhostTube’s products maintain thousands of ratings while explicitly stating that paranormal communication is theoretical and their tools should not be treated as definitive proof. GhostTube VOX also answers microphone/privacy accusations by explaining that the microphone is optional unless the user records. [S05][S07][S08][S19][S21]

Ghost Hunting Tools’ developer publicly says its responses are generated from randomized inputs and open to interpretation. [S04]

Sono X10 goes unusually far in its App Store description by explaining exactly that it uses small phonemes/speech fragments and how phone-sensor triggers select positions in its voice bank. [S15]

Physical K-II users frequently baseline the device near known electronics before an investigation. [S25]

**Conclusion:** a short “How it works” screen is not anti-paranormal. It is a credibility feature. The app should explain its mechanism in plain language and avoid claiming more than the mechanism supports.

## 3.5 Haptics should confirm intentional actions, not manufacture “activity”

There is not strong audience evidence that paranormal users are asking for constant vibration. The audience evidence is stronger for **clear, immediate feedback** in the dark: K-II LEDs, REM Pod lights/tones, physical button feel, and audible/visual alerts. [S25][S28]

Apple’s current haptic guidance says short, intentional haptics are generally preferable, that haptics should have an obvious source, that they should be optional, and that developers must consider interference with camera/gyroscope/microphone experiences. [S46][S47][S48][S56]

Apple’s audio API explicitly defaults to **not allowing haptics/system sounds while recording from audio input**, underscoring that recording and vibration are a real interaction conflict. [S57]

**Conclusion:** haptics should make controls feel mechanical. Do **not** make the phone randomly buzz as if it has “detected a spirit.” Magnetic-event haptics were considered during research but are **out of V1** per the canonical source of truth. Optional scan haptics remain secondary and OFF by default.

---

# 4. AUDIENCE SEGMENTS

## SERIOUS PARANORMAL HOBBYIST

### What makes the app feel legitimate

- direct sweep terminology and controls rather than invented “entity strength” concepts;
- rate shown in milliseconds;
- forward/reverse sweep;
- truthful band/source labeling;
- no canned sentences or “smart” conversational replies;
- no speech recognition choosing responses;
- raw sensor readings with units when sensors are shown;
- local recording, timestamps/marks, replay, export;
- offline core session behavior where technically possible;
- no account requirement for the core tool;
- no ads during sessions;
- clear explanation of sensor limitations and false positives;
- predictable output that does not secretly change based on microphone content.

### What makes it feel fake

- skulls, séances, occult animations, glowing ghost silhouettes;
- “GHOST DETECTED” or “ENTITY 97%” language;
- unexplained random words;
- complete sentences designed to feel relevant;
- fake analog gauges with no data source;
- temperature claims from an iPhone without an external temperature sensor;
- exact P-SB7 visual imitation.

**Evidence:** [S10][S23][S25][S32][S35][S36][S37][S39]

## CASUAL BELIEVER / CURIOUS USER

### What makes it understandable and satisfying

- the first screen already looks like a spirit box;
- one obvious POWER/start action;
- safe defaults — no requirement to learn sweep engineering before hearing anything;
- large MARK control for “I heard something”; 
- a visible timer and obvious recording state;
- a replay screen that makes marked moments effortless to revisit;
- concise one-time explanation of what the buttons mean;
- enough instrument styling to feel special without a cockpit of tiny labels.

Casual users often report meaningful experiences with word/radar apps, but that does not mean a focused instrument must replicate those mechanics. Ghost Radar and Spirit Entities show that immediacy and simple visual feedback have broad appeal; the focused spirit-box app should capture that immediacy without becoming a super-app. [S14][S16]

## HALLOWEEN / PARTY USER

### What makes it fun immediately without feeling like a scam

- a real trial session before payment;
- fast power-on and audible sweep;
- clear animated scan state;
- tactile power and MARK feedback;
- replay of “what just happened” immediately after the session;
- no setup wizard longer than one screen;
- no forced belief claims.

A harsh App Store complaint about paying for a week without being able to try the actual experience is direct evidence that the trial must expose the real core loop before purchase. [S02]

## THE OVERLAP

All three segments benefit from:

1. **dark, readable, field-oriented UI**;
2. **obvious controls**;
3. **recognizable spirit-box sweep behavior**;
4. **no ad interruption**;
5. **record + replay**;
6. **strong control feedback**;
7. **no unexplained trickery**.

The overlap is large enough that V1 should not have separate “serious” and “party” modes.

---

# 5. OLD-SCHOOL VS MODERN UI

## Evidence-backed conclusion

**Do not choose between skeuomorphic and modern. Use moderate skeuomorphism for the instrument surface and modern iOS structure everywhere else.**

### What old-school hardware contributes

- red/amber illuminated display in darkness;
- persistent current mode/status;
- controls that look pressable and have fixed locations;
- coarse, deliberate settings rather than hidden gestures;
- obvious POWER state;
- visual separation of display vs controls. [S23][S24][S25][S27][S32][S52]

### What modern successful apps contribute

GhostTube VOX demonstrates that paranormal users will accept a clean, modern black interface with waveform feedback and large controls. Its 4.4/2.8K U.S. rating is materially stronger than older heavily skeuomorphic SBX 12 (about 3.0/735) or Sono X10 (3.4/982). Ratings do not isolate UI causality, so this is not proof that modern is better, but it disproves the idea that credibility requires a hardware replica. [S07][S08][S11][S15][S52]

### Visual balance to implement

**Instrument semantics:** old-school.  
**Layout discipline:** modern.  
**Textures:** restrained.  
**Typography:** modern, legible, with monospaced/tabular numerals only in the display.  
**Animation:** low-key and functional.  
**No horror theme skinning.**

---

# 6. CONTROL LAYOUT — WHAT USERS EXPECT VS WHAT V1 NEEDS

| Control / indicator | Evidence of expectation | V1 decision | Visibility | Form | Notes |
|---|---|---|---|---|---|
| POWER | Very strong from physical boxes | **Include** | Always | Separate tactile-looking key; hold ~0.4s to power off | Prevent accidental end-of-session |
| Sweep direction | Strong; P-SB7/SBox core control | **Include** | Always | FWD / REV two-state control | Hobbyists know it; casual tutorial labels it once |
| Sweep rate | Strong; central hardware control and app praise | **Include** | Always | `RATE – / +` with ms value | Default 200 ms; supported steps should match engine |
| AM / FM | Strong for true radio-style sweep | **Include only if truthful** | Always if real; otherwise replace with truthful source/bank label | Two-state button | Never show fake bands merely for theater |
| Volume | Strong on hardware | **Use iPhone hardware volume buttons by default** | No dedicated main slider | Physical iPhone buttons | Avoid redundant UI; software output gain can live in Settings if needed |
| Mute | Moderate; useful but not core | **Exclude main screen** | Settings/system | — | A visible mute-output warning is more useful than a mute button |
| Scan start/stop | Strong | **Power starts/stops the sweep** | Always | POWER state | Avoid separate SCAN unless later testing shows pause demand |
| Frequency display | Strong visual cue on radio hardware | **Conditional** | Central display | Large monospaced numeric | Label MHz/kHz only if it actually represents the engine |
| Band/channel display | Strong if radio-based | **Conditional** | Central display | Compact mode label | Truthfulness overrides aesthetics |
| Signal meter | Familiar but high risk of implying “spirit strength” | **Do not include generic signal meter** | — | — | Do not substitute a raw magnetic bar in V1; magnetometer is out of scope |
| Record | Repeated high-value evidence | **Include** | Always | Large latching REC key with red status LED | First mic permission only when user taps REC |
| MARK | Strong workflow need, although not traditional hardware | **Include prominently** | Always; disabled when nothing is recordable | Largest thumb-zone key | Metadata timestamp; no audible beep |
| Timer | Strong session utility | **Include** | Always | Top status strip | Session elapsed and REC elapsed state |
| Flashlight | Present on hardware; iPhone already provides it | **Exclude V1** | — | — | Feature-bloat risk |
| Magnetometer | Relevant to audience, real iPhone sensor available | **V1 decision: EXCLUDE** — superseded by canonical source of truth. Audience research showed potential relevance, but magnetometer/EMF functionality is explicitly out of V1. | — | — | Preserve research finding; do not ship in V1 |
| Magnetic alert | Some hardware uses lights/tones; audience appreciates alerts | **V1 decision: EXCLUDE** — superseded by canonical source of truth. Historical research only; no magnetic-alert feature in V1. | — | — | Preserve research finding; do not ship in V1 |
| Temperature | Present on physical SB7/MEL hardware | **Exclude** | — | — | iPhone cannot be treated as a dedicated ambient thermometer |
| Noise / white noise | Common spirit-box/ITC option | **Engine-dependent** | Settings, not main | Minimal selector | Avoid turning main UI into a mixer |
| Echo / reverb / distortion | Present in Necrophonic/VOX; also source of intelligibility complaints | **Exclude from V1** | — | — | Default clarity is more important |
| Session history | Recording users value retained evidence | **Include** | Separate Sessions screen | Chronological list | Local-first, no account required |
| Export/share | Hardware SD/WAV workflow + investigator review habits | **Include** | Replay screen | System share action | Low complexity, high ownership/trust value |

**Sources:** [S08][S21][S23][S24][S32][S33][S39][S58]

---

# 7. AUDIO EXPERIENCE

## 7.1 What sounds authentic to this audience

For radio-sweep hardware, authenticity comes from the recognizable behavior of **rapid changing broadcast fragments/static**, controllable sweep speed, direction, and band. P-SB7 hardware exposes sweep speeds in milliseconds and FWD/REV; SBox exposes AM/FM sweep, pause/direction, recording, and headphone listening. [S23][S24][S32][S33]

For sound-bank apps, users tolerate ambiguity but become suspicious of identifiable loops, repeated full phrases, or outputs that seem semantically engineered. Sono X10 and Necrophonic try to address this by disclosing phoneme/partial-speech banks instead of claiming a database of scripted answers. [S15][S58]

## 7.2 What immediately feels fake

**Repeated evidence:**

- exact repeated phrases after restart; [S02][S59]
- generic word databases and preprogrammed phrases; [S03][S17][S35][S36][S37]
- complete conversational answers that appear too well targeted; [S03][S36]
- multiple voices speaking simultaneously to the point of unintelligibility; [S02][S58][S59]
- artificial “creepy” voices that reduce clarity; [S03]
- heavy echo/reverb/distortion that makes users work harder to understand output. [S08][S58]

## 7.3 Recommended V1 audio behavior

### Required behavior

1. **Continuous sweep texture when powered on.** It must immediately sound like a spirit-box session, not a word generator waiting for a trigger.
2. **Adjustable rate and direction.** Rate must alter the audible cadence in a way the user can perceive.
3. **No mandatory semantic response cadence.** The app must be allowed to produce long stretches with nothing that sounds meaningful.
4. **No complete generated sentences.** If the engine uses source audio fragments, keep source units short enough that it cannot masquerade as a deliberately written answer.
5. **No speech recognition driving responses.** Microphone input is for recording only unless the product later explicitly introduces another mechanism and discloses it.
6. **No obvious per-session loop.** Repetition must be minimized; the same recognizable fragment should not recur predictably after app restart.
7. **Do not stack many voices simultaneously by default.** One dominant fragment stream is more credible and more intelligible than a wall of chatter.
8. **Default processing mostly dry.** No default echo or reverb. The strongest available user evidence says extra effects often make words harder to understand. [S08][S58]
9. **Headphones must work naturally.** Do not force speaker playback. This supports normal private listening and Estes-style use. [S32][S40][S41]

### Mechanism-dependent rule

Do **not** show `FM 99.7 MHz`, `AM 880 kHz`, or a “station” display unless the audio engine actually has a meaningful frequency/band model. If the engine is a procedural or bank-based sweep, show a truthful `SWEEP`, `SOURCE`, or `POSITION` value instead.

This is a major credibility safeguard. A fake MHz counter would make the interface look convincing in screenshots while making the mechanism less defensible to serious users.

## 7.4 Clean vs dirty audio

Users do not uniformly want pristine sound. Spirit-box use relies on noise, radio fragments, and ambiguity. But “dirty” should mean **source texture**, not processing sludge.

**V1 default:** preserve sweep/static texture; avoid echo/reverb/distortion controls.  
**Later test candidate:** a single `STATIC: FULL / REDUCED` control if the engine can expose it cheaply and honestly.  
**Do not build:** 4-slider audio mixer on the main screen.

---

# 8. SESSION WORKFLOW — HOW PEOPLE ACTUALLY USE THESE TOOLS

## Evidence

Community and product sources consistently show three common patterns:

1. **Question-and-pause session:** investigator asks questions aloud and listens for potential replies. [S39][S41]
2. **Recorded review:** investigators often record because possible voices are missed live and reviewed later. [S21][S32][S39]
3. **Estes / sensory-deprivation use:** one person listens through over-ear/noise-isolating headphones, often blindfolded, while another person asks questions; the listener is intentionally deprived of question context. [S40][S41][S42]

Sessions vary widely. Evidence includes short EVP recordings, 15–20 minute guidance for sensory-deprivation fatigue, and longer group investigations. It would be false precision to declare one universal session length. [S21][S41][S43]

## V1 workflow

### 1. Open app

Land directly on the powered-off instrument. No home-dashboard grid.

### 2. POWER

- press POWER;
- short mechanical power-on haptic;
- display illuminates;
- sweep begins at the last-used settings or safe defaults;
- first run shows a single compact coaching overlay: `BAND • DIRECTION • RATE • REC • MARK`.

### 3. Listen / ask questions

- no prompts telling the user what questions to ask;
- no on-screen generated “ghost dialogue”;
- screen remains readable but visually quiet;
- controls stay in fixed positions.

### 4. Record if desired

- first tap on REC requests microphone permission;
- permission copy explicitly says the microphone is used to capture the session when REC is active;
- REC becomes visibly latched;
- top status changes to red `REC` + elapsed time;
- MARK becomes active.

### 5. MARK interesting moments

- one thumb tap;
- no confirmation modal;
- distinct haptic;
- visual mark count increments;
- marker is stored at the exact session timestamp;
- no beep is recorded into the audio.

### 6. Stop / power off

- pressing REC saves recording immediately;
- powering off while recording automatically finalizes and saves — never discard;
- display dims with power-off haptic.

### 7. Review

- post-session sheet: duration, marks, `REPLAY`, `SHARE`, `DONE`;
- replay opens waveform with visible marker ticks;
- previous/next mark buttons jump directly to marked timestamps;
- user can scrub freely.

---

# 9. RECORDING / MARKERS — TRYING TO DISPROVE THE V1

## Current hypothesis

`recording + MARK timestamps + replay` is enough.

## Evidence against the minimum

The strongest serious-investigator workflow includes **moving recordings off the device** for review or evidence preservation. SBox records to SD; community users move files into audio software; newer recorder apps and Ghost Radio include share/export. [S32][S33][S39][S22]

GhostTube EVP’s review workflow uses scrubbable visualization and tagging because a linear audio file becomes cumbersome when the interesting moment is seconds inside a longer recording. [S21]

Spirit Talker file-loss complaints show that users emotionally value accumulated session history. [S03]

## Verdict

The V1 should be:

- **record**;
- **MARK**;
- **waveform replay**;
- **previous/next marker navigation**;
- **local session history**;
- **system Share/Export of the original recording**.

### Do not add in V1

- AI transcript;
- automatic “EVP detection”;
- generated captions of what the app thinks it heard;
- noise-reduction editor;
- pitch shifting;
- playback speed controls;
- multi-track editor;
- cloud sync/account;
- collaborative evidence feed;
- per-marker text notes.

The last item — marker notes — is useful but not necessary to validate the core workflow. A timestamp is the high-leverage primitive.

---

# 10. TRUST / CREDIBILITY

## 10.1 The core trust problem

Paranormal app skepticism is not confined to people who reject the paranormal. Self-described believers and hobbyists frequently distinguish between physical instruments and apps they believe are simply preprogrammed. [S35][S36][S37]

The recurring suspicions are:

- the app is listening to the question and generating a related answer;
- the app contains a bank of scary/common words and random timing;
- fake EMF graphics are unrelated to actual phone sensors;
- internet/location access feeds personalized responses;
- output is a loop;
- the app claims “real detection” without describing a mechanism. [S03][S08][S35][S36][S37]

## 10.2 Exact trust architecture

### Microphone

**Rule:** the spirit-box sweep must run without microphone permission. Request microphone access only when the user taps REC. Apple provides explicit recording permission APIs, so there is no technical need to ask at launch. [S51]

**Recommended copy:**

> **Microphone**  
> Used only when you press REC so your questions and the session can be captured. It is not used to choose or generate responses.

### Magnetometer

> **V1 product decision (superseded):** Magnetometer / raw MAG / EMF-meter functionality is **out of V1** per the canonical source of truth. The research below is retained as audience/competitor evidence only.

Apple’s Core Motion APIs expose three-axis magnetic field measurements in microteslas. Raw measurements include the Earth’s field plus device/surrounding bias; calibrated motion data can remove device bias and reports accuracy. [S49][S50]

**Research rule (if ever revisited post-V1):** call the feature `MAGNETIC FIELD` or `MAG`, display `µT`, and explain conventional causes.

**Recommended copy:**

> **Magnetic Field**  
> Reads the iPhone magnetometer in µT. Magnets, speakers, wiring, cases/accessories and nearby electronics can change the reading. A spike is an environmental measurement, not proof of paranormal activity.

### Temperature

Do not claim the iPhone is measuring room temperature. Physical MEL/SB7 hardware has dedicated temperature sensing; the iPhone interface does not provide an equivalent general-purpose ambient-temperature sensor for this use. The app should simply omit temperature. [S24][S27]

### Paranormal claim

GhostTube maintains strong ratings while using restrained disclaimers that paranormal communication is theoretical. [S05][S19][S21]

**Recommended copy:**

> **Experimental tool**  
> Paranormal communication has not been scientifically established. This app is designed for spirit-box / ITC experimentation and entertainment. Interpret what you hear for yourself.

### Engine explanation

The final wording depends on the real audio engine. The screen must state:

- where the sweep audio comes from;
- whether it uses radio streams, licensed/archive snippets, synthetic noise, or short sound-bank fragments;
- whether any complete words/sentences are deliberately stored;
- whether the microphone affects output;
- whether the engine requires internet;
- whether sessions work offline after entitlement is active.

**Do not ship a “How it works” screen until every sentence is technically true.**

## 10.3 Transparency language style

Use calm instrumentation language, not defensive language.

Good:

- `Uses iPhone magnetometer`
- `Microphone is used only while recording`
- `No speech recognition`
- `No AI-generated replies`
- `Audio source: …`
- `Works offline after access is active` (only if true)

Bad:

- `100% REAL GHOST DETECTION`
- `Scientifically proven`
- `Entity detected`
- `Spirits control your phone`
- `Professional EMF meter` for a phone magnetometer

---

# 11. HAPTICS — FIRST-CLASS, BUT DISCIPLINED

## Audience finding

Direct demand for “more vibration” is weak. Direct demand for **clear field feedback** is strong. Physical equipment earns praise when the user can understand an event without staring at a complicated display: K-II LEDs, REM Pod lights/tones, illuminated meter screens, mechanical buttons, and distinct start/stop states. [S25][S27][S28]

Apple’s guidance maps well to this audience: haptics should reinforce a clear action or event, short haptics are generally preferable in ordinary apps, haptics should be optional, and they should not interfere with the microphone/camera/gyroscope experience. [S46][S47][S48][S56]

Therefore the correct strategy is **a small tactile vocabulary that feels like instrument switches and detents**, not paranormal “buzz events.”

## PROPOSED HAPTIC LANGUAGE

> The numeric values below are **design targets**, not evidence-derived physiological constants. Tune on real devices. Use Core Haptics where available and standard selection/impact feedback where it produces a better native result.

| Event | Purpose | Pattern | Intensity | Approx. timing | Default | Evidence / rationale |
|---|---|---|---|---|---|---|
| **Power On** | Make the app feel like a device becoming live | Crisp medium transient, short pause, smaller confirming transient | Medium then light | ~35 ms + 70 ms gap + ~25 ms | ON | Physical tools have unambiguous power state; two-stage pattern feels like switch + circuit wake [S23][S25] |
| **Power Off** | Distinct from power-on; signal finality | Single rounded medium transient with slightly longer decay | Medium-low | ~70–100 ms | ON | Clear state transition without theatrics; Apple favors intentional short feedback [S46][S48] |
| **Mode Change** | Confirm AM/FM or other truthful engine mode | One crisp selection tick | Light | ~15–25 ms | ON | Mirrors physical toggle/detent and Apple selection feedback [S23][S46] |
| **Sweep Rate Change** | Let users change rate without staring | One crisp tick per discrete rate step | Light | ~15–20 ms | ON | Hardware sweep rates are discrete values; tactile detents reduce visual dependence [S23][S24] |
| **MARK** | Confirm an interesting moment was captured without looking | Distinct double transient: crisp + stronger crisp | Medium-high | ~30 ms + 65 ms gap + ~45 ms | ON when not restricted by recording mode | MARK is the most important blind-use action; must be unmistakable |
| **Record Start** | Confirm capture has begun | Firm single impact followed by very light tick | Medium | ~40 ms + 80 ms gap + ~20 ms | ON, **played before capture begins** | Recording state must be unambiguous; avoid polluting captured audio [S21][S32][S57] |
| **Record Stop** | Confirm capture has ended/saved | Single firm rounded impact | Medium | ~60–80 ms | ON, **played after capture finalizes** | Different feel from start and protects recording [S57] |
| **Magnetic Event** | Optional eyes-free notice of a user-defined/raw field change | Single soft rounded pulse; no “alarm” pattern | Medium-low | ~50–70 ms | **N/A — excluded from V1** | Research only; magnetometer/EMF is out of V1 per canonical source of truth [S25][S28][S49] |
| **Optional Tactile Scan** | Experimental “instrument motor” feel | Very light crisp tick, rate-linked but hard-capped at <=2 Hz | Very light | ~10–15 ms each | **OFF** | **INFERENCE only.** No strong user demand; continuous haptics risk fatigue/distraction and recording interference [S56] |
| **Purchase confirmation** | Confirm transaction result | Native system success feedback | System | System | ON | Do not create a paranormal-specific money vibration; use platform semantics |

## Recording conflict: critical implementation rule

Apple’s `AVAudioSession` defaults to **disallowing haptics and system sounds while recording input**. Apple’s HIG also explicitly warns that haptics can disrupt microphone experiences. [S56][S57]

### V1 recording policy

- `Record Start` haptic happens **before** the recording capture boundary.
- `Record Stop` haptic happens **after** the final audio sample is committed.
- Magnetic Event haptics are not in V1 (magnetometer/EMF excluded per canonical scope);
- Optional Tactile Scan is suppressed during recording;
- MARK is the only candidate haptic during recording because it is user-triggered and operationally important.

**Preferred V1:** keep MARK haptic enabled only if testing confirms it does not create objectionable mechanical contamination. If it does, the recording mode should still show an instant visual marker and offer a `MARK HAPTIC DURING RECORDING` toggle. Do not add a beep.

## Haptics we should NOT implement

- random vibration labeled or implied as “spirit detected”;
- vibration every time an audio fragment occurs;
- full-rate vibration at 100–350 ms sweep intervals;
- long continuous rumble during scanning;
- escalating horror/game-controller effects;
- repeated buzzing for magnetic readings with no cooldown;
- haptic alerts during replay;
- acoustic confirmation sounds for MARK;
- different “entity types” represented by vibration patterns.

These are either unsupported by audience evidence, likely to annoy during listening, or harmful to credibility.

---

# 12. VISUAL DETAILS — EVIDENCE-BACKED INVENTORY

## Color

### Recommended

- **Body/background:** near-black matte graphite.
- **Primary instrument display:** warm amber-red / red-orange, low bloom.
- **Primary text outside display:** off-white / light gray.
- **Recording:** a single clear red REC indicator.
- **Magnetic meter (research only; not V1):** restrained 5-segment neutral-to-warning scale; if a multicolor scale is used, use green → amber → red only for magnitude, never “safe → ghost.”

### Evidence

- P-SB7 and MEL hardware use red illuminated displays designed for field/night readability. [S23][S24][S27][S52]
- K-II’s green-to-red LEDs are praised because spikes are easy to see in dark environments. [S25][S53]
- GhostTube proves that a nearly black modern surface with white controls is accepted by the audience. [S07][S52]

### Avoid

- saturated purple occult gradients;
- bright neon cyan/magenta as the main identity;
- radioactive green “Matrix” styling;
- red flashing alarm backgrounds;
- fake night-vision green unless the feature is actually a camera mode — which V1 should not have.

## LCD / main display

Use an LCD-*inspired* panel, not an exact seven-segment replica.

- recessed dark display surface;
- warm illuminated numerals;
- tabular/monospaced numbers;
- very subtle scan-line or bloom only if it does not reduce readability;
- persistent `RATE`, `DIR`, and truthful `BAND/SOURCE` state;
- one dominant scan/frequency/position value;
- elapsed session time in a quieter top strip.

**Do not:** copy P-SB7 bezel proportions, exact control grid, logo position, speaker grille, or case silhouette. [S52]

## Button style

- large dark graphite keys with a shallow bevel/recess;
- visible pressed state;
- fixed location;
- uppercase short labels;
- 44pt+ minimum touch targets, with key controls substantially larger;
- no tiny multi-function labels like physical hardware manuals require.

## Typography

- native/modern sans for labels and explanatory UI;
- monospaced/tabular digits inside instrument display;
- no horror font;
- no fake stencil/military font as body text;
- no distressed texture on text.

## Meters

**Use:** segmented horizontal field bar when raw magnetic field is visible — **research note only; magnetometer/EMF is excluded from V1.**  
**Do not use:** analog needle meter unless future evidence proves it improves comprehension. The strongest hardware references here are digital displays and LED bars, not analog dials.

## Graphs

Main screen: none.  
Replay: waveform only.  
No live spectrogram in V1. GhostTube EVP shows that a visualizer can be valuable for review, but the spirit-box main loop does not require a technical-analysis dashboard. [S21]

## Glow

- restrained around illuminated display and active REC lamp;
- no persistent outer glow around every control;
- no “haunted aura.”

## Animation

- scan movement should be quick, mechanical, and deterministic-looking;
- button press: 80–120 ms visual depression/release;
- LCD power-on: short illumination ramp, not cinematic flicker;
- MARK: single brief confirmation pulse/tick on display;
- no floating particles, ghosts, smoke, lens flare, or jump scares.

---

# 13. DARK-ROOM AND ONE-THUMB ERGONOMICS

Field reviews matter because users explicitly mention operating equipment in dark locations. SBox users praise compactness but warn that dense buttons take practice in the dark; K-II users value visible LED state; MEL is marketed around one-hand operation. [S25][S27][S32]

## Requirements

1. **Fixed control positions.** Do not move buttons when recording starts.
2. **MARK in the thumb zone.** It must be hittable without looking.
3. **REC and POWER separated spatially.** Accidental power-off is worse than a missed setting change.
4. **Power-off requires a short hold.** No modal confirmation needed for a normal off action; if recording is active, finalize/save automatically.
5. **Rate controls use discrete steps.** Slider precision is worse in darkness.
6. **Text labels, not mystery icons, for core spirit-box actions.** `FWD`, `REV`, `RATE`, `REC`, `MARK`, `POWER` are faster to learn than abstract symbols.
7. **No swipe-only hidden controls.** Gestures can exist as accelerators in replay, not as the only way to operate the instrument.
8. **Brightness stays restrained.** The app should not blow out dark-adapted eyes.
9. **No mode carousel.** The main screen is the instrument.

---

# 14. APP STORE ICON AND SCREENSHOT CONVERSION

## What must happen in under one second

A user searching `spirit box` should see:

> **“That is a spirit-box instrument, not a ghost-chat game.”**

The recognizable cues are:

- dark handheld-instrument surface;
- illuminated radio-style display;
- scan/sweep state;
- a few labeled physical controls;
- no cartoon ghost or AI-chat bubble.

The product must get those cues without copying the protected visual identity of a specific hardware device.

## ICON DIRECTION — one recommendation

**Icon:** a cropped abstract field-radio faceplate.

- near-black square;
- central warm amber-red rectangular display;
- inside display: three/four illuminated sweep bars plus a small directional arrow;
- one tiny red status LED beneath;
- no readable brand/device text;
- no skull, ghost, Ouija board, pentagram, haunted house, or human face;
- no P-SB7 case silhouette or exact button matrix.

Why: a radio-instrument display is a generic category cue; a specific branded hardware front panel is trade-dress risk.

## SCREENSHOT ORDER

### Screenshot 1 — conversion screenshot

Show the **live main instrument** almost full-screen.

Headline: **`SPIRIT BOX. SWEEP. LISTEN.`**  
Subline: **`A focused field instrument for iPhone.`**

The screenshot itself must visibly show `FWD`, `200 ms`, a truthful band/source state, REC, MARK, and the amber display.

### Screenshot 2 — differentiator

Headline: **`HEAR SOMETHING? MARK IT.`**

Show a thumb hitting the large MARK control with `MARK 03` visible. No fake ghost response text.

### Screenshot 3 — evidence workflow

Headline: **`REPLAY THE MOMENT.`**

Show waveform with 3 amber marker ticks, playback position, Previous Mark / Next Mark.

### Screenshot 4 — trust

Headline: **`NO SCRIPTED ANSWERS.`**

Only if technically true, show 3 concise claims:

- `No speech recognition`
- `Mic only when recording`
- `Mechanism explained in-app`

If the engine uses a finite audio bank, do **not** say “No prerecorded audio.” Say exactly what it uses.

### Screenshot 5 — raw sensor (superseded; not in V1)

Headline: **`RAW MAGNETIC FIELD. NO FAKE “GHOST LEVEL.”`**

Show `MAG 48 µT` and one line: `Uses the iPhone magnetometer. Electronics and magnets affect readings.`

Magnetometer/EMF is out of V1 per canonical scope; retain this screenshot direction only as historical research.

### Screenshot 6 — purchase/trial confidence

Headline: **`TRY A REAL SESSION FIRST.`**

Show access choices only after demonstrating the core experience. This directly addresses the no-demo frustration seen in competitor reviews. [S02]

## What current competitors teach visually

- GhostTube VOX: modern dark panel, waveform, large record affordance, exposed audio controls. Useful as a **mobile hierarchy** reference, not a spirit-box industrial-design reference. [S52]
- P-SB7 / SB7 Pro: red illuminated display and fixed labeled controls create instant “instrument” recognition. Useful for **category semantics**, not for copying. [S52][S54]
- K-II: five clear lights turn a complex measurement into glanceable state. Useful for **glanceability**, not for copying its branded meter face. [S53]
- SBox: field users value compact controls + recording + headphone support; one reviewer warns about button complexity in darkness. [S32]

### Screenshot/reference links

- GhostTube VOX settings screenshot: [S52]
- SB7/SB7 Pro product images: [S23][S54]
- K-II product image: [S25][S53]
- SBox product page with hardware imagery: [S32][S33]

---

# 15. PHYSICAL HARDWARE LESSONS TRANSLATED TO IPHONE

## P-SB7 / SB7 family

### What the hardware does

- AM/FM;
- FWD/REV;
- discrete sweep-rate control;
- numeric display with rate/band/frequency;
- volume;
- illuminated display;
- headphones/speaker;
- power button;
- flashlight/temperature on some versions. [S23][S24]

### What users praise

- compact size;
- straightforward sweep controls;
- reasonable learning curve;
- Bluetooth/headphone options on newer versions;
- real physical instrument feel. [S23]

### What users complain about

- built-in speaker can be insufficient for some users;
- hardware can become button-dense as features accumulate. [S23][S32]

### iPhone translation

Adopt the **sweep-control vocabulary, direct state display, illuminated-panel hierarchy, and compactness**. Do not copy the face layout, red display proportions, speaker grille, exact button grid, logos, product name, or case silhouette.

## SBox Ghost Scanner + Recorder

### What users praise

- recording directly inside the device;
- clear playback;
- Bluetooth/wired headphones;
- loud speaker;
- portability;
- simple core operation. [S32][S33]

### What they dislike

- button learning curve in darkness;
- some users still prefer a dedicated external EVP recorder for separate evidence. [S32]

### iPhone translation

Make recording a first-class key, not a hidden tool. Give users direct access to the file and make replay/marker navigation better than the hardware.

## K-II meter

### What users praise

- “stupidly simple” on/off interaction;
- instant multicolor LED feedback;
- usefulness for baseline checks around known electronics;
- easy dark-room visibility. [S25]

### iPhone translation

Audience research suggested that if magnetic field were shown, a **small raw magnitude display with a glanceable segmented bar** could increase credibility. **V1 decision: exclude magnetometer/EMF entirely** per canonical scope. Do not turn magnetic readings into a “ghost probability.”

## MEL Meter

### What hardware contributes

- simultaneous EMF and temperature;
- red illuminated display;
- one-hand operation;
- flashlight;
- direct numeric units. [S27]

### iPhone translation

The useful lesson is **one hand + direct units**, not “copy all sensor categories.” The iPhone app should *not* fake ambient temperature just because physical hardware has it.

## REM Pod

### What users praise

- immediate bright lights + clear tones;
- sensitivity adjustment;
- easy setup;
- alerts that can be noticed while attention is elsewhere;
- dark-room usability. [S28]

### iPhone translation

Use distinctive feedback for user actions. Magnetic alerts were considered during research but are **out of V1** per canonical scope. Do not equate alerts with paranormal confirmation.

## Ovilus 5

### What it teaches

Ovilus exposes many modes and logs, and its documentation spends significant effort explaining how those modes work. [S31]

### iPhone translation

The log/history concept is useful. The **mode sprawl is not**. A focused spirit-box app should not import Dictionary, True/False, Draw, Motion, Proximity, Oracle, or similar modes.

## Dedicated EVP recorder

A simple Olympus recorder workflow is essentially folder → REC → STOP, and reviewers praise ease of use. [S34]

### iPhone translation

The record path should be equally obvious. Do not force users through naming, location, folder, or metadata prompts before capture.

---

# 16. COMPETITOR / TOOL UI SCORECARD

> Ratings and counts are storefront snapshots and may move. Hardware retailers generally expose individual review counts rather than a normalized App-Store-like average. `Unknown` means the evidence reviewed did not establish the item.

| Product | Platform / physical | Core job | UI style | Old-school vs modern | Control density | Audio approach | Haptics / vibration | Recording | Session history | Trust / transparency | What users praise | What users hate | Rating / review signal | Key screenshots / links | Lessons worth adopting | Elements we must NOT copy | Usefulness |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **GhostTube VOX** | iOS/Android | Radio-stream sound synthesizer / paranormal session | Black modern waveform + sliders | Modern | Medium | Online radio-stream snippets; white noise; echo/reverb/distortion options | Not established | Yes | Some recording workflow | Strong mechanism explanation; paranormal disclaimer; mic optional except recording | No fixed vocabulary; modern tool feel; radio-source explanation | Echo/distortion can obscure words; privacy suspicion; online dependency | 4.4 / ~2.8K iOS | [S07][S08][S52] | Modern hierarchy, waveform, transparency | Do not copy control arrangement, branding, community stack | **Very high** |
| **GhostTube EVP** | iOS/Android | EVP recorder and review | Modern dark recorder | Modern | Medium | Raw microphone + optional experimental modulation | Not established | **Yes** | **Yes** | Strong disclaimer and mechanism detail | Thought-out recorder, tagging, replay, portable field use | Saving/record-state ambiguity in some reviews | 4.7 / ~630 iOS | [S20][S21] | Recording, tagging concept, scrubbable review | Do not copy branded visualizer or feature suite | **Very high** |
| **Spirit Box EMF Ghost Detector** | iOS | Sound-bank ITC + extras | Dark paranormal multi-tool | Mixed | High | Phoneme/partial speech/reverse/foreign fragments + white noise, echo/reverb | Unknown | Not clearly central | Unknown | Explains sound-bank contents | Some users like consistency | No demo; overlapping voices; repeated output; gimmick accusation | 4.0 / ~454 | [S01][S02] | Trial must expose real audio; disclose source units | Do not copy banks/branding/radar extras | High (negative evidence) |
| **Spirit Box EVP Ghost Detector** | iOS | Spirit-box + magnetometer + recording | Modern paranormal instrument | Mixed | Medium-high | App-specific spirit-box output tied to sensors | Unknown | **Yes** | Yes | Data-not-collected label; “real hardware” messaging | “Feels like equipment”; recording/review; raw phone hardware | Small review sample; super-app creep in category | 4.7 / 49 | [S10] | Equipment tone, recording prominence | Do not copy wording, layouts, claims | High, but low sample |
| **Spirit Talker** | iOS | Sensor-triggered word/phrase talker | Dark paranormal device | Mixed | Medium | Spoken/text words and phrases | Unknown | Files/history present | Yes | Disclaimer says paranormal theoretical | Long-time investigator adoption by some users | Programmed-feeling names/phrases; creepy voice; sensor credibility complaints; lost files | 2.8 / ~699 | [S03][S60] | Preserve files; avoid creepy voice treatment | Word-generator model, names/phrases, branded identity | **Very high negative reference** |
| **Spirit Entities Talker** | iOS | All-in-one talker/box/EMF/EVP | Feature-rich paranormal suite | Mixed | High | Multiple voice/word/sensor modes | Unknown | Yes | Moderate | Fun, lots of features; recording later analysis | Can feel like broad entertainment suite rather than focused instrument | 4.5 / ~2.3K | [S16] | Recording has broad appeal | Do not import oracle/super-app breadth | Medium |
| **Ghost Hunting Tools - Detector** | iOS | Spirit box/EVP/EMF/word tools | Dark utility-paranormal | Mixed | High | Curated dictionary/randomized inputs per developer response | Unknown | Some session features | Some | Developer explicitly acknowledges randomized inputs | Easy entry point, “authentic” feeling for believers | Skeptics reject randomized word output | 4.2 / ~10K | [S04] | Transparent mechanism beats pretending | Word-response mechanics, multi-tool sprawl | Medium-high |
| **Necrophonic** | iOS | Phoneme/sound-bank ITC | Minimal specialized tool | Mixed / old-school concept | Low-medium | 8 phoneme/partial-speech banks + optional white-noise bank; echo/reverb | Unknown | External/other recording commonly used | No central history | Description explains bank composition | Easy to use; scan rate useful; atmosphere | Overlapping voices; echo hurts intelligibility; volume/intensity | 3.7–3.8 / ~540 | [S06][S58] | Simplicity, mechanism disclosure, rate control | Sound banks, branded styling, claims | High |
| **SBX 12 Spirit Box** | iOS | Simulated/scan spirit box | Heavy device skeuomorphism | Old-school | Medium | Single/dual sweep; FM/multi; rate 50–350ms per listing history | Unknown | No strong evidence | No | Limited | Recognizable “spirit box” appearance | Old visual does not translate into strong rating | ~3.0 / ~735 | [S11][S55] | Category recognition from LCD/control semantics | Exact industrial/device UI imitation | High visual caution |
| **Sono X10 Spirit Box** | iOS | Sensor-triggered phoneme bank | Older dark spirit-box tool | Old-school/mixed | Low | Phonemes/small speech cuts, no full sentences/words claimed | Unknown | No central recording | Unknown | Unusually detailed mechanism explanation | Users who understand method value explanation | Silent/confusing output and loop suspicion in negative reviews | 3.4 / ~982 | [S15] | Explain audio source precisely | Do not use sensor-trigger claim without solid model | High trust reference |
| **Paranormal EMF Recorder and Scanner** | iOS | Magnetometer logging | Utility / scientific-looking | Modern utility | Medium | N/A | Not established | Sensor logging | Yes | Explicitly says real magnetometer measurements and separates simulated option | Users test it near real electronic/magnetic sources | “EMF” terminology can still overstate what phone measures | 4.2 / ~620 | [S13] | Raw data, charts/history, real sensor units | Do not copy UI; do not call magnetometer full-spectrum EMF | High sensor reference |
| **Ghost EVP Radio - Paranormal** | iOS | Spirit box + EMF + motion | Instrument-themed utility | Mixed | High | Randomized signals/spirit-box audio + tools | Listing includes vibration/audio/flash alerts | Yes | Yes | Some calibration explanation | Feature depth, paid upfront, analysis tools | “Exciting but confusing” style complexity; calibration uncertainty | 4.3 / ~776; $4.99 | [S18] | Direct paid tool positioning, alerts | Multi-tool density, opaque “signal” claims | Medium-high |
| **Ghost Radar Classic** | iOS | Paranormal radar + word output | Radar visualization | Old-school app | Low | Word/event output, not sweep audio | Unknown | No | Limited | Entertainment disclaimer | Immediate colored-dot feedback and simplicity | Low serious-instrument credibility | 3.6 / ~2.4K | [S14] | Immediate legibility for casuals | Radar dots/ghost-map metaphor | Medium |
| **Spirit Words** | iOS | Random word generator | Very simple | Modern/basic | Low | Database of random words | Unknown | No | Scroll list | Description openly states random-word database | Extremely easy to start | Model itself triggers category skepticism | 3.3 / 167 | [S17] | Honesty about mechanism | Entire random-word interaction | High anti-reference |
| **GhostTube original** | iOS | Multi-tool paranormal video | Modern dark toolkit | Modern | High | Dictionary/voices + sensor/video analysis | Unknown | Video/audio | Logs/community | Strong explicit disclaimer and sensor explanation | Polished, large user base, sensor transparency | Super-app complexity is outside this product’s job | 4.3 / ~6.8K | [S19] | Transparent claims can coexist with appeal | Tool-grid breadth/community dependence | Medium-high |
| **Ghost Hunting Radio Spirit Box** | Android | Manual simulated radio sweep + recording | Radio-tuner instrument | Old-school/mixed | Medium | Simulated AM/FM/shortwave using archival broadcasts | Unknown | **Yes** | Stats | Explicit entertainment note; tells users source is archival radio | Hands-on tuning, speed/direction, offline packs, WAV export | Ads/IAP; manual tuning adds more work than this V1 needs | 4.5 / ~821; 100K+ installs | [S22] | Honest radio mental model, export | Archive content/library, captions/station model | **Very high** |
| **P-SB7 / SB7** | Physical | Radio sweep spirit box | Black handheld, red LCD, fixed labeled buttons | Old-school hardware | Medium-high | Real AM/FM frequency sweep | Physical button feel; audio/temp alerts on variants | No integrated recording on standard SB7 | No | Mechanism observable as radio scan | Compact, recognizable, sweep controls, newer Bluetooth | Speaker loudness for some; small button matrix | 80 retailer reviews on current GhostStop page | [S23][S24][S54] | Sweep vocabulary, red display, fixed controls | Exact case, display, labels/layout, grille, brand | **Very high** |
| **SBox Ghost Scanner + Recorder** | Physical | Sweep radio + direct recording | Compact black field radio | Old-school hardware | Medium-high | AM/FM sweep | Physical controls | **Yes** | Playback / SD file | Direct recording path is clear | Recording, Bluetooth/wired headphones, loud audio, portability | Button learning curve in the dark | 120 retailer reviews | [S32][S33] | Recording must be first class | Button map/case/product branding | **Very high** |
| **K-II EMF Meter** | Physical | EMF magnitude indication | Simple black meter + five LEDs | Old-school hardware | Very low | N/A | Physical switch; visual LEDs | No | No | Readings can be baseline-tested near known sources | Immediate LED feedback, simplicity, sturdiness, dark visibility | Coarse values; susceptible to normal EM sources | 29 retailer reviews | [S25][S53] | Glanceability, one-action operation, baseline mindset | Exact five-light face/trade dress | High |
| **MEL Meter** | Physical | EMF + temperature | Red numeric display | Old-school scientific meter | Medium | N/A | Physical controls; visual display | Some variants/logging context | Limited | Direct units | One-hand operation, red display, combined readings | Manual/control learning mentioned | 17 retailer reviews | [S27] | One-hand + units | Sensor set, case/display layout | Medium-high |
| **REM Pod** | Physical | Proximity/field-change alert | Instrument with antenna/lights | Old-school hardware | Low-medium | Audio tones | **Core feedback is lights + tones** | No | No | Sensor behavior can be tested around normal interference | Clear alerts, simple setup, visible in dark | Many alerts can be overinterpreted; not data-rich | 53 retailer reviews | [S28] | Unmistakable event feedback | Antenna/light geometry, paranormal certainty | Medium |
| **Ovilus 5** | Physical | Environmental readings mapped to words/modes | Touchscreen instrument | Modernized hardware | **High** | Dictionary/phonetic voice modes | Physical audio/touch | Logs word events | Yes | Manufacturer documents mapping and says no random generator | Variety, logs, explicit mode definitions | Mode count creates learning burden | Manufacturer/retailer rather than App Store signal | [S31] | History/log concept, explain mechanism | Word mapping, icons, mode system, industrial design | Medium |
| **Olympus EVP Recorder** | Physical | Audio capture | Conventional digital recorder | Utility hardware | Low | Raw microphone | Physical button feel | **Yes** | Folder/file system | Clear recorder semantics | User-friendly, live listening | Separate device burden | 26 retailer reviews | [S34] | REC/STOP simplicity | Device styling/brand | High recording reference |

---

# 17. FINAL PRODUCT RECOMMENDATION — EXACT V1 EXPERIENCE

## DESIGN NAME

**FIELD RADIO INSTRUMENT**

A restrained handheld spirit-box interface that borrows the *grammar* of field radio equipment — illuminated display, fixed scan controls, physical button affordances — while using native iPhone spacing, typography, navigation, audio routing, file handling and accessibility.

## 17.1 MAIN SCREEN

### Overall layout

Portrait, one screen, no scrolling during a session.

```text
┌─────────────────────────────────────┐
│ SESSION  00:07:42          REC 00:03:11 │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  FM*      FWD       200 ms    │  │
│  │                               │  │
│  │          99.7*                │  │
│  │  ▸ ▸ ▸ ▸ ▸  SWEEP  ▸ ▸ ▸     │  │
│  │                               │  │
│  │  MAG 48 µT   ▮▮▮▯▯           │  │
│  └───────────────────────────────┘  │
│                                     │
│ [ AM/FM* ] [ FWD/REV ] [ RATE − + ]│
│                                     │
│ [  REC  ] [       MARK       ] [POWER]│
│                                     │
│              SESSIONS               │
└─────────────────────────────────────┘
```

`*` Only use AM/FM and MHz/kHz if those values are truthful to the actual audio engine. If not, replace them with truthful `SOURCE` / `SWEEP POSITION` terminology. This is non-negotiable.

The magnetometer row (`MAG xx µT`) in the wireframe above is **not in V1**; omit from shipping UI per canonical scope.

### Hierarchy

1. **Instrument display** — dominant.
2. **MARK** — dominant action in lower thumb zone.
3. **REC** — unmistakable but smaller than MARK.
4. **FWD/REV + RATE + band/source** — always visible, secondary.
5. **POWER** — separated from REC/MARK and requires a short hold to shut down.
6. **SESSIONS** — text/button below instrument deck, visually quiet.

### Display

- matte near-black outer surface;
- recessed amber-red display panel;
- large monospaced numeric scan/frequency/position value;
- top display row: truthful source/band, direction, rate;
- bottom display row: no magnetometer/MAG strip in V1 (excluded per canonical scope);
- scan activity shown as a simple moving segmented line, not a radar or spirit-strength meter;
- no fake analog needle;
- no ghost text/phrases appearing on top of the instrument.

### Controls

#### POWER

- dark rectangular key with tiny status lamp;
- tap/brief press powers on;
- hold ~0.4 sec powers off;
- power-off during recording finalizes/saves first.

#### FWD / REV

- one two-state rectangular control;
- labels remain visible;
- selected state is lit, not replaced by an icon.

#### RATE

- `−` and `+` detents around current `ms` value;
- target values if the engine supports the same traditional range: **100, 150, 200, 250, 300, 350 ms**;
- default **200 ms** because it is common, understandable, and sits in the middle of traditional P-SB7 settings. [S23][S24]

#### AM / FM

- only if the engine genuinely has band semantics;
- otherwise use one truthful source selector or omit the mode control entirely.

#### REC

- circular/rounded key with red center lamp;
- idle: `REC`;
- active: red lamp + `REC` top status + elapsed capture time;
- no layout changes when recording begins.

#### MARK

- widest button in lower center;
- label `MARK` always visible;
- while recording: tap creates timestamp and increments compact marker count (`MARK 03`);
- when nothing can be replayed/recorded: disabled, not hidden;
- no confirmation sheet;
- no sound effect.

### One-thumb behavior

The user should be able to:

- hit MARK repeatedly without looking;
- change rate one detent at a time;
- flip direction;
- start/stop recording;
- power down;

without reaching into the top third of the phone.

## 17.2 VISUAL IDENTITY

### Material language

- matte graphite/black instrument surface;
- subtle inset panel seams;
- tiny restrained specular highlight on physical-looking keys;
- illuminated display and status lamp are the only meaningful glow;
- no fake screws;
- no faux speaker grille;
- no worn metal;
- no leather/wood;
- no exact hardware body silhouette.

### Old-school / modern balance

**Old-school:** display hierarchy, labels, control permanence, rate/direction semantics, physical button affordance.  
**Modern:** typography, spacing, accessibility, system navigation, waveform replay, share sheet, purchase flow, settings.

### Degree of skeuomorphism

**Moderate.** The screen should feel like a physical instrument panel, but nobody should confuse it with a software photograph of a specific commercial device.

## 17.3 AUDIO BEHAVIOR

- immediate sweep on power-on;
- rate visibly and audibly changes cadence;
- forward/reverse audibly affects the scan model if technically meaningful;
- mostly dry default processing;
- no echo/reverb/distortion controls in V1;
- no complete generated sentences;
- no microphone-driven semantic replies;
- no minimum response frequency;
- null/ambiguous sessions are allowed;
- no obvious session loop/repetition;
- headphone output works with normal iOS routing;
- output does not become louder or “more active” merely because the user asked a common question.

## 17.4 HAPTIC BEHAVIOR

Default ON:

- Power On;
- Power Off;
- Mode Change;
- Sweep Rate Change;
- REC start/stop outside recording boundary;
- MARK if real-device testing confirms acceptable recording contamination.

Default OFF:

- Tactile Scan.

Magnetic Event haptics were considered during research but are **out of V1** per canonical scope.

Never:

- random “ghost response” vibration;
- continuous rumble;
- haptic on every audio fragment;
- horror/game effects.

## 17.5 SESSION WORKFLOW

`Open → Power → Listen / ask → REC → MARK moments → Stop → Replay → Share / Done`

No dashboard between launch and instrument. No profile. No haunted-location feed. No “select investigation type.”

## 17.6 RECORDING / REPLAY WORKFLOW

### Sessions list

Each saved row:

- date + time;
- duration;
- number of markers;
- no generated title required.

### Replay

- waveform;
- amber vertical MARK ticks;
- play/pause;
- scrubber;
- `‹ MARK` and `MARK ›` buttons;
- current time / total time;
- system `Share` action exporting the original audio file;
- delete in overflow/context action with confirmation.

### Persistence

- local-first;
- no account required;
- do not silently delete older recordings;
- storage use visible in Settings later if needed.

## 17.7 SETTINGS

Keep settings short.

### SESSION

- `Keep Screen Awake During Session` — ON

Magnetometer / magnetic-alert settings are omitted — not in V1 per canonical scope.

### HAPTICS

- `Instrument Haptics` — ON
- `MARK Haptic While Recording` — ON only if clean in testing
- `Tactile Scan` — OFF

### AUDIO

- no mixer in V1;
- only expose a software output-gain/static control if the engine genuinely requires it beyond iPhone hardware volume.

### PRIVACY / TRUST

- `How It Works`
- `Microphone & Recording`
- `Sensor Notes`
- `Privacy`

### ACCESS

- `Restore Purchases`
- current entitlement (`Trial`, `Tonight Pass`, `Lifetime`)

No theme selector. No skins. No sound-bank marketplace. No haunted map.

## 17.8 HOW IT WORKS / TRUST SCREEN

Use a calm one-screen explainer.

### Header

**WHAT THIS INSTRUMENT DOES**

### Copy structure

**Sweep audio**  
`[Exact engine description goes here.] The app does not use speech recognition to choose responses.`

**Recording**  
`The microphone is used only when you press REC so your spoken questions and the session can be captured.`

**Magnetic Field** *(superseded — not in V1; retained as historical research copy only)*  
`The MAG display reads the iPhone magnetometer in µT. Magnets, speakers, wiring, cases/accessories and nearby electronics can change the reading.`

**Interpretation**  
`Paranormal communication has not been scientifically established. This is an experimental spirit-box / ITC tool. Interpret what you hear for yourself.`

**Privacy / offline**  
State exactly whether session processing is on-device and which entitlement checks require internet. Never promise “offline” beyond what the shipping implementation supports.

## 17.9 APP STORE ICON

One icon direction only:

- black/graphite instrument crop;
- centered amber-red display window;
- simple horizontal sweep bars + direction indicator;
- one tiny red LED below;
- no ghost face;
- no skull;
- no text smaller than it can render;
- no replica SB7 case.

## 17.10 SCREENSHOT DIRECTION

1. **SPIRIT BOX. SWEEP. LISTEN.** — main instrument.
2. **HEAR SOMETHING? MARK IT.** — thumb / MARK state.
3. **REPLAY THE MOMENT.** — waveform + marks.
4. **NO SCRIPTED ANSWERS.** — only if technically true; explain mic and mechanism.
5. **RAW MAGNETIC FIELD.** — superseded; magnetometer/EMF is not in V1.
6. **TRY A REAL SESSION FIRST.** — trial/access confidence.

---

# 18. DESIGN DO / DON'T LIST

## DO

- make the app recognizable as a spirit box immediately;
- use a warm red/amber display for dark-room instrument identity;
- keep FWD/REV and RATE visible;
- show `ms` explicitly;
- make MARK the easiest button to hit blindly;
- make recording state impossible to miss;
- let quiet/meaningless stretches occur;
- keep source audio more intelligible than theatrical;
- keep sessions locally accessible;
- let users export original recordings;
- disclose exact audio mechanism;
- request microphone permission only at REC;
- use actual `µT` magnetic field units only if sensor data were ever shown post-V1 (not in V1);
- make haptics short, mechanical, and optional;
- suppress unsolicited haptics during recording;
- let iPhone physical volume buttons do what they already do well.

## DON'T

- copy the SB7/SBox industrial design;
- use the SB7 name in product identity;
- claim the phone measures ambient temperature;
- claim a magnetometer is a comprehensive EMF/ghost detector;
- show a fake frequency just because it converts well visually;
- add skulls, Ouija boards, ghosts, smoke, VHS horror, or neon séance art;
- use complete canned “spirit replies”;
- generate AI dialogue;
- use speech recognition to make answers feel relevant;
- run echo/reverb by default;
- create a multi-tool dashboard;
- add SLS camera, radar, oracle, ghost dictionary, haunted map, flashlight, social feed or AI interpreter in V1;
- hide recording in a menu;
- make MARK produce a beep;
- vibrate randomly as if a “presence” was detected;
- paywall the user before they hear the actual core experience once.

---

# 19. PRE-MORTEM — TRY TO DISPROVE THIS DESIGN

## Failure mode 1: serious users still think it is a toy

### Why it could happen

A red LCD and chunky buttons can become costume design if the underlying engine does not support the displayed semantics.

### Evidence that would falsify the direction

Serious hobbyists independently say the interface looks like a “fake SB7 app,” “toy radio,” or “Halloween skin,” especially when they notice fake band/frequency values.

### Mitigation

Truthful labels first. Reduce decorative casing before removing instrument semantics.

## Failure mode 2: it looks too much like existing hardware

### Why it could happen

The SB7 silhouette, red display and button matrix are strongly recognizable. Over-referencing those elements creates trade-dress/IP risk and can make the product look like an unauthorized software replica.

### Redesign trigger

If blinded testers identify a specific commercial device/brand from the UI before being told the app category, similarity is too high.

### Mitigation

Change panel proportions, control geometry, display aspect, typography and button grouping. Keep generic concepts only.

## Failure mode 3: it is too modern and loses instant “spirit box” recognition

### Why it could happen

A generic waveform + giant record circle reads as “voice recorder.”

### Redesign trigger

In a one-second screenshot test, target users cannot identify the screen as a spirit box without reading the title.

### Mitigation

Strengthen sweep state, rate/direction labels and instrument display — not paranormal decoration.

## Failure mode 4: it is too old / looks like a cheap clone

### Why it could happen

Older spirit-box apps already use literal faux-device chrome. SBX 12 and older bank apps do not have standout ratings simply because they look old-school. [S11][S15]

### Redesign trigger

Users call it “dated,” “Android-looking,” “cheap,” or “a screenshot of hardware.”

### Mitigation

Flatten textures, preserve native typography/spacing, keep only physical affordances that improve interaction.

## Failure mode 5: controls are too complicated

### Why it could happen

Hardware enthusiasts can tolerate several dedicated buttons, but one SBox reviewer specifically calls out a dark-room learning curve. [S32]

### Redesign trigger

First-time users cannot power on, change rate, record and mark without explanation in a 30-second task.

### Mitigation

Do not add another main-screen control. Move the least-used control to Settings before shrinking buttons.

## Failure mode 6: controls are too simple for serious users

### Why it could happen

If the app is just POWER + spooky waveform, it is indistinguishable from a noise generator.

### Redesign trigger

Experienced testers immediately ask where sweep direction and rate are or describe it as a recorder/white-noise app.

### Mitigation

Keep rate + direction visible. Keep truthful band/source state visible.

## Failure mode 7: haptics ruin listening or contaminate recordings

### Why it could happen

Apple explicitly warns that haptic force can disrupt microphone experiences and disables haptics/system sounds during recording by default. [S56][S57]

### Redesign trigger

MARK produces a clearly audible/mechanical artifact in the captured track or users disable haptics after one session because they are distracting.

### Mitigation

Suppress scan haptics during recording. Magnetic-event haptics are not in V1. If needed, suppress MARK haptics during recording too and retain only visual confirmation.

## Failure mode 8: transparency reduces the paranormal “magic”

### Why it could happen

Some users prefer suggestive language and may dislike disclaimers.

### Evidence against the fear

GhostTube apps maintain strong review counts while explicitly explaining theoretical/experimental status; multiple app reviews value knowing the audio or sensor mechanism. [S05][S07][S10][S21]

### Redesign trigger

Only if real target testing shows the trust screen materially reduces trial-to-session start while not improving credibility scores.

### Mitigation

Keep transparency concise and non-preachy. Do not put a scientific disclaimer modal in front of every session.

## Failure mode 9: serious and casual audiences want incompatible interfaces

### Why it could happen

Serious users want control; casuals want one-button immediacy.

### Current solution

Safe default settings + visible but simple rate/direction controls. Casual users can press POWER and ignore them; serious users can change them.

### Redesign trigger

Casual users repeatedly change controls accidentally or serious users repeatedly ask for hidden core scan parameters.

## Failure mode 10: recording is not worth the complexity

### Why this bear case is weak

Recording/review demand appears across app reviews, hardware reviews and investigator workflow discussions. [S10][S16][S20][S21][S32][S39]

### What would change the decision

Only if prototype sessions show users almost never record and almost never replay, despite being shown the feature, while recording materially destabilizes the audio engine.

## Failure mode 11: “spirit box” conversion requires protected visual associations

### Why this is unlikely

Generic category cues — radio sweep display, rate/direction, illuminated numeric panel, physical controls — appear across multiple products, not only one branded device. [S11][S22][S23][S32]

### Kill trigger

If screenshot testing shows users only understand the app when the UI gets so close to P-SB7/SBox trade dress that legal safety becomes questionable, abandon the visual treatment and re-test a more abstract radio-instrument face.

---

# 20. BUILD GATE

## WHAT WE SHOULD BUILD — EXACT V1 INTERFACE

### Main instrument

- matte graphite field-instrument screen;
- warm amber/red LCD-inspired scan panel;
- truthful sweep/source value;
- FWD/REV;
- discrete sweep rate in ms;
- AM/FM only if real to engine;
- session timer;
- REC;
- very large MARK;
- separate guarded POWER;
- fixed one-thumb layout;
- mechanical control haptics.

### Recording

- microphone permission only after REC tap;
- local audio recording;
- marker timestamps;
- visible record timer/state;
- automatic safe finalization if user powers off.

### Replay

- waveform;
- visible marker ticks;
- scrubbing;
- previous/next marker;
- Share/Export original audio;
- chronological session history.

### Trust

- one `How It Works` screen;
- exact audio source/mechanism;
- no speech-recognition statement if true;
- mic-used-only-for-recording statement if true;
- experimental/paranormal-not-scientifically-established disclosure;
- honest offline behavior.

### Commerce presentation

- genuine core-session trial before purchase;
- $1.99 Tonight Pass (24 hours, non-renewing) and $9.99 Lifetime launch options per canonical product strategy; no 7-day tier;
- no auto-renewing subscription initially;
- no ads.

## WHAT WE SHOULD NOT BUILD

- SLS camera;
- ghost radar;
- word/phrase generator;
- AI chatbot or AI interpretation;
- generated complete sentences;
- haunted-location map;
- oracle / yes-no / dice / tarot modes;
- camera/video toolkit;
- flashlight button;
- fake ambient temperature;
- fake “EMF ghost strength”;
- magnetometer / raw MAG readout / magnetic-field alerts in V1;
- fake frequency readout;
- echo/reverb/distortion mixer;
- skins/themes;
- social feed;
- cloud account;
- automatic EVP detector;
- transcription;
- complex editing suite;
- sound-bank marketplace;
- haptic “ghost events.”

## WHAT WE STILL DO NOT KNOW

Only two material design questions remain:

1. **Exact audio-engine semantics.** This determines whether the main display can truthfully say AM/FM and MHz/kHz, and what precise “How It Works” copy can ship.
2. **MARK haptic while microphone recording.** Apple’s platform behavior makes this a real audio-quality question; it needs on-device testing.

**Resolved (no longer open):** Whether the compact magnetometer readout increases credibility or creates feature-bloat / sensor confusion. Magnetometer/EMF is **out of V1** per the canonical source of truth.

None of these blocks the base UI architecture.

## CHEAPEST PRODUCT TEST

Do **not** build the full app to answer the remaining UI question.

Create a **single-screen on-device interaction prototype** with:

- the recommended field-radio visual treatment;
- working Power / FWD-REV / Rate / REC / MARK press states;
- prerecorded or placeholder sweep audio;
- real control haptics;
- no backend, no real spirit-box engine, no history implementation.

Test it against **one deliberately cleaner modern-black alternative** with the same controls — not to choose from endless concepts, but to falsify the field-instrument skin.

Use target users from both groups:

- people who have used a physical spirit box or paranormal investigation equipment;
- casual believers/curious users who have used paranormal apps.

### Test tasks

1. Show the screenshot for **one second**: “What do you think this app does?”
2. Hand them the phone in a dim room: “Start a session.”
3. “Make the scan faster.”
4. “Reverse it.”
5. “Start recording.”
6. While looking away: “Mark the moment you just heard.”
7. Ask: “Does this feel like equipment, a game, or a generic phone app? Why?”
8. Toggle control haptics off without telling them and repeat several actions.
9. Test MARK while recording and listen to the captured track for mechanical artifact.
10. Show App Store screenshot mockups and ask which one is a credible spirit box before reading text.

## KILL / REDESIGN CRITERIA

Redesign the chosen visual/interaction direction if any of these occur:

- a clear majority of serious-equipment testers call the recommended version a toy, fake hardware clone, or Halloween app;
- users cannot identify the app as a spirit box from the first screenshot without relying on product title text;
- first-time users repeatedly miss RATE, direction, REC, or MARK;
- the visual similarity causes testers to name a specific commercial device immediately;
- MARK haptic creates obvious microphone contamination that cannot be solved without weakening recording;
- users consistently prefer the clean modern comparator **because it feels more credible**, not merely prettier;
- raw MAG data causes users to interpret normal magnetic fluctuations as an app-generated “ghost response” despite the labeling *(historical prototype concern; magnetometer excluded from V1)*.

If the field-radio treatment fails, preserve the workflow and simplify the skin. Do **not** rescue it with more paranormal decoration.

---

# 21. FINAL DECISION IN ONE PARAGRAPH

Build a **dark, restrained, old-school field-radio instrument with modern iPhone execution**: warm amber/red LCD-like display, truthful sweep status, visible FWD/REV and millisecond rate controls, large REC and even larger MARK in the thumb zone, and short mechanical haptics for deliberate controls. Magnetometer/EMF is **out of V1** per the canonical source of truth. Audio should sound like a controllable sweep, not a dialogue generator: no scripted complete sentences, no microphone-driven replies, no default echo/reverb sludge, no guaranteed “hits,” and no fake frequency display. Recordings should persist locally, replay on a waveform with marker navigation, and export through the system share sheet. The app should explain exactly what the engine does, request the microphone only for recording, and explicitly avoid scientific-proof claims. This is the narrowest design that satisfies the evidence from serious hardware users, casual paranormal-app users, dark-room operation, trust complaints and current successful mobile patterns without becoming an SB7 clone or a ghost-hunting super-app.

---

# 22. SOURCE REGISTER

All URLs accessed/reviewed for this report were current or recently indexed as of **2026-09-02** unless noted. Ratings are snapshots.

## App Store / Google Play

**[S01] Spirit Box EMF Ghost Detector — App Store listing**  
https://apps.apple.com/us/app/spirit-box-emf-ghost-detector/id6741384006

**[S02] Spirit Box EMF Ghost Detector — App Store reviews**  
https://apps.apple.com/us/app/spirit-box-emf-ghost-detector/id6741384006?platform=iphone&see-all=reviews

**[S03] Spirit Talker — App Store reviews**  
https://apps.apple.com/us/app/spirit-talker/id1536762482?platform=iphone&see-all=reviews

**[S04] Ghost Hunting Tools - Detector — App Store listing/reviews**  
https://apps.apple.com/us/app/ghost-hunting-tools-detector/id1025393457  
https://apps.apple.com/us/app/ghost-hunting-tools-detector/id1025393457?platform=iphone&see-all=reviews

**[S05] GhostTube SLS Camera — App Store reviews**  
https://apps.apple.com/us/app/ghosttube-sls-camera/id1519650688?platform=iphone&see-all=reviews

**[S06] Necrophonic — App Store listing**  
https://apps.apple.com/us/app/necrophonic/id1396698319

**[S07] GhostTube VOX — App Store listing**  
https://apps.apple.com/us/app/ghosttube-vox/id1574490738

**[S08] GhostTube VOX — App Store reviews**  
https://apps.apple.com/us/app/ghosttube-vox/id1574490738?platform=iphone&see-all=reviews

**[S09] GhostTube — Recommended VOX settings / mechanism**  
https://ghosttube.com/blogs/ghosttube/what-are-the-best-settings-to-use-on-ghosttube-vox

**[S10] Spirit Box EVP Ghost Detector — App Store reviews**  
https://apps.apple.com/us/app/spirit-box-evp-ghost-detector/id6758265625?platform=iphone&see-all=reviews

**[S11] SBX 12 Spirit Box — App Store**  
https://apps.apple.com/us/app/sbx-12-spirit-box/id1051643118

**[S12] Spirit Box SBX Ghost Talker — App Store**  
https://apps.apple.com/us/app/spirit-box-sbx-ghost-talker/id6763719251

**[S13] Paranormal EMF Recorder and Scanner — App Store**  
https://apps.apple.com/us/app/paranormal-emf-recorder-and-scanner/id975030171

**[S14] Ghost Radar Classic — App Store**  
https://apps.apple.com/us/app/ghost-radar-classic/id368470785

**[S15] Sono X10 Spirit Box — App Store**  
https://apps.apple.com/us/app/sono-x10-spirit-box/id987656337

**[S16] Spirit Entities Talker — App Store reviews**  
https://apps.apple.com/us/app/spirit-entities-talker/id6472714903?platform=iphone&see-all=reviews

**[S17] Spirit Words — App Store**  
https://apps.apple.com/us/app/spirit-words/id6446749894

**[S18] Ghost EVP Radio - Paranormal — App Store**  
https://apps.apple.com/us/app/ghost-evp-radio-paranormal/id925169973

**[S19] GhostTube — App Store**  
https://apps.apple.com/us/app/ghosttube/id1429639135

**[S20] GhostTube EVP — App Store reviews**  
https://apps.apple.com/us/app/ghosttube-evp/id6747162108?platform=iphone&see-all=reviews

**[S21] GhostTube — About GhostTube EVP / session workflow**  
https://ghosttube.com/blogs/ghosttube/about-ghosttube-evp

**[S22] Ghost Hunting Radio Spirit Box — Google Play**  
https://play.google.com/store/apps/details?id=com.weaseldev.ghostradio

## Physical hardware / manuals / retailer reviews

**[S23] P-SB7 / SB7 Spirit Box — GhostStop**  
https://www.ghoststop.com/spirit-box-sb7/

**[S24] P-SB7 operating instructions / controls**  
https://manuals.plus/m/99d23188286a187c27d984839e91f44e8500c2bcd78c5f2d51378fe2a20b0fa5

**[S25] K-II EMF Meter — GhostStop reviews / controls**  
https://www.ghoststop.com/k2-emf-meter/

**[S26] Skeptical Inquirer — testing / limitations of K-II-style paranormal interpretation**  
https://web.randi.org/swift/testing-the-k-ii-emf-meter-does-it-communicate-with-spirits-no.html

**[S27] MEL EMF / Temperature Meter — GhostStop**  
https://www.ghoststop.com/mel-meter/

**[S28] REM Pod — GhostStop reviews**  
https://www.ghoststop.com/rem-pod-with-temp/

**[S29] REM Pod investigator review / usage overview**  
https://hauntgears.com/rem-pod-review-serious-investigators/

**[S30] Skeptical Inquirer — REM Pod limitations / interference**  
https://skepticalinquirer.org/exclusive/ghost-hunting-gadgets-the-rem-pod/

**[S31] Ovilus 5 — Digital Dowsing guide / modes / logs**  
https://www.digitaldowsing.com/product-guides/ovilus-v/modes/  
https://www.digitaldowsing.com/shop/ovilus-5-rev-b/

**[S32] SBox Ghost Scanner + Recorder — GhostStop reviews**  
https://www.ghoststop.com/sbox-ghost-box-recorder/

**[S33] SBox Ghost Scanner — official feature guide**  
https://www.ghostsbox.com/

**[S34] Olympus EVP Recorder — GhostStop reviews / directions**  
https://www.ghoststop.com/olympus-evp-recorder-with-usb-and-live-listening/

## Community / workflow / skepticism

**[S35] Reddit r/GhostHunting — “Which Spirit Box apps actually work?”**  
https://www.reddit.com/r/GhostHunting/comments/1dg2nfv/which_spirit_box_apps_actually_work/

**[S36] Reddit r/GhostHunting — “Do spirit boxes on the App Store actually work?”**  
https://www.reddit.com/r/GhostHunting/comments/1eqzv5j/do_spirit_boxes_on_the_app_store_actually_work/

**[S37] Reddit r/GhostHunting — “What’s the best spirit box app” / microphone suspicion**  
https://www.reddit.com/r/GhostHunting/comments/176aayz/

**[S38] Reddit r/GhostHunting — app trust / permission / airplane-mode discussion**  
https://www.reddit.com/r/GhostHunting/comments/q7f2j1/

**[S39] Reddit r/GhostHunting — spirit-box activity advice / recording sessions**  
https://www.reddit.com/r/GhostHunting/comments/1adnzxq/

**[S40] Reddit r/GhostHunting — Estes method / headphones / blindfold discussion**  
https://www.reddit.com/r/GhostHunting/comments/ql6azb/

**[S41] Ghostly Voices — Estes Method guide**  
https://ghostly-voices.com/estes-method

**[S42] Reddit r/GhostHunting — Estes method roles / headphones / questions**  
https://www.reddit.com/r/GhostHunting/comments/1o03l30/estes_method_alone/

**[S43] Ghostly Activities — field session with null/gibberish result**  
https://ghostlyactivities.com/ghost-hunt-spooked-in-seattle-on-february-4th-2020/

**[S44] Nicole D. Strickland — EVP / ITC session methodology**  
https://nicoledstrickland.com/evp-itc/

**[S45] Ethnographic paper — ghost-hunting practices / media and evidence review**  
https://www.researchgate.net/publication/362693437_Hospitality_and_Proof_Human_Mediums_Technical_Media_and_Controversial_Knowledge_in_Ghost-Hunting_Practices_in_the_United_States

## Apple platform behavior / sensor truth

**[S46] Apple HIG — Playing haptics**  
https://developer.apple.com/design/human-interface-guidelines/playing-haptics

**[S47] Apple HIG — Feedback / multimodal feedback**  
https://developer.apple.com/design/human-interface-guidelines/feedback

**[S48] Apple Developer — Playing haptic feedback in your app**  
https://developer.apple.com/documentation/applepencil/playing-haptic-feedback-in-your-app

**[S49] Apple Core Motion — raw magnetometer field**  
https://developer.apple.com/documentation/coremotion/cmmagnetometerdata/magneticfield

**[S50] Apple Core Motion — CMMagneticField / calibrated magnetic field**  
https://developer.apple.com/documentation/coremotion/cmmagneticfield  
https://developer.apple.com/documentation/coremotion/cmdevicemotion/magneticfield

**[S51] Apple AVFAudio — microphone recording permission**  
https://developer.apple.com/documentation/avfaudio/avaudioapplication

## Visual references

**[S52] GhostTube VOX settings screenshot / interface reference**  
https://ghosttube.com/blogs/ghosttube/what-are-the-best-settings-to-use-on-ghosttube-vox  
Image used by source: https://cdn.shopify.com/s/files/1/0556/2030/5180/files/47092_480x480.jpg?v=1686110668

**[S53] K-II product image / LED reference**  
https://www.ghoststop.com/k2-emf-meter/

**[S54] SB7 Pro product image / field-radio control reference**  
https://www.ghoststop.com/sb7-pro-spirit-box/

**[S55] SBX 12 historical visual reference**  
https://dotapps.jp/products/com-kumlah-sbxpro

## Additional evidence added during review mining

**[S56] Apple HIG — explicit microphone/camera/gyro interference warning for haptics**  
https://developer.apple.com/design/human-interface-guidelines/playing-haptics

**[S57] Apple AVAudioSession — allowHapticsAndSystemSoundsDuringRecording (default false)**  
https://developer.apple.com/documentation/avfaudio/avaudiosession/allowhapticsandsystemsoundsduringrecording

**[S58] Necrophonic — App Store reviews (scan-rate/ease + overlapping/echo intelligibility evidence)**  
https://apps.apple.com/us/app/necrophonic/id1396698319?platform=iphone&see-all=reviews

**[S59] Necrophone — App Store review reporting repeated phrase / many voices**  
https://apps.apple.com/us/app/necrophone/id1601220983

**[S60] Spirit Talker — App Store listing + review evidence on creepy voice / sensor credibility**  
https://apps.apple.com/us/app/spirit-talker/id1536762482

---

# 23. SOURCE-QUALITY CAVEATS

- App Store reviews verify what reviewers said, not whether paranormal claims are true.
- Retailer hardware reviews are useful for ergonomics and usability themes but are hosted by a seller and therefore should not be treated as neutral efficacy research.
- Reddit is especially useful for skepticism, workflows and language used by enthusiasts; individual paranormal claims are anecdotal.
- Product descriptions are reliable for documented feature/control claims but not for scientific efficacy.
- Apple documentation is the authoritative basis for iPhone haptics, microphone permission behavior and magnetometer units.
- Small-review-count apps such as Spirit Box EVP Ghost Detector are directional evidence only; they should not outweigh larger, repeated themes.
- Rating differences between apps do **not** isolate UI quality. Ratings are used here as context, never as proof that a visual style causes success.

---

# 24. HANDOFF SUMMARY FOR THE PRODUCT / CODING AGENT

The implementation target is **not** “make a spooky app.” It is:

> **Make the iPhone feel like a compact field radio that a ghost hunter would willingly put next to an SBox, K-II or recorder — while being easier to operate, easier to mark, and much easier to replay.**

The product must earn credibility through **consistent mechanics, direct controls, evidence preservation and transparency**, not through visual theatrics or generated supernatural claims.
