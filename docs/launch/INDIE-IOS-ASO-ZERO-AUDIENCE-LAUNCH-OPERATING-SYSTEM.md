# INDIE iOS ASO & ZERO-AUDIENCE LAUNCH OPERATING SYSTEM

**Research date:** September 10, 2026  
**Platform:** Apple App Store / iPhone first  
**Use case:** Solo or very small indie developer launching with little or no existing social audience  
**Project application:** Spirit Box  
**Status:** **CURRENT ASO EXECUTION SOURCE OF TRUTH** — complements the revised Spirit Box creative/metadata playbook. Where this document discusses ASO process, measurement, launch execution, App Store discovery surfaces, or post-launch iteration, use this document. The revised Spirit Box playbook remains the source for the exact current listing concept and creative direction.

---

## 0. EXECUTIVE VERDICT

ASO is not "pick keywords, fill metadata, and wait." It is a system with five linked jobs:

> **VALIDATE DEMAND → BECOME RELEVANT → EARN THE INSTALL → EARN TRUST/USAGE → ITERATE FROM REAL DATA**

For an indie with no social following, the highest-probability launch strategy is **organic-search-after-seeding, not metadata-only**.

Apple explicitly says App Store search uses both:

- **text relevance** — title, subtitle, keywords, and primary category; and
- **user behavior** — downloads, ratings and reviews, "and more." [A1]

Excellent metadata can make a new app eligible. It does not promise competitive rank. 2026 Spirit Box title-clones with almost no ratings demonstrate the gap. See `docs/research/RESEARCH-REVALIDATION-2026-09-10.md`.

That means excellent metadata can make a new app eligible and relevant for the right queries, but Apple does not promise that metadata alone will produce competitive rank. There is also no Apple-backed threshold such as "50 installs," "200 installs," or "1,000 installs" that unlocks ranking.

The practical indie strategy is therefore:

1. **Choose demand you can realistically compete for before launch.**
2. **Put the exact highest-value intent in the strongest truthful metadata.**
3. **Make the search-result unit convert before worrying about a long description.**
4. **Seed a small number of real target users without creating a social-media business.**
5. **Prompt for ratings only after genuine successful use.**
6. **Measure search discovery, downloads, conversion, activation, purchase and review themes.**
7. **Change one major variable at a time and keep a written experiment log.**
8. **Kill or reposition if economically useful search traction does not appear after disciplined iterations.**

### The zero-audience conclusion

You do **not** need to become a creator or build a large public following to give an indie app a fair launch.

You **do** need some way to break the completely cold start and learn whether the product converts for actual buyers. The best no-social method is usually **target-community seeding**: private beta users, direct outreach to people already doing the job, moderator-approved niche posts, relevant forums/Discords/Meetups, and existing happy users. This is very different from posting daily build logs to X.

For Spirit Box specifically, the project already has a better route than generic "build in public": experienced paranormal investigators, hardware owners, EVP users, small investigation groups, and carefully selected communities. [P1]

### The most important changes to the revised Spirit Box ASO playbook

The September 10 revised playbook is directionally strong and correctly demotes several unsupported ASO claims. [P0] This research adds five material updates:

1. **Custom Product Pages are now an organic-search tool.** Apple allows approved keywords from the latest app version to be assigned to a Custom Product Page (CPP), so the tailored page can appear for those searches instead of the default page. A brand-new app cannot create a CPP until it is Ready for Distribution in at least one territory, so this is a **post-launch expansion lever**, not a launch dependency. [A4]
2. **App Tags are a current U.S. discovery surface.** Apple generates them from App Store Connect metadata using AI and human curation; developers can review/deselect tags. Tags can appear in search results and on the product page. [A5]
3. **App Store Search analytics includes Apple Ads.** If Apple Ads is running, the "App Store search" source is not a clean organic number. Paid reporting must be reconciled separately before claiming organic growth. [A6]
4. **New iOS 27 search-result creative assets are coming in fall 2026.** Apple has announced separate rich image/video assets for search results and product-page headers, managed through the new Asset Library. Treat this as a launch-readiness watch item, not a dependency until it is available in the account/storefront. [A7]
5. **The review prompt has a hard system limit.** Apple permits the standard in-app rating prompt up to three times in a 365-day period. The prompt should be placed after a completed, satisfying sequence, not at first launch or in the middle of a task. [A2]

---

# 1. WHAT ASO CAN AND CANNOT DO

## 1.1 What ASO can do

A strong ASO system can:

- make an app relevant for the queries its intended users actually type;
- improve the probability that a search impression becomes a download;
- expose under-served long-tail intent;
- help a smaller app compete where incumbents are weak, irrelevant, poorly converted, or badly positioned;
- convert external/referral traffic more efficiently;
- improve Apple Ads efficiency if paid search is later used;
- create an evidence loop for what users call the problem and which promises convert;
- expand into additional intent clusters through localizations and, after launch, keyword-linked CPPs.

## 1.2 What ASO cannot do

ASO cannot:

- create consumer demand that does not exist;
- guarantee top rank for a competitive head term;
- make a weak or misleading product retain users;
- turn a term with tiny actual install volume into a large business just because difficulty is low;
- prove willingness to pay from keyword popularity alone;
- guarantee that paid Apple Ads boosts organic rank;
- guarantee that screenshot text directly changes keyword rank;
- rescue a product whose top search results are overwhelmingly stronger and better trusted;
- replace all launch distribution with a secret metadata trick.

The earlier project research already produced the most important warning: easy-looking keyword difficulty can coexist with economically trivial install volume. [P2]

---

# 2. EVIDENCE HIERARCHY — WHAT TO BELIEVE

ASO advice is full of confident claims that are actually reverse engineering, vendor marketing, or one developer's experience. Use this hierarchy.

| Level | Evidence | How to use it |
|---|---|---|
| **1 — VERIFIED** | Current Apple Developer / App Store Connect documentation | Treat as platform fact until Apple changes it |
| **2 — MEASURED FIRST-PARTY** | Your own App Store Connect, StoreKit, RevenueCat, crash/activation data | Highest-value evidence for your own decisions |
| **3 — OBSERVED PRACTITIONER** | A developer or agency shows the change, test method, and before/after result | Useful for hypotheses, not universal rules |
| **4 — VENDOR REVERSE ENGINEERING** | Appfigures, AppTweak, SplitMetrics, Phiture, etc. infer ranking behavior from data | Use directionally; verify against Apple and your own results |
| **5 — ANECDOTE** | Reddit, X, indie postmortems, single launch stories | Use to discover failure modes and tactics, never magic numbers |
| **6 — FOLKLORE** | Uncited "everyone knows Apple does X" claims | Do not build strategy around it |

### Claims accepted as platform facts

Apple currently confirms that:

- search relevance uses **title, subtitle, keywords and primary category**, plus user behavior including downloads, ratings and reviews, and more; [A1]
- primary and secondary categories are indexed, while the primary category is especially important to discovery and placement; [A1]
- the app name and subtitle are each capped at 30 characters; [A2]
- App Store Connect's reference specifies a **100-byte** keyword limit, while Apple's public search guidance describes 100 characters total; use the App Store Connect counter as the final authority, especially with non-ASCII text. Apple advises avoiding duplicates, filler, irrelevant terms and protected competitor terms; [A1][A3]
- promotional text does **not** affect App Store search ranking; [A1]
- up to three screenshots/app previews can appear in search results depending on orientation/platform; [A1][A2]
- ratings and reviews can influence search rank and conversion; [A1][A2]
- App Store Connect can attribute downloads, sales, usage and subscriptions to the acquisition source recorded at download/redownload; [A6]
- App Store Search source metrics include ads that appear in search results; [A6]
- localized metadata can make the app searchable with localized keywords in supported countries/regions; [A8]
- keyword-linked CPPs can replace the default page for selected organic searches after the app is live and the CPP is approved/visible. [A4]

### Claims deliberately NOT treated as facts

| Claim | Verdict |
|---|---|
| "Apple gives every new app a guaranteed 7-day ranking boost" | **UNVERIFIED** |
| "1,000 launch downloads is the threshold Apple needs" | **UNVERIFIED** |
| "Apple Ads automatically creates an organic halo" | **UNVERIFIED** |
| "Screenshots are a confirmed direct ranking field" | **UNVERIFIED**; screenshot copy still matters greatly for conversion |
| "Retention, crash rate or update frequency have known direct ranking weights" | **UNKNOWN**; optimize them because they matter to product/business anyway |
| "Title gets exactly X% more ranking weight than subtitle" | **UNVERIFIED** |
| "Use every single title/subtitle character no matter what" | **HEURISTIC**, not a rule |
| "iOS ranking is title + subtitle + keyword field, and that's it" | **FALSE/INCOMPLETE**; Apple also names category and user behavior |
| "50–200 launch installs is enough to move the algorithm" | **UNVERIFIED MAGIC NUMBER** |

The Expo ASO Skills article is useful as an automation workflow, but it repeats several industry claims (such as direct screenshot indexing) that Apple does not independently confirm. Use the skills as an analyst, not as an oracle. [S1]

---

# 3. THE ASO FUNNEL

Treat ASO as four separate diagnostic layers. Do not use "ASO is bad" as a diagnosis.

## Layer 1 — Demand

**Question:** Are enough people searching for this job/category to support the business?

Evidence:
- keyword popularity/search estimate;
- competitor estimated downloads;
- keyword-attributed install estimates where available;
- ranking apps' rating velocity and recency;
- seasonal history;
- whether the query is generic purchase intent or branded navigation.

**Failure:** You can rank, but there is no money-sized traffic.

## Layer 2 — Relevance / visibility

**Question:** Does Apple understand that the app is a good result for this query, and are we ranking high enough to receive meaningful impressions?

Evidence:
- rank by keyword;
- search impressions/downloads;
- metadata coverage;
- category;
- app tags;
- competitors occupying the SERP.

**Failure:** Strong product, almost no qualified search exposure.

## Layer 3 — Conversion

**Question:** When the user sees the search result or page, do they choose us?

Evidence:
- unique impressions;
- first-time downloads;
- conversion rate by source/territory;
- product page views;
- first screenshot/icon/title/subtitle comprehension;
- ratings/reviews visible beside the result.

**Failure:** Impressions exist, downloads do not.

## Layer 4 — Product / economics

**Question:** Did the install become successful usage and money?

Evidence:
- activation event;
- trial completion;
- purchase;
- refund;
- retention where relevant;
- review sentiment;
- revenue/proceeds by acquisition source.

**Failure:** ASO can be "working" while the business is not.

### Diagnosis matrix

| What you see | Most likely problem | Next move |
|---|---|---|
| Low search impressions + low rank | Visibility/relevance or weak demand | Recheck query economics and metadata |
| High rank + low impressions | Keyword demand was overestimated | Demote/kill the keyword |
| Good impressions + weak downloads | Search-result conversion | Test icon, title/subtitle promise, first screenshot |
| Good downloads + weak activation | Product/listing promise mismatch or onboarding | Fix product before buying/creating more traffic |
| Good activation + weak purchase | Pricing/paywall/value | Monetization experiment |
| Good purchases + low search volume | Opportunity may be valid but too small | Expand adjacent intent/locale, not random features |
| Rising rank + falling conversion | You may be attracting broader/worse-fit traffic | Tighten intent/message |
| Apple Ads on + "search" downloads rise | Paid and organic are mixed | Reconcile Apple Ads separately before declaring organic lift |

---

# 4. PRE-LAUNCH KEYWORD RESEARCH — EXACT PROCEDURE

The objective is **not** to find the most keywords. It is to find the smallest set of queries capable of supporting the business.

Phiture's long-running Keyword Optimization Cycle is the right mental model: **research → prioritize → target → measure**. [S8] Appfigures and current practitioner material independently converge on the same process: build a wide semantic set, score demand/competition/relevance, then track what happens rather than treating the first metadata choice as permanent. [S2][S9]

## Step 1 — Define the job in user language

Write one sentence without product jargon:

> "Someone searches the App Store because they want to ______."

Then write 5–10 ways a user would say that job.

For Spirit Box:

- spirit box
- ghost box
- ghost talker
- ghost hunting tools
- paranormal tool
- ITC
- EVP recorder **only if the actual user job overlaps our recording/review product**

Do not begin with feature adjectives such as "beautiful," "fast," or "private." Start with the **category/job noun**.

## Step 2 — Build a 100–200-query raw list

Sources, in order:

1. Apple App Store autocomplete/search hints.
2. Exact titles/subtitles of the apps already ranking.
3. Relevant tokens from competitor descriptions.
4. Competitor and category reviews — especially the words users use to describe the job.
5. Related App Store searches / search hints.
6. Keyword-tool suggestions and competitor gaps.
7. Adjacent problem/outcome terms.
8. Seasonal terms **only if current data proves they rise and still match the product**.
9. AI expansion last — use AI to generate variants, not to invent demand.

Appfigures' strongest practical research advice is to mine not only competitor metadata, but also your own and competitors' reviews for the language users naturally use. [S2]

## Step 3 — Tag every candidate by intent

Use four buckets:

- **CATEGORY:** what the thing is (`spirit box`)
- **FEATURE/JOB:** what the user wants to do (`EVP recorder`, `mark recording`)
- **OUTCOME/USE CASE:** why/where they want it (`ghost hunting`)
- **BRAND/COMPETITOR:** navigation or comparison (`GhostTube`) — useful for research/ads, **not** unauthorized App Store keyword-field stuffing

A fifth optional bucket is **SEASONAL**.

This prevents a common mistake: comparing a broad discovery query with a precise purchase-intent query as though they were the same kind of traffic.

## Step 4 — Record SERP reality, not only a difficulty score

For every serious candidate, record:

- tool popularity/search score;
- tool difficulty/competition score;
- current rank if live;
- top 10 apps;
- estimated downloads of top results if available;
- rating count and star rating of top 3–5;
- age/release recency of the weakest apps in top 10;
- whether the results actually solve the same job;
- monetization model of top results;
- exact relevance to our V1;
- whether the term can combine with existing title/subtitle/keyword tokens.

A "difficulty 0" number is not enough. The project already learned this the hard way on previous app research: rankability without meaningful installs is commercially irrelevant. [P2]

## Step 5 — Score opportunity qualitatively

Do **not** invent a pseudo-scientific weighted formula unless the inputs are real and comparable.

Use:

**Demand:** High / Medium / Low  
**Intent fit:** Exact / Strong / Weak  
**Competition:** Weak / Mixed / Strong  
**Paid intent:** High / Medium / Low  
**SERP weakness:** Clear / Some / None  
**Build truthfulness:** Exact / Partial / No  
**Decision:** Primary / Secondary / Explore / Reject

### Primary keyword standard

A primary keyword should have:

- obvious category/job match;
- enough demand to matter;
- a SERP where a new entrant has a plausible path;
- results that monetize or otherwise demonstrate valuable intent;
- language the user would immediately recognize in the listing;
- no need to distort the product to qualify.

## Step 6 — Pick the launch portfolio

For a small indie, launch with:

- **1 primary money query**
- **3–7 strong secondary/combination targets**
- **a broader token set** in the keyword field for combinations
- **0 vanity terms** chosen only because their raw popularity is large

Long-tail-first is a valid strategy when the head term is unwinnable. It is **not** a religion: Sebastian Röhl's HabitKit deliberately went all-in on the hard head term `habit tracker`, put it in the name, and eventually reached strong positions. His result shows that a difficult head term can work when product-market fit, time, usage, reviews and acquisition align; it does not prove every indie should choose the hardest term. [S3]

## Step 7 — Freeze the launch snapshot

Save:

- date/time;
- all selected keyword scores;
- top 10 for primary and key secondaries;
- competitor title/subtitle/screenshots;
- your proposed metadata;
- your current rank (if pre-existing);
- hypothesis for every premium metadata choice.

Without this snapshot, post-launch movement becomes storytelling.

---

# 5. METADATA CONSTRUCTION — iOS

## 5.1 App name — 30 characters

Job:

> **Maximize category recognition + search relevance without looking spammy or misleading.**

Rules:

- protect the single most valuable truthful keyword;
- favor immediate comprehension over clever brand poetry at launch;
- use remaining characters for either a powerful secondary intent or a human differentiator;
- never use a competitor trademark to borrow traffic;
- do not use words that imply functionality the app does not have.

Practitioner audits consistently find that many indie apps waste title space, but "use all 30 characters" should be treated as a **heuristic**. If the 29th and 30th characters force a weak or misleading term, leave them unused. [S4][S5]

## 5.2 Subtitle — 30 characters

Job:

> **Add new indexed intent and/or a clear benefit that improves the search result.**

Do not repeat the title unnecessarily.

A useful decision rule:

- if a high-value secondary keyword earns the space, use it;
- if secondaries are weak, spend the subtitle on a conversion benefit that clarifies why your result is better.

## 5.3 Keyword field — 100-byte App Store Connect limit

Apple's App Store Connect reference specifies up to **100 bytes** for the keyword field, while Apple's public App Store search page describes the field as 100 characters total. For implementation, use App Store Connect's own counter as the final authority, especially for non-ASCII/localized terms.

Rules Apple explicitly supports:

- comma separated;
- no spaces after commas unless a space is required inside a phrase;
- do not duplicate words already covered by the name/subtitle/category;
- do not waste space on singular/plural duplicates;
- avoid broad filler such as `app`;
- no competitor names or unauthorized trademarks;
- no irrelevant terms. [A1][A3]

### Atomic-token principle

Apple can form combinations from useful tokens, so do not automatically store every long-tail phrase as a literal phrase. Prefer reusable words when they create multiple relevant combinations.

But do not blindly atomize a phrase if a current tool/test shows the exact phrase behaves differently. Treat phrase-vs-token handling as something to verify, not folklore.

## 5.4 Description — conversion + web search, not App Store keyword stuffing

Apple explicitly tells developers not to add unnecessary keywords to the description to improve App Store search. [A2]

Use the description to:

1. make the first visible sentence explain the core job and differentiation;
2. describe the real workflow;
3. address the biggest trust objection;
4. explain pricing/trial mechanics without brittle regional price copy where possible;
5. include support/privacy credibility.

Apple's App Store Connect reference also states that the description is used for **web engine search results** after release, so natural category language still has value outside the App Store ranking field. [A3]

## 5.5 Promotional text — conversion/updates only

Promotional text:

- can be changed without a full app-version submission;
- does not affect App Store search ranking;
- is good for a launch message, seasonal note, new feature, limited-time event or current proof point. [A1][A2]

## 5.6 Category

Choose the most accurate primary category.

Do not choose a less-relevant category merely because it looks easier. Apple indexes category and can reject irrelevant categorization. [A1]

## 5.7 App Tags — new 2026 operating check

In the U.S., Apple can apply glanceable tags based on the en-US metadata, AI and human curation. Tags can appear in search and on the product page. Developers can deselect irrelevant assigned tags in App Store Connect. [A5]

**Operating step after approval/live:**

1. App Store Connect → App Information.
2. Review App Store Tags.
3. Deselect anything misleading.
4. If the assigned tags are weak, inspect whether the metadata itself is semantically vague.
5. Do not rewrite the whole listing solely to chase a tag; relevance and conversion still come first.

---

# 6. THE SEARCH-RESULT UNIT — WHERE MOST SMALL APPS SHOULD FOCUS

The user often decides before reading the long description.

Apple says search can show:

- icon;
- app name;
- subtitle;
- rating;
- up to three screenshots/app previews depending on platform/orientation;
- app tags;
- other result content. [A1]

The first job is therefore to make this cluster work **without the user opening the full product page**.

## The 5-second test

Show a realistic search result to a target user for five seconds. Ask:

1. What is this app?
2. What would you use it for?
3. Why would you choose it instead of the result above/below?
4. What do you think happens after you install?

If the answer to #1 is wrong, do not polish screenshot #5.

## Icon

The icon must:

- be recognizable at search size;
- communicate category/quality, not every feature;
- contrast with the actual SERP, not a design canvas;
- avoid details that disappear at thumbnail size.

SplitMetrics case studies are valuable here because they repeatedly show that creative "best practices" can reverse by audience. One case found a supposedly recommended plain background performed worse; another reordering alone improved conversion. The lesson is **test category-specific hypotheses**, not "always use X." [S6]

## Screenshot #1

Screenshot #1 should answer:

> **"Yes, this is the thing you searched for — and here is the strongest reason to care."**

Avoid:

- vague brand slogans;
- tiny UI;
- feature lists;
- multiple promises;
- decorative lifestyle imagery that obscures what the app does.

SplitMetrics' audit of 70+ App Store pages found common creative failures such as inconclusive screenshot messaging, hard-to-read text, overcrowding, missing feature-oriented shots, and weak icon association. Treat the percentages as an agency sample, not universal rates, but the failure modes are directly useful. [S5]

## Screenshots #2–3

Use them to complete one causal story:

> **Problem/trigger → hero action → payoff**

For Spirit Box, the revised playbook's sequence is already structurally strong:

1. category + sweep;
2. hear something → MARK;
3. replay the exact moment. [P0]

That is better than using screenshots 1–3 as three unrelated feature cards.

## Screenshots #4+

Resolve objections:

- trust/privacy;
- offline;
- pricing/trial;
- export/history;
- proof/social proof only when legitimately earned.

Do not manufacture ratings, awards, user counts or "scientific" claims.

## Screenshot text and ranking

Some 2025–2026 vendor reverse engineering claims Apple may use screenshot captions/semantic content in discovery. Apple has not explicitly listed screenshot OCR as a ranking field in its public search-factor description. [S1][S2]

**Practical decision:** Use real query language in screenshot headlines when it also improves human message-match. Do **not** keyword-stuff visuals or sacrifice clarity for an unverified ranking theory.

---

# 7. CUSTOM PRODUCT PAGES — THE BIGGEST 2026 ASO ADDITION

This deserves its own section because older ASO playbooks often treat CPPs as paid-campaign landing pages. That is now incomplete.

Apple currently allows:

- up to **70** CPPs;
- unique screenshots, app previews, promotional text and keywords;
- organic search keyword assignment from the app's latest approved version;
- per-page impressions, downloads and conversion analytics after minimum data thresholds;
- deep links for supported iOS versions. [A4]

## Critical launch limitation

A brand-new app can create CPPs only after it is **Ready for Distribution in at least one country or region**. [A4]

Therefore:

> **Do not delay first release to build CPPs. Launch with the strongest default page. Add CPPs once the live app reveals a second intent cluster worth tailoring.**

## When a CPP deserves to exist

Create one only when:

- a meaningful keyword cluster has distinct intent;
- the default page is forced to compromise between two audiences/jobs;
- a different first screenshot/proof point would materially improve message-match;
- there is enough traffic to measure it.

### Example for Spirit Box

**Default page:** `spirit box` — category + field instrument + MARK/replay.

Possible future CPPs **only if data supports them:**

- `ghost hunting` cluster → investigator/field-use creative;
- `EVP recorder` cluster → recording/mark/replay creative **only if searchers actually accept the product as relevant**;
- a seasonal Halloween/party cluster → only if tool/search data shows material seasonal intent and the positioning does not damage serious-user conversion.

Do not create 10 CPPs just because Apple permits 70.

---

# 8. RATINGS & REVIEWS — TRUST AND DISCOVERY

Apple explicitly states that ratings/reviews can influence search rank and whether users engage from search. [A1][A2]

The correct goal is not "get five stars." It is:

> **Create enough genuinely successful use that satisfied users are naturally likely to rate, then remove friction from the request.**

## In-app prompt rules

Apple's system prompt can be requested up to three times in 365 days. [A2]

Recommended logic:

1. User completes a meaningful success sequence.
2. No crash/error/permission failure occurred in the session.
3. User has had enough exposure to judge the app.
4. Prompt after the sequence ends, not while they are performing the action.
5. Do not show after first open, immediately after onboarding, or directly before/after a paywall.

For Spirit Box, a better event than "pressed MARK once" is:

> completed a real session → used replay/marks successfully → returned to a neutral post-session state.

## Do not

- buy reviews;
- reward a five-star review;
- gate support based on rating;
- ask only users who pre-select "happy" in a way that manipulates the review system;
- pressure beta users to write positive reviews.

## Human review recovery

Reply to early reviews quickly, especially if:

- the user misunderstood functionality;
- a bug was fixed;
- pricing is unclear;
- a recording was lost;
- a trust concern is raised.

Apple notifies reviewers of developer responses and lets them update their reviews. [A2]

Sebastian Röhl's experience is useful here: he responds to reviews and asks happy users who email him to review the app. That is a practitioner tactic, not a ranking guarantee, but it is cheap and aligned with genuine satisfaction. [S3]

---

# 9. LAUNCHING WITH NO SOCIAL PRESENCE — THE ACTUAL PLAYBOOK

## 9.1 First principle: do not become a content creator unless the audience overlap is real

"Build in public" worked as part of HabitKit's story because a broad productivity app overlapped well with the developer/X audience and Röhl already used that channel. He explicitly frames the ranking impact as his belief, not measured proof. [S3]

For a niche consumer app, generic indie audiences are usually low-quality traffic.

### Use this rule

**If the people watching the build are not plausible buyers, build-in-public is not acquisition. It is entertainment for other developers.**

For Spirit Box, a 500-person ghost-hunting community is more valuable than 10,000 generic #buildinpublic impressions if the latter contains almost no paranormal users.

## 9.2 The four launch-seed channels, ranked

### 1. Target-user beta / direct outreach — PRIMARY

Recruit real people who already do the job.

Best use:
- 15–30 users;
- private or small-group feedback;
- qualification before access;
- explicit request for criticism.

For Spirit Box, the prior acquisition research recommends a core of physical spirit-box owners, EVP/audio investigators, skeptical app users, and small paranormal groups. [P1]

The pitch is not:

> "Please download my app and give me five stars."

It is:

> "I built an iPhone version of this workflow. I need people who use real equipment to tell me exactly what feels fake, confusing, or useless."

That produces better product feedback and gives the first public version a chance to earn authentic advocates.

### 2. Niche communities — PRIMARY, PERMISSION-FIRST

Good:
- highly relevant subreddit where a feedback post is allowed;
- specialist Discord;
- forum;
- Meetup/association organizer;
- small Facebook group with admin approval.

Bad:
- dropping a TestFlight/App Store link into the largest subreddit;
- identical cross-posting;
- pretending not to be the developer;
- leading with a promotion instead of useful context.

The Spirit Box project already identified that r/GhostHunting can be approached cautiously, while r/Paranormal and r/Ghosts have rules that make public recruitment inappropriate. [P1]

### 3. Product Hunt / indie launch directories — OPTIONAL

Product Hunt is a **cheap lottery ticket**, not the business model.

Evidence from indie launch reports is mixed:
- some products get hundreds or thousands of early users;
- others get only a few dozen installs even after preparing a launch;
- developer-heavy attention can be irrelevant for a niche consumer app.

Rule:

> Spend a few hours preparing the listing if the launch can be repurposed elsewhere. Do not spend days optimizing Product Hunt if Product Hunt users are not the buyer.

For Spirit Box: low priority.

### 4. Personal network — QA/support, not market proof

Friends, coworkers and family can:
- catch crashes;
- verify onboarding;
- produce the first few real-device sessions;
- share the app with someone genuinely relevant.

They should **not** be counted as evidence that the niche converts, and they should not be pressured for reviews they cannot honestly write as target users.

## 9.3 Free Apple featuring nomination — asymmetric upside

App Store Connect lets developers nominate a new app launch, major update or other relevant story for editorial featuring. [A9]

Do it because:
- cost is nearly zero once assets/story exist;
- downside is negligible;
- featuring is not assumed in the revenue model.

Apple's nomination template guidance says to finalize the plan **at least three weeks in advance**. [A9] If you are already inside that window, submit as soon as the story is ready, but do not delay launch or assume consideration.

## 9.4 Launch-day sequencing

### Before release

- Build is stable.
- Listing is final.
- Analytics/purchase events work.
- Support/privacy pages work.
- 15–30 target beta users have completed real sessions.
- Known severe problems are fixed.
- Keyword/SERP launch snapshot is saved.
- Review prompt is implemented but not aggressive.
- Featuring nomination submitted if appropriate.
- One niche-community post and a handful of direct outreach messages are drafted, not blasted.

### Day 0

1. Release.
2. Verify the live listing exactly as a user sees it.
3. Search the primary term manually and record rank/appearance.
4. Verify purchase/trial.
5. Send the public link to qualified beta users and direct contacts.
6. Post to **one** approved high-fit community if allowed.
7. Do not change metadata because the first six hours look quiet.

### Days 1–3

- watch crashes, entitlement bugs, recording/data-loss problems;
- respond to support;
- record reviews and repeated confusion;
- verify App Store Connect source data as it appears;
- log rank daily for primary and a few secondaries;
- do not make five listing edits at once.

### Days 4–7

- perform the second small target-community outreach batch;
- compare first search impressions/downloads to other sources;
- run the 5-second listing test with new people who did not see development;
- fix catastrophic conversion confusion only;
- respond to every substantive review.

### Days 8–14

- decide whether the bottleneck is demand, rank, conversion, product or monetization;
- if primary term is ranking poorly but search intent still looks attractive, choose **one** visibility hypothesis;
- if impressions are decent but installs weak, choose **one** creative hypothesis;
- consider an Apple Ads diagnostic only if it answers a specific unknown.

### Days 15–28

- first controlled metadata/creative iteration;
- create the first CPP **only if** a distinct secondary cluster has enough evidence;
- expand localization only where demand/competition economics justify it;
- update the experiment log;
- decide continue / reposition / kill.

---

# 10. APPLE ADS — OPTIONAL DIAGNOSTIC, NOT RANKING FUEL

The revised project stance is correct: Apple Ads should not block launch. [P0]

Sebastian Röhl is unusually useful as a warning here. He ran about €2.50-per-install Apple search traffic while admitting he did not measure whether it affected rank and concluded the spend looked poor. That is not evidence for an organic halo; it is evidence for **measuring before believing the halo story**. [S3]

## Good indie uses of Apple Ads

- estimate whether a query converts before spending a metadata cycle on it;
- obtain search-term data;
- compare two high-intent clusters;
- send a query to a matching CPP after the app is live;
- validate whether the issue is search demand versus store conversion.

## Bad uses

- "buy installs so Apple will rank me";
- broad Search Match with no learning question;
- paying for branded traffic you would likely receive organically;
- continuing after CPA clearly cannot work;
- using paid search to disguise an organic thesis that failed.

## Minimum viable diagnostic

If setup is easy and the question matters:

- small capped budget;
- exact-match primary query + 1–3 serious alternatives;
- no broad scale;
- define the question in advance;
- stop when the answer is decision-useful.

### Measurement warning

App Store Connect's **App Store search** source includes views/downloads from ads appearing in search results. [A6]

Therefore if Apple Ads runs:

> **Do not call App Store Search downloads "organic downloads."**

Use Apple Ads reporting to subtract/reconcile paid acquisition and compare total business impact.

---

# 11. PRODUCT PAGE OPTIMIZATION / A-B TESTING

Apple's Product Page Optimization (PPO) lets developers test alternate product-page creatives with eligible App Store traffic and read results in App Analytics. [A2]

Phiture and SplitMetrics case studies provide a useful consistent lesson: **creative changes can produce large gains, but results are app/audience-specific and experimentation compounds through multiple iterations.** Pura Mente's Phiture work used 25 iterations over six months; SplitMetrics examples show even simple screenshot order/background tests sometimes outperform accepted "best practices." [S6][S7]

## Indie rule: do not fake statistical certainty

If traffic is tiny, a formal A/B test can run indefinitely or return an inconclusive result.

Use this ladder:

### Low traffic

- 5-second search-result comprehension tests;
- 10–20 target-user preference tests;
- qualitative interviews;
- competitor-SERP comparisons;
- sequential store changes with careful date logging.

### Medium traffic

- Apple PPO;
- one strong hypothesis at a time;
- screenshot #1 / icon / major framing before tiny cosmetic changes.

### High traffic

- continuous experiment backlog;
- localization/CPP-specific testing;
- more granular creative changes.

## Experiment record

For every change record:

**Hypothesis**  
**What changed**  
**Why it should work**  
**Primary metric**  
**Guardrail metric**  
**Start date**  
**Confounders**  
**Result**  
**Decision**  
**Next test**

App Store Marketing's current practitioner checklist expresses this well: one primary goal, one hypothesis, one major change, one readout. [S9]

---

# 12. LOCALIZATION — EXPANSION, NOT FREE KEYWORD SPAM

Apple supports localized app metadata and localized keywords. Users can search with localized keywords where the App Store supports the language, and which localization appears depends on territory/device/language context. [A8]

This makes localization powerful, but it is often abused in ASO advice.

## Correct sequence

1. Prove the English/U.S. core or identify a specific non-U.S. market with known demand.
2. Pull that market's actual SERP and query language.
3. Localize:
   - title/subtitle where appropriate;
   - keywords;
   - screenshots;
   - description/trust copy.
4. Have a fluent speaker check user-facing text.
5. Measure territory-specific impressions/downloads/revenue.

## What not to do

- dump unrelated English keyword lists into every localization merely to multiply field space;
- assume old "cross-localization" maps are permanent;
- translate U.S. keywords literally and assume search intent transfers;
- launch 20 localizations that cannot be supported or reviewed.

Some agency/vendor guides recommend aggressive cross-localization tricks. They can be worth researching, but Apple itself documents which localizations display/index by territory; verify the current mapping before using any workaround. [A8]

---

# 13. AI ASO WORKFLOW — USEFUL, WITH GUARDRAILS

The Expo article points to the open-source `aso-skills` project, which can be installed for Cursor and other Agent Skills-compatible tools. The repository contains skills for audit, keyword research, metadata, competitor analysis, screenshots, CPPs, reviews, launch, analytics and more. With its Appeeky integration, it can pull live store data; standalone mode is framework/knowledge based. [S1][S10]

## Recommended use

Use the AI layer to:

- generate the initial 100–200 keyword candidate set;
- normalize/export competitor metadata;
- classify query intent;
- flag duplicate keyword tokens;
- count metadata characters;
- produce metadata alternatives **from a supplied keyword dataset**;
- track competitor changes;
- draft experiment readouts;
- summarize reviews into recurring language/pain themes.

## Never allow the AI to

- invent keyword volume;
- invent difficulty;
- invent rank;
- invent download estimates;
- tell you a screenshot "will rank" because it contains a keyword;
- select a keyword without showing the input evidence;
- overwrite a strong human-conversion message solely to fill characters;
- turn a reverse-engineered vendor claim into an Apple fact.

## Cursor installation option

The public repository currently documents:

`npx skills add eronred/aso-skills -a cursor`

Before relying on its data output, identify whether the result came from:
- a live data integration;
- App Store Connect;
- a public App Store lookup;
- or the model's general knowledge.

Every output should include **source + date + metric definition**.

### Best workflow for this project

1. Put this ASO operating document and the Spirit Box product source in Cursor context.
2. Feed the final Sonar/free-tool export as a data file.
3. Run keyword research/audit.
4. Require the agent to output:
   - raw evidence table;
   - primary/secondary/reject classification;
   - metadata candidates;
   - rejected terms and reason;
   - explicit unknowns.
5. Human review before updating App Store Connect.

This removes repetitive ASO clerical work without handing commercial judgment to the model.

---

# 14. WEEKLY ASO OPERATING CADENCE

A useful ASO system is intentionally boring.

## Monday — diagnose

Review:

- primary/secondary rank;
- search unique impressions;
- first-time downloads;
- source conversion;
- ratings/reviews;
- activation;
- purchases/revenue;
- competitor metadata/creative changes.

Pick exactly one weekly priority:

> **VISIBILITY** or **CONVERSION** or **PRODUCT/ECONOMICS**

Do not optimize all three at once.

## Midweek — build the smallest test

Examples:

- swap one weak subtitle term;
- replace screenshot #1 promise;
- create one CPP;
- adjust one review-prompt eligibility rule;
- fix a repeated onboarding trust confusion.

## Friday — ship/read out

Write five lines:

1. Hypothesis.
2. Change.
3. Expected result.
4. Observed result so far.
5. Next action / wait.

Do not interpret three days of noisy rank movement as proof unless the effect is overwhelming and the underlying metric is reliable.

### Metadata waiting period

Practitioners commonly report that metadata movement can take roughly **2–4 weeks** to stabilize, but Apple does not publish a guaranteed stabilization window. [S4]

Use 2–4 weeks as a **patience heuristic**, not as a law. A catastrophic relevance loss or obvious bug does not need to sit untouched for a month.

---

# 15. THE 30-DAY ZERO-AUDIENCE LAUNCH CALENDAR

| Timing | Action | Output / gate |
|---|---|---|
| **D-28 to D-21** | If pursuing editorial featuring, prepare and submit the App Launch nomination; Apple recommends at least three weeks' lead time | Optional featuring nomination |
| **D-21 to D-14** | Final 100–200 keyword pass; capture SERPs; identify primary + 3–7 secondaries | Keyword decision sheet |
| **D-14** | Lock title/subtitle/keyword control; run 5-second search-result test | Listing comprehension gate |
| **D-14 to D-7** | Target beta with 15–30 real users; fix category-specific trust/usability failures | Product is credible enough to earn reviews |
| **D-10** | Final icon + first 3 screenshots at real search size | Search-result package |
| **D-10 to D-5** | Configure App Store Connect metadata, analytics, purchases, support/privacy | Submission-ready |
| **D-7 to D-3** | Draft direct outreach + one permission-approved community launch post | No mass social plan required |
| **D-1** | Save keyword/rank/competitor baseline | Measurement baseline |
| **Launch day** | Release; verify store, purchase, ranking; notify qualified testers/contacts | Clean launch |
| **D+1 to D+3** | Reliability/support/reviews; no panic ASO changes | Technical gate |
| **D+4 to D+7** | Second targeted outreach; search-result comprehension test; first source read | Cold-start evidence |
| **D+8 to D+14** | Diagnose bottleneck; one experiment if justified | Visibility vs conversion vs product decision |
| **D+15 to D+28** | First deliberate metadata/creative iteration; consider one CPP after live | First ASO cycle |
| **D+28 to D+30** | Commercial review | Continue / expand / reposition / kill |

---

# 16. SPIRIT BOX — EXACT APPLICATION

This section is deliberately short because the revised Spirit Box ASO playbook already contains the exact current creative. [P0]

## 16.1 Keep

- `spirit box` as the primary money query unless the final bounded research pass materially contradicts the earlier AppTweak economics;
- exact `Spirit Box` phrase in the app name;
- current first-three-screenshot story:
  1. category;
  2. MARK action;
  3. replay payoff;
- trust messaging after the hero workflow;
- no false radio/RF/SB7 terms;
- one real free session before monetization;
- no dependency on Apple Ads or a social following.

## 16.2 Re-open before final metadata

Only one thing should be reopened:

> **Secondary-keyword economics.**

The current hidden field still contains terms such as `communication`, `research`, `audio`, `tool`, etc. Some may be weak character uses. The bounded final pass should test whether better exact-intent tokens exist.

For every candidate ask:

- Does a real user search this?
- Are top results weak enough?
- Does it combine with another valuable token?
- Does V1 actually satisfy the intent?
- Would ranking for it produce buyers, not merely impressions?

## 16.3 Do not overreach on EVP

`EVP` / `EVP recorder` can look attractive because the app records and replays sessions. But intent may be different: a person specifically searching for an EVP recorder may expect raw recorder-first functionality, not a spirit-box sweep.

**Cheapest test:** inspect that SERP and ask 5–10 EVP-focused target users whether the Spirit Box workflow is a legitimate result for that search.

**Kill criterion:** if users consistently see it as irrelevant or the top SERP is dominated by strong dedicated recorders, do not use premium metadata space on it.

## 16.4 Launch distribution

Use the prior Spirit Box acquisition plan rather than generic build-in-public:

- physical spirit-box / field-equipment users;
- EVP/audio investigators;
- existing paranormal-app users;
- organizer/mod-approved small communities;
- direct private outreach to skeptical reviewers and investigation teams. [P1]

Do **not** make X/Threads/Indie Hackers/Product Hunt activity a condition for launch.

## 16.5 First post-launch CPP

Do not pre-decide it.

After enough live data:

- if `ghost hunting` brings meaningful impressions but default conversion is mediocre, test an investigator-focused CPP;
- if a second query cluster has little traffic, do not build a CPP for it;
- if `spirit box` overwhelmingly dominates economics, keep focus rather than expanding for novelty.

## 16.6 App tags

As soon as App Store Connect assigns U.S. tags, inspect them. A wrong tag in this trust-sensitive category is worth correcting immediately. [A5]

## 16.7 iOS 27 creative-assets watch

Apple's new search-result rich media could be valuable for an instrument-like app because it creates more visual control directly in search. It is announced for fall 2026 / iOS 27 and may not yet be available in the account on launch day. [A7]

**Action:** check App Store Connect before final submission. If the feature is live, create **one** search-result asset centered on the field instrument + the core promise. If not, launch with the existing screenshot system.

Do not delay the app for it.

---

# 17. MAJOR RECOMMENDATIONS — BULL CASE, BEAR CASE, TEST, KILL RULE

## A. Organic-search-first launch

**WHY IT COULD WORK**  
The product targets existing exact App Store intent, and prior project data showed meaningful keyword-attributed installs even below #1 for `spirit box`. [P0]

**WHY IT COULD FAIL**  
The prior #1 entrant had adjacent category history; metadata alone may not reproduce its rank. Search demand may be smaller or more competitive by launch.

**WHAT WE KNOW**  
Apple explicitly uses relevance + user behavior, not metadata alone. [A1]

**WHAT WE INFER**  
A good listing plus a small target-user seed gives the app a fairer cold-start test without creating paid/social dependency.

**WHAT WE STILL NEED TO FIND OUT**  
Final September keyword/SERP state and live launch rank/impressions.

**CHEAPEST NEXT TEST**  
One bounded secondary-keyword pass + real search-result comp.

**KILL CRITERION**  
After multiple disciplined metadata/creative cycles, primary search produces too little qualified traffic/revenue to justify continued work.

## B. Target communities instead of generic build-in-public

**WHY IT COULD WORK**  
Audience quality is far higher; the project has already identified specific groups and investigator cohorts. [P1]

**WHY IT COULD FAIL**  
Promotional rules can block posts, and serious investigators may reject phone-based spirit boxes entirely.

**WHAT WE KNOW**  
Relevant communities exist, but several large paranormal subreddits prohibit solicitation. [P1]

**WHAT WE INFER**  
Permission-first, criticism-seeking outreach is more credible than launch spam.

**UNKNOWN**  
How many will convert from tester to public user/reviewer.

**CHEAPEST NEXT TEST**  
Recruit the first 10 qualified testers individually.

**KILL CRITERION**  
If the best-qualified users reject the core audio/product mechanism, do not solve the problem with more marketing.

## C. CPP expansion after launch

**WHY IT COULD WORK**  
Apple now supports organic keyword-linked CPPs. [A4]

**WHY IT COULD FAIL**  
Low traffic makes segmentation unnecessary and unmeasurable.

**WHAT WE KNOW**  
CPP creation requires the app to be Ready for Distribution in at least one territory, so it is not a pre-launch requirement. [A4]

**CHEAPEST NEXT TEST**  
Wait for one secondary cluster with measurable impressions/rank, then make one page.

**KILL CRITERION**  
No meaningful secondary cluster or no conversion difference.

## D. AI-assisted ASO operations

**WHY IT COULD WORK**  
It reduces repetitive research/formatting and keeps the process inside Cursor. [S1][S10]

**WHY IT COULD FAIL**  
Models can confidently hallucinate ASO metrics or promote vendor folklore.

**WHAT WE KNOW**  
The public skills can run standalone and can use Appeeky for live data if connected. [S10]

**CHEAPEST NEXT TEST**  
Install only the core ASO/keyword/metadata skills and feed them a known data export; compare output against the source rows.

**KILL CRITERION**  
If the agent cannot consistently preserve source values and distinguish verified vs inferred claims, use it only for clerical formatting.

---

# 18. ASO ANTI-PATTERNS — DO NOT DO THESE

1. **Do not choose a concept because a keyword is easy.**
2. **Do not equate tool popularity with actual monthly buyers.**
3. **Do not treat a high rank as success if the query sends negligible installs.**
4. **Do not target a keyword the product only partially satisfies.**
5. **Do not fill premium metadata with vague branding before category intent is secured.**
6. **Do not duplicate title/subtitle tokens in the keyword field without a specific verified reason.**
7. **Do not stuff the iOS description for App Store ranking.**
8. **Do not keyword-stuff screenshots for speculative OCR ranking.**
9. **Do not copy competitor visual trade dress because it "looks category-correct."**
10. **Do not use competitor trademarks as hidden keywords.**
11. **Do not launch with zero review-prompt logic and hope users rate spontaneously.**
12. **Do not prompt for reviews on first open or during a task.**
13. **Do not buy/incentivize reviews.**
14. **Do not read Apple Ads traffic as organic search.**
15. **Do not run Apple Ads without a question the spend is answering.**
16. **Do not create many CPPs before a second intent cluster exists.**
17. **Do not localize by machine translation alone and call it ASO.**
18. **Do not change metadata + icon + screenshots + pricing simultaneously unless the listing is so broken that attribution does not matter.**
19. **Do not declare an A/B test winner from inadequate traffic.**
20. **Do not preserve an app because development sunk cost makes killing it emotionally painful.**

---

# 19. ONE-PAGE OPERATING CHECKLIST

## Before build commitment

- [ ] Primary search job exists.
- [ ] Demand appears economically meaningful.
- [ ] Top results are beatable or poorly matched.
- [ ] Monetization/willingness to pay is plausible.
- [ ] The product can truthfully satisfy the query.
- [ ] No stronger simple opportunity has displaced it.

## Before App Store submission

- [ ] 100–200 candidate keyword pass complete.
- [ ] One primary + 3–7 secondary targets chosen.
- [ ] Launch SERPs saved.
- [ ] Title/subtitle/keyword field contain no waste/misleading terms.
- [ ] Correct primary/secondary category.
- [ ] Icon passes tiny-size test.
- [ ] Screenshot #1 confirms search intent.
- [ ] Screenshots #1–3 tell one causal story.
- [ ] Trust/pricing objections resolved later in sequence.
- [ ] Description is human conversion copy, not keyword stuffing.
- [ ] Review prompt fires after successful use.
- [ ] Analytics + purchase/activation events tested.
- [ ] 15–30 target beta users have used the real product.
- [ ] Severe review-killing bugs fixed.
- [ ] Featuring nomination submitted if appropriate.
- [ ] iOS 27 creative-asset availability checked; non-blocking.

## First month

- [ ] Live listing verified.
- [ ] Rank tracked for primary + serious secondaries.
- [ ] Search impressions/downloads monitored.
- [ ] Apple Ads separated from organic interpretation.
- [ ] Reviews responded to.
- [ ] One bottleneck diagnosed at a time.
- [ ] One major test/change at a time.
- [ ] CPP added only if real second intent exists.
- [ ] Commercial kill criterion reviewed at day 28–30.

---

# 20. SOURCE AUDIT — WHAT EACH SUPPLIED SOURCE WAS GOOD FOR

## Expo / ASO Skills

**Useful:** operationalizing audit → keyword research → metadata → creative/analytics in Cursor/agent workflows; open-source skill structure.  
**Do not inherit blindly:** hard ranking-weight claims and screenshot-indexing claims not confirmed by Apple.  
**Use:** automation layer on top of real data. [S1][S10]

## Sebastian Röhl / HabitKit

**Useful:** real indie example of protecting one major head term in the title, review timing, patience, and acknowledging luck.  
**Important negative lesson:** he explicitly does not know whether Apple Ads improved organic rank and described his own unmeasured CPA as poor.  
**Build-in-public:** context-specific, not proof of an App Store authority signal. [S3]

## Appfigures guides

**Useful:** wide keyword collection, competitor/review mining, popularity × competition × relevance, tracking, metadata hygiene, CRO.  
**Treat cautiously:** vendor reverse engineering such as screenshot semantic ranking, exact algorithm weights, new-app boost claims, or hard launch thresholds. [S2]

## Aurélien Weiss / 200+ indie audits

**Useful:** repeated indie failures: wasted title/subtitle, duplicate keyword field, impossible head terms, no tracking, no localization.  
**Correction:** "title + subtitle + keyword field — that's it" is incomplete; Apple explicitly adds category and user behavior.  
**Use:** checklist of common preventable mistakes, not algorithm specification. [S4]

## Phiture

**Useful:** the Keyword Optimization Cycle and disciplined experiment backlog; treating ASO as two linked jobs — visibility and conversion; cumulative learning over many iterations.  
**Not indie-portable:** enterprise experiment volume, localization scale and large-traffic A/B cadence. [S7][S8]

## SplitMetrics

**Useful:** real examples proving screenshot/icon/order conventions are audience-specific; common product-page failure modes; hypothesis-driven creative testing.  
**Do not copy:** headline uplift percentages from unrelated categories as forecasts for your app. [S5][S6]

## App Store Marketing

**Useful:** current 2026 intent-cluster framing, message-match, CPP segmentation, weekly one-hypothesis cadence, Apple Ads incrementality mindset.  
**Use:** operating system, not source of Apple algorithm facts. [S9]

---

# 21. SOURCES

## Apple — primary sources

**[A1] App Store Search**  
https://developer.apple.com/app-store/search/

**[A2] Creating Your Product Page**  
https://developer.apple.com/app-store/product-page/

**[A3] App Store Connect — Platform Version Information**  
https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information

**[A4] App Store Connect — Configure Multiple Product Page Versions / keyword-linked CPPs**  
https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions

**[A5] App Store Connect — Manage App Tags**  
https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags

**[A6] App Store Connect Analytics — Acquisition**  
https://developer.apple.com/help/app-store-connect-analytics/acquisition/acquisition

**[A7] WWDC26 App Store Guide / Enhance Your Presence**  
https://developer.apple.com/wwdc26/guides/app-store/  
https://developer.apple.com/videos/play/wwdc2026/205/

**[A8] App Store Connect — Localize App Information / App Store Localizations**  
https://developer.apple.com/help/app-store-connect/manage-app-information/localize-app-information  
https://developer.apple.com/help/app-store-connect/reference/app-information/app-store-localizations

**[A9] App Store Connect — Featuring Nominations**  
https://developer.apple.com/help/app-store-connect/manage-featuring-nominations/nominate-your-app-for-featuring/

## Supplied practitioner / industry sources

**[S1] Expo — ASO Skills: ASO in Your AI Workflow**  
https://dev.to/expo/aso-skills-aso-in-your-ai-workflow-3288

**[S2] Appfigures — ASO Guides**  
https://appfigures.com/resources/guides

**[S3] Sebastian Röhl — My App Store Optimization Strategy**  
https://sebastianroehl.substack.com/p/my-app-store-optimization-strategy

**[S4] Aurélien Weiss — I Audited 200+ Indie Apps for Free**  
https://medium.com/@a.weiss_97627/i-audited-200-indie-apps-for-free-80-make-the-same-aso-mistakes-657ca25a24e0

**[S5] SplitMetrics — 70+ App Store product-page audits**  
https://splitmetrics.com/blog/aso-mistakes-affecting-app-visibility-and-conversion-rate/

**[S6] SplitMetrics — screenshot/icon conversion case studies**  
https://splitmetrics.com/cases/olbg-ios-screenshots-optimization/  
https://splitmetrics.com/cases/skoda-a-b-tests-ios-screenshots/  
https://splitmetrics.com/cases/hobnob-app-optimizing-with-splitmetrics/

**[S7] Phiture — Pura Mente / Clue / case-study methodology**  
https://phiture.com/success-stories/puramente/  
https://phiture.com/success-stories/clue-case-study/

**[S8] Phiture — ASO Stack / Keyword Optimization Cycle**  
https://phiture.com/blog/applying-frameworks-to-accelerate-mobile-growth/  
https://phiture.com/resources/keywords-tool/

**[S9] App Store Marketing — ASO Guide 2026 / weekly checklist**  
https://appstoremarketing.com/guides/aso-guide/  
https://appstoremarketing.com/guides/aso-checklist/

**[S10] Eronred — aso-skills GitHub repository**  
https://github.com/Eronred/aso-skills

## Project sources

**[P0] APP STORE CONVERSION AND ASO PLAYBOOK — Revised September 10, 2026**  
Project file: `APP-STORE-CONVERSION-AND-ASO-PLAYBOOK-REVISED-2026-09-10.md`

**[P1] GHOST-SPIRIT-BOX-FIRST-USERS-ACQUISITION-PLAN**  
Project file: `GHOST-SPIRIT-BOX-FIRST-USERS-ACQUISITION-PLAN.md`

**[P2] APP PROFITABILITY — CURRENT SOURCE OF TRUTH**  
Project file: `APP-PROFITABILITY-CURRENT-SOURCE-OF-TRUTH-2026-09-02.md`

---

# 22. FINAL DECISION

The revised Spirit Box playbook should **not** be thrown out. Its September 10 correction is largely right: protect `spirit box`, make secondary terms prove their value, do not pretend Apple Ads is required, and keep unverified algorithm theories labeled as inference. [P0]

The missing piece was an **execution system**.

The launch should now be managed as:

> **one validated search intent → one strong default search result → a small cohort of qualified real users → source-level measurement → one controlled iteration → expansion only after evidence.**

No social following is required.

No paid acquisition is required.

No magic cold-start threshold is assumed.

But "no marketing dependency" must not be confused with "do nothing outside App Store Connect." A small amount of targeted human seeding is cheap insurance against a completely blind launch, gives the product a chance to earn legitimate ratings, and tells us whether poor results come from the product, the listing, the rank, or the market.

If economically useful organic search does not emerge after the app has had a fair, measured, iterated test, the correct response is to **kill or reposition the opportunity** — not to quietly turn it into a paid/social acquisition business that violates the original thesis.