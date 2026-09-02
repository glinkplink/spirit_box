# GHOST APP FAILURE FORENSICS AND COMPETITIVE WHITE SPACE

**Canonical project research source**  
**Date:** September 2, 2026  
**Market:** iPhone / U.S. App Store first, with Android/Reddit/creator evidence used only where it helps explain behavior or distribution  
**Objective:** determine why the paranormal-app graveyard is so large, why a few products win, and whether a new focused spirit-box app can occupy a profitable position without fighting the strongest incumbent on its home turf.

---

## 1. EXECUTIVE VERDICT

### Final decision: **CONDITIONAL YES — but only for a narrower product than the initial feature list implies.**

The commercial anomaly remains compelling: the project has already verified that a very small May-2026 entrant, **Spirit Box SBX Ghost Talker**, reached #1 for the generic `spirit box` query and appears to generate roughly $9K/month in RevenueCat-verified revenue. This pass does **not** redo that demand validation.

This pass changes the product thesis in one important way:

> **“No subscription + recording/replay + offline” is not white space by itself.**

A new 2026 app, **SpectraBox: Spirit Box EVP**, already offers a one-time $7.99 unlock, no ads, no account, no tracking, on-device operation, session recording/playback, timestamped transcripts, case files, EMF, and an explicit transparency message. GhostTube EVP already offers **audio tagging** and instant review. Bello Studios now offers a live-radio spirit box inside a broader toolkit. Therefore a generic “more polished, no-subscription paranormal app with recording” would already be entering a filling gap.

The opportunity that still looks commercially useful is narrower:

> **A dedicated, tactile, old-school radio-sweep-style pocket instrument whose entire UX is optimized around one fast session: START → LISTEN → MARK → REVIEW, with no AI interpretation, no generated word dictionary, no SLS, no community, no haunted-location network, no horror-game clutter, and no recurring subscription.**

The product should compete most directly with the **May-2026 SBX-style leader**, not with GhostTube as an ecosystem. It should deliberately avoid the jobs GhostTube is strongest at: SLS/video capture, social/community, haunted-location discovery, AI interpretation, multi-app toolkits, and creator workflows.

### The largest commercial risk

The remaining differentiation is **executional, not a durable moat**. WPPNT already owns a very similar search-facing promise (portable SBX-like sweep). GhostTube VOX owns a branded radio-sweep experiment. GhostTube EVP owns tagging/review. SpectraBox owns transparent offline/no-sub/session-history positioning. Bello Studios has already added a live internet-radio sweep to a multi-tool app.

If a user cannot understand from the first App Store screenshot why **“MARK the exact moment, replay around the mark, and use it like a field instrument”** is meaningfully different, this becomes another interchangeable ghost app.

### The most important trust constraint

There is a hard product-positioning tension between **offline** and **real radio scanning** on iPhone. Current iOS media APIs support files and internet streams; this research found no public iPhone API that lets a third-party app tune terrestrial AM/FM broadcasts. Current spirit-box apps resolve this in three ways:

1. **Internet radio streams** — closer to actual broadcast content, but requires connectivity and introduces rights/licensing/App Review considerations.
2. **Prebuilt phoneme/audio banks** — works offline, but users frequently accuse these apps of canned or repeated responses.
3. **Procedural/synthesized audio** — works offline and can be transparent, but it is not real RF scanning.

Therefore the product must **never imply that an offline iPhone app is literally scanning terrestrial AM/FM frequencies**. If V1 uses synthesized or banked audio, the App Store copy and in-app help should say so plainly. “AM-style / FM-style sweep modes” is defensible; “real AM/FM radio scan” would be a trust problem unless the implementation actually uses licensed/authorized internet streams and is described accurately.

---

## 2. EVIDENCE STANDARD

### Commercial classifications used in the scorecard

**A. PROVEN COMMERCIAL SUCCESS**  
Revenue or unusually strong monetization evidence exists.

**B. STRONG MARKET PRESENCE**  
Strong rankings, large rating base, cross-platform scale, recognized brand, creator adoption, or sustained current activity. Revenue is unknown unless explicitly stated.

**C. MODEST / NICHE**  
Meaningful usage exists, but no evidence in this pass establishes major commercial scale.

**D. WEAK / STAGNANT**  
Weak discovery evidence combined with age/stagnation, poor review quality, obvious product/trust problems, or minimal traction after enough time to judge. **Few ratings alone are not sufficient.**

**E. UNKNOWN / TOO NEW**  
Insufficient evidence or too recent to classify fairly.

### Claim labels

- **VERIFIED FACT** — directly supported by current App Store/Google Play/developer-site evidence, or by the project’s prior RevenueCat/ASO work.
- **REPEATED USER THEME** — recurring pattern in reviews, Reddit discussions, or comments. It is evidence of user perception, not scientific truth.
- **INFERENCE** — the best explanation of the facts, but not directly observed.
- **UNKNOWN** — no defensible conclusion from available evidence.

### Important caveat

Paranormal efficacy is outside the scope of this report. Reviews saying an app is “real,” “accurate,” “fake,” or “a scam” are analyzed as **trust, conversion, retention, and product-perception signals**, not as proof for or against paranormal phenomena.

---

## 3. WHY MOST GHOST APPS FAIL — RANKED FAILURE MECHANISMS

### #1 — TRUST COLLAPSE

**Importance: VERY HIGH**

This is the category’s defining failure mode.

Users do not merely ask “is this fun?” They repeatedly ask:

- Is it listening to my microphone and feeding my own words back?
- Are the phrases pre-recorded?
- Is the word bank random?
- Why am I getting the same responses again?
- Is the EMF meter actually connected to the magnetometer?
- Why does it say supernatural things when no one asked a question?
- Does the app explain what causes a trigger?

**VERIFIED FACT:** GhostTube explicitly states that no current tool scientifically “detects ghosts,” explains that its tools react to environmental readings, and tells users that interpretation is subjective. Its privacy/help pages explicitly say microphone audio is used for recording/sound visualization, **not** to generate words. [S11][S12]

**REPEATED USER THEME:** Spirit Entities Talker reviewers ask for a clearer explanation of how words are generated because otherwise the output can feel fake. PhenVox reviewers report the same words appearing in the same order. Necrometer reviewers complain about repeated phrases and pre-recorded creepy noises. AI Spirit Box reviewers identify it as a generic chatbot and object to repetitive grief-adjacent responses. [S23][S27][S28][S29]

**INFERENCE:** In this category, mechanism transparency is not a minor support-page feature. It is part of the product itself. A less “magical” explanation can actually increase trust because it gives skeptical believers a reason to keep experimenting.

**Implication for us:**  
Do not generate spooky words, use AI “spirit responses,” or make invisible claims about microphone analysis in V1. Let the mystery live in the **audio interpretation**, while the mechanics remain inspectable.

---

### #2 — MONETIZATION BEFORE VALUE

**Importance: VERY HIGH**

The category has a recurring pattern of free App Store listings that immediately demand a weekly subscription before the user can establish whether the experience is even interesting.

**VERIFIED FACT:** The May-2026 SBX leader currently lists $4.99/week, $9.99/month, a $14.99 offer, and $29.99 lifetime. Canadian reviews complain that the app cannot be used even once without paying. [S1][S2]

**VERIFIED FACT:** Boss Web’s Spirit Box EMF Ghost Detector lists weekly/monthly/lifetime plans. A review explicitly objects to paying $5 for one week **without a demo**, while another user says they had previously paid approximately $10 and later found the app moved to subscription access. [S26]

**VERIFIED FACT:** ZipoApps’ Ghost Detector - Spirit Box lists roughly $4.99/week and $19.99/month and contains advertising. [S31]

**REPEATED USER THEME:** “Looks free, then asks for money,” “subscription just to try it,” “paid once and now subscription,” and “ads interrupt the session” recur across multiple apps.

**Counterexample:** GhostTube makes the core functions usable for free and explicitly argues that this helps beginners try the tools before investing. [S11]

**INFERENCE:** A **real trial** is a stronger commercial differentiator than simply being cheaper. Users need enough uninterrupted time to decide whether the experience produced an interesting moment.

**Implication for us:**  
Do not lead with a hard paywall. The free experience should permit one legitimate session, not a decorative demo.

---

### #3 — BAD AUDIO AND “OBVIOUS LOOP” PERCEPTION

**Importance: HIGH**

A spirit box is primarily an **audio product**. Users are unusually sensitive to repetition, clipping, intelligibility, obvious loops, and unnatural cadence.

**REPEATED USER THEME:** Necrophonic users praise its concept but complain that the sweep can be too fast, clipped, difficult to understand, or low-volume. SBX12 reviews complain that words are difficult to hear. Boss Web’s product receives complaints about multiple voices speaking at once and repeated output. [S18][S26][S38]

**REPEATED USER THEME:** Positive reviews repeatedly praise “clear,” “natural,” “professional,” or “like real equipment” audio. HOPE Spirit Box users specifically contrast it with annoying static and say they replay sessions. [S25]

**INFERENCE:** Better audio is not decorative polish; it is core gameplay quality. A beautiful shell around cheap-sounding loops will fail the authenticity test quickly.

**Implication for us:**  
The audio prototype deserves a separate kill gate before UI polish. A long blind listening test should reveal whether a user can detect obvious repeated structures.

---

### #4 — NO EVIDENCE-REVIEW WORKFLOW

**Importance: HIGH**

The strongest repeat-use behavior is not “press the scary button again.” It is **reviewing what happened**.

**REPEATED USER THEME / VERIFIED PRODUCT EVIDENCE:**

- A Necrophonic review says the app is worth the purchase but explicitly wants built-in recording so the session can be reviewed later. [S18]
- HOPE Spirit Box users say they replay sessions, but recording files sometimes fail to save or are difficult to reopen. [S25]
- Spirit Entities Talker receives praise for adding recording so sessions can be analyzed later. [S23]
- GhostTube EVP includes **audio tagging**, audio boosting, voice-activated review, and instant playback. [S6]
- GhostTube users ask for longer history/export rather than only limited recent results.
- The May-2026 SBX leader’s positive “backup equipment” review says interesting responses were worth noting and reviewing later. [S2]

**INFERENCE:** Recording/review increases retention because it converts a one-off novelty into a session artifact.

**Implication for us:**  
MARK is worth keeping, but only if it creates an exceptionally fast review flow. “Recording exists” is no longer differentiation; **mark-centered replay around the moment of interest** can still be.

---

### #5 — FEATURE BLOAT WITHOUT A CLEAR HERO JOB

**Importance: HIGH**

There are many apps that list EMF, SLS, EVP, AI, radar, thermal filters, word generators, case files, stories, and cameras. Their existence disproves the idea that breadth itself wins.

Examples include newer products such as Animavox, SpiritusX, Ghost Whispers, and multiple “all-in-one” ghost detector kits that have very limited visible market presence despite huge feature lists.

**VERIFIED FACT:** GhostTube itself did not remain a single giant app. It split major jobs into **Original, SLS, VOX, SEER, and EVP** and monetizes them as a portfolio/bundle. [S9][S13]

**INFERENCE:** Specialized tools are easier to understand in search, easier to demonstrate in screenshots, and can build stronger product identities than a dashboard of weak modules.

**Implication for us:**  
Magnetometer + flashlight may remain supporting controls because they serve the same field session. SLS, AI interpretation, haunted locations, video editing, dictionaries, case-management systems, and social sharing should stay out of V1.

---

### #6 — NO DISTRIBUTION OR SEARCH IDENTITY

**Importance: HIGH**

Many apps are not obviously bad; they are simply invisible.

**VERIFIED FACT:** TeslaVision EMF Detector is a clean $4.99 professional-style utility with no ads/subscription and good ratings, but only a small rating base after years. Newer polished toolkits similarly have very low visible traction.

**INFERENCE:** “No ads” and “professional UI” are not acquisition channels. The app must map to a recognizable query and communicate the job instantly.

The May-2026 commercial anomaly is important precisely because its title is aggressively literal: **Spirit Box SBX Ghost Talker**. It satisfies generic search intent before it establishes any brand identity.

**Implication for us:**  
Do not sacrifice keyword clarity for a clever app name at launch. Brand can sit beside the intent, not replace it.

---

### #7 — COPYCAT SURFACE AREA WITHOUT THE ORIGINAL MOAT

**Importance: HIGH**

There are apps with names or feature lists adjacent to Necrophonic, Necrometer, GhostTube, SBX/SB7, SLS, and Spirit Talker that have not reproduced the leaders’ visible market presence.

**Examples:**

- Necrophonic-adjacent or Necrometer clones with tiny rating bases and poor reviews.
- “Void: Necrometer & Ghost Tube,” which combines recognizable category terms but has little visible traction.
- multiple generic SBX/spirit-box variants from legacy portfolios with weak ratings.
- feature-heavy “professional paranormal toolkit” apps with negligible discovery.

**INFERENCE:** What is difficult to copy is not the button layout. It is:

- keyword/ranking history;
- creator adoption;
- brand trust;
- years of reviews;
- a community/content funnel;
- credible explanations of mechanism;
- reliable execution;
- cross-promotion.

**Implication for us:**  
Do not imitate GhostTube’s icon system, naming, SLS presentation, community language, or “all-in-one equipment replacement” message. Do not lean on trademark-adjacent names such as Necrophonic/Necrometer/GhostTube.

---

### #8 — RELIABILITY FAILURES DESTROY THE SESSION

**Importance: MEDIUM-HIGH**

A crash in a weather app is annoying. A lost recording after a 20-minute paranormal session destroys the entire product promise.

**REPEATED USER THEME:** HOPE Spirit Box reviews mention sessions that stop recording or fail to save. Spirit Talker users have complained about lost saved material after reinstall/update. GhostTube release notes show regular work on freezes, stuttering audio, screen sleep, streaming compatibility, and OS updates. [S25][S7][S5]

**INFERENCE:** Recording persistence, audio-session recovery, interruptions, calls, route changes, backgrounding, and low-battery behavior are high-leverage QA areas.

---

### #9 — “TOY” POSITIONING ATTRACTS DOWNLOADS BUT MAY CAP SERIOUS WTP

**Importance: MEDIUM**

Some large-rating apps are explicitly pranks/games. Their 4K–6K rating bases show broad curiosity, not necessarily willingness to pay for an instrument.

**VERIFIED FACT:** App Star Family’s Ghost Detector & Spirit Box explicitly says it does not provide actual ghost detection; ZipoApps frames the experience partly like a ghost-hunting movie/prank; several apps advertise sleepovers and parties. [S32][S31]

**INFERENCE:** The casual segment is useful acquisition, especially around Halloween and social use, but the premium product should not visually resemble a horror game if the intended WTP comes from hobbyists/investigators.

---

### #10 — NOVELTY RETENTION IS SEGMENT-DEPENDENT

**Importance: MEDIUM**

The category contains both one-night curiosity and repeat-investigator behavior.

**REPEATED USER THEME:** Reddit discussions include people seeking apps for a ghost-hunting opportunity that weekend, people treating them as sleepover entertainment, and people who keep GhostTube/Necrophonic/Spirit Talker in their regular investigation kit. [S41][S42][S44]

**INFERENCE:** A product built only for a Halloween gag has low retention; a product built only for expert investigators limits the top of funnel. The best positioning is **serious-feeling but immediately usable**.

---

## 4. THE STRONG MULTI-APP DEVELOPER: GHOSTTUBE PTY LTD — VERIFIED

The likely developer the project remembered is indeed **GhostTube Pty Ltd**, but it is not the only meaningful multi-app developer.

### GhostTube’s current portfolio

**VERIFIED FACT:** GhostTube’s own Terms of Service says GhostTube Pty Ltd owns/operates:

- GhostTube
- GhostTube SLS
- GhostTube VOX
- GhostTube SEER
- GhostTube EVP
- GhostTube Explore
- ghosttube.com
- amyscrypt.com

[S13]

The five primary apps are sold together in a **12-month bundle for $49.99**, while individual 12-month plans are generally $12.99 and SEER is $14.99. The web subscriptions are explicitly non-renewing 12-month products and require a GhostTube account to redeem. [S9][S10]

### Visible iOS scale, September 2026

| Product | Current iOS evidence | Primary job |
|---|---:|---|
| GhostTube Original | ~6.8K ratings, 4.3 | sensor/video toolkit + word dictionary + community |
| GhostTube SLS | ~9.4K ratings, 4.6 | SLS/LiDAR/pose-camera alternative |
| GhostTube VOX | ~2.8K ratings, 4.4 | internet-radio stream sweeper / audio experiment |
| GhostTube SEER | ~552 ratings, 4.5 | sensor-triggered AI imagery |
| GhostTube EVP | ~630 ratings, 4.7 | EVP recorder, tagging, DR60-style workflow |

**Important:** These are market-presence signals, **not revenue estimates**.

### Cross-platform evidence

The Google Play listing for GhostTube Original has shown **5M+ downloads**, supporting strong market presence outside iOS as well. Revenue remains unknown.

### Launch/portfolio chronology — what is actually supportable

- **April 2020:** Amy’s Crypt Patreon says a working GhostTube Community demo already existed. [S17]
- **August 2020:** Amy’s Crypt Patreon content references GhostTube SLS sessions, establishing SLS as an early expansion.  
- **November 2021:** public creator communications announced/marketed GhostTube VOX.  
- **March 18, 2023:** GhostTube SEER’s iOS release date is independently visible in app-history sources; GhostTube blog content about SEER is dated March 2023. [S7]
- **October 1, 2023:** SEER was added to the GhostTube bundle.  
- **September 2025:** GhostTube published detailed EVP/DR60/modulated-EVP content as the EVP product joined the portfolio. [S47]
- **2026:** all five apps remain actively marketed together; VOX and SEER show 2026 maintenance updates, and EVP is current. [S5][S6][S7]

Exact first-release dates for every early product were not all independently established in this pass; where absent, this report does not invent them.

---

## 5. WHY GHOSTTUBE WON — THE ACTUAL MOAT

### 5.1 Creator distribution is part of the company, not an external marketing tactic

**VERIFIED FACT:** GhostTube’s Terms explicitly include **amyscrypt.com** among GhostTube Pty Ltd’s platforms. [S13]

**VERIFIED FACT:** Amy’s Crypt YouTube descriptions directly link the GhostTube app portfolio. A recent third-party channel snapshot in August 2026 showed roughly **346K subscribers, 34.5M views, and 614 videos**; exact live counts move over time. [S14][S16]

**VERIFIED FACT:** Amy’s Crypt Patreon tells members they may be invited to test new products such as GhostTube. [S15]

**INFERENCE:** This creates a closed loop that a copycat does not get by reproducing features:

content audience → product exposure → beta testers → reviews/feedback → more product content → portfolio cross-promotion.

This is one of the most important reasons not to attack GhostTube’s creator/video ecosystem directly.

---

### 5.2 Portfolio segmentation instead of one bloated app

GhostTube has separate products for:

- general sensor/video capture;
- SLS visualization;
- radio-stream sweep audio;
- AI interpretation/art;
- EVP recording/review.

The products share brand, community, subscriptions, and haunted-location data.

**INFERENCE:** This architecture gives each app a clear App Store proposition while still increasing customer lifetime value through cross-sell.

Trying to beat this with one “ultimate ghost toolkit” would combine all of GhostTube’s product scope without inheriting any of its distribution.

---

### 5.3 Trust through skeptical transparency

GhostTube repeatedly tells users:

- it does not scientifically detect ghosts;
- normal environmental causes can produce triggers;
- microphone audio is not used to generate dictionary words;
- recordings remain local unless users intentionally share them;
- users should understand the mechanism when interpreting results.

[S11][S12]

**REPEATED USER THEME:** Reddit users who distrust most paranormal apps still sometimes single GhostTube out as more credible because they can understand the sensor behavior, or because they trust Amy and Jarrad. [S41][S42][S43]

**INFERENCE:** In a low-trust category, skepticism is a brand asset.

---

### 5.4 Community and haunted-location data create ecosystem switching costs

The flagship, SLS, VOX, SEER, and EVP all connect into GhostTube Explore/community and a haunted-location database. Premium subscriptions include additional posting/search privileges. [S9][S10]

This is not necessary to create a useful spirit box. It **is** expensive to compete with directly because it adds:

- accumulated location content;
- user-generated evidence;
- account identity;
- network content;
- moderation/support needs;
- reasons to remain inside one branded ecosystem.

---

### 5.5 Localization is unusually broad

GhostTube’s main apps support roughly **29–31 languages** in current App Store listings.

**INFERENCE:** This expands search/review surface and creator usability across regions. It is replicable eventually, but not a sensible V1 battle for a solo entrant.

---

### 5.6 Cross-app pricing and bundling increase monetization depth

Individual annual plans are inexpensive relative to physical paranormal equipment, while the bundle creates a higher annual price point. The ecosystem can monetize a serious investigator across multiple jobs instead of forcing a single app to carry all revenue. [S9][S10]

This is a moat we should **avoid**, not replicate in V1.

---

### 5.7 Content/SEO compounds the brand

GhostTube maintains educational content on:

- whether the apps are “real or fake”;
- how the sensor tools work;
- reviewing evidence;
- DR60 recorders;
- modulated EVP;
- AI in paranormal investigating.

[S11][S47]

**INFERENCE:** This captures users beyond App Store search and answers the exact trust objections that create one-star reviews elsewhere.

---

### 5.8 Frequent maintenance protects a hardware-like product

Current GhostTube release notes show fixes for iOS changes, radio-stream compatibility, audio stutter, screen sleep, AI generation freezes, and other field-use issues. [S5][S7]

A paranormal instrument app has to survive OS/audio/session changes over time. Legacy apps that are barely maintained lose this advantage.

---

## 6. GHOSTTUBE MOAT MAP

| Moat | Strength | Evidence | Can we replicate quickly? | Should we try? | Should we avoid head-on? |
|---|---|---|---|---|---|
| Amy’s Crypt creator audience | **Very High** | owned platform relationship + ~346K YouTube snapshot + direct app links [S13][S14][S16] | No | No | **Yes** |
| Brand recognition | **High** | 5-app family, multi-year presence, registered trademark [S13] | No | Build our own slowly | **Yes** |
| Portfolio cross-promotion | **High** | 5 apps + bundle [S9] | Not in V1 | No | **Yes** |
| Community / Explore | **High** | posts, evidence, account privileges [S9][S12] | No | No | **Yes** |
| Haunted-location database | **High** | thousands of locations + search privileges [S4][S9] | No | No | **Yes** |
| SLS / LiDAR identity | **High** | SLS has strongest iOS rating base in portfolio | Technically partly | No | **Yes** |
| EVP recorder + DR60 workflow | **Medium-High** | dedicated app, tagging, VAS, booster, playback [S6] | Technically yes | Only minimal overlapping review UX | **Mostly** |
| Radio-stream spirit-box job | **Medium-High** | VOX 2.8K ratings, current updates [S5] | Yes, but rights/internet complexity | Compete narrowly, not feature-for-feature | **Partly** |
| Sensor transparency | **High trust value** | detailed mechanism/privacy docs [S11][S12] | Yes | **Yes** | No |
| Free usable core | **High acquisition value** | official positioning; core available without upfront spend [S11] | Yes | **Yes** | No |
| Localization | **Medium-High** | ~29+ languages | Later | Later | No need in V1 |
| AI interpretation / SEER | **Medium** | branded product, but AI-art criticism in reviews [S7] | Yes | **No** | Avoid |
| SEO / educational content | **Medium** | active GhostTube blog/help [S47] | Gradually | Yes later | No |
| Physical Lens / merchandise | **Medium** | GhostTube Lens + store | No need | No | Yes |
| Subscription bundle economics | **Medium** | $49.99 bundle + individual annual plans [S9][S10] | Yes structurally | No in V1 | Avoid |

### Bottom line

GhostTube’s strongest moat is **distribution + trust + ecosystem**, not a secret signal-processing algorithm.

That is good news for a focused entrant only if the entrant stays out of the ecosystem battle.

---

## 7. OTHER MULTI-APP PARANORMAL DEVELOPERS

GhostTube is not alone.

### 7.1 Spotted Ghosts Ltd — the strongest non-GhostTube specialist brand found

**VERIFIED FACT:** Spotted Ghosts says it has been building paranormal tools since 2013 and claims roughly **6.5 million downloads across platforms**. This is a developer claim, not independently audited. Its portfolio spans Spirit Talker, LiDAR/SLS, music boxes, spirit bell, spirit typer, EMF yes/no, resonators, EVP recorders, and physical hardware. [S21]

**VERIFIED FACT:** Spirit Talker is $4.99 on iOS, has roughly **699 ratings**, and currently shows a **#3 Lifestyle** chart position. Google Play shows **100K+ downloads** and roughly **5.8K reviews**. [S19][S20]

**VERIFIED FACT:** The listing names a long set of paranormal creators/shows including Sam and Colby, Twin Paranormal, Exploring with Josh and others. [S19]

**Actual moat:** creator adoption + “original” status + long category history + physical-device credibility.

**Weakness:** iOS rating quality is poor (~2.8), with complaints about sensor behavior and UI/voice issues. The brand is significant, but the product execution leaves visible openings.

**Positioning consequence:** Do not build an Ovilus/word-generator clone. Spirit Talker already owns that identity far better than we could in a month.

---

### 7.2 Chris Rogers / BitPlague — Necrophonic ecosystem

Necrophonic is the strongest narrow paid-app outlier found outside GhostTube/Spirit Talker.

**VERIFIED FACT:** Necrophonic is a $9.99 upfront purchase, launched June 2018, currently has roughly **542 ratings**, and has recently appeared high in the U.S. Utilities chart. Its description is unusually explicit about the eight phoneme/sound banks and states that it does not contain full words/phrases beyond basic phonetic fragments. [S18]

**VERIFIED FACT:** The same developer publishes Necrometer, The Miracle Box, Transcend Theory, Spiritus Ghost Box, DeadWave and other paranormal apps. [S18]

**Moat:** recognizable legacy product name, creator/community familiarity, simple one-time price, distinct sound identity.

**Weakness:** the last meaningful feature release shown is from **2022**; users ask for built-in recording and better audio control.

**Positioning consequence:** This validates one-time paid spirit communication apps, but it also shows that a beloved core loop can remain vulnerable to session-workflow improvements.

---

### 7.3 Zee Weasel

**VERIFIED FACT:** Ghost Hunting Tools - Detector has roughly **10K iOS ratings** and 4.2 stars. It combines a word-based spirit box, EVP, and EMF with ads and Pro options. The developer also has Spirit Chat Box - Ghost Talker with ~751 ratings. [S22][S37]

**Moat:** old App Store presence, strong rating history, broad search coverage.

**Weakness:** ad/tracking footprint, large app size, word-bank trust questions, and broad-tool positioning.

---

### 7.4 Bello Studios LLC

**VERIFIED FACT:** Spirit Entities Talker has roughly **2.3K ratings / 4.5**, frequent updates, a low-cost one-time unlock model, and increasingly broad features. Bello’s newer Ghost Talker - Spirit Box Live has ~119 ratings and explicitly uses **live internet radio streams**, plus EMF, SLS-style tools, spectrograms and history. [S23][S36]

**Moat:** fast iteration and a growing portfolio.

**Weakness:** less external brand/community evidence than GhostTube; newer product breadth is drifting toward the same all-in-one territory.

**Positioning consequence:** Bello is a more immediate **feature-copy risk** than GhostTube because a small developer can move quickly into obvious white space.

---

### 7.5 Janus Pedersen / Ballista Studios — legacy ghost-box portfolio

Sono X10, Sono X10 Pro, PhenVox, SBX12 and related apps show an older multi-app strategy.

**Strength:** early category presence and recognizable hardware-inspired concepts.

**Weakness:** poor current ratings on several products, stale UI/maintenance, difficult text, repeated-word accusations, limited export/history.

**Lesson:** a portfolio is not a moat if the individual apps stop evolving.

---

### 7.6 WPPNT LTD / Ewregu — emerging rapid portfolio

The project’s current revenue anomaly, Spirit Box SBX Ghost Talker, comes from WPPNT LTD / Ewregu. The developer now also appears around Spirit Box EVP/K-II/related products.

**Strength:** aggressive generic ASO and hard monetization; fast updates.

**Weakness:** low rating quality on the flagship and repeated paywall/fake accusations.

**Lesson:** this is the competitor we can realistically attack at the **same search intent**, because its moat appears much thinner than GhostTube’s.

---

## 8. WHAT GHOSTTUBE OWNS — AND WHAT WE SHOULD NOT ATTACK

### Jobs GhostTube effectively owns or has a major structural advantage in

1. **Paranormal ecosystem / “toolset” identity**
2. **SLS camera / LiDAR / pose-detection alternative**
3. **Video evidence capture for creators**
4. **Haunted-location discovery**
5. **Paranormal social/community posting**
6. **AI paranormal interpretation / generated imagery**
7. **Multi-app bundle for enthusiasts**
8. **General sensor-based dictionary toolkit**
9. **Dedicated EVP / DR60-style recorder**
10. **Creator-led content distribution**

### Jobs we should deliberately avoid

- building an SLS module “because GhostTube has one”;
- creating an AI spirit interpreter;
- haunted-location maps;
- user accounts/community;
- paranormal feed/social network;
- creator video editor as a hero feature;
- five weak tools in one dashboard;
- matching the GhostTube icon/naming architecture;
- copying GhostTube’s creator/investigator positioning broadly.

### Why

Every one of those jobs makes GhostTube’s accumulated brand, content, accounts, community, creator audience, and portfolio more relevant. We want the opposite: a job where the user judges the product in the **first 30 seconds of handling the instrument**.

---

## 9. WHAT GHOSTTUBE DOES NOT FULLY OWN

### 9.1 A single-purpose tactile “radio” instrument

GhostTube VOX is a radio-stream sweeper, but it is still part of the GhostTube video/community ecosystem and depends on internet streams. Its identity is “GhostTube VOX,” not a minimalist pocket SB7 replacement.

The May-2026 WPPNT app proves that generic users will choose a focused SBX-style proposition over a broader incumbent.

**White-space quality: MEDIUM-HIGH, but occupied by WPPNT.**

Our goal is not to find an empty category. It is to be the better product at the same high-value job.

---

### 9.2 MARK-centered sweep review

GhostTube EVP has audio tagging, but that is inside an EVP recorder. SpectraBox has transcript timestamps/correlation, but its spirit-box mechanism is procedural word/speech output rather than a dedicated old-school radio-sweep interface.

**Possible wedge:** during a sweep session, the user hears something, taps a huge **MARK** control with one thumb, feels a distinct haptic confirmation, and later sees only the marked moments with a short pre/post audio window.

This is more specific than “recording.”

**White-space quality: MEDIUM.** Easy to copy, but immediately useful.

---

### 9.3 No generated words, no AI interpretation

Many current apps manufacture the feeling of communication by selecting dictionary words, generating text, or using AI.

That mechanism is also a major source of distrust.

A product that says:

> “We do not generate answers. We do not listen to your questions to create responses. You hear the sweep and decide what matters.”

can position **absence** as credibility.

**White-space quality: MEDIUM-HIGH for trust messaging.**

---

### 9.4 Physical-instrument UX

Current products range from generic mobile dashboards to horror-game graphics. The May leader’s positive reviews explicitly describe it as a pocket replacement/backup for physical gear.

A design language based on:

- large physical-feeling controls;
- dark-room readability;
- one-thumb operation;
- tactile detents via haptics;
- a hardware-like tuning/sweep speed control;
- no modal navigation during a session;
- instant flashlight;
- unmistakable recording/mark state;

is commercially coherent.

**Important:** “better UI” is only a wedge if it makes the *job* visibly easier in screenshots. Beauty alone is not enough.

---

## 10. 50-APP FAILURE / MARKET SCORECARD

**As of September 2, 2026.** Rating counts move over time. “Rank/discovery” is only included when observed or already project-verified; a rating count is not treated as revenue. Launch/update cells are `UNKNOWN` when this pass did not establish them confidently.

| # | App | Developer | Launch / last update evidence | Rating / count | Rank / discovery evidence | Monetization | Core job / UI type | Positive review theme | Negative / trust theme | Class | Likely success / weakness | Confidence | Relevance |
|---:|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | **Spirit Box SBX Ghost Talker** | Ewregu / WPPNT LTD | May 2026 / Aug 14 2026 | 2.9 / 49 US | **Project-verified #1 generic `spirit box`** | Free listing; $4.99 wk, $9.99 mo, $29.99 lifetime | Focused SBX-style sweep | “Pocket SB7,” backup when hardware dies | pay-before-use; fake/pre-recorded accusations | **A** | Exact-intent ASO + simple job + aggressive monetization; rating damage from trust/paywall | High | **Primary direct commercial target** |
| 2 | Spirit Box EVP Ghost Detector | Ewregu / WPPNT | UNKNOWN / active 2026 | ~4.7 / ~49 in prior pass | no rank verified | IAP | EVP/spirit-box toolkit | recording/review praised | UNKNOWN broader | C | Same portfolio; some product credibility | Med | Direct feature adjacency |
| 3 | Spirit Box SBX PRO Ghost Radio | Ewregu / WPPNT | 2026 / active | low/unknown | no rank verified | IAP | SBX/radio variant | UNKNOWN | UNKNOWN | E | Too little evidence | Low | Watch copy/portfolio expansion |
| 4 | **GhostTube** | GhostTube Pty Ltd | legacy / active 2026 | 4.3 / 6.8K | Google Play 5M+ downloads; strong brand | Free + ads/IAP/subs | sensor/video toolkit + word dictionary + community | trusted ecosystem, real sensors, creator use | price/history limits; random-word skepticism | **B** | Brand + creator audience + community + transparency | High | Avoid head-on |
| 5 | **GhostTube VOX** | GhostTube Pty Ltd | 2021 era / May 27 2026 | 4.4 / 2.8K | strong branded presence | Free + IAP/sub | internet-radio sweeper / video tool | no fixed word bank; multiple voices; trust in dev | premium limits; internet dependence | **B** | Brand + specific audio job + ecosystem | High | **Closest GhostTube overlap** |
| 6 | **GhostTube SLS** | GhostTube Pty Ltd | active by 2020 / active | ~4.6 / 9.4K | strongest rating base in ecosystem | Free + IAP/sub | SLS/LiDAR camera | accessible alternative to expensive SLS | false-positive/pareidolia concerns | **B** | clear job + creator adoption | High | **Do not compete** |
| 7 | **GhostTube SEER** | GhostTube Pty Ltd | Mar 18 2023 / May 18 2026 | 4.5 / ~552 | ecosystem distribution | Free + IAP/sub | sensor-triggered AI imagery | novel/immersive | “AI slop,” recycled/interpretation distrust | **B** | ecosystem carries experimental product | High | Avoid AI wedge |
| 8 | **GhostTube EVP** | GhostTube Pty Ltd | 2025 / active 2026 | 4.7 / 630 | ecosystem distribution | Free + IAP/sub | EVP recorder + DR60 + tagging | specialized review workflow | premium/account ecosystem complexity | **B** | owns EVP review job inside brand | High | Partial overlap: tagging/replay |
| 9 | **Necrophonic** | Chris Rogers / BitPlague | Jun 10 2018 / Jun 19 2022 feature update | 3.7 / ~542 | current Utilities chart presence observed | **$9.99 upfront** | 8 phoneme/sound banks | “worth $10,” strong believer stories | clipped/fast/low audio; wants recording | **B** | legacy brand + simple one-time purchase | High | Important paid outlier |
| 10 | **Spirit Talker** | Spotted Ghosts Ltd | Oct 2020 / Feb 26 2025 | 2.8 / 699 | **#3 Lifestyle**; Play 100K+ | **$4.99 upfront** | sensor-driven Ovilus-style word generator | creator adoption; session history | sensor skepticism, voice/UI complaints | **B** | “original” brand + creator placements | High | Avoid word-generator battle |
| 11 | **Ghost Hunting Tools - Detector** | Zee Weasel | legacy / May 2026 active | 4.2 / 10K | substantial rating base | ads + $19.99/29.99 Pro + subs | spirit box/EVP/EMF kit | broad utility; long-term use | tracking/ads; word-bank trust | **B** | age + ASO + ratings | High | Broad incumbent, not direct ideal |
| 12 | **Spirit Entities Talker** | Bello Studios | ~2023 / frequent 2026 updates | 4.5 / 2.3K | strong rating growth | ads + ~$4.99 unlock | word talker + box + EMF/EVP/history | users cite coherent answers; recording praised | mechanism explanation requested | **B** | rapid iteration + low-friction monetization | High | Strong second-tier competitor |
| 13 | **Ghost Talker - Spirit Box Live** | Bello Studios | 2025 / active | 4.7 / 119 | growing but no major rank proven | $6.99 unlock | **live internet-radio sweep** + SLS/EMF | broad live-radio capability | bloat/tracking risk; early | C | fast feature expansion | Med | **High feature-copy risk** |
| 14 | **Spirit Chat Box - Ghost Talker** | Zee Weasel | 2025/26 / active | 4.5 / ~751 | meaningful rating base | IAP | 12K-word bank + sensors | clean/immediate | word-bank skepticism | B | developer cross-promotion + ASO | Med-High | Word-mode competitor |
| 15 | **SBX 12 Spirit Box** | Janus Pedersen | legacy / UNKNOWN | 3.0 / 735 | legacy visibility | free lite; legacy pro ecosystem | sweep/channel simulator | familiar sweep controls | hard-to-hear audio, dated | C | early mover, now stale | Med | Hardware-style precedent |
| 16 | **Sono X10 Spirit Box** | Janus Pedersen | ~2015 / largely legacy | 3.4 / 982 | legacy rating base | free | voice-bank spirit box | unusually transparent mechanism | dated; historical fake complaints | C | old search/review footprint | Med | Transparency precedent |
| 17 | Sono X10 Pro | Janus Pedersen | legacy | 2.4 / ~70 | weak current evidence | $3.99 | paid pro spirit box | UNKNOWN | poor rating / stale | D | pro variant did not inherit scale | Med | Copy/portfolio failure example |
| 18 | **PhenVox Ghost Box** | Janus Pedersen | ~2014 / legacy | 2.6 / 116 | weak current | $3.99 | word/voice ghost box | some intrigue | same words/order, tiny font, no export | **D** | trust + UX + stagnation | High | Strong failure case |
| 19 | **Spirit Words** | Susan Hope Paulin | 2023 / Dec 2025 | 3.3 / 167 | modest | free/ads | random-word spirit talker | simple curiosity | openly random database; UI issues | C | narrow novelty, limited depth | Med | Shows word-generator ceiling |
| 20 | **AI Spirit Box** | Susan Hope Paulin | 2023 / active-ish | 2.9 / 27 | weak | free | AI chatbot framed as spirits | useful for roleplay to some | repetitive, “just chatbot,” grief trust concern | **D** | proposition destroys trust | High | **Avoid AI responses** |
| 21 | **Ghost Radar: CLASSIC** | Spud Pickles | legacy / current listing | 3.6 / 2.4K | strong legacy name | free + IAP | paranormal radar | “original” nostalgia | unverifiable/entertainment ceiling | B | first-mover/legacy brand | Med | Legacy outlier |
| 22 | **Ghost Detector - Spirit Box** | ZipoApps | ~2021 / active | 4.5 / 6K | strong rating base | ads + $4.99 wk / $19.99 mo | camera/radar/EMF entertainment | fun, sleepover-like use | ads interrupt; expensive subscription | **B** | broad casual funnel + ASO/localization | High | Casual audience competitor |
| 23 | **Ghost Detector & Spirit Box** | App Star Family | Sep 2021 / Jan 2025 | 4.5 / 4K | strong rating base | weekly/monthly/yearly subs | ghost stories + camera/sensor entertainment | fun/complete | clearly entertainment; recurring subscription | **B** | content + broad casual proposition | High | Not direct serious instrument |
| 24 | **Ghost detector spirit hunter** | Alex Quesada | ~2022 / active | 4.7 / 5.2K | strong rating base | ads + one-time remove ads | camera/radar game | easy spooky fun | entertainment only | **B** | low-friction casual experience | High | Proves casual top-of-funnel |
| 25 | **Spirit Box Talk to Ghost** | Hoai Hoang | ~2021 / active | 3.7 / 840 | meaningful but generic | $3.99 wk / $9.99 mo / $39.99 yr | ghost-camera prank/talker | scary/fun | “free then pay,” explicitly prank | C | search demand but weak trust | High | Monetization anti-pattern |
| 26 | **Ghost Detector Spirit Box** | Nguyen Dang Hoang Vu | ~2023 / active | 4.0 / 1.1K | meaningful | $3.99 wk / $9.99 mo / $39.99 yr | camera/radar/talker | casual engagement | broad/tracking/subscription | C/B | generic ASO + monetization | Med | Saturation evidence |
| 27 | **Spirit Box Talk To Ghost AI** | Thu Ha Chu Thi | 2023/24 / active | 4.2 / 379 | modest | $3.99 wk / $29.99 yr | AI/camera entertainment | fun story interaction | explicitly not real detection | C | entertainment proposition | High | Avoid AI lane |
| 28 | **Spirit Box: Ghost Whispers** | Hoang Le | 2025 / active | 4.2 / 134 | modest | ads + large one-time packs ($24.99–49.99) | spirit box + EMF + AI | some feature enthusiasm | unclear/overstuffed proposition | C | breadth, not strong brand | Med | Bloat example |
| 29 | **Spirit Box EMF Ghost Detector** | Boss Web SRL | 2025 / Mar 2026 | 4.0 / 454 | modest | weekly/monthly/lifetime | phoneme banks + EMF | “favorite box,” consistent feel | no demo; repeats; subscription transition anger | C | decent core hurt by monetization | High | **Actionable review mining** |
| 30 | **Ghost Detector EMF Necrometer** | Boss Web SRL | Nov 13 2025 / Feb 11 2026 | 4.0 / 389 | modest | $4.99 wk / $9.99 mo / $29.99 lifetime | EMF + DR60 bank + TTS | professional-style tools | trust claims broad; portfolio overlap | C | aggressive ASO/portfolio | High | Fast-copy competitor |
| 31 | **HOPE Spirit Box** | Hope Paranormal | ~2021 / active | 3.3 / 294 | niche | free + IAP | sound-bank spirit box + recordings | clear audio; replay valued | recordings fail/save poorly; short sessions | **C** | good core hurt by reliability | High | **Best review-workflow evidence** |
| 32 | **Necrometer - Spirit box** | Minh Nhat Dang | Oct 25 2023 / Oct 31 2023 | ~2.1 / 44 | current chart signal exists but tiny satisfaction | $4.99 | generic necrometer/talker | limited | repeated phrases, prerecorded noises, missing iOS feature | **D** | name imitation without trust/execution | High | Copycat failure |
| 33 | **Necrometer PRO: Spirit Box EVP** | HDHB | 2026 | 5.0 / 21 | #115 Utilities observed | $9.99 | all-in-one EMF/box/EVP/radar | very early praise | users already ask for “actual radio sweep” | **E** | too new to judge | Med | New competitor watch |
| 34 | **Necrophonic Pro** | Ali Mert Tufekci | ~2025 | ~3.0 / ~1 | no discovery evidence | $9.99 | name-adjacent sound box | UNKNOWN | weak traction/name confusion | **D/E** | surface-copy has no brand moat | Low-Med | Copycat caution |
| 35 | **Paranormal Spirit Box** | Thien Duy Nguyen | ~2024 | ~4.3 / ~4 | no rank evidence | $4.99 | sound-bank spirit box | limited | insufficient evidence | **D** | old enough for weak visible traction | Low-Med | Invisible competitor example |
| 36 | **Void: Necrometer & Ghost Tube** | indie dev | Aug 2024 | 4.5 / ~10 | no rank evidence | $0.99 | fictional AI/simulation | honest fiction | trademark-adjacent naming; little discovery | **D** | cheap + familiar terms did not create scale | Med | Copycat naming lesson |
| 37 | **TeslaVision EMF Detector** | Jeda Software | Oct 2023 / Nov 2024 | 4.4 / ~10 | no strong rank evidence | $4.99, no ads/sub | professional EMF | transparent/professional | little discovery | **D (visibility)** | product quality alone insufficient | Med | “better UI” is not distribution |
| 38 | **Ghost Music Box** | Jeda Software | ~2024 | 3.8 / ~13 | low visibility | one-time/no ads | sensor-triggered music box | niche instrument feel | tiny visible adoption | D | narrow job without distribution | Med | Instrument niche precedent |
| 39 | **Fantasm** | Jeda Software | UNKNOWN | 4.8 / ~65 | niche | UNKNOWN | professional multi-tool ITC platform | polished/pro feel | low visibility | C | quality but no major discovery evidence | Med | Feature breadth not enough |
| 40 | **Animavox: Paranormal Toolkit** | indie | Feb 25 2026 / Jul 16 2026 | 5.0 / ~1 | essentially none | $2.99 mo / $29.99 yr | SLS/LiDAR/EMF/EVP/box/case files | ambitious “no gimmicks” | no visible traction | **D/E** | huge spec list has not produced discovery | Med | Strong bloat/distribution example |
| 41 | **SpiritusX** | indie | 2026 | 5.0 / ~2 | none yet | UNKNOWN | 8 modes, large dictionary, sensor kit | ambitious hardware-alternative | too new / no presence | **E** | insufficient evidence | Low | Watch only |
| 42 | **SpectraBox: Spirit Box EVP** | Vikram Joshi | ~Aug 2026 / Jul 24 v1.3 shown | no rating count shown yet | brand new | **free + $7.99 one-time** | procedural word/sound box + EMF + SLS + recording/export | extreme transparency; no ads/sub/account; session history | too new to know retention | **E** | **fills much of our former white space** | High facts / Low commercial | **Major emerging threat** |
| 43 | **Ghost Detector: Spirit Box EVP** | Anul Agarwal | 2026 | 5.0 / ~2 | none | UNKNOWN | recorder/history/EMF | honest entertainment | too new | E | insufficient evidence | Low | Watch |
| 44 | **Ghost Detector: Spirit Box AR** | indie | 2026 | 5.0 / ~1 | none | ~$3.99 weekly / ~$34.99 annual | AR/radar party app | Halloween/sleepover framing | no traction evidence | E | too new | Low | Seasonal evidence only |
| 45 | **Ghost Detector - Spirit Radar** | indie | 2026-ish | 4.5 / ~114 | modest | ~$4.99 weekly / ~$19.99 annual | party/sleepover radar | social fun | subscription-heavy | C | casual demand | Med | One-night segment evidence |
| 46 | **Spirit Box: EVP Ghost Detector** | Cloud Motion Lab | 2026-ish | 4.1 / ~46 | low/modest | weekly/yearly/lifetime + ads | box + horror stories/scanner | lots to explore | unclear hero job / monetization | C | bloat + generic discovery | Med | Avoid story/game expansion |
| 47 | **Ghost Detector EMF Scanner** | Cloud Motion Lab | 2026-ish | 4.7 / ~7 | weak | IAP/ads likely | EMF + soundboard/camera | novelty | no discovery evidence | D/E | too little traction | Low | Generic copycat |
| 48 | **Ghost Detector: Spirit Box EMF** | MUHAMMET USLU | 2026 | very low/unknown | no rank evidence | IAP | full kit/reporting | timestamped-report ambition | crowded/unclear differentiation | E | too new | Low | Watch |
| 49 | **Spirit Story Box** | legacy indie | legacy | 3.3 / ~121 | historical press mentions | $1.99 + IAP | generated sentence/story experiment | novelty/press | dated, not radio instrument | C | legacy PR outlier | Med | Different narrow job |
| 50 | **Spirit Contact Talker** | Bello Studios LLC | UNKNOWN / active portfolio | UNKNOWN | cross-promo from Bello | IAP | spirit communication app | UNKNOWN | UNKNOWN | E | portfolio adjacency, insufficient data | Low | Shows developer expansion |

### Scorecard takeaway

The category is not a simple split between “good apps” and “failed apps.” It contains at least five different businesses:

1. **creator/brand ecosystems** (GhostTube, Spirit Talker);
2. **legacy paid instruments** (Necrophonic);
3. **ASO-first monetization machines** (May-2026 WPPNT leader, generic subscription apps);
4. **large casual ghost games** (ZipoApps/AppStar-style);
5. **small specialist tools** that may be good products but have little discovery.

Our intended business model belongs closest to **#3 + the product quality of #2**, not #1 or #4.

---

## 11. REVIEW MINING — THE MOST ACTIONABLE THEMES

### Strong signal: “I like the core, but X makes me stop/rate poorly”

These are more valuable than generic one-star complaints.

| App | Core value users like | Friction that damages it | Commercial implication |
|---|---|---|---|
| Necrophonic | recognizable sound-bank experiment; users say it is worth $10 | no built-in recording; sweep clarity/speed problems | paid upfront is viable; review workflow is a real gap |
| HOPE Spirit Box | clear responses/audio; people replay sessions | recordings stop, disappear, or are hard to reopen | reliability of recording is a core feature, not polish |
| Spirit Box EMF Ghost Detector | some users call it their favorite/consistent | no real demo; $5/week; prior-purchase → subscription anger | **trial before paywall** is a high-leverage differentiator |
| GhostTube Original | users trust sensors/ecosystem | history limits, premium cost, dictionary concerns | full history/export can support retention, but GhostTube already owns ecosystem |
| Spirit Entities Talker | coherent-feeling responses, simple use, recording | skeptical users do not understand mechanism | put “how it works” inside onboarding, not buried on website |
| Spirit Talker | creator-backed original; saved sessions | sensor skepticism, voice/UI problems, lost data complaints | creator distribution can overcome mediocre execution, but reliability still matters |
| May-2026 SBX leader | pocket hardware substitute / backup | paywall-before-use; pre-recorded/fake accusations | **our closest exploitable weakness** |

### Strong negative product signals

- repeated exact words/phrases;
- same sequence across sessions;
- creepy prerecorded audio that feels canned;
- chatbot-style answers;
- EMF behavior that does not correlate with obvious magnetic sources;
- “fake” visual ghosts/radar;
- unclear sensor mechanism.

### Positive language worth designing toward

Repeated positive-review language clusters around:

- “professional”;
- “real equipment” / “backup equipment”;
- “clear” audio;
- “simple”;
- “works right away”;
- “record/review later”;
- “no random word bank”;
- “uses real sensors”;
- “I can keep it on my phone instead of carrying another device.”

This language is much more strategically useful than generic “spooky” or “fun.”

---

## 12. DIRECT COMPETITION MATRIX

**Legend:** Yes = clearly present; Partial = some equivalent but not the same workflow; No = absent/not core; Unknown = not verified. “Search strength” is qualitative based on visible market presence/title/brand, not invented keyword-volume data.

| Product | Primary job | Search / brand strength | UI identity | Spirit-box method | Recording | MARK / tags | Replay/history | EMF | Words | SLS | AI | Community / locations | Ads | Subscription | Lifetime/upfront | Trust positioning | Our overlap | Direct risk |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **OUR PROPOSED V1** | tactile radio-sweep session + review | none yet | old-school field instrument | **must be transparently defined** | Yes | **Yes, hero** | **Yes, hero** | Yes/supporting | **No recommended** | No | No | No | No | **No recurring** | $9.99 hypothesis + short pass | mechanism/privacy front-and-center | — | — |
| **Spirit Box SBX Ghost Talker** | pocket SBX-style sweep | **Very high generic ASO in project data** | focused instrument | simulated continuous radio-style sweep; speed/reverse/AM-FM style | No verified | No | No | unclear/supporting REM/indicator | No | No | No | No | No | **Yes** | $29.99 lifetime | no data collection, but fake/paywall reviews | **Very High** | **VERY HIGH** |
| **GhostTube VOX** | sensor-reactive internet-radio sweep | high brand | GhostTube/video tool | real internet-radio streams synthesized on triggers | video/session capture features | no sweep-specific mark verified | partial | sensor triggers | No fixed dictionary | No | No | **Yes** | ecosystem ads possible | Yes | annual web plans | strong mechanism disclaimer | **High audio-job overlap** | **HIGH** but moat avoidable |
| **GhostTube EVP** | EVP recorder / DR60 | high brand | professional recorder | microphone + modulated EVP | **Yes** | **Yes: audio tagging** | **Yes** | sensor modulation | No core word bank | No | No | Yes ecosystem | ecosystem | Yes | annual | strong transparency | **Medium workflow overlap** | Medium |
| **Necrophonic** | phoneme-bank ITC | strong legacy paid | distinctive instrument | 8 phoneme/sound banks | **No built-in per reviews** | No | No | No | no full-word bank | No | No | No | No | **No** | **$9.99 upfront** | explains banks; no data collection | High session/audio overlap | **HIGH** legacy |
| **Spirit Entities Talker** | sensor word communication + toolkit | strong mid-tier | clean talker/toolkit | word/talker + newer box | **Yes** | partial | Yes | Yes | **Yes** | some broader features | AI analysis added | No major community moat | ads | no major recurring plan found; one-time pack | ~$4.99 pack | mixed: users ask for more explanation | Medium | Medium |
| **Ghost Hunting Tools** | all-in-one beginner kit | **10K ratings** | broad toolkit | curated word bank, no radio hiss | EVP | partial/history | partial | Yes | **Yes** | No core | No core | No | **Yes** | Yes | $19.99/$29.99 Pro options | increasingly transparent | Low-Medium | Medium |
| **SBX12** | legacy sweep box | legacy | hardware-like | channel/sweep simulation | No verified | No | No | No | No | No | No | No | lite ads | legacy pro | separate paid variants | basic mechanism | High | Medium-low current |
| **HOPE Spirit Box** | sound-bank session | niche | focused box | sound banks | **Yes** | No | **Yes** | No | No | No | No | No | No/limited | IAP | free core | creator/personality trust | High | Medium |
| **Spirit Talker** | Ovilus-style sensor words | strong creator brand | word instrument | sensor-triggered dictionary | session save | event list | history | Yes | **Yes** | No core | No | No | No | No | **$4.99 upfront** | “original,” mechanism docs | Low | Low if we avoid words |
| **Ghost Talker - Spirit Box Live** | live-radio all-in-one toolkit | growing | broad lab | **up to 12 live internet radio streams** | session/history/capture | not hero | Yes | Yes | Yes alt mode | Yes | No core | No major community | tracking | one-time unlock | $6.99 | explains radio source | **High** | **HIGH feature threat** |
| **SpectraBox** | transparent all-in-one session/evidence toy | brand-new | clean modern toolkit | **procedural on-device sound + spoken words; explicitly not radio** | **Yes** | EVP tagging / timestamps | **Yes + export** | Yes | **Yes** | Yes-style | analysis tools | No | **No** | **No** | **$7.99 one-time** | **extremely explicit** no fakery/tracking | **High workflow overlap** | **HIGH emerging** |
| **Ghost Detector - Spirit Box (Zipo)** | casual ghost-camera game | broad casual | horror/camera | not serious radio job | screen record | No | limited | Yes | mixed | camera effects | No | No | **Yes** | **Yes** | no notable lifetime in listing | explicit entertainment | Low | Low for serious instrument; high for casual attention |

### Where we are directly competing

1. **WPPNT / Spirit Box SBX Ghost Talker** — same generic query, same physical-box analogy, same simple sweep controls.
2. **GhostTube VOX** — same broad “spirit box through radio fragments” job, but with stronger brand and online streams.
3. **Bello Ghost Talker - Spirit Box Live** — live-radio sweeper with fast-moving feature expansion.
4. **Necrophonic** — same user desire for a pocket communication instrument, despite different audio mechanism.
5. **SpectraBox** — same anti-subscription/transparency/session-history story, though not the same radio-sweep mechanic.

### Where we are differentiated

- no generated word answers;
- no AI interpretation;
- no SLS/camera gimmicks;
- no community/account/location database;
- offline-first if using transparent synthesized/banked audio;
- **MARK is central, not hidden in an EVP module**;
- hardware-like one-thumb controls and haptics;
- review is organized around moments the user chose, not a giant transcript;
- no recurring subscription;
- instrument-first App Store presentation rather than “ultimate ghost toolkit.”

---

## 13. WHITE-SPACE ANALYSIS

### Wedge A — Dedicated instrument vs super-app

**User demand:** YES. The May-2026 leader’s search success and “pocket SB7” reviews directly support it.  
**Already solved?** Partly: WPPNT leader and Necrophonic are focused.  
**Noticeable in App Store?** YES, if screenshots show one instrument and one flow.  
**Copyable?** Very.  
**Avoids GhostTube moat?** YES.  
**Complexity:** LOW.  
**Revenue effect:** likely positive because it maps to exact search intent.  
**Verdict:** **KEEP.**

### Wedge B — Tactile/haptic hardware feel

**User demand:** INDIRECT but credible. Reviews value products that feel like real/backup equipment; no competitor in this pass visibly owns haptics as a marketing claim.  
**Already solved?** Not strongly visible.  
**Noticeable in App Store?** Only if visually demonstrated; haptics themselves are not visible in a screenshot.  
**Copyable?** Very.  
**Avoids GhostTube moat?** YES.  
**Complexity:** LOW-MEDIUM.  
**Revenue effect:** primarily conversion/review quality, not discovery.  
**Verdict:** **KEEP as product quality, not the sole positioning wedge.**

### Wedge C — Better audio

**User demand:** YES. Clear/professional audio is a repeated positive; clipping/repetition is a repeated negative.  
**Already solved?** No universally accepted winner.  
**Noticeable in App Store?** Hard in screenshots; strong in preview video and reviews.  
**Copyable?** Medium; quality execution is harder than adding a checkbox.  
**Avoids GhostTube moat?** Somewhat.  
**Complexity:** MEDIUM and deserving of prototype time.  
**Revenue effect:** likely retention/review quality.  
**Verdict:** **CORE QUALITY GATE.**

### Wedge D — Recording

**User demand:** YES. Strong review evidence.  
**Already solved?** YES by many apps.  
**Noticeable?** Yes but not differentiating alone.  
**Copyable?** Yes.  
**Verdict:** **TABLE STAKES, NOT WHITE SPACE.**

### Wedge E — MARK timestamps + mark-centered replay

**User demand:** recording/review demand is clear; explicit “MARK this exact sweep moment” demand is inferred from note-taking/tagging behavior. GhostTube EVP validates tagging, but not in a dedicated radio-sweep UX.  
**Already solved?** Partially.  
**Noticeable?** **Yes** if screenshot 2 clearly shows “Hear something? Tap MARK. Replay 10 seconds around it.”  
**Copyable?** Yes.  
**Avoids GhostTube moat?** Yes if kept inside single instrument.  
**Complexity:** LOW-MEDIUM.  
**Revenue effect:** can increase perceived seriousness + repeat use.  
**Verdict:** **BEST PRODUCT WEDGE FOUND.**

### Wedge F — Offline

**User demand:** privacy/reliability appeal is visible; SpectraBox markets airplane-mode operation explicitly.  
**Already solved?** YES by sound-bank/procedural products.  
**Trade-off:** cannot simultaneously claim real terrestrial radio scanning.  
**Verdict:** **KEEP only if mechanism transparency stays stronger than “real radio” theater.**

### Wedge G — No ads

**User demand:** YES.  
**Already solved?** multiple paid/lifetime products exist.  
**Verdict:** **IMPORTANT HYGIENE, NOT DIFFERENTIATION.**

### Wedge H — No recurring subscription

**User demand:** YES, strongly.  
**Already solved?** Necrophonic, Spirit Talker, SpectraBox and lifetime options already exist.  
**Verdict:** **CONVERSION ADVANTAGE, NOT UNIQUE MOAT.**

### Wedge I — Transparent mechanism/privacy

**User demand:** YES, unusually strong in this category.  
**Already solved?** GhostTube and SpectraBox do this well; many others do not.  
**Verdict:** **MANDATORY.** We cannot beat GhostTube on trust while being vaguer than GhostTube.

### Wedge J — Low-cost one-night access

**User demand:** the **segment** exists; exact price is not validated. See pricing section.  
**Already solved?** Weekly subscriptions are common; an Android spirit-radio app has used a small one-off payment for an ad-free session, which is directional evidence only.  
**Verdict:** **TESTABLE MONETIZATION WEDGE, NOT YET VERIFIED.**

---

## 14. SEASONAL / CASUAL AUDIENCE

### Verified behavioral evidence

The category clearly includes:

- weekend ghost hunts;
- historic/haunted locations;
- “my real spirit box died” backup use;
- friends messing around;
- sleepovers;
- Halloween;
- parties;
- dark-room/home curiosity.

Examples:

- A May-2026 SBX review describes using the app when physical equipment died during an investigation. [S2]
- Generic ghost apps explicitly advertise sleepovers and parties. [S31]
- Reddit threads include users seeking phone tools for a ghost-hunting opportunity that weekend and joking that some apps belong at Halloween sleepovers. [S41][S44]
- Ghost Hunting Tools’ current listing literally suggests opening it at a bonfire, basement, or empty hotel room. [S22]

### What this does **not** prove

It does **not** prove:

- that Halloween creates a specific X% revenue spike;
- that $1.99 is the optimal 24-hour price;
- that one-night users convert better than subscriptions;
- that search demand is predominantly seasonal.

No defensible current App Store seasonality/download series was obtained in this pass, so those remain **UNKNOWN**.

### Segment conclusion

A one-night user is real enough to design a purchase option for, but not important enough to redesign the core product into a prank app.

The product should still look like equipment. The casual user should feel like they are borrowing a serious tool for a night.

---

## 15. PRICING FORENSICS

### Current relevant reference points

| Product | Current observed monetization |
|---|---|
| May-2026 Spirit Box SBX leader | $4.99/week, $9.99/month, $29.99 lifetime; hard-paywall complaints |
| Necrophonic | **$9.99 upfront** |
| Spirit Talker | **$4.99 upfront** |
| SpectraBox | free limited core + **$7.99 one-time Pro** |
| Ghost Talker - Spirit Box Live | **$6.99 one-time unlock** |
| GhostTube individual apps | free core + roughly **$12.99 non-renewing 12 months** via web; bundle $49.99 |
| Ghost Hunting Tools | ads + monthly/yearly + $19.99/$29.99 Pro options |
| Zipo ghost detector | ~$4.99/week / ~$19.99 month + ads |

### Evaluate the current hypothesis

#### Free real trial

**SUPPORTED.**

This directly addresses one of the strongest repeated review complaints and mirrors GhostTube’s trust/acquisition advantage.

#### $1.99 / 24 hours

**PLAUSIBLE, NOT VALIDATED.**

Why it could work:

- one-night/party/weekend usage clearly exists;
- subscription resentment is strong;
- price is small relative to $4.99 weekly competitors;
- it allows a casual user to pay without feeling trapped.

Why it could fail:

- a user may interpret paying for “24 hours” as another rental gimmick;
- if the free trial is meaningful, casual users may not need the pass;
- Apple purchase-state UX must be extremely clear;
- no evidence in this pass proves $1.99 is the right price.

**Verdict:** TEST, do not treat as established.

#### $4.99 / 7 days

**WEAKEST PART OF THE CURRENT PRICE LADDER.**

At a $9.99 lifetime price, a 7-day pass costs half of permanent ownership. It is also psychologically adjacent to the category’s hated $4.99/week subscriptions.

**INFERENCE:** This tier is likely to confuse positioning and cannibalize the clean “one night or own it” story.

**Recommendation for launch testing:** **omit the 7-day tier initially** unless prelaunch/user testing reveals a strong weekend-investigation use case that specifically rejects both 24h and lifetime.

#### $9.99 lifetime launch price

**SUPPORTED AS A PLAUSIBLE PRICE POINT.**

Necrophonic has sustained a $9.99 upfront model for years; SpectraBox is $7.99 one-time; Spirit Talker is $4.99. The May-2026 leader asks $29.99 lifetime.

This does **not** prove $9.99 maximizes revenue, but it shows the price is not obviously outside category willingness-to-pay.

### Recommended initial pricing hypothesis after this pass

> **Free real session → $1.99 24-hour access OR $9.99 lifetime launch unlock. No 7-day tier at first. No auto-renewing subscription.**

This is still a hypothesis. Its advantage is strategic clarity:

- curious tonight → $1.99;
- investigator/hobbyist → own it.

If lifetime conversion is unusually strong, $9.99 may eventually be too cheap. Do not pre-commit to permanent pricing before observing actual purchase mix.

---

## 16. WHY COPYCATS FAIL

### Copying a famous name does not copy trust

Apps with Necrophonic/Necrometer/GhostTube-adjacent naming frequently have tiny visible traction or poor ratings.

The original Necrophonic explains exactly what is in its sound banks and has years of creator/community familiarity. A lookalike with repeated canned phrases triggers the exact opposite response.

### Copying a feature list does not copy distribution

Animavox and similar toolkits can list more features than GhostTube while having essentially no visible market presence.

GhostTube’s moat includes creator links, community data, a web content engine, cross-app accounts, ratings, and a multi-year brand. None of that appears in an App Store feature checklist.

### Copying hardware aesthetics does not copy audio credibility

A user who expects an SB7-like experience listens for cadence, sweep feel, clarity and randomness. Cheap loops become obvious through repeated use.

### Copying “no ads” does not create search traffic

Low-priced or no-ad paranormal apps can remain invisible. Product economics require an acquisition mechanism, not just a less annoying monetization model.

### Copying “professional” UI does not solve a vague job

A tool with six meters and a “serious” dark interface can still be less compelling than one big START button and an exact promise.

### What cannot be copied quickly

- accumulated reviews;
- creator relationships;
- historical brand memory;
- community data;
- search authority;
- long-running tutorial/SEO content;
- years of iteration on edge cases;
- trust earned through transparent explanations and responsive support.

Our strategy should therefore **not** depend on copying any of those. It should depend on a narrower job that does not require them.

---

## 17. SUCCESSFUL OUTLIERS THAT ARE NOT GHOSTTUBE

### 17.1 May-2026 Spirit Box SBX Ghost Talker — the recent ASO outlier

**Narrow job:** pocket SBX-style sweep.  
**Search intent:** literal generic `spirit box`.  
**Monetization:** aggressive weekly/monthly/lifetime.  
**Distribution:** prior project work supports generic App Store search as material.  
**Why it matters:** proves a small recent entrant can break through without building a GhostTube ecosystem.  
**Weakness:** bad rating quality and monetization/trust complaints.

This is the most replicable commercial precedent for us.

### 17.2 Necrophonic — legacy paid instrument

**Narrow job:** phoneme-bank ITC audio instrument.  
**Price:** $9.99 upfront.  
**Why it won:** recognizable audio concept, long brand history, creator/community usage, simple one-time pricing.  
**Weakness:** stale product and no integrated review workflow.

This is evidence that users will pay outright for a focused paranormal audio tool.

### 17.3 Spirit Talker — creator-adopted Ovilus alternative

**Narrow job:** sensor-triggered word communication.  
**Price:** $4.99 upfront.  
**Distribution:** extensive creator/show mentions in its own listing; Android 100K+ installs.  
**Why it won:** “original” identity + creator adoption + long presence.  
**Weakness:** poor iOS rating and sensor/UI complaints.

This is **not** easily replicable because its creator-network/history is the moat.

### 17.4 Ghost Radar Classic — legacy brand

**Narrow job:** radar-like paranormal readings.  
**Why it won:** first-mover “original” positioning and long-lived name recognition.  
**Replicability today:** LOW. Legacy status cannot be recreated.

### 17.5 Large casual ghost-detector apps

Apps from ZipoApps, App Star Family and others have thousands of ratings by leaning into camera/radar entertainment, stories, and spooky group play.

**Why they matter:** curiosity is huge.  
**Why we should not imitate them:** their business is entertainment volume, ads/subscriptions, and novelty—not a premium instrument relationship.

---

## 18. COMMERCIAL USER SEGMENTS

| Segment | Willingness to pay | Expected features | UI expectation | Trust requirement | Session frequency | Dominant competitors | Should we target? | GhostTube ownership |
|---|---|---|---|---|---|---|---|---|
| **1. Serious paranormal investigator** | Medium-High if reliable | transparent mechanism, recording, marks, export, stability, EMF, dark-room use | real equipment, no gimmicks | **Very High** | recurring investigations | GhostTube ecosystem, Spirit Talker, Necrophonic, physical hardware | **Secondary target / backup-tool angle** | High overall, but not exclusive for simple sweep |
| **2. Hobbyist / believer** | Medium | immediate box session, believable audio, history, simple controls | instrument-like but approachable | High | weekly/monthly/episodic | Necrophonic, GhostTube, Spirit Entities | **PRIMARY** | Medium-High |
| **3. Curious beginner** | Low-Medium | instant first result, tutorial, no scary paywall | easy, visually clear | Medium | a few sessions | generic ghost detectors, GhostTube free core | **Top-of-funnel target** | Medium |
| **4. Halloween / party / one-night user** | Low | instant fun, no account, short purchase, flashlight, easy handoff | approachable + atmospheric | Lower, but hates being scammed | seasonal / one night | prank/radar apps | **Monetization segment, not design center** | Low |
| **5. Paranormal content creator** | Medium-High | video overlays, SLS, export, social sharing, locations, creator-friendly formats | production tool | High | frequent | **GhostTube strongly** | **NO as primary** | **Very High** |

### Recommended audience hierarchy

1. **Hobbyist/believer who wants a credible pocket spirit box**
2. **Serious investigator who wants a backup/secondary box without carrying hardware**
3. curious/one-night user via real trial + 24h option
4. content creator only incidentally

Do not contort V1 around content creators; that invites direct GhostTube competition.

---

## 19. PRODUCT POSITIONING AFTER THIS PASS

### Recommended one-sentence position

> **For paranormal hobbyists and investigators who want a pocket spirit box—not another ghost-hunting super-app—build a tactile, old-school sweep instrument centered on START → LISTEN → MARK → REPLAY, with transparent audio mechanics and simple one-time/one-night access, and deliberately avoid GhostTube’s SLS, AI, community, haunted-location, and creator ecosystem.**

### What the product should *be*

- one hero screen;
- convincing, non-obviously-looped sweep audio;
- explicit sweep speed;
- forward / reverse;
- AM-style / FM-style modes **only if labeled honestly**;
- record every real session;
- giant MARK control reachable by thumb;
- distinct haptic feedback for start/stop/mark/speed detents;
- post-session list of marked moments;
- one-tap replay around each mark;
- magnetometer as a supporting readout;
- flashlight;
- dark-room / red-light-conscious UX;
- offline if mechanism is procedural/banked;
- no account;
- no ads;
- no recurring subscription;
- mechanism/privacy explanation accessible before first session.

### What the product should *not* be

- a GhostTube replacement;
- SLS camera;
- word generator;
- AI chatbot;
- AI “spirit interpretation”;
- haunted location directory;
- social community;
- paranormal news/content feed;
- a case-management suite in V1;
- a giant multi-tool dashboard;
- a cartoon/scary prank app;
- an exact visual copy of SB7/P-SB hardware;
- a false claim of tuning terrestrial AM/FM while offline.

---

## 20. THE IP / TRADE-DRESS POSITION

### Higher-risk behavior to avoid

- putting `GhostTube`, `Necrophonic`, `Necrometer`, or `Spirit Talker` in a confusing product name;
- copying GhostTube’s icon system/wordmark;
- marketing as an “SB7 app” in a way that implies affiliation;
- reproducing a physical spirit box’s exact faceplate/control arrangement/trade dress;
- copying another app’s audio banks or prerecorded source material;
- using third-party internet radio streams without understanding rights/App Review requirements.

GhostTube publishes formal brand guidelines and identifies GhostTube as a registered trademark in multiple jurisdictions. [S13]

### Safer differentiation

Use generic descriptive terms such as **spirit box, radio sweep, paranormal recorder, EVP review** in a clearly original brand/interface, and describe inspiration at the category level rather than passing off the product as another company’s device.

---

## 21. INTERNET RADIO VS OFFLINE — A COMMERCIAL/LEGAL DESIGN DECISION

This is the biggest product-mechanism question still hidden inside the seemingly simple V1.

### Option 1 — Internet-radio streams

**Pros**

- closer to classic spirit-box “broadcast fragments” behavior;
- avoids the accusation that every voice is a developer-authored bank;
- GhostTube VOX and Bello’s live-radio product show the concept is accepted in-market.

**Cons**

- not offline;
- network latency/outages;
- geography/station availability;
- audible copyrighted broadcasts/music;
- current Apple Developer Forum threads show App Review may ask internet-radio apps for evidence of rights/permissions under Guideline 5.2.3. [S45]

### Option 2 — phoneme/audio banks

**Pros**

- offline;
- low operational complexity;
- proven by Necrophonic/legacy products.

**Cons**

- repetition is one of the category’s strongest trust failures;
- requires excellent corpus design/randomization;
- source/licensing must be clean.

### Option 3 — procedural/synthetic audio

**Pros**

- offline;
- deterministic privacy/no streaming;
- can be transparently described;
- no dependence on broadcaster rights.

**Cons**

- not actual radio;
- can feel artificial if audio design is weak;
- SpectraBox already markets this transparency strongly.

### Research conclusion

Do **not** decide this based on what sounds coolest in the feature list.

> **We should find out whether target users prefer “real internet-radio fragments” or “offline synthetic sweep with transparent mechanics” before finalizing the audio architecture.**

That question can affect trust, offline positioning, App Review risk, and the core product promise more than any visual design decision.

---

## 22. CHEAPEST REMAINING TEST

The app idea has enough commercial evidence to justify a final no-code kill test, but **not** enough differentiation to skip it.

### Test exactly this proposition against current alternatives

Create three App-Store-style concept cards/screenshots (not a functioning app):

**A. Our recommended product**  
“Pocket Spirit Box — Listen. MARK. Replay.”  
No generated words. Offline. No subscription.

**B. Current leader-style product**  
“SBX Spirit Box — AM/FM sweep, speed, reverse.”

**C. Broad toolkit**  
“Spirit Box + EMF + SLS + EVP + AI.”

Show them to target users drawn from paranormal hobbyist/investigator communities and ask:

- Which would you download first?
- What do you think each one actually does?
- Which looks most like real equipment?
- Which do you trust most?
- Does MARK/replay change your preference?
- Would you rather have offline synthetic audio with explicit transparency or live internet-radio fragments?
- Which payment feels least objectionable: $1.99 tonight, $9.99 lifetime, or subscription?

Do not ask “do you like our idea?” The comparison is the test.

### Why this is the cheapest decisive test

The biggest remaining uncertainty is **not whether spirit-box demand exists**. It is whether the proposed differentiation is visible and valuable enough to win a click against the exact leader and increasingly capable substitutes.

---

## 23. KILL CRITERION

Kill or materially reposition the project before implementation if either of the following becomes true:

1. **The first-screen proposition cannot make users distinguish our START → MARK → REPLAY instrument from the May-2026 leader, GhostTube VOX, SpectraBox, or Bello’s live-radio app.**

2. Review/concept testing shows that target users overwhelmingly care about **real live radio** and reject an offline synthesized/banked implementation as fake, while a compliant/authorized internet-radio implementation would destroy the desired offline/simple/low-maintenance profile.

3. The top `spirit box` search results add another strong focused entrant that already combines tactile sweep + real trial + mark-centered recording/replay + one-time pricing before we ship.

The product should not be preserved because we have already researched it.

---

## 24. FINAL ANSWERS

### 1. WHY MOST GHOST APPS FAIL

Ranked:

1. **Trust collapse** — repeated/canned output, opaque mechanics, mic/listening suspicions, fake sensor claims.
2. **Monetization before value** — hard paywall, weekly subscription, misleading free listing, ads interrupting sessions.
3. **Weak audio / obvious loops** — clipped, noisy, repetitive, confusing output.
4. **No session-review workflow** — interesting moments vanish; recordings/history are unreliable or absent.
5. **Feature bloat / unclear hero job** — many weak tools do not create a stronger search proposition.
6. **No acquisition identity** — quality/no-ads apps can remain invisible without exact-intent ASO, brand, or creator distribution.
7. **Copying surface features without the original moat** — no inherited trust, reviews, creators, search authority, or community.
8. **Reliability / abandoned maintenance** — lost recordings and stale OS compatibility are especially destructive in field tools.
9. **Toy-like positioning** — can acquire casual users but weakens serious-instrument WTP.
10. **Novelty-only retention** — one-night fun without session artifacts gives users little reason to return.

### 2. WHY THE STRONG MULTI-APP DEVELOPER SUCCEEDED

GhostTube’s moat is:

> **creator distribution + brand trust + transparent mechanism explanations + a portfolio of specialized apps + community/haunted-location content + localization + ongoing maintenance + cross-app bundling.**

It did **not** win simply because its UI is better.

### 3. WHAT THEY OWN

Avoid direct attack on:

- SLS;
- paranormal video/content creation;
- AI interpretation;
- haunted locations;
- community/social evidence;
- all-in-one sensor ecosystem;
- multi-app subscription bundle;
- creator-led distribution.

### 4. WHAT THEY DO NOT OWN

They do not fully own:

- generic `spirit box` search;
- the minimal “pocket hardware replacement” job;
- a one-screen tactile old-school instrument identity;
- mark-centered sweep review;
- a deliberately **non-AI, non-word-generator** trust position;
- simple one-night/lifetime access.

But parts of this white space are already being filled by WPPNT, SpectraBox, Bello Studios and GhostTube EVP.

### 5. OUR RECOMMENDED POSITION

> **For paranormal hobbyists and investigators who want a pocket spirit box—not another ghost-hunting super-app—build a tactile old-school sweep instrument centered on START → LISTEN → MARK → REPLAY, differentiated by transparent audio mechanics, exceptional haptics/session review, and simple one-night/lifetime access, while deliberately avoiding GhostTube’s SLS, AI, community, haunted-location, and creator ecosystem.**

### 6. SHOULD WE STILL BUILD?

## **CONDITIONAL YES**

The demand and commercial anomaly are strong enough to keep the concept alive. This pass did **not** find a reason to kill the category.

However, the initial broad differentiation claim has been weakened by new competitors. The build should proceed only after the no-code concept test confirms that **MARK/replay + instrument feel + transparency** is a visible reason to choose the app.

### 7. BIGGEST BEAR CASE

> **The market gap may be temporary and shallow: we are arriving just as multiple developers converge on no-subscription, transparent, recorded paranormal sessions, while the most established players already own brand trust and the current ASO leader already owns the exact SBX-style search promise.**

If our differentiator is merely “more polished,” an incumbent can copy it and a user may never notice it from search results.

### 8. CHEAPEST REMAINING TEST

A no-code App Store concept comparison focused specifically on:

- tactile single-purpose instrument vs toolkit;
- **MARK/replay** as the hero feature;
- offline transparent synthesis vs live internet-radio fragments;
- $1.99 24h vs $9.99 lifetime vs subscription.

### 9. KILL CRITERION

Kill if users cannot clearly articulate why they would choose the START → MARK → REPLAY product over the current leader/VOX/SpectraBox after seeing only the store proposition, or if the audio-mechanism preference forces us into an internet-radio/licensing/maintenance model that breaks the small-offline-product thesis.

---

# SOURCE REGISTER

All sources accessed/currently checked around September 2, 2026 unless otherwise noted. App Store rating counts are storefront- and time-sensitive.

### Core direct competitors

**[S1] Apple App Store — Spirit Box SBX Ghost Talker (Ewregu / WPPNT LTD)**  
https://apps.apple.com/us/app/spirit-box-sbx-ghost-talker/id6763719251

**[S2] Apple App Store Canada — Spirit Box SBX Ghost Talker reviews**  
https://apps.apple.com/ca/app/spirit-box-sbx-ghost-talker/id6763719251?see-all=reviews

**[S3] Apple App Store — SpectraBox: Spirit Box EVP**  
https://apps.apple.com/us/app/spectrabox-spirit-box-evp/id6780213241

**[S18] Apple App Store — Necrophonic**  
https://apps.apple.com/us/app/necrophonic/id1396698319

**[S25] Apple App Store — HOPE Spirit Box reviews**  
https://apps.apple.com/us/app/hope-spirit-box/id1575801221?see-all=reviews

**[S26] Apple App Store — Spirit Box EMF Ghost Detector (Boss Web SRL)**  
https://apps.apple.com/us/app/spirit-box-emf-ghost-detector/id6741384006

**[S27] Apple App Store — Necrometer - Spirit box (Minh Nhat Dang) reviews**  
https://apps.apple.com/us/app/necrometer-spirit-box/id6470335901?see-all=reviews

**[S28] Apple App Store — PhenVox Ghost Box**  
https://apps.apple.com/us/app/phenvox-ghost-box/id928922244

**[S29] Apple App Store — AI Spirit Box**  
https://apps.apple.com/us/app/ai-spirit-box/id6452472376

### GhostTube ecosystem

**[S4] Apple App Store — GhostTube Original**  
https://apps.apple.com/us/app/ghosttube/id1429639135

**[S5] Apple App Store — GhostTube VOX**  
https://apps.apple.com/us/app/ghosttube-vox/id1574490738

**[S6] Apple App Store — GhostTube EVP**  
https://apps.apple.com/us/app/ghosttube-evp/id6747162108

**[S7] Apple App Store — GhostTube SEER**  
https://apps.apple.com/us/app/ghosttube-seer/id1644487365

**[S8] GhostTube official — GhostTube SLS product page**  
https://ghosttube.com/products/ghosttube-sls

**[S9] GhostTube official — Bundle 12-month subscription**  
https://ghosttube.com/products/ghosttube-bundle-12-month-subscription

**[S10] GhostTube official — Subscriptions collection**  
https://ghosttube.com/collections/subscriptions

**[S11] GhostTube official — “Is GhostTube Real or Fake?”**  
https://ghosttube.com/blogs/ghosttube/is-ghosttube-real-or-fake

**[S12] GhostTube official — Information collected / permissions**  
https://ghosttube.com/pages/help-privacy-info

**[S13] GhostTube official — Terms of service**  
https://ghosttube.com/policies/terms-of-service

**[S47] GhostTube official — Blog / educational content**  
https://ghosttube.com/blogs/ghosttube

### GhostTube creator/distribution evidence

**[S14] Amy’s Crypt YouTube — channel/video descriptions linking GhostTube products**  
https://www.youtube.com/@AmysCrypt

**[S15] Amy’s Crypt Patreon — About**  
https://www.patreon.com/amyscrypt/about

**[S16] SPEAKRJ — Amy’s Crypt YouTube stats, updated Aug. 15, 2026 (third-party)**  
https://www.speakrj.com/audit/report/UCiEK-SwMjiYsiWzXvOKqKdg/youtube/media-stats

**[S17] Amy’s Crypt Patreon — GhostTube Community post, Apr. 3, 2022**  
https://www.patreon.com/amyscrypt/posts/ghosttube-64646038

### Spotted Ghosts

**[S19] Apple App Store — Spirit Talker**  
https://apps.apple.com/us/app/spirit-talker/id1536762482

**[S20] Google Play — Spirit Talker**  
https://play.google.com/store/apps/details?id=com.SpottedGhosts.SpiritTalker

**[S21] Spotted Ghosts official — About**  
https://spottedghosts.com/about/

### Other meaningful iOS products

**[S22] Apple App Store — Ghost Hunting Tools - Detector**  
https://apps.apple.com/us/app/ghost-hunting-tools-detector/id1025393457

**[S23] Apple App Store — Spirit Entities Talker reviews**  
https://apps.apple.com/us/app/spirit-entities-talker/id6472714903?see-all=reviews

**[S24] Apple App Store — Spirit Entities Talker**  
https://apps.apple.com/us/app/spirit-entities-talker/id6472714903

**[S30] Apple App Store — Ghost Radar: CLASSIC**  
https://apps.apple.com/us/app/ghost-radar-classic/id368470785

**[S31] Apple App Store — Ghost Detector - Spirit Box (ZipoApps)**  
https://apps.apple.com/us/app/ghost-detector-spirit-box/id1583251752

**[S32] Apple App Store — Ghost Detector & Spirit Box (App Star Family)**  
https://apps.apple.com/us/app/ghost-detector-spirit-box/id1581358592

**[S33] Apple App Store — Spirit Box Talk to Ghost**  
https://apps.apple.com/us/app/spirit-box-talk-to-ghost/id1585598730

**[S34] Apple App Store — Ghost detector spirit hunter**  
https://apps.apple.com/us/app/ghost-detector-spirit-hunter/id1612816141

**[S35] Apple App Store — Ghost Detector EMF Necrometer (Boss Web SRL)**  
https://apps.apple.com/us/app/ghost-detector-emf-necrometer/id6754881764

**[S36] Apple App Store — Ghost Talker - Spirit Box Live (Bello Studios)**  
https://apps.apple.com/us/app/ghost-talker-spirit-box-live/id6742842360

**[S37] Apple App Store — Spirit Chat Box - Ghost Talker (Zee Weasel)**  
https://apps.apple.com/us/app/spirit-chat-box-ghost-talker/id6748859963

**[S38] Apple App Store — SBX 12 Spirit Box**  
https://apps.apple.com/us/app/sbx-12-spirit-box/id1051643118

**[S39] Apple App Store — Sono X10 Spirit Box**  
https://apps.apple.com/us/app/sono-x10-spirit-box/id987656337

**[S40] Apple App Store — Spirit Words**  
https://apps.apple.com/us/app/spirit-words/id6446749894

### User/community evidence

**[S41] Reddit r/GhostHunting — “Which Spirit Box apps actually work?” (June 2024; updated comments through 2026)**  
https://www.reddit.com/r/GhostHunting/comments/1dg2nfv/which_spirit_box_apps_actually_work/

**[S42] Reddit r/ParanormalEncounters — “What’s the best Spirit Box app for an iPhone?”**  
https://www.reddit.com/r/ParanormalEncounters/comments/15ewok7/

**[S43] Reddit r/GhostHunting — “What’s the best spirit box app”**  
https://www.reddit.com/r/GhostHunting/comments/176aayz/

**[S44] Reddit r/GhostHunting — “ghost hunting phone apps?”**  
https://www.reddit.com/r/GhostHunting/comments/rxyx64/

### iOS radio/technical constraint evidence

**[S45] Apple Developer Forums — July 2026 discussion of internet-radio App Review / Guideline 5.2.3 rights documentation**  
https://developer.apple.com/forums/tags/http-live-streaming

**[S46] Apple Developer — AVFoundation overview**  
https://developer.apple.com/av-foundation/

### Source-discipline notes

- The project’s **~$9K/month RevenueCat figure and generic `spirit box` ranking history for the May-2026 leader** come from prior project research and are treated as established inputs because this pass was explicitly instructed not to redo generic demand validation.
- GhostTube/Amy’s Crypt subscriber counts are third-party snapshots and are used only as scale evidence; they are not revenue estimates.
- Spotted Ghosts’ “6.5 million downloads” figure is a developer claim and is labeled as such.
- No revenue is attributed to GhostTube, Spirit Talker, Necrophonic or other apps without direct evidence.
- No rating count is treated as equivalent to revenue.
- No keyword volume, download count, conversion rate, featuring, or paid acquisition is invented.
- Apps classified D are not labeled weak merely because they have few ratings; classification uses age/stagnation, poor review patterns, missing discovery evidence, or obvious execution issues where available.

---

## CANONICAL PROJECT STATE AFTER THIS PASS

### ALIVE

- Generic `spirit box` commercial opportunity.
- Focused single-purpose instrument strategy.
- real free trial.
- no recurring subscription.
- recording.
- **MARK + mark-centered replay as hero workflow.**
- strong haptics / physical instrument feel.
- transparent mechanism/privacy.
- offline if we accept transparent synthesized/banked audio.

### DEMOTED FROM “DIFFERENTIATOR” TO “TABLE STAKES”

- recording alone;
- replay alone;
- no ads;
- no subscription;
- offline;
- EMF/magnetometer;
- flashlight;
- “professional UI.”

### KILLED / DO NOT ADD TO V1

- SLS;
- AI interpretation;
- generated ghost phrases/word answers;
- community;
- haunted locations;
- accounts;
- social feed;
- broad paranormal super-app dashboard;
- creator video platform;
- exact SB7 visual imitation;
- misleading “real AM/FM” claims for an offline implementation.

### MATERIAL UNKNOWN

> **Do target buyers prefer transparent offline synthesized/banked sweep audio, or do they only trust a spirit-box app when it uses live internet-radio fragments?**

This is the cheapest high-leverage question remaining before the audio architecture is finalized.

