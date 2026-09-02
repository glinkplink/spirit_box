# QA and Field-Test Plan

**Product:** Spirit Box — focused iPhone spirit-box instrument  
**Status:** Operational QA source for MVP build and TestFlight  
**Date:** September 2, 2026  
**Canonical authority:** `docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md`

> Supporting documents inform test design but never override canonical scope, pricing, audio architecture, or trust language. When in doubt, test canonical behavior.

**Core workflow under test:** START → LISTEN → MARK → REPLAY

---

## How to use this document

| Audience | Use |
|---|---|
| Engineering agents | Risk-based PR checks (Section 15), traceability (Section 18), release gates (Section 17) |
| Human testers | Sections 4–12, bug template (Section 14), TestFlight plan (Section 16) |
| Product owner | Severity system (Section 13), release gates (Section 17), unresolved decisions |

Passing one test level does **not** imply another passed. A green simulator build does not clear physical-device audio, subjective audio quality, or target-user field testing.

---

# Section 1 — QA Objectives

Highest-level objectives for Spirit Box V1 QA:

| # | Objective | What “good” means |
|---|---|---|
| 1 | **Core workflow correctness** | User can START → LISTEN → MARK → REPLAY without confusion or dead ends |
| 2 | **Audio believability and stability** | Sweep feels like a continuous instrument, not a clip randomizer; no semantic steering |
| 3 | **Session integrity** | Sessions start/stop cleanly; state is recoverable and understandable |
| 4 | **MARK correctness** | Marks save instantly, align with audio, survive restart, and support navigation |
| 5 | **Replay correctness** | Waveform, scrubber, prev/next MARK, and export reflect what was heard |
| 6 | **Recording/export integrity** | No silent loss; failed saves are explicit; exports are faithful |
| 7 | **Entitlement correctness** | Free trial, Tonight Pass, Lifetime, expiry, and restore behave per canonical model |
| 8 | **Offline reliability** | Core instrument and saved sessions work without network |
| 9 | **iOS lifecycle reliability** | Lock, background, interruptions, route changes, and relaunch are safe |
| 10 | **Dark-room / field usability** | One-thumb, low-glance, low-brightness operation in real investigation contexts |
| 11 | **Performance and battery sanity** | Extended sessions remain stable without runaway CPU, memory, heat, or drain |
| 12 | **Trust / transparency** | All claims match implementation; no fake radio, detection, or AI implications |
| 13 | **Crash and data-loss prevention** | No P0/P1 defects in normal workflows |
| 14 | **App Store release readiness** | Metadata, screenshots, permissions, and review notes match shipped behavior |

### Severity priority order

When triaging or scheduling QA, prioritize failures in roughly this order:

1. Crashes  
2. Lost recordings  
3. Corrupted sessions  
4. Broken entitlements  
5. Broken START / LISTEN / MARK / REPLAY  
6. Broken audio (instability, semantic behavior, obvious canned output)  
7. Broken export  
8. Misleading product behavior (false claims, fake radio, detection language)  
9. Major usability failures in field conditions  
10. Cosmetic defects  

---

# Section 2 — Test Levels

| Level | Code | Purpose | Typical tooling | Does **not** substitute for |
|---|---|---|---|---|
| **A. Automated unit tests** | `UNIT` | Deterministic business logic: scheduling constraints, entitlement state transitions, timestamp math, session ordering | XCTest on pure Swift types | Real audio, haptics, StoreKit, UI feel |
| **B. Automated build / integration checks** | `BUILD` | Compile, link, asset bundling, basic smoke launch | CI / `xcodebuild` | Physical audio routes, subjective quality |
| **C. Simulator QA** | `SIM` | UI/state/lifecycle flows that do not require hardware audio fidelity | iOS Simulator | Speaker behavior, haptics, mic capture fidelity, battery |
| **D. Physical-device QA** | `DEVICE` | Speaker, headphones, Bluetooth, haptics, interruptions, mic recording, heat, dark-room handling | Physical iPhone(s) | Target-user credibility judgments at scale |
| **E. Manual audio quality gate** | `AUDIO-GATE` | Subjective 15–20+ minute listening against canonical kill criteria | Audio harness → production app | Functional UI tests alone |
| **F. TestFlight field test** | `FIELD` | Real paranormal users under investigation-like conditions | TestFlight + structured feedback | Developer-only quick checks |

### Independence rule

| If this passed… | You still need… |
|---|---|
| `UNIT` + `BUILD` | `SIM` for UI/lifecycle regressions |
| `SIM` | `DEVICE` for audio routes, haptics, mic, interruptions |
| `DEVICE` functional checks | `AUDIO-GATE` with realistic Phase 1+ corpus |
| Internal `DEVICE` + `AUDIO-GATE` | `FIELD` with target users before trusting conversion/usability |

---

# Section 3 — Device / OS Matrix

Lean matrix for a solo indie developer. Do not expand into enterprise coverage unless a specific defect demands it.

### Physical devices

| Device role | Status | Why |
|---|---|---|
| **Primary development / daily-test iPhone** | **REQUIRED** | Main build target; speaker, haptics, mic, and StoreKit sandbox |
| **Second iPhone — older supported class** | **NICE TO HAVE** | Catches performance, screen-size, and older-chip regressions |
| **Bluetooth headphones / earbuds** | **REQUIRED** (any pair available) | Route-change and field-realistic listening |
| **Wired headphones** | **NICE TO HAVE** | Alternate route; exposes different latency/impedance behavior |

> Do not claim testing occurred on hardware that was not actually used. Record exact model identifiers in bug reports.

### Simulators

| Simulator profile | Status | Why |
|---|---|---|
| **Smallest supported screen class** | **REQUIRED** | Layout stress for one-thumb controls and MARK target |
| **Common modern screen class** | **REQUIRED** | Primary design center |
| **Large-screen class** | **NICE TO HAVE** | Pro Max layout and reachability |

### iOS versions

| OS target | Status | Why |
|---|---|---|
| **Current shipping iOS on primary device** | **REQUIRED** | Daily QA baseline |
| **Oldest supported deployment-target iOS** | **REQUIRED** where practical | Minimum OS compatibility |
| **Latest available iOS point release before launch** | **REQUIRED** | Pre-release regression on newest OS |

---

# Section 4 — Audio Harness / Engine QA

Applies to the private audio harness and, later, the production sweep engine. Canonical architecture: **offline original/licensed short audio + phoneme bank + non-semantic sweep renderer**.

> **DEV FIXTURES CANNOT PASS THE CANONICAL AUDIO GATE.** Placeholder, synthetic, or undersized fixture banks may be used for engineering smoke tests only. Release authorization requires evaluation with a realistic Phase 1 human corpus per `docs/production/AUDIO-CORPUS-ACQUISITION-AND-PRODUCTION-PLAN.md`.

### Functional harness tests

| ID | Case | Steps | Pass criteria |
|---|---|---|---|
| A-01 | START | Start sweep from stopped state | Audio begins; state shows active; no crash |
| A-02 | STOP | Stop active sweep | Audio stops cleanly; no hung engine |
| A-03 | Repeated START/STOP | 20+ cycles | No leak, stuck state, or progressive glitch |
| A-04 | Sweep rate 75 ms | Set 75 ms; listen ≥2 min | Rate change is audible vs other detents |
| A-05 | Sweep rate 125 ms | Set 125 ms; listen ≥2 min | Distinct from 75 / 200 / 300 |
| A-06 | Sweep rate 200 ms | Set 200 ms (default target); listen ≥2 min | Stable default behavior |
| A-07 | Sweep rate 300 ms | Set 300 ms; listen ≥2 min | Slowest detent audibly slower |
| A-08 | FWD | Forward direction ≥2 min | Traversal direction perceptible |
| A-09 | REV | Reverse direction ≥2 min | Audible difference vs FWD |
| A-10 | FWD ↔ REV toggle | Switch during playback | Immediate audible/visual change |
| A-11 | Zero corpus | Engine with empty/missing bank | Safe failure: clear error or silent engine — **no crash**; **PRODUCT DECISION REQUIRED** for exact UX |
| A-12 | One-asset corpus | Minimal bank | Stresses repetition handling; documents scheduler fallback |
| A-13 | Small corpus | Harness-scale bank (e.g. dev subset) | Engineering regression only — **not** audio-gate |
| A-14 | Production-sized corpus | Phase 1 (~120) → production (~480) when available | Required for canonical audio gate |
| A-15 | Procedural noise continuity | Listen 5+ min | Noise bed continuous; no long unintended silence |
| A-16 | Clipping | Normal and high volume | No harsh digital clipping on device speaker |
| A-17 | Gaps / seams | Headphones + speaker | No regular audible dropouts between fragments |
| A-18 | Abrupt transitions | Headphones | Transitions not distractingly clicky unless intentional |
| A-19 | Repeated voices | 15+ min with event log | Same performer not obviously dominant |
| A-20 | Repeated assets | Cross-check event log vs ear | Same `asset_id` not unacceptably frequent |
| A-21 | Scheduler fallback | Force edge selection constraints | Engine continues; no deadlock |
| A-22 | Long uninterrupted playback | 20 min (gate); 60 min (stress later) | Stable; no runaway CPU/memory |
| A-23 | Speaker | iPhone speaker, normal + low volume | Usable in dark room; no exclusive route failure |
| A-24 | Wired headphones | If available | Correct route; acceptable latency |
| A-25 | Bluetooth headphones | BT route | Connect/disconnect handled safely |
| A-26 | Volume changes | System volume during sweep | No crash; level responds |
| A-27 | Route change during playback | Speaker → BT → speaker | Playback recovers or stops safely — verify actual spec |
| A-28 | Output capture | Record harness output if supported | Capture matches heard mix |
| A-29 | Debug logs | Enable internal event log | asset ID, voice family, rate, direction, repeat distance present |

### Canonical audio kill gate (Phase 1+ human corpus)

Run **15–20 minutes** continuous listening per session on **device speaker** (primary) and **headphones** (secondary). Use multiple deterministic seeds when available.

**Reject / block release if listeners report:**

- obvious recognizable repetition of the same distinctive clip  
- sentence-like assembly or stable multiword phrases  
- strong “clip randomizer” impression rather than continuous instrument  
- response-like timing after spoken questions  
- recognizable repeated performers dominating the session  
- unnatural loops, excessive silence, obvious sample edges, or overly synthetic cadence  

**Neutral listener prompts (do not lead):**

- “What, if anything, made the audio feel artificial?”  
- “Did you notice repeated sounds or voices? If yes, describe when.”  
- “Did anything seem timed as a response to what you said?”  

Correlate subjective marks with event-log asset IDs. A single ambiguous pareidolia word is not automatic failure; **stable** repeats and multi-listener agreement are.

---

# Section 5 — Core Workflow QA

Implementation-neutral cases for **START → LISTEN → MARK → REPLAY**.

### Normal flow

| ID | Case | Steps | Pass criteria |
|---|---|---|---|
| W-01 | First session | Fresh install → start sweep | Audio plays; user understands active state without tutorial |
| W-02 | Listen continuously | Run sweep 3+ min | Stable playback; timer advances |
| W-03 | One MARK | Tap MARK once during session | Timestamp saved; count updates; no modal |
| W-04 | Many MARKs | Place 5–15 marks over session | All retained; navigable in replay |
| W-05 | Rapid MARK presses | 10 taps in 5 seconds | No crash; marks deduped or all stored per spec — verify implementation |
| W-06 | MARK immediately after START | MARK within 2 s of start | Valid timestamp near session start |
| W-07 | MARK immediately before STOP | MARK then stop within 2 s | Mark retained in finalized session |
| W-08 | Stop session | Stop via canonical stop/power control | Session ends cleanly; recording finalizes if active |
| W-09 | Open replay | From session history | Replay loads correct session |
| W-10 | Previous MARK | From replay, jump to prior mark | Lands on correct moment audibly and visually |
| W-11 | Next MARK | Jump forward | Correct mark selected |
| W-12 | Scrub around marks | Drag scrubber near marks | Waveform ticks align with heard audio |
| W-13 | Zero MARKs | Complete session without marks | Replay still works; prev/next disabled or graceful |
| W-14 | Many MARKs | Session with 20+ marks | Navigation remains usable |
| W-15 | Very short session | <30 s | Session saved if recorded; no corrupt metadata |
| W-16 | Long session | At least free-trial length (3 min) and longer paid session | Stable end-to-end |
| W-17 | Repeated session creation | Create 10 sessions sequentially | No orphan files; history ordering correct |

### Failure / edge flow

| ID | Case | Pass criteria |
|---|---|---|
| W-18 | Start while storage full | Clear user message; no false success |
| W-19 | MARK without recording | MARK behavior defined — timestamp associated with live session or rejected clearly (**verify implementation**) |
| W-20 | Navigate away mid-session | **PRODUCT DECISION REQUIRED** — session continues, pauses, or warns |
| W-21 | Denied microphone + REC | REC blocked with explanation; sweep still works |
| W-22 | Paywall after free session | Second full session blocked; first session still replayable |

---

# Section 6 — Recording + Session Integrity

**Absolute priority: NO SILENT LOSS OF A USER RECORDING.**

If recording cannot begin or storage fails, the user must be clearly told. No false success state.

| ID | Case | Pass criteria |
|---|---|---|
| R-01 | Recording begins | Tap REC → grant mic if needed → recording active indicator | Clear REC state; capture starts |
| R-02 | Recording ends | Stop REC or end session | File finalized; duration sane |
| R-03 | Session file exists | After stop, inspect storage (dev) / replay entry | File present and playable |
| R-04 | Metadata persists | Date, duration, mark count | Survives app restart |
| R-05 | MARK timestamp alignment | MARK during known spoken cue | Replay lands within acceptable tolerance — compare A/V |
| R-06 | Replay after restart | Kill app; relaunch; open replay | Same session playable |
| R-07 | Multiple sessions | Create ≥3 sessions | All listed; correct ordering (newest first unless spec differs) |
| R-08 | Session ordering | Create sessions across days | Chronological integrity |
| R-09 | Deletion (if implemented) | Delete with confirmation | Removed from list; file removed; undo N/A unless specified |
| R-10 | Export / share | Export from replay | Shared file plays externally; matches session |
| R-11 | Failed export | Simulate share cancel / disk issue | User informed; original session intact |
| R-12 | Low disk space | Near-full storage | Start/record blocked or fails loudly |
| R-13 | Interruption during recording | Phone call / alarm | Recording finalizes or pauses safely — **verify spec** |
| R-14 | App backgrounding | Home button / swipe up during REC | No silent truncation |
| R-15 | App termination | Force quit during REC | **PRODUCT DECISION REQUIRED** — recovery vs partial file; user must not think save succeeded if it did not |
| R-16 | Crash recovery | Simulate crash during save | No corrupt index; user messaging on next launch |
| R-17 | Missing file | Delete file on disk (dev) | App shows error state, not empty success |
| R-18 | Corrupted file | Truncate file (dev) | Graceful error; no crash loop |

### Power-off with active recording

Per canonical: power-off should finalize and save recording. Verify hold-to-stop prevents accidental loss.

---

# Section 7 — iOS Lifecycle / Interruption QA

For each scenario: perform action during active sweep and/or active recording. Document **expected safe behavior**; do not assume background audio unless implementation explicitly provides it.

| Scenario | Sweep expected | Recording expected | Notes |
|---|---|---|---|
| Lock screen | **PRODUCT DECISION REQUIRED** | Should not lose data | Verify mic/sweep policy |
| App background | **PRODUCT DECISION REQUIRED** | Finalize or continue per spec | Distinguish sweep vs REC |
| Return foreground | State recoverable | REC indicator accurate | |
| Phone call | Interrupt audio | Recording handles per iOS rules | No crash |
| Siri interruption | Audio ducks/pauses | No corruption | |
| Alarm / timer | Audio interrupted | Session recoverable | |
| Another app takes audio focus | Music/podcast handoff | Resume or stop clearly | |
| Headphone disconnect | Pause or route to speaker safely | No crash | |
| Bluetooth route change | Rebind or stop | User-visible state | |
| Control Center volume | Volume applies | No engine crash | |
| Mic permission denied | N/A for sweep | REC blocked with copy | Sweep works |
| Low Power Mode | Extended run stable | No abnormal kill | Compare battery vs normal |
| Incoming notification | No spurious UI block | MARK still reachable | |
| Orientation change | Portrait canonical | No broken layout if rotation allowed | **PRODUCT DECISION REQUIRED** if landscape supported |
| Memory pressure / relaunch | No data loss | Sessions list intact | |

---

# Section 8 — Entitlement / Paywall QA

Document future verification for locked commercial model. Do **not** treat undocumented StoreKit edge cases as settled — mark for implementation verification.

**Canonical model:** free download → one complete **3-minute** real session → paywall → **$1.99 Tonight Pass (24 h, non-renewing)** or **$9.99 Lifetime (one-time)** → existing recordings remain accessible after expiry.

### Free user

| ID | Case | Pass criteria |
|---|---|---|
| E-01 | First 3-minute session | Full sweep, rate, direction, REC, MARK, replay work |
| E-02 | No premature paywall | Paywall only after real trial use, not at launch |
| E-03 | Trial not reusable forever | Second full session requires purchase |
| E-04 | Trial crash fairness | **PRODUCT DECISION REQUIRED** — if distinguishable, aborted trial should not permanently consume trial |

### Tonight Pass ($1.99)

| ID | Case | Pass criteria |
|---|---|---|
| E-10 | Purchase completes | Full access unlocks |
| E-11 | 24-hour duration | Access expires ~24 h after purchase; labeled non-renewing |
| E-12 | No auto-renew | No subscription UI or renewal charge |
| E-13 | Expiration behavior | New sessions locked; replay/export of old sessions works |
| E-14 | Device / app restart | Entitlement persists until expiry |
| E-15 | Restore / reconciliation | StoreKit restore succeeds — verify offline cache policy at implementation |
| E-16 | Clock / timezone edges | Expiry uses consistent logic — verify with sandbox time skew |
| E-17 | No accidental permanent unlock | Expired Tonight Pass does not grant Lifetime |

### Lifetime ($9.99)

| ID | Case | Pass criteria |
|---|---|---|
| E-20 | Purchase completes | Permanent unlock |
| E-21 | Restore works | Reinstall → restore → access |
| E-22 | Survives reinstall | Per StoreKit expected behavior |

### After expiry

| ID | Case | Pass criteria |
|---|---|---|
| E-30 | Existing recordings accessible | Replay + export work |
| E-31 | New session gating | Starting new full session shows paywall |
| E-32 | No hostage content | User can review/export prior work |

### Purchase edge cases

| ID | Case | Pass criteria |
|---|---|---|
| E-40 | Canceled purchase | No unlock; clear state |
| E-41 | Purchase failure | Error shown; no unlock |
| E-42 | Pending transaction | UI reflects pending; completes when resolved |
| E-43 | Network unavailable | Graceful messaging; cached entitlement honored if already entitled |
| E-44 | StoreKit unavailable | Cannot purchase; core replay still works for owned sessions |
| E-45 | Duplicate purchase taps | Single charge / idempotent unlock |
| E-46 | Interrupted purchase | State reconciles on relaunch |
| E-47 | Already-owned Lifetime | Cannot double-buy; access remains |
| E-48 | Lifetime while Tonight Pass active | Lifetime supersedes; no conflicting states |

---

# Section 9 — Offline QA

Distinguish **core instrument** (must work offline) from **commerce** (may need network for purchase/restore).

| ID | Case | Pass criteria |
|---|---|---|
| O-01 | Airplane mode before launch | App opens; sweep works if entitled; replay works |
| O-02 | Airplane mode during use | Active session continues safely |
| O-03 | Wi-Fi disabled | Same as O-01/O-02 |
| O-04 | Cellular disabled | Same |
| O-05 | Purchase cached, then offline | Entitled features work without network |
| O-06 | App relaunch offline | Sessions and marks persist |
| O-07 | Replay offline | Playback and export work |
| O-08 | Session creation offline | Allowed when entitled |
| O-09 | New purchase offline | Clear failure; no false unlock |

---

# Section 10 — Field Usability QA

Test under conditions target users care about. Prefer real dim environments over office lighting.

### Dark room

| Check | Pass criteria |
|---|---|
| Controls readable at low brightness | No full-screen white flash |
| MARK easy to find | Largest thumb target; fixed position |
| No tiny precision targets | Core actions ≥ comfortable tap size |
| State visible at a glance | REC, sweep active, mark count |

### One-handed use

Verify without second hand: START/STOP (power), MARK, REC, sweep rate, direction.

### Low attention

| Check | Pass criteria |
|---|---|
| Minimal continuous staring | State changes obvious |
| Accidental destructive actions | Power-off requires hold; delete confirms |

### Field conditions

Walking slowly, sitting, phone in one hand, speaker and headphones, low brightness, system dark mode, sessions ≥15 min.

### Haptics (once implemented)

| Check | Pass criteria |
|---|---|
| Useful confirmation | Power, rate, direction, REC, MARK distinct |
| Not excessive | Tolerable over 15+ min |
| Not paranormal “detection” | No random entity vibrations |
| Recording contamination | If MARK haptic audible in recording, disable during REC per canonical |

---

# Section 11 — Trust / Claims QA

Perform a **trust review before every release** covering onboarding, paywall, App Store screenshots, description, in-app labels, and settings/help.

### Must never imply

- proof of ghosts or verified paranormal detection  
- real RF scanning, AM/FM tuning, or frequency numbers (unless engine literally does — it does not in V1)  
- generated spirit responses or AI interpretation  
- scientific validation not supported  
- EMF functionality (absent in V1)  
- speech recognition or question-driven audio selection  

### Must remain accurate

- offline sweep through on-device vocal fragments and noise textures  
- microphone only when user starts REC  
- MARK = user timestamp, not “evidence” or “answer”  
- experimental / entertainment disclaimer present  
- privacy claims match actual SDK and network behavior  

### Red-flag strings to grep before release

`AM`, `FM`, `MHz`, `kHz`, `frequency`, `tuner`, `RF`, `ghost detected`, `entity detected`, `spirit response`, `evidence`, `proof`, `AI`, `subscription`, `7-day`, `EMF`

---

# Section 12 — Performance / Stability QA

Use **comparison and regression detection** unless numeric budgets are later justified by profiling.

| Check | Method | Watch for |
|---|---|---|
| 20-minute audio run | DEVICE | Glitches, memory growth, heat |
| 60-minute stress (pre-launch) | DEVICE | Same; schedule before store submit |
| Repeated session creation | 20+ sessions | Storage growth, list slowdown |
| Memory growth | Instruments / Activity Monitor | Unbounded climb during sweep |
| CPU sanity | Instruments | Sustained pegging |
| Battery drain | 20-min session vs idle baseline | Abnormal drain |
| Device heat | Hand feel + thermal state | Uncomfortable warmth |
| Audio glitches | Ear + log | Dropouts, underruns |
| UI responsiveness during REC | Tap MARK/controls under load | Lag > ~1 s |
| Storage growth | Per-session file size reasonable | Runaway WAV size |

---

# Section 13 — Bug Severity System

| Severity | Name | Examples | Release policy |
|---|---|---|---|
| **P0** | Release blocker | Crash on normal workflow; data loss; corrupted recording; purchase broken for many users; app unusable | Blocks release |
| **P1** | High | Core workflow broken; MARK/replay unreliable; severe audio failure; common entitlement failure; export consistently broken | Blocks release unless explicit documented waiver |
| **P2** | Medium | Significant UX problem; intermittent non-core failure; device-specific with workaround | Ship with tracking; fix if time allows |
| **P3** | Low | Cosmetic; minor layout; low-impact polish | Backlog |

**Rule:** Unresolved **P0** and **P1** block release unless the product owner documents an explicit waiver with rationale and user impact.

---

# Section 14 — Bug Report Template

```markdown
## Title
[Short description]

## Severity
P0 | P1 | P2 | P3

## Build
[Build number / commit / TestFlight version]

## Device
[iPhone model]

## iOS version
[e.g. 18.6]

## Entitlement state
Free trial | Tonight Pass (active/expired) | Lifetime | Unknown

## Audio route
Speaker | Wired | Bluetooth | Muted

## Network state
Online | Offline | Airplane mode

## Steps to reproduce
1.
2.
3.

## Expected
[What should happen per canonical behavior]

## Actual
[What happened]

## Frequency
Always | Often | Sometimes | Once

## Session / recording affected?
Yes — [session date/id] | No

## Logs / screenshots / video
[Attach or path]

## Reproducible after relaunch?
Yes | No | Unknown

## Notes
[Anything else]

### Audio-specific (if applicable)
- Sweep rate: 75 | 125 | 200 | 300 ms
- Direction: FWD | REV
- Output: Speaker | Wired | Bluetooth
- Approximate timestamp in session:
- Asset / event-log IDs (if available):
```

---

# Section 15 — PR Acceptance Checklist

Risk-based — not every PR needs full regression.

```markdown
## Spirit Box PR checklist

- [ ] **Canonical requirement:** Which section of `docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md` does this implement?
- [ ] **Out of scope:** What is explicitly NOT included?
- [ ] **Automated tests:** What UNIT tests were added or run?
- [ ] **Build:** Did CI / local build pass?
- [ ] **Simulator QA:** What SIM cases were run?
- [ ] **Physical device required?** Yes / No
- [ ] **Physical device QA performed?** Yes / No / N/A — list device + iOS
- [ ] **Recordings affected?** Yes / No — if yes, list R-xx cases run
- [ ] **Entitlement affected?** Yes / No — if yes, list E-xx cases run
- [ ] **Audio affected?** Yes / No — if yes, list A-xx cases run
- [ ] **Data loss risk?** Yes / No — if yes, describe mitigation
- [ ] **New permissions?** Yes / No
- [ ] **User-visible claims changed?** Yes / No — if yes, trust review (Section 11)
- [ ] **Remains unverified:** What still needs DEVICE / AUDIO-GATE / FIELD testing?
```

---

# Section 16 — TestFlight Field-Test Plan

Target: **20–50** testers for first structured field cycle, aligned with `docs/launch/GHOST-SPIRIT-BOX-FIRST-USERS-ACQUISITION-PLAN.md`.

### Cohort split

| Track | Count (guide) | Purpose |
|---|---|---|
| **Internal / technical** | 3–5 | Crashes, device matrix, interruptions, export, entitlement sandbox |
| **Target-user field** | 15–45 | Credibility, audio believability, MARK/replay value, dark-room use |

### Internal / technical test (abbreviated)

- Execute Sections 4–9 on primary DEVICE  
- File bugs using Section 14  
- Confirm no P0/P1 open before widening field test  

### Target-user field test

**Framing (to testers):** “Compare this iPhone instrument to how you actually investigate. Tell us what feels fake, confusing, or unreliable — not whether ghosts responded.”

**Structured feedback — use neutral questions:**

| Topic | Questions |
|---|---|
| Immediate understanding | “What did you think this app was for in the first 30 seconds?” “What confused you?” |
| Instrument feel | “Did the controls feel like field equipment or a generic phone app? Why?” |
| Audio believability | “What, if anything, made the audio feel artificial?” |
| Repetition | “Did you notice repeated sounds or voices? If yes, describe when.” |
| Clip vs instrument | “Did it sound more like one continuous sweep or like separate clips being played?” |
| MARK | “Did you use MARK? Was it easy to press without looking? Did replay help?” |
| Replay | “Could you get back to a moment you cared about? What got in the way?” |
| Dark room | “Could you use it in low light with one hand?” |
| Controls | “Which controls were hard to find or understand?” |
| Reliability | “Any crashes, recording failures, or lost sessions?” |
| Return intent | “Would you use this again on an investigation? Why or why not?” |
| Willingness to pay | “After your free session, would you consider paying? What price felt fair?” (directional only — free TestFlight does not validate real conversion) |

**Avoid leading questions** such as “Does this feel realistic?” or “Did spirits respond?”

### Tester report minimum metadata

- Build number  
- Device model + iOS version  
- Approximate session time and date  
- Speaker / wired / Bluetooth  
- Marker or session reference if issue filed  
- Optional: owns physical spirit box (yes/no)  

### Exit criteria for field-test gate

- Representative sessions completed across ≥3 user types (hobbyist, skeptical investigator, casual)  
- No structural audio/usability failure (persistent clip-randomizer feel, unusable MARK/replay, dark-room failure)  
- No open unwaived P0/P1 from field testers  

---

# Section 17 — Release Gates

All gates must pass before App Store submission unless explicitly waived by product owner.

| Gate | Criteria | Primary sections |
|---|---|---|
| **AUDIO GATE** | Realistic Phase 1+ corpus survives canonical 15–20 min evaluation; dev fixtures do not qualify | 4 |
| **CORE FUNCTIONAL GATE** | START → LISTEN → MARK → REPLAY reliable on DEVICE | 5, 6 |
| **DATA INTEGRITY GATE** | No known recording/session-loss P0/P1 | 6, 13 |
| **COMMERCE GATE** | Trial, Tonight Pass, Lifetime, expiry, restore verified in sandbox | 8 |
| **OFFLINE GATE** | Core instrument + replay offline when entitled | 9 |
| **DEVICE GATE** | Required physical-device checks completed | 3, 7 |
| **FIELD-TEST GATE** | Target users completed representative sessions; no structural usability/audio failure | 16 |
| **RELEASE-BLOCKER GATE** | No unresolved P0/P1 without documented waiver | 13 |
| **TRUST GATE** | Section 11 review passed for app + store metadata | 11 |

---

# Section 18 — Traceability Matrix

Status values: `NOT IMPLEMENTED` | `READY TO TEST` | `NOT YET RUN` | `PASS` | `FAIL` | `BLOCKED`

Do not mark future functionality as `PASS`.

| Requirement | Canonical source | Test level | Primary test cases | Release gate | Status |
|---|---|---|---|---|---|
| Offline non-semantic sweep engine | §6, §18 | AUDIO-GATE, DEVICE | A-01–A-29, audio kill gate | AUDIO GATE | NOT YET RUN — WAITING FOR PHASE 1 CORPUS |
| Sweep rates 75/125/200/300 ms | §6.3 | DEVICE, AUDIO-GATE | A-04–A-07 | AUDIO GATE | NOT IMPLEMENTED |
| Forward / reverse | §6, §9.3 | DEVICE | A-08–A-10, W-02 | CORE FUNCTIONAL | NOT IMPLEMENTED |
| Power start/stop + hold-to-off | §9.2 | DEVICE, SIM | W-01, W-08, field usability | CORE FUNCTIONAL | NOT IMPLEMENTED |
| Local recording (optional) | §12.1 | DEVICE | R-01–R-18 | DATA INTEGRITY | NOT IMPLEMENTED |
| MARK timestamps | §12.2 | DEVICE | W-03–W-07, R-05 | CORE FUNCTIONAL | NOT IMPLEMENTED |
| Session history + replay | §12.4–12.5 | DEVICE, SIM | W-09–W-12, R-06 | CORE FUNCTIONAL | NOT IMPLEMENTED |
| Prev/next MARK + export | §12.5 | DEVICE | W-10–W-11, R-10 | CORE FUNCTIONAL | NOT IMPLEMENTED |
| Recordings after entitlement expiry | §12.6, §15 | DEVICE | E-30–E-32, O-07 | COMMERCE, OFFLINE | NOT IMPLEMENTED |
| One free 3-minute session | §15.2 | DEVICE | E-01–E-04 | COMMERCE | NOT IMPLEMENTED |
| Tonight Pass $1.99 / 24 h | §15.3 | DEVICE | E-10–E-17 | COMMERCE | NOT IMPLEMENTED |
| Lifetime $9.99 one-time | §15.4 | DEVICE | E-20–E-22 | COMMERCE | NOT IMPLEMENTED |
| No subscription / no 7-day tier | §15.5, §23 | BUILD, review | Trust grep, E-12 | TRUST, COMMERCE | NOT IMPLEMENTED |
| Restore purchases | §15.7 | DEVICE | E-15, E-21 | COMMERCE | NOT IMPLEMENTED |
| How Sweep Works + disclaimers | §13 | SIM, FIELD | Section 11 | TRUST | NOT IMPLEMENTED |
| Mic permission only on REC | §12.1, §20 | DEVICE, SIM | W-21, R-01 | TRUST | NOT IMPLEMENTED |
| No fake AM/FM / frequency UI | §7, §23 | SIM, review | Section 11 | TRUST | NOT IMPLEMENTED |
| Core haptics (not detection) | §11 | DEVICE | Field haptics | DEVICE GATE | NOT IMPLEMENTED |
| Interruption safety | §25, Phase 4 | DEVICE | Section 7 | DATA INTEGRITY | NOT IMPLEMENTED |
| Offline core instrument | §20 | DEVICE | O-01–O-08 | OFFLINE | NOT IMPLEMENTED |
| Anti-repetition scheduler | §6.2 | AUDIO-GATE | A-19–A-21, kill gate | AUDIO GATE | NOT YET RUN — WAITING FOR PHASE 1 CORPUS |
| Source rights ledger complete | §6.1, §20 | Review | Production doc §14 | AUDIO GATE | NOT IMPLEMENTED |
| App Store metadata accuracy | §16 | Review | Section 11 | TRUST | NOT IMPLEMENTED |

---

## Unresolved product decisions (for implementation)

Mark these during QA rather than inventing behavior:

1. **Background audio / background sweep** — canonical does not require continuous background playback.  
2. **Behavior when app backgrounds mid-session** — pause vs continue.  
3. **Crash during recording recovery** — partial file vs discard messaging.  
4. **Empty corpus UX** — error vs silent engine.  
5. **MARK without active recording** — whether marks attach to listen-only sessions.  
6. **Free-trial consumption on crash** — fairness rules.  
7. **Offline StoreKit reconciliation** — exact cached entitlement rules.  
8. **Landscape support** — canonical UI is portrait; rotation policy TBD.  

---

## Supporting doc alignment notes

| Topic | Note |
|---|---|
| UI research (`GHOST-HUNTER-UI-AUDIENCE-DEEP-DIVE.md`) | Mentions AM/FM *if truthful* and magnetometer/EMF as research context. **Canonical V1 excludes fake frequencies and magnetometer.** QA follows canonical. |
| ASO playbook | Title/subtitle variants are marketing input; QA verifies **shipped** metadata matches actual engine. |
| Acquisition plan | Field-test cohort sizing and neutral question framing incorporated in Section 16. |
| Corpus plan | Audio gate timings, listener panel, and kill criteria aligned with Section 4. |

---

## Document history

| Date | Change |
|---|---|
| 2026-09-02 | Initial operational QA and field-test plan |
