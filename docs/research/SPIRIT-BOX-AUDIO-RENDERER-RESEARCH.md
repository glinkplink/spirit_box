SPIRIT BOX AUDIO RESEARCH — UPDATED SOURCE OF TRUTH

Date: 2026-09-10
Purpose: Give audio-evaluation models and implementation agents a current, evidence-separated view of what we know about convincing spirit-box audio and what should be tested next.

1. Current conclusion

The old isolated-phoneme prototype taught us something useful, but its central corpus recommendation is now outdated.

We are no longer relying on sustained vowels/consonants as the main source. The current renderer uses a 1,200-asset VCTK-derived corpus cut from natural human speech, which already gives us coarticulation, consonant attacks, formant movement, pitch motion, and natural speech transitions.

That means the highest-value question is no longer:

Do we need richer source material?

It is now:

Is the current renderer using good source material in the wrong way?

The main renderer risks are currently too much vocal activity, too-frequent speaker changes, overly rigid one-fragment-per-sweep-step behavior, static balance, and Reverse behavior that may sound like a reverse scan. Current live/offline defaults are the experimental `listening-test` preset in `SweepRendererSettings` (7% configured probability, 100–180 ms exposure bounds, rate-limited by dwell). Those values are a candidate, not a proven improvement and not P-SB7 calibration.

Forensic measurements for Run3 / Run4 / Run5, reference files, and the candidate preset live in [`SPIRIT-BOX-AUDIO-RUN-COMPARISON.md`](./SPIRIT-BOX-AUDIO-RUN-COMPARISON.md). That ledger labels recomputed vs reported-unverified vs unknown provenance. Do not treat Run5 as proof of the current default settings: its bundle does not record build or effective renderer settings.

We should test those before replacing the corpus.

## Run 3 live 2-minute smoke (2026-09-10)

Live engine capture `20260909-234802-86b84c46` on the PR #28 clocked DSP and bundled 1,200-asset VCTK bank. 120 s requested and captured. Mixed-rate live smoke, not a Section 18 endurance pass.

Verified on this capture:

- limiter sample peak exactly −2.50 dBFS; true peak −2.35 dBTP
- 209 vocal events, 209 unique assets, 0 repeats, 0 constraint relaxations
- vocal density 25.7%; vocal runs capped at 2 slots; max consecutive same performer 1
- vocal density is already intermittent; do not treat older “voice on every slot” notes as current

Rejected as shipping changes from that review:

1. **Per-rate output-gain trims.** Mixed-rate short-segment LUFS is not a calibration source. PR #28 equal-length 60 s renders at 300 ms and 200 ms differed by 0.14 LUFS. Sweep rate must remain a cadence control (Source of Truth §6.2). Revisit only with equal-length single-rate 75 / 125 / 200 / 300 captures.
2. **Relaxing speaker cooldown on clustered vocal slots.** Canonical §6.2 requires avoiding adjacent clips from the same voice/register family. Research §5.B remains an explicit A/B experiment, not a silent production default.

Next required gate: 15–20 minutes on physical iOS hardware with unprimed listeners (Source of Truth §18). Prefer mostly Forward at 200/300 ms; long uninterrupted Reverse is a separate reverse-semantics test, not the default endurance protocol.

## Run 4 reported device notes (2026-09-10)

**Evidence:** SUBJECTIVE / REPORTED_NOT_REPRODUCED. The Run6 ledger did not re-listen; physical-device review is not evidenced on this branch. Treat the following as reported notes attached to TestFlight Build 4 (`4eb5a164`), not as a verified listening verdict.

A reported TestFlight Build 4 (`4eb5a164`) review described the PR #28 DSP changes as introducing two acoustic defects:
1. Static noise bed was pulsing / gating due to a 10 ms ducking envelope on every slot (`ProceduralNoiseState.slotEnvelope` dropping to 0.06).
2. Voice snippets were firing too frequently (33% probability vs reference ~5.8%) and were over-clipped to 50–75 ms, creating unnatural transient clicks/pops.

Remediations applied on branch `fix/continuous-static-natural-speech`:
- Removed per-slot noise bed ducking; static noise bed is now 100% continuous without periodic modulation.
- Calibrated vocal probability to ~8% (from 33%), matching the measured reference audio baseline.
- Extended vocal exposure to 80–220 ms (50–80% of dwell) with smooth raised-cosine windowing, allowing natural human speech transitions to be heard without clicks.
- Forward speech orientation during reverse sweep (reverse corpus sequence traversal without waveform reversal).


1. What competitor research actually supports

VERIFIED FACT

GhostTube VOX

GhostTube says VOX uses real online digital-radio broadcasts as source audio and provides controls/effects including white noise, echo, reverb, and speed/pitch distortion.

Why this matters:

its raw source already contains natural continuous human speech;

even short exposures inherit real coarticulation and prosody;

it has an easier path to “radio caught mid-speech” than an isolated-phoneme bank.

Source:

[https://ghosttube.com/blogs/ghosttube/ghosttube-vox](https://ghosttube.com/blogs/ghosttube/ghosttube-vox)

[https://apps.apple.com/us/app/ghosttube-vox/id1574490738](https://apps.apple.com/us/app/ghosttube-vox/id1574490738)

Necrophonic

The developer describes:

multiple sound banks;

phonemes;

partial words;

reversed material;

foreign-language speech;

separately mastered banks emphasizing different frequency regions;

randomized reverse playback.

Why this matters:

the source pool is heterogeneous;

speech-like transitions are preserved;

spectral variation and reversal are deliberate variety tools.

Source:

[https://apps.apple.com/us/app/necrophonic/id1396698319](https://apps.apple.com/us/app/necrophonic/id1396698319)

HOPE Spirit Box

The developer describes its banks as chopped, reversed and slowed human speech, deliberately made wordless. Current Android materials advertise up to 33 banks representing different human-speech sounds.

Its interaction also allows longer audible bursts than a strict micro-fragment-only design.

Why this matters:

it preserves more natural voice structure than isolated vowels;

it demonstrates that “wordless” does not require “speechless”;

clarity can coexist with less constant static.

Sources:

[https://hopeparanormal.com/app/](https://hopeparanormal.com/app/)

[https://hopeparanormal.com/spirit-box/faulty-spirit-communication-apps-that-give-false-positives/](https://hopeparanormal.com/spirit-box/faulty-spirit-communication-apps-that-give-false-positives/)

[https://play.google.com/store/apps/details?id=com.hopeparanormal.hsb1](https://play.google.com/store/apps/details?id=com.hopeparanormal.hsb1)

EchoVox

EchoVox uses multiple banks/channels with independent speed controls, randomization, blending/shuffling, and phonetic material.

Why this matters:

speed variation and combinatorial source variation are established techniques;

it does not prove we should use overlapping voices, only that source timing/speed variation can matter.

Source:

[https://play.google.com/store/apps/details?id=com.bigbeard.echovox](https://play.google.com/store/apps/details?id=com.bigbeard.echovox)

Spiritus Ghost Box

Its changelog explicitly says the developer:

doubled bank size;

added hundreds of sounds;

changed the rate of audio occurrences;

fine-tuned playback speed;

did so in response to repetition/audio-quality concerns.

Why this matters:
This is unusually direct evidence that source diversity + event timing + playback speed materially affected perceived quality.

Source:

[https://apps.apple.com/us/app/spiritus-ghost-box/id1119043157](https://apps.apple.com/us/app/spiritus-ghost-box/id1119043157)

1. Strong inference from the evidence

Natural speech trajectories matter more than isolated steady-state phonemes

Sustained /a/, /m/, /s/, /sh/, etc. contain much less of what listeners recognize as human speech than moving transitions between phonemes.

A convincing brief “speech catch” benefits from:

consonant-vowel motion;

releases and attacks;

changing formants;

short pitch contours;

micro-prosody;

breath and onset/offset dynamics;

partial syllable boundaries.

This is why the old isolated-phoneme prototype tended to sound like:

tone → hiss → tone → breath

rather than:

a radio briefly crossing somebody speaking.

This conclusion remains useful.

What changed is that VCTK already gives us this richer structure, so we should not replace it merely because the old phoneme prototype failed.

1. What is now superseded

The following older recommendation is no longer current:

Record or generate several minutes of fluent nonsense speech and replace isolated phonemes with arbitrary 150–700 ms windows.

That was a sensible bridge away from the original isolated-phoneme bank.

But we now have a legally usable natural-speech corpus with human coarticulation already present.

Updated rule

Do not replace VCTK unless listening shows one of these is actually true:

the VCTK windows are intrinsically too recognizable;

sentence cadence leaks through despite scheduling protections;

voices are too clean/modern to process into a convincing sweep;

the corpus cannot sustain 15–20 minutes without obvious recognizable repetition;

renderer changes fail to fix the main perceptual problems.

Until then, corpus replacement is premature.

1. Current renderer findings that matter most

These are implementation facts from the current sweep renderer, not competitor research.

A. Vocal occupancy is intermittent, not every slot

**Superseded:** the engine no longer schedules a vocal on every sweep slot. `VocalDensityScheduler` plus `SweepRendererSettings.listeningTest` currently target **7%** configured vocal-event probability with a hard max run of 2 slots. That is a scheduler target, not measured density, and not “~1 in 14” marketing copy.

Run 3 measured 25.7% vocal / 74.3% noise-only on a mixed-rate live capture whose bundle does **not** record the applied probability. Run 5 measured 33.3% at 300 ms FWD with ~66–75 ms exposures; build/settings provenance is **UNKNOWN** (see the run-comparison ledger). Do not treat older “voice on every slot” notes as current, and do not treat Run 5 as the current 7% preset.

Remaining occupancy question: which experimental probability survives unprimed listening, not whether noise-only slots exist.

B. The source speaker can change every slot

The scheduler has strong anti-repeat protections, including speaker cooldowns. Those protections are useful for avoiding obvious repetition, but they can also create a perceptual side effect:

voice A → voice B → voice C → voice D

every few hundred milliseconds.

That may sound less like scanning across speech and more like a randomized voice collage.

We need to test whether some vocal bursts should keep one underlying speaker/source family alive across multiple sweep steps.

This is a perceptual question, not something we should assume. Run 3 confirmed every 2-slot vocal cluster switched performers. That is current canonical behavior (Source of Truth §6.2), not a defect. TEST 2 still requires an explicit product-owner override of §6.2 before it can ship.

C. Sweep rate currently also defines the fragment exposure window

A 300 ms sweep step can yield roughly a 300 ms vocal window; a 75 ms step yields a much shorter one.

That is simple and technically coherent, but it may be too rigid.

The sweep movement and vocal-event lifetime do not necessarily need to be the same concept.

A useful experiment is:

keep the sweep stepping at the selected rate, but allow vocal events to span fewer or multiple steps.

Examples worth testing:

short catch: 80–200 ms;

normal catch: 200–450 ms;

rare connected burst: 500–900 ms.

These are test ranges, not validated production values.

D. Reverse currently affects traversal; waveform orientation is a separate choice

The scheduler reverses source traversal when direction changes.

Current production/harness behavior plays forward-orientation speech snippets while walking the corpus in reverse. Literal PCM reversal remains available in the buffer factory for tests, but it is not the live reverse-scan default.

Those are two different behaviors. Keep the current forward-PCM reverse traversal unless a verified bug requires a narrow repair.

Required A/B test (still open as a perceptual question, not a claim that the current default is proven):

Compare:

A — reverse traversal only

versus

B — reverse traversal + literal waveform reversal

Keep whichever sounds more like a convincing reverse sweep in the reference audio.

Do not keep literal waveform reversal merely because it creates variety.

E. Current processing is deliberately restrained

Current tuning includes:

continuous procedural noise;

high-pass around 280 Hz;

low-pass around 4.2 kHz;

short fades;

bounded gain variation;

peak limiting;

one dominant vocal stream.

This is a good baseline.

The current problem should not automatically be blamed on “not enough effects.”

1. What should be tested next

TEST 1 — Vocal density

Create otherwise identical renders with different probabilities of a foreground vocal event.

Suggested starting A/B/C:

A: current shared preset (~7% configured probability);

B: archived PR #31 (~8% configured probability);

C: a sparser or denser experimental arm only if A/B is inconclusive.

Do not treat short-clip density as a universal band. 60-second files vary; use a long deterministic scheduler test for occupancy contracts.

Noise/sweep should continue through silent-vocal slots.

What to listen for

Does the output stop sounding like nonstop chopped voices?

Do vocal catches feel more salient?

Does static become boring when speech is too sparse?

Which density resembles the reference audio most closely?

TEST 2 — Speaker/source continuity

Compare:

A: current speaker changes;

B: allow occasional 2-step continuity;

C: allow rare 2–4-step vocal bursts from the same underlying source family.

Do not allow adjacent windows that reconstruct the original sentence.

What to listen for

more believable human catches;

less “voice roulette”;

whether longer continuity exposes sentence structure;

whether it becomes too intelligible.

TEST 3 — Reverse semantics

Compare:

reverse traversal only;

reverse traversal + reversed waveform.

This should be judged blind if possible.

TEST 4 — Vocal exposure independent of sweep step

At the existing sweep rates, test different vocal-event durations rather than forcing every voice window to equal the dwell.

Particularly important at:

75 ms;

125 ms;

200 ms;

300 ms.

The goal is to determine whether the UI sweep rate should control scan cadence while vocal exposure has its own bounded timing behavior.

TEST 5 — Static balance

Current static should be treated as glue, not the main event.

Test small level changes before changing its entire synthesis model.

Questions:

Is static masking useful human transitions?

Does it feel too uniform?

Does it disappear too much under speech?

Does it sound like generic white noise rather than a changing sweep texture?

Avoid assuming “more static = more realistic.”

TEST 6 — Mild spectral / speed variation

Only after timing and density are improved.

Potential tests:

2–3 restrained spectral profiles;

small playback-speed variance;

small bounded gain variation.

These are secondary.

Do not use heavy pitch shifting, reverb, horror effects, or multiple intelligible overlapping voices to hide a bad scheduler.

1. What we know vs. what we are inferring

VERIFIED / CURRENTLY OBSERVED

Successful spirit-box apps use richer human-speech material than sustained isolated vowels alone.

Several competitors deliberately vary source banks, playback rate, direction/reversal, or spectral character.

Spiritus specifically changed source-bank size, occurrence timing and speed while improving its audio.

The current app uses VCTK-derived natural speech, not the old isolated-phoneme bank.

The current renderer schedules vocals at sweep slots with continuous procedural noise.

Current Reverse default is reverse corpus traversal with forward-orientation snippets. Literal waveform reversal is not the live default.

The current renderer uses one dominant vocal stream rather than multiple simultaneous voices.

STRONG INFERENCE

VCTK is probably rich enough for the next perceptual gate.

The current “rapid-fire voices” problem is likely caused at least partly by renderer timing/density rather than insufficient source complexity.

Constant vocal occupancy is probably less convincing than intermittent catches.

Frequent speaker changes may be making the output feel more randomized than instrument-like.

SPECULATION / MUST TEST

Ideal vocal occupancy percentage.

Ideal burst duration.

Whether same-speaker continuity should last 2, 3, or 4 sweep steps.

Whether literal waveform reversal helps.

Exact static level.

Exact filter profiles.

Exact playback-speed variance.

Whether rare secondary bleed would help at all.

1. Recommended perceptual target

The target is not “maximum intelligibility.”

The target is:

continuous sweep texture with brief, unpredictable, human-sounding catches that sometimes resemble partial speech without behaving like constructed answers.

Good output should feel like:

sweep… static… fragment… sweep… nothing… brief human catch… sweep… partial syllable… static…

Bad output feels like:

voice-voice-voice-voice-voice

or:

loud static covering everything

or:

clean chopped podcast sentences

or:

obvious spooky sound design.

1. Cheapest next decision

Before changing corpus architecture again:

Determine whether vocal density, continuity, event duration, and Reverse semantics can make the existing VCTK renderer sound convincingly closer to the reference audio.

That is cheaper than building a new corpus and directly targets the strongest current failure mode.

1. Kill / escalation criterion

Keep VCTK + the current offline non-semantic architecture if renderer tuning can produce a convincing 15–20 minute session without:

obvious clip-randomizer feel;

recognizable recurring fragments;

reconstructed sentence cadence;

excessive intelligibility;

mechanical speaker roulette;

annoying static;

fake-response timing.

If timing/density/continuity/spectral tuning cannot get there after one disciplined tuning pass, then revisit the source-corpus design.

Do not jump immediately to live radio merely because one tuning configuration sounds bad.

1. Practical review lens for audio models

When reviewing renders against /recordings/reference-audio, prioritize:

vocal-event density;

speaker-switching rate;

speech continuity;

sweep cadence versus vocal-event duration;

static/noise balance;

Forward/Reverse perceptual behavior;

recognizability / sentence leakage;

repetition;

tonal credibility;

overall “instrument” feel.

The key question is:

Does this sound like a scanning instrument intermittently catching human speech, or like software rapidly selecting voice clips?