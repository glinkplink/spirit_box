# Ironwork / Structural Steel iOS Niche Deep Dive

**Date:** 2026-09-10  
**Addendum:** 2026-09-11 — work-order / invoice / signed-extras hypothesis (Invoice Fly, Joist, Bead Board)  
**Role:** Exploratory commercial research. Supporting evidence. Does **not** override `docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md`.  
**Status of this file:** Research only. Do not treat as BUILD AUTHORIZED.  
**Evidence labels:** VERIFIED FACT / INFERENCE / SPECULATION / UNKNOWN.  
**Capture method:** US iTunes Search API (`country=us`, `entity=software`, 2026-09-10 and 2026-09-11) plus public web sources (BLS, App Store listings, vendor pricing pages, RSS customer reviews). Rankings are API order, not a guaranteed on-device SERP clone.

---

## Executive Verdict

**Calculators / AISC pocket apps: INTERESTING BUT SMALL** (unchanged).  
**Work-order + signed extras for solo/small-team welders: PROMISING — ONE CHEAP TEST.**  
**Cloning Invoice Fly: KILL.**

There is a real, paid, repetitive job in this industry — small fabricators and misc-metals shops already spend money on weight/quote math, pocket references, and (at the shop level) expensive estimating software. That is not the same thing as a better iPhone business than mileage, acreage, or Spirit Box.

**2026-09-11 correction:** The more interesting product is not a steel calculator. It is a **work-order / invoice tracker that gets extras signed before the torch comes back on**, for solo and small-team welders. Invoice Fly is what those people **find** when they type `welding invoice`. It is not the closest product to that job. Joist, Bead Board, Jobkore, and MyChangeOrder are.

What the evidence actually shows:

1. **Exact “ironworker app” search is a dead end.** It returns union locals, credit unions, and apprenticeship apps — not tools people pay for.
2. **The iOS tools that do exist are tiny.** After 10–17 years, the strongest dedicated steel apps have **113–323 US ratings**. Mileage leaders have **50k–113k**. Acreage leaders have **10k–13k**. Construction Master Pro (general trades, not steel) has **~40k**.
3. **People pay, but cheap.** Documented iOS prices cluster at **$2.99–$8.99 lifetime** or **$40–$48/year** for calculator bundles. The expensive money ($399/month, $1,500/year, $7,500 lifetime) sits in **desktop/B2B estimating**, which is not an App Store wedge.
4. **Android already absorbed the mass demand.** Google Play’s Metal Weight Calculator (Pixelsdo) has **1M+ downloads and ~49k reviews**, mostly free with ads. iPhone is the thinner, higher-ARPU slice of a job that is already “solved enough.”
5. **A new competitor (Fabora) is running the exact “21-tool steel/fab bundle at $47.99/year” test right now** (launched 2026-07-30; **2 US ratings** as of this capture). We do not need to build in order to watch that experiment.

**Do not prioritize ironwork.** Profitability > familiarity. The industry is real; the reachable iPhone product is a durable indie utility with a plausible ceiling in the **low-to-mid four figures per month**, not a $20k+/month business without turning into B2B sales.

---

## Market / User Map

### Who these people actually are

| Role | What they do on a phone | Who pays for software | iPhone-product relevance |
|---|---|---|---|
| Union ironworker (raising gang, connectors, rod busters) | Look up weld symbols, bolt grades, rebar weights; take photos; text the foreman | Almost never the worker. Union/employer/GC tools. | Low. `ironworker app` SERP is union-local apps. |
| Non-union erector / small steel sub | Same field lookups + daily notes + delivery photos | Owner might buy a $10–$50 tool | Medium. Small crews, weak software. |
| Structural steel fabricator (AISC shop) | Shop uses Tekla/PowerFab/STRUMIS; estimator uses Bluebeam + Excel | Company. $10k–$100k systems. | Low for V1. High for a different company. |
| Miscellaneous metals / ornamental / railing / stairs shop | Measure openings, space pickets, quote rails/stairs, cut lists | **Owner-operator. This is the App Store buyer.** | Highest. |
| Welding/fabrication crew (job shop, mobile welder) | Weight, cut length, settings charts, quote a small job | Worker or owner | High for calculator/quote; low for CAD. |
| Foreman | Hours, tonnage, delays, photos, punch | Employer platform (Raken/Procore) or paper | Daily-report wedge is tempting; collaboration explodes scope. |
| Estimator / PM | Takeoff from PDFs, labor hours, coatings, freight | Company. Bluebeam $330–$590/user/year. | Not an iPhone V1. |
| Detailer / field engineer | Section properties, connection geometry | Company + AISC Manual (~$350–$450) | Reference apps exist; design liability is high. |

**VERIFIED FACT (BLS Occupational Outlook, 2024):**

- Structural iron and steel workers: **~65,700** jobs; median wage **$62,700**.
- Reinforcing iron and rebar workers: **~19,400**.
- Combined ironworker-class occupations in the OOH table: **~85,100**.
- Structural metal fabricators and fitters: **~53,800** (projected **down** ~16% by 2034).
- Welders, cutters, solderers, and brazers: **~457,300** jobs (most in manufacturing, not structural erection).
- Fabricated metal product manufacturing establishments (NAICS 332): **~61,000**.
- AISC membership page: **>35,000** members (fabricators, engineers, producers, students — not 35,000 shops). AISC member directory search returned **2,284** company results on capture.

**INFERENCE:** The people who will buy an iPhone app with a credit card are **not** 65,700 union ironworkers. They are **owner-operators of small fab / misc-metals / ornamental / mobile-welding shops**, plus a subset of estimators and layout fitters who already carry a phone. That reachable set is thousands, not hundreds of thousands.

### The actual mobile jobs (ranked by how often a phone is already in the hand)

1. **Look up a shape and get lb/ft, then multiply by length and quantity.** Pocket card, AISC PDF, mill chart, or a free calculator.
2. **Quote a small job from the truck:** plate/bar/tube/rail pieces → weight → $/lb → tax/delivery fudge → text the number.
3. **Layout geometry:** stair rise/run, stringer, picket/baluster spacing, hole centers.
4. **Weld/bolt field reference:** symbols, electrode, wrench size, hole size. Paper handbook or Miller/Hobart free apps.
5. **Photo proof:** deliveries, welds, extras, damage. Camera roll + text. Not a product until a GC demands a named report.
6. **Hours / daily log.** Paper, Notes, or the GC’s Raken/Procore.
7. **Full structural takeoff.** Desktop. Not mobile.

**VERIFIED FACT:** A working ironworker (Antonio Pebworth) posted on r/Ironworker in 2026 that he “got tired of not having a good field app,” shipped **Ironworker Pro** ($2.99, Capacitor wrap, offline), and the first trade-forum replies asked for **rigging load limits and rebar/iron weight**, and noted it looked **welding-heavy**. US ratings on capture: **6**. That is primary evidence of felt need **and** of how small the paying response is.

---

## Existing Software & Economics

Do not infer revenue from ratings. Ratings are an adoption/time-in-market proxy only.

### iOS products that actually map to this trade

| Product | Exact job | Platform | Pricing (listing) | US ratings (2026-09-10) | Company / size signal | Revenue evidence | Mobile quality | Acquisition |
|---|---|---|---|---|---|---|---|---|
| **Steel Profiles** (Matteo Rossi / theolternative) | AISC/EU/UK/CISC/AS section properties + weight lists | iPhone/iPad/Mac | Free; IAP **$2.99/library**, **All libraries $4.99** | **323** @ 4.65★; first release **2012** | Solo/small; also WiFiPhoto, Livesick (unrelated) | **UNKNOWN.** 14 years × cheap IAP. Not a $10k/mo signal. | Strong for engineers; updated 2026-03 with AISC 16 | App Store exact `steel shapes` / `steel sections` |
| **[steel shapes]** (jesus homes) | Full AISC shape database, historic editions, PDF sheets | iPhone/iPad | **$4.99 paid** | **113** @ 4.81★; first release **2009**; updated 2026-05 | Tiny paid specialist, 17 years | **UNKNOWN.** Longevity + paid price = durable demand, small scale. | Reviews: “pocket Steel Manual”; wants fractions | App Store `steel shapes`, `AISC shapes` |
| **Steel Profiles AISC** (same Matteo Rossi) | AISC-only paid sibling | iOS | **$2.99** | **33** @ 4.67★; last update **2017-09** | Same solo | UNKNOWN | Stale sibling of the free+IAP app | Cross-promo |
| **steelyard** (Mohamed Saad) | Metal mass + cost | iPhone | Free + IAP (**Ad Blocker $9.99** listed) | **298** @ 4.71★; 2017–2026 | Small; also Metal+ (12 ratings) | UNKNOWN. Reviews beg to **pay to kill ads**. | Field-oriented; ads destroy it | `steel calculator`, `metal weight` |
| **Weight calculator for metals** (Electronial) | Shape × density × units | iOS | Free | **263** @ 4.13★; last update **2022-12** | Small | UNKNOWN | Imperial missing/broken; ads; stale | `steel weight calculator` |
| **Metal Weight Calculator App** (Valaji Global) | Same | iOS | Free | **153** @ 4.63★; last update **2024-05** | Clone-mill pattern (also Steel Weight Calculator, 62 ratings) | UNKNOWN | Ads | Generic keywords |
| **Fabora: Steel & Metal Tools** (jason bennett) | 21-tool fab bundle: weight, sections, weld, stairs, quotes, DXF | iOS | Free 6 tools; **Pro $5.99/mo or $47.99/yr** (US listing) | **2** @ 4.5★; released **2026-07-30** | One-person / tiny; faboraplatform.com | **Too new.** This is the live test of the bundle thesis. | Ambitious, offline, no account | New; UK-leaning libraries + US AISC |
| **Ironworker Pro** (Antonio Pebworth) | Field reference: weld symbols, settings, construction calc, job log | iOS | **$2.99** paid, no sub | **6** @ 5★; released **2026-06** | Built by a working ironworker | UNKNOWN. Trade-forum launch. | Capacitor; welding-weighted | Reddit / trade forum |
| **Baluster Calculator Elite** (Cyberprodigy LLC) | Picket/baluster spacing, flat + rake | iOS | **$8.99** paid | **363** @ 4.88★; 2013–2026 | Trade-calculator portfolio (Crown, Conduit, Concrete, Duct “Elite” apps) | UNKNOWN. Best **paid narrow-job** analogue. Mixed carpenter/DIY/fab. | Simple; missing edge-of-picket marks | `railing calculator`, `handrail calculator` |
| **Stair Calculator: Construction** (Phan Nhat Đang) | Rise/run/stringer | iOS | Free + sub (complaints) | **739** @ 4.12★ | Indie | UNKNOWN | DIY/carpenter, not steel fab | `stair calculator` (generic) |
| **RedX Stairs** | 3D stair design + PDF | iOS | Sub; reviews cite **~$59/year** and trial traps | **409** @ 4.48★ | Small product company | UNKNOWN. Subscription backlash. | Overbuilt for field; wood-stair bias | `stair calculator` |
| **Stair Stringer** (H3Apps) | Stringer layout | iOS | **$1.99** | **86** @ 4.72★ | Tiny | UNKNOWN | GCs like the diagram | `stair layout` |
| **Construction Master Pro Calc** (Calculated Industries) | Feet-inch-fraction construction math, stairs, roofs | iOS | Free trial; **$4.99/mo or $39.99/yr** | **39,716** @ 4.84★; claims **1.12M downloads** | Incumbent hardware brand (physical 4065 MSRP **$74.95**) | Brand + hardware funnel. Not steel-specific. | Excellent math; **subscription hate** is the #1 review theme | Brand search + 40 years of jobsites |
| **Flange Bolt Size & Torque** | ASME flange bolt charts | iOS | Free → **subscription (~$5/mo)** per reviews | **370** @ 4.58★ | Small | UNKNOWN. Users: “I use this constantly” then rage at sub. | Pipefitter, not ironworker | Trade search |
| **Unravel: Steel Calculator** (Majestic Steel USA) | Coil/sheet mill calculator | iOS | Free (supplier app) | **10** @ 4.9★ | Steel distributor marketing | Not a product business | Narrow coil job | Installed by customers of the mill |
| **Deflection** (Ketchep) | Beam deflection | iOS | **$4.99** | **115** @ 4.57★ | Tiny | UNKNOWN | Engineers; **HIGH liability** if used as design | `beam calculator` |
| **Raken** | Construction daily reports / time / photos | iOS | Quote-based SaaS (third parties guess ~$15–$80/user/mo; **not verified**) | **22,266** @ 4.75★ | Serious field-SaaS company | Company-pays. Not steel-specific. | Excellent at the generic daily-report job | Sales + GC mandate |
| **Miller / Hobart Weld Setting Calculator** | Weld machine settings | iOS | Free | 79 / 9 | Miller Electric | Marketing, not indie revenue | Fine, brand-trusted | Brand |

### Desktop / SaaS (where the real steel money is)

| Product | Job | Pricing | Relevance to an iPhone V1 |
|---|---|---|---|
| **Bluebeam Revu** | PDF takeoff/markup | **$330 Core / $440 Complete / $590 Max** per user/year (bluebeam.com/pricing, 2026) | Estimators already pay this. An iPhone app does not replace it. |
| **SteelFlo** | AI PDF steel takeoff + pricing | **$399/month** published | Proves shops will pay **company** prices. Not App Store. |
| **MiscMetal Estimator Pro** | Misc-metals estimating | **$1,500/year + $1,797 setup**, or **$7,500 lifetime** (metal-estimator-pro.com) | Strongest proof that **misc metals quoting is expensive**. Desktop, shop-level. |
| **RailEstimate Pro** (estimate-pro.com) | Railing/stair fab estimating | Marketing site; **exact public price UNKNOWN** | Same job, shop software. |
| **Kreo** | AI takeoff (generic) | **$35–$175/user/month** | Not steel-native. |
| **STACK** | Takeoff + estimate | **$249–$299/user/month** billed annually | GC/sub platform. |
| **Tekla PowerFab / STRUMIS / FabSuite lineage** | Fab ERP + estimating | Quote-based; industry writeups treat year-one as **five to six figures** | Employer software. Out of scope. |
| **Metal Building Bid Wizard** | Metal building estimating | **$597/seat** one-time (vendor page) | Adjacent, not ironwork field. |
| **StairBiz / Staircon** | Stair manufacturing CAD/CAM | Custom / CNC-tied | Wood stair factories, not iPhone. |

### Android (demand proxy the iPhone SERP hides)

**VERIFIED FACT:** Google Play **Metal Weight Calculator** by Pixelsdo: **1M+ downloads**, **~48.9k reviews**, 4.8★, **free**, offline. **Steel Weight Calculator** by despDev: **500k+ downloads**, ~5k reviews. AppBrain for despDev: **~910 downloads in the last 30 days** (~30/day) on a mature free app.

**INFERENCE:** The metal-weight **job** is globally real and mostly satisfied by **free Android calculators with ads**. iOS rating counts (150–300) are not “an undiscovered goldmine”; they are the **paid/Western/iPhone remainder** of a job Android already commoditized.

### Developer forensics (do not mistake portfolio for niche demand)

- **Matteo Rossi:** Steel Profiles is the real product; WiFiPhoto and Livesick are unrelated. Niche demand is organic enough to keep updating AISC 16 in 2026, but the rest of the portfolio is not a steel audience machine.
- **Cyberprodigy:** A **construction-calculator mill** (Baluster, Crown, Conduit Bender, Concrete, Duct). Baluster’s 363 ratings are partly **portfolio + carpenter/DIY**, not proof of a structural-steel audience.
- **Calculated Industries:** 40-year hardware brand. App downloads are **brand transfer**, not ASO white space.
- **Valaji / several 2023–2026 weight apps:** Clone-mill keyword stuffing. Same pattern as Spirit Box SERP junk.
- **Fabora (jason bennett) and Ironworker Pro (Antonio Pebworth):** Genuine 2026 attempts by tiny builders to occupy this exact gap. Both have **single-digit ratings**. That is the cold-start.

---

## Search Intent

No third-party search-volume numbers were purchased. **Do not invent volume.** What follows is SERP composition from the 2026-09-10 iTunes Search API.

| Query | User intent | What actually ranks | Exact vs generic | Do small apps rank? | Commercial relevance | Likely to pay? |
|---|---|---|---|---|---|---|
| `ironworker app` | Union member services | IW Mobile, apprenticeship, IMPACT, **local union apps**, credit union. Ironworker Pro is **#10** with 6 ratings. | **Wrong intent** | Yes, but they are locals | Near zero for a tool | Union dues, not IAP |
| `ironworker calculator` | Ambiguous | Generic calculators + Construction Master + Miller | Contaminated | No steel-native #1 | Low | Unclear |
| `steel calculator` / `steel weight calculator` / `metal weight calculator` | Weight of a piece | Mix of dedicated weight apps (Valaji, Electronial, steelyard) **and** generic calculators | Partial exact | Yes — this is the accessible steel SERP | Medium | Some; many expect free |
| `steel shapes` / `steel sections` / `AISC shapes` | Look up a W12x50 | **Exact:** [steel shapes], Steel Profiles, CSiSteel | **Best exact-intent cluster** | Yes, and they are old paid/IAP apps | Medium-high for engineers/detailers | **$3–$5 proven** |
| `AISC shapes` | Same, but polluted | #3 onward is **children’s shape games** | Head is exact; tail is garbage | The two steel apps still occupy #1–#2 | Medium | Yes, if they meant AISC |
| `steel estimating` / `steel takeoff` | Bid a job | Hover, SimplyWise, Xactimate, Steel Profiles, knife-steel chart | **Wrong / polluted** | Dedicated steel estimators **do not exist** in the top 12 | High intent, zero iOS product | Desktop money, not here |
| `beam calculator` | Often **structural design** | SkyCiv, Deflection ($4.99), hobby apps | Mixed; liability | Tiny apps rank because volume is low | Medium | Engineers; **HIGH risk** |
| `stair calculator` / `stair layout` / `stringer calculator` | Rise/run/stringer | Strong cluster, **739 + 409 + 86** ratings | Exact, but **carpenter/DIY** | Yes | Medium | Yes, $2–$60; mixed DIY |
| `railing calculator` / `handrail calculator` | Picket spacing | **Baluster Calculator Elite $8.99** then generic calculators | Partial | The $8.99 app is #1/#2 | Medium | **Yes at $9** |
| `welding calculator` / `weld calculator` | Machine settings | Miller/Hobart free brand apps; 2026 clones with **0 ratings** | Brand-captured | Clones do not stick | Low for indie | Free expected |
| `weld log` | Inspection record | Games, Miller, Weld.com, ELD apps | **No product** | No | Compliance job | Company |
| `rigging calculator` / `crane rigging` | Sling angles, loads | Mostly **0-rating 2026 apps** + hated Crane & Rigger (1.4★) | Exact, tiny | Yes because empty | High WTP **if trusted** | **HIGH liability — do not build** |
| `construction daily report` | Field diary | **Raken 22k**, Fieldwire 13k, plus tiny indies | Exact, **generic construction** | New AI daily-report apps exist with 0–7 ratings | High for companies | Employer |
| `steel erection` / `anchor bolt` / `field layout` / `bolt calculator` | Trade tasks | Contaminated (boat anchors, photo layouts, generic calcs, games) | Mostly useless | N/A | Low as keywords | No |

**INFERENCE:** The only **clean, trade-relevant, small-app-accessible** iOS queries are `steel shapes` / `AISC shapes` / `steel weight calculator` / `metal weight calculator`, plus adjacent `stair` and `railing` which are **not uniquely ironwork**. There is no empty `ironworker` keyword waiting.

---

## Review-Mined Pain

Pattern: **“I use this constantly, but I hate X.”** That is the wedge language. Generic 1-stars are cheaper to ignore.

### Steel / metal calculators

- **Ads make a good app unusable.** steelyard: “This app is incredible… HORRENDOUS ads… Please release a paid app.” Electronial / Valaji: same.
- **Imperial vs metric.** Electronial 2026: “No option for imperial.” Other reviews: defaults reset to metric every change; “UA Pipefitter/Welder” couldn’t run a 20' stick of 4x4x½ angle.
- **Units and keypad.** Keyboard covers results; can’t lock lb/in/ft; want **feet-inch-fraction**, not 1.25.
- **Wrong or stale math.** “Calculations were simply wrong… tested against known standards.” Indian sections removed (user: “If purchase required I am ready to pay”).
- **Want a project, not a one-shot.** Unravel (coil) users asked to save/load calculations in 2013. Still the gap.

### Steel Profiles / [steel shapes]

- Retired ironworker / layout fitter: “wish I had this app… Saves time & materials when detailing my own jobs.”
- Local 401 ironworker: “comes in handy, when doing detail work.”
- “Kinda like having a pocket Steel Manual.” “With this app and the AISC downloaded as a PDF you are good to go for iron.”
- Want **fractions**, not decimals. Gage-line glitch after an update.

### Baluster / railing (mixed carpenter + fab)

- Contractor: “Worth the 9 bucks.”
- Stair/rail installer: tested on **iron balusters**, “worked perfectly.”
- Steel fab: “elite metals… for my railing pickets this is perfect.”
- Hate: centers vs **edge of picket**, 1" width cap, 1/16" resolution, 200" run cap, rake/tread mark-out.

### Construction Master / RedX / Flange Bolt (pricing psychology)

- Calculated Industries moved a beloved **once-paid** calculator to **$39.99/year**. Reviews: “$40 a year for a calculator?” “I would rather pay once.” Physical 4065 is **~$65–$75 once**.
- RedX Stairs: trial → **~$59/year**, “scam,” lockout of saved work when sub ends.
- Flange Bolt: “I use this app at least once a week… I would’ve paid a **flat price**… I’m not paying every month… I can check my handy book.”

**INFERENCE:** This audience will pay **once** for a tool that replaces a book or a $75 hardware calculator. They **punish subscriptions** for settled math. Fabora’s $47.99/year is therefore swimming against documented preference unless the workflow (quotes, projects, export) is clearly more than a calculator.

### Crane & Rigger (liability + trust collapse)

Years of 1-stars: load charts wrong for the actual crane, subscription after a paid purchase, app dead after domain expiry. **Do not enter rigging.**

---

## High-WTP Workflows

Ranked by willingness to pay **for an individual or owner-operator on the App Store**, not by industry software budgets.

| Rank | Job | Why money exists | Why it still may not be *our* money |
|---|---|---|---|
| 1 | **Misc-metals / railing / stair shop quoting** (desktop) | MiscMetal Estimator Pro **$1,500/yr + $1,797 setup** or **$7,500 lifetime**. SteelFlo **$399/mo**. | B2B, PDF takeoff, assemblies, labor libraries. Not V1 iPhone. |
| 2 | **Bluebeam-class plan takeoff** | **$330–$590/user/year**, standard estimator tool. | Desktop/Windows-first. Replacing it is a company. |
| 3 | **Physical construction calculator** | Construction Master Pro **~$75**; workers already buy it. App sub **$40/yr** with 40k ratings. | Brand-captured; not steel-specific; subscription fatigue. |
| 4 | **Pocket steel reference** | AISC Manual **$350–$450**; IMPACT Ironworker Foreman Pocket Guide historically **$15**; Structural Steel Detail **wheel $18**; SSTC Welding Quality Handbook **$25**; Audel Welding Pocket **~$23–$27**. | Manual is for engineers; cheap cards already exist; iOS replacements sell for **$3–$5**. |
| 5 | **Baluster/picket layout** | **$8.99** with 363 ratings; contractors call it worth it. | Mixed DIY; 13-year incumbent; not a $20k/mo ceiling. |
| 6 | **Weight → $/lb → quote on the phone** | Reviews offer to pay; shops live on this math; scrap/fab/mobile welders. | Free Android 1M; iOS already has steelyard/Fabora/Valaji. WTP likely **$10–$50 once** or **~$40/yr**. |
| 7 | **Daily steel erection report** | GCs pay Raken. Extra work billed from photos. | Employer purchase; team backend; generic tools exist. |
| 8 | **Rigging / crane** | Mistakes cost lives and claims; people *would* pay. | **Disqualified.** |

**Smallest product that could make $20–$100 feel trivial:** a shop owner quoting a $4,000 rail job from the parking lot, who currently rebuilds an Excel row or guesses weight. Saving **one missed stick of material or one under-bid** pays for a year of software. That is a **shop** story, not an App Store volume story.

---

## 10 Product Hypotheses

Scores: H / M / L. Revenue ceiling is **App Store / individual or tiny-shop**, not enterprise.

| # | Hypothesis | Demand | WTP | Competition | Acquisition | Build | Maint. | Liability | Ceiling | Decision |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | **Steel weight + project takeoff + PDF quote** (shape, length, qty, $/lb, tax, share) | M | M | H (steelyard, Fabora, Android 1M) | M (`steel weight`) | L–M | L | L | ~$3–10k/mo if lucky | **Keep as best ironwork candidate; still small** |
| 2 | **AISC pocket shapes + favorites + weight** | M (exact query) | L–M ($3–$5 proven) | H (Steel Profiles, [steel shapes]) | M | M (data) | M (edition updates) | L–M (if you imply design) | <$5k/mo | Park. Licensing + incumbents. |
| 3 | **Railing / picket / baluster layout for metal** (edge marks, rake, iron pickets, material list) | M | M ($9 proven) | M (Cyberprodigy; carpenter-skewed) | M-L | L | L | M (ADA 4" sphere — disclose, don’t certify) | <$5k/mo | Interesting niche; not enough ceiling |
| 4 | **Misc-metals estimator (assemblies, labor, galvanizing)** | H (shop budgets) | **H** | M (MiscMetal $7.5k, Excel) | L (sales) | **H** | H | L–M | Could be $20k+ **as B2B** | **Kill as iPhone V1** |
| 5 | **Stair stringer + metal stair layout** | M | M | H (RedX, Stair Calculator, CMPro) | M (but DIY) | M | M (code tables) | M | <$5k/mo | Kill; carpenter market, subscription graveyard |
| 6 | **Steel erection daily report** (tonnage, bolts, welds, delays, PDF email) | M | M (if owner) | H (Raken 22k) | L | M → **H** if teams | H | L | Unknown; support-heavy | Kill for solo App Store |
| 7 | **Weld log / inspection record** | M (compliance) | H (company) | L on iOS | L | H (records, signatures) | H | H | B2B | Kill |
| 8 | **Bolt / wrench / hole / fillet-weld field charts** | M | L | M (handbooks, Fabora, Miller) | L | L | M (standards) | M | Tiny | Kill; $25 book exists |
| 9 | **Rigging / sling / crane calculator** | M | H | L (graveyard) | M | M | H (charts) | **H** | Irrelevant | **Kill hard** |
| 10 | **Beam / connection / load design** | M | H | M (SkyCiv, Deflection) | M | H | H | **H** | Don’t care | **Kill hard** |

---

## Candidates Killed

| Candidate | Kill reason |
|---|---|
| “Ironworker app” as a brand/query | SERP is union infrastructure. |
| Generic steel calculator with nicer UI | Android 1M free; iOS ads/clones; **kill criterion 10**. |
| Full structural estimating / PDF AI takeoff | CAD/BIM/plan-recognition; **kill criterion 4**; SteelFlo already at $399/mo. |
| AISC-complete engineering manual on a phone | Copyright/licensing; [steel shapes] already did it for $4.99. |
| Rigging, crane, structural design, code-compliance stamps | Liability disproportionate. |
| Daily report / weld log as a network product | Backend, teams, employer sales (**kill criterion 5**). |
| Welding-settings calculator | Miller/Hobart give it away. |
| Stair calculator for carpenters | Crowded, DIY, not ironwork. |
| Subscription for settled math | Documented 1-star pattern (CMPro, RedX, Flange Bolt). |

---

## Top 3

### 1. Fabricator weight → cost → project quote (best ironwork candidate)

**Exact user:** Owner-operator of a small fab / ornamental / misc-metals / mobile-welding shop. Sometimes a working fitter quoting extras from the truck.

**Who pays?** The owner, personally, App Store. Employer reimbursement plausible but not required.

**Exact job:** Customer texts an opening or a cut list. User picks material and shape, enters length × qty, sees pounds, types $/lb (and maybe a labor lump), gets a number they can PDF/text. Repeat for 8 line items. Save as “Johnson stairs.”

**Immediately before opening:** Standing in a driveway or at a saw, tape in one hand.

**Workaround today:** Phone calculator + memory of 40.8 lb/ft; Excel on a dirty laptop; mill PDF; steelyard with ads; Notes app.

**Competitors:** steelyard, Fabora, Valaji/Electronial, web calculators, Excel. **Not** Tekla.

**Money:** Reviews explicitly offer to pay to remove ads. Shops already pay **$1,500–$7,500** for full estimating (different product). Physical Construction Master **~$75**. Credible iOS price: **$19.99–$39.99 lifetime** or **$29–$49/year** if projects/PDF are the product.

**Search/distribution:** `steel weight calculator`, `metal weight calculator`, `steel calculator`. Facebook fab groups, welding YouTube, supplier counter — **not** a machine, but real. First 100 users: welding/fab Facebook groups + r/Welding + supplier PDF one-pager, **if** the groups tolerate it.

**Differentiation:** Not the formula (density × volume is public). The **job file**: line items, running tons, $/lb remembered per material, feet-inch-fraction, offline, **no ads**, PDF/text quote, imperial-first. Fabora is already shooting this bundle.

**V1:** 12 shapes × common metals; user $/lb; project list; share sheet PDF; no account; no live steel-price API.

**Ship this month?** Yes, if we steal no AISC design tables and use geometry + published densities + user-entered W-shape lb/ft.

**Maintenance:** Low unless we chase every mill catalog.

**Liability:** Low if labeled “material estimate, not structural design.” Wrong weight on a quote loses money, not a building.

**Ceiling:** **No evidence** this becomes $20k/month on the App Store. Optimistic model in Revenue Ceiling section tops out near **$5–10k/month** with heroic share.

**Bear case:** Fabora + steelyard + Android free already exist; users won’t pay $40/year for math; iOS SERP is clone-choked; we have no fab audience.

**Cheapest test:** Do **not** code. Track Fabora’s US rating count for 90 days. Read 50 steelyard/Electronial reviews (already done: ads + imperial). Ask 10 shop owners whether they pay for a phone quote tool or keep Excel.

**Kill criterion:** Fabora still <50 US ratings by ~2026-12-31 **and** 8/10 owners say they would not pay $30/year.

### 2. Metal railing / picket layout + cut list

**Exact user:** Misc-metals / ornamental installer or small rail shop. Overlap with finish carpenters (contaminates demand).

**Who pays?** Installer or shop owner. **$8.99** already proven.

**Exact job:** 14'6" balcony, ¾" iron pickets, 4" max gap, rake on the stair. Need mark-out list **to the edge of the picket**, not just centers.

**Workaround:** Tape + division, Baluster Calculator Elite, carpenter apps.

**Competitors:** Cyberprodigy $8.99 (363 ratings) — gaps in edge marks, width limits, resolution.

**Money:** “Worth the 9 bucks.” Elite metals review is actual fab. Ceiling of a $9 tool with 363 ratings after 13 years is a **lifestyle product**.

**Search:** `railing calculator` is generic-calc polluted; Baluster still ranks. Distribution via stair/rail Facebook groups.

**V1:** Flat + rake, imperial fractions, iron picket widths, edge *and* center, export mark list. No ADA “certification.”

**Ship this month?** Yes.

**Liability:** Medium. Spacing errors fail inspection; do not claim code compliance.

**Ceiling:** Below Spirit Box’s hoped $10k/month unless expanded into full railing **estimating** (then see hypothesis 4).

**Bear case:** Cyberprodigy is “good enough”; many users are DIYers; ironwork-specific volume is a slice of 363 ratings.

**Cheapest test:** Message 20 ornamental/rail shops: “Do you pay for Baluster Elite? What’s wrong?” If they don’t know the app, demand is not searching.

**Kill criterion:** Cannot find 10 US metal-rail shops that currently pay for *any* layout app.

### 3. Pocket steel shapes reference (AISC-class)

**Exact user:** Detailer, PE, layout fitter, estimator who is tired of the 4-lb manual.

**Who pays?** Individual. **$2.99–$4.99** for 17 years.

**Exact job:** “What’s the flange width and lb/ft of W16x26?”

**Workaround:** AISC PDF, Steel Profiles, [steel shapes], mill card, the wheel calculator ($18).

**Competitors:** Two long-lived paid apps **and** Fabora’s free section library (listing claims 1,660 AISC shapes).

**Money:** Proven and **tiny**. 113 + 323 ratings is the market speaking.

**Licensing:** AISC Shapes Database is **copyrighted**. Site license is personal/internal/noncommercial. Commercial reprint of manuals needs **advance written permission** (aisc.org copyright permissions). Do **not** embed the official tables without a rights basis. Geometry-based weight for plate/bar/tube is fine; copying AISC property tables is not.

**V1 without the tables:** User-typed designation + **user-entered** lb/ft, plus public mill dimensions where independently sourced. That is a worse product than the incumbents.

**Ceiling:** Capped by $5 price and 17 years of evidence.

**Kill criterion:** Already killed as a growth business. Keep only as a module inside #1, using non-AISC-copied data.

---

## Best Ironwork Opportunity

**Steel/metal weight + saved project + simple quote export** for small fabricators and misc-metals owner-operators.

Not because it is a large opportunity — because it is the **only** intersection of: low liability, iPhone-present job, documented “I’ll pay,” V1 in weeks, and no need to become a construction-SaaS company.

It is still **smaller than we need**.

---

## Acquisition

### How this trade actually finds tools

| Channel | Reality |
|---|---|
| App Store search | Works for `steel weight` / `steel shapes`. Volume **UNKNOWN**, but rating stocks imply **thin**. |
| Google | Web calculators (often free, ad-supported) steal the casual query. |
| Reddit | r/Ironworker, r/Welding: occasional “I built an app” posts. r/Ironworker helped Ironworker Pro to **6 ratings**, not 6,000. |
| Facebook trade groups | Real concentration of shop owners. Also hostile to spam. Repeatable only with genuine useful posts and reputation. |
| YouTube welding/fab creators | Possible seeding (same shape as Spirit Box investigator seeding). Not a flywheel unless we become a channel. |
| Union / apprenticeship | They ship their **own** apps (IW Mobile). Not a distribution partner for an indie calculator. |
| Suppliers / steel service centers | Majestic Steel’s Unravel has **10 ratings** after 15 years. Supplier apps do not automatically become products. |
| Trade shows (NASCC) | AISC conference app exists. Booth sales = B2B motion. |

**First 100 qualified users (if we were testing, which we should not, yet):** 20 shop-owner conversations from public directories / groups; 1 honest demo video to fab YouTube commenters who already complain about Excel; App Store listing on exact weight keywords. That is **manual seeding**, same cost class as Spirit Box, with a **worse** exact-intent keyword.

**INFERENCE:** A niche can survive low keyword volume **if** ARPU is high. Here ARPU is **not** high enough on the App Store to offset the thin funnel. High ARPU lives in MiscMetal/SteelFlo, which require sales.

---

## Monetization

**Match documented preference:** paid unlock or lifetime. Do not lead with subscription for a calculator.

| Model | Fit |
|---|---|
| $9.99–$19.99 lifetime | Matches Baluster / “I’ll pay to kill ads.” Easy. Ceiling death. |
| $39.99 lifetime | Plausible if PDF quotes + projects are excellent. Still one-shot economics. |
| $39–$49/year | Fabora/CMPro territory. Review history says trades **resent** this for math apps. Only if the product is clearly a **quoting workbook**. |
| $79–$149/year | Justified for shop estimating. Buyers then expect assemblies, labor, support — i.e. B2B. |
| $20–$100/month SaaS | Real in this industry. **Wrong company shape** for this repo’s indie iPhone constraint. |

**Who pays:** Prefer **small owner**. Union journeyman is the wrong customer. Company deployment (Procore/Raken) is the wrong motion.

---

## Build Scope

If — contrary to the verdict — a V1 were specified:

**In**

- Offline.
- Imperial-first, feet-inch-fraction.
- Plate, bar, tube, pipe, angle, channel; W-shape via **user lb/ft** (the designation *is* the weight).
- Density table for CS / SS / Al (public engineering data).
- Line-item project, running weight, user $/lb, share PDF/text.
- Huge buttons, no account, no ads.

**Out**

- AISC design properties (Ix, Sx, r) unless licensed.
- Live steel price feeds.
- PDF plan takeoff / AI.
- Rigging, loads, code stamps.
- Team accounts.
- AWS D1.1 copyrighted tables.

**Build time:** A focused engineer could ship the in-list in well under a month. That is not the hard part. **Demand is.**

---

## Liability / Data / Licensing

| Area | Risk | Rule |
|---|---|---|
| Weight / quote | Low | Disclose estimate only. |
| Layout spacing | Medium | No “meets IRC/ADA” claim. Show the 4" sphere as a **user-entered max gap**. |
| Weld settings | Medium | Point at WPS / mill charts; Miller already owns trust. |
| AISC database | Legal | Need written permission or independent mill data. **Do not ship copied Manual tables.** |
| AWS / AISC specs | Legal | Pocket handbooks are licensed publications ($25). Don’t OCR them. |
| Rigging / crane / member design | **High** | Out. Crane & Rigger is the tombstone. |

steelpy and similar GitHub “AISC” CSVs are **not** a rights basis for a commercial App Store app. Apache-2.0 on a scrape does not extinguish AISC copyright.

---

## Revenue Ceiling

### Required customers (developer revenue ≈ App Store proceeds)

Assume **15% Apple commission** (Small Business Program). Round. These are **steady-state** figures, not a launch month.

**Subscription (active paying accounts)**

| Price / year | $10k/mo | $20k/mo | $30k/mo | $50k/mo |
|---|---|---|---|---|
| $39 | **3,628** | 7,256 | 10,884 | 18,140 |
| $47.99 (Fabora) | **2,948** | 5,896 | 8,844 | 14,740 |
| $79 | **1,790** | 3,580 | 5,370 | 8,950 |
| $149 | **949** | 1,897 | 2,846 | 4,743 |

**Lifetime (new buyers *per year* to average that monthly run-rate)** — this is the trap. One-time sales require a **continuous** acquisition engine.

| Price | $10k/mo equiv / yr | $20k | $30k | $50k |
|---|---|---|---|---|
| $19.99 | **7,075** new/yr | 14,150 | 21,225 | 35,376 |
| $39.99 | **3,536** | 7,072 | 10,608 | 17,680 |
| $79.99 | **1,768** | 3,536 | 5,304 | 8,840 |

**VERIFIED FACT:** After 14–17 years, the best dedicated iOS steel apps have **113 and 323 US ratings**. Even a generous 20:1 download:rating heuristic (UNKNOWN, not Apple-published) implies a few thousand to maybe ~6,000 lifetime US downloaders for the category leader — **not** 3,600 concurrent $39/year subscribers.

**INFERENCE — reachable audience:**

- US structural ironworkers + fabricators/fitters ≈ **120k** people.
- iPhone-using **buyers** (owners, estimators, mobile welders) might be **5k–20k** (SPECULATION band).
- Capturing **15%** of a 10k high-intent owner set at $49/year ≈ 1,500 subs ≈ **~$5–6k/month** after Apple — and 15% share is already a category win against Fabora, Steel Profiles, and free Android.

**$20k+/month** on the App Store requires either (a) expanding into **global** Android+iOS with ads (Pixelsdo’s game, race to free) or (b) **B2B estimating** at MiscMetal/SteelFlo prices. (a) is a different product ethics/quality bar; (b) is a different company.

**SPECULATION (labeled):** A well-executed quote app might do **$2–8k/month** at peak with luck and seeding. Treat **$10k/month as the optimistic cap**, not the base case. **$20k/month is not evidenced.**

---

## Bear Case

1. The job is real; the **iPhone white space is not**. Android gave the calculator away.
2. Everyone who wanted a $5 AISC pocket app **already bought it in 2009–2012**.
3. Fabora is shipping the “winning” bundle in 2026 and has **2 ratings**. That is the market answering.
4. Search intent for `ironworker` is unions; for `steel estimating` is Hover/Xactimate.
5. Trades will use a **free web calculator** on the same phone.
6. High-ARPU estimating requires PDF takeoff, labor libraries, and support — we refused that shape on purpose.
7. AISC data is the obvious moat and we **cannot** copy it.
8. Familiarity with jobsites is not distribution.
9. Subscription backlash will cap ARPU at lifetime ~$20–$40.
10. Ceiling collides with kill criterion 8 (~$5–10k/month).

---

## Cheapest Test

**Do not build.**

**Single cheapest invalidator for the whole niche (App Store):**  
Watch **Fabora** (id `6788312316`) US rating count and review themes for one quarter. If a 21-tool offline Pro app at $47.99/year cannot recruit even a hundred raters, a second bundle will not either.

**Single cheapest invalidator for candidate #1:**  
10 conversations with US fab/misc-metals owners (public Instagram/Facebook shops). Script: “What do you use to quote a 12-piece rail from the truck? Would you pay $40/year for phone line-items + PDF?” If ≥8 say Excel/Notes/free calculator and would not pay, **stop**.

**Single cheapest invalidator for candidate #2:**  
Check whether ornamental shops even know Baluster Calculator Elite.

No landing page and no prototype until those answers exist. A landing page would not disprove “Excel is enough.”

---

## Ironwork vs Mileage vs Acreage vs Spirit Box

| Dimension | Ironwork winner (weight+quote) | Mileage | Acreage / field measure | Spirit Box |
|---|---|---|---|---|
| **Proven WTP** | $3–$9 lifetime; $40–$48/yr unproven at scale; shop software $399–$1,500/mo is a **different product** | **$11–$14/mo** widely paid (MileIQ / Everlance listings) | Freemium; Planimeter **$7.99**; premium unlocks UNKNOWN | $4.99–$9.99 category; our hypothesis $1.99 / $9.99 lifetime |
| **Comparable revenue** | **UNKNOWN**, likely tiny. No public $10k/mo steel-iOS app. | Everlance vendor estimate **~$20k/mo iOS** (bumetric; treat as **vendor, not audited**). Category is multiple apps at this scale. MileIQ is Microsoft. | UNKNOWN. 10k–13k ratings on leaders imply a real but crowded utility business. | **UNKNOWN**; ~$9k/mo line for the May leader was **demoted**. Spirit Talker estimates not ours. |
| **Plausible ceiling** | **~$5–10k/mo optimistic App Store**; $20k+ only via B2B | **Category** is far above $50k/mo. **A new indie** facing MileIQ/Everlance/Stride is a different, uglier fight. | Unclear; search looks bigger than steel, WTP weaker. Weak evidence of >> Spirit Box. | Canonical: questionable **~$10k/mo-ish** cap |
| **Exact search intent** | Weak for “ironworker”; moderate for “steel weight/shapes” | Extremely exact (`mileage tracker`) | Exact (`GPS fields area`, `acreage`) | **Exact** (`spirit box`) — still the cleanest phrase |
| **Organic accessibility** | Small apps rank because **nobody big wants the keyword**. That is thin demand, not a gift. | Brutal. 113k / 96k / 52k / 39k rating incumbents. | Accessible-looking but clone-flooded (same disease as Spirit Box) | Exact title clones **do not** take #1; seeding still required (2026-09-10 ledger) |
| **Alternative distribution** | Fab groups, welding YT, supplier counters — manual | Tax/driver influencers, IRS-season pull, rideshare forums | Farm/ag/real-estate | Investigator micro-creators (required seeding plan) |
| **Competition** | Tiny paid incumbents + Fabora + Android free giants | Oligopoly + Microsoft | Many clones; Farmis/Rento leader | Clone mill + GhostTube/Necrophonic |
| **V1 build time** | Short (quote workbook) | **Long** (automatic trip detection, GPS, classification, IRS reports, battery) | Medium (maps, GPS, exports, offline tiles) | Short **if** audio passes; audio is the gate |
| **Technical risk** | Low | **High** | Medium (GPS accuracy, map tiles) | Audio perception + App Review (no fake RF) |
| **Maintenance** | Low | High (OS background location) | Medium (map SDKs) | Corpus/renderer until the gate passes |
| **Support burden** | Quotes “wrong” vs mill ticket | Tax/audit anxiety, missed trips | “My acres don’t match the deed” | “I heard the same word twice” |
| **Content/data burden** | Low if no AISC tables; **high if we chase them** | Low | Map providers | Licensed speech corpus (already in motion) |
| **Liability** | Low (quoting) | Low (tax records; user still responsible) | Low–medium (not a survey) | Low (entertainment/instrument; no scientific claims) |
| **Pricing power** | Weak on App Store; strong only in B2B | Strong (direct $ saved at 72.5¢/mile, 2026 IRS rate **on Everlance’s listing**) | Weak | Weak–moderate; Halloween pulse |
| **Confidence** | **High that it is small.** Low that it beats the other three. | High that **the category** is the largest. Low that **we** should attack it next. | Medium: bigger SERP than steel, weaker WTP proof. | Medium-low commercially (CONDITIONAL BUILD); highest on **exact intent + simple iPhone V1** among options that aren’t oligopolies. |

Fatal weaknesses (do not average away):

- **Ironwork:** Ceiling + Android commoditization + AISC licensing + no exact consumer query.
- **Mileage:** Acquisition and automatic-detection difficulty for a new indie; incumbents are category-defining.
- **Acreage:** Clone swamp; unproven that a new listing prints more than Spirit Box.
- **Spirit Box:** Thin keyword economics, seeding requirement, audio gate, seasonal pulse.

---

## Addendum 2026-09-11 — Work orders, invoices, signed extras

This is a different product than the calculator thesis. It was not assumed in the 2026-09-10 pass. Re-evaluate on evidence, not on familiarity.

### What the user named

Solo / small-team welder tool:

1. Generate a work order fast.
2. Get it signed on the phone.
3. Stop scope creep (“can you just…”).
4. Track the job through invoice / paid.

Named competitor: **Invoice Fly**.

### Invoice Fly is the search incumbent, not the job incumbent

**VERIFIED FACT (iTunes Lookup, 2026-09-11):**

| App | Job | US ratings | Price on listing / site | Notes |
|---|---|---|---|---|
| **Invoice Maker - Invoice Fly** (Labhouse Mobile SL, Barcelona) | Generic estimate/invoice/signature/payments | **103,899** @ 4.76★; released 2022-02 | Site: **$8.99/week** or **$98.99/year**. IAP also shows $17.99 monthly/premium SKUs | Claims 125,000+ small businesses. About page lists plumbers, landscapers, cleaners, carpenters — **not welders**. |
| Invoice Simple | Same horizontal job | **122,724** | Freemium mill | Owns `invoice maker` |
| Square Invoices | Invoice + get paid | **92,849** | **Free** (Square take-rate) | Default “good enough” |
| Invoice2go | Same | **55,747** | ~$6/mo class historically | Mature |
| **Joist** | Contractor estimates, invoices, **work orders**, signatures; **change orders on Elite** | **14,010** @ 4.75★ | **$10 / $17 / $32 per month** (Basics / Pro / Elite). Elite = change orders. | This is the actual closest **contractor** product. Claims 1.3M contractors / $85B transactions (vendor claim, not audited). |
| Jobber | Full field-service OS | **20,832** | IAP from **$29.99–$399.99/mo** depending on plan | 250,000+ service pros (vendor). Lawn/clean/plumb-shaped. |
| Housecall Pro | Same | **29,639** | From ~$40–$79/mo class | Home services |
| Contractor+ | Estimate/invoice CRM | **1,872** | Reviews cite ~$15 → $30/mo, annual $360+ | 1-man shop praise **and** hostage-data hate |
| **Bead Board: Welding** (Crux Labs) | Welding shop job board: quote → working → done → paid, PDFs, photos, offline | **0** ratings; released **2026-04-14**; still 0 on 2026-09-11 | **$99/month** whole shop | Native iOS/Android. The welding-vertical already exists. |
| Jobkore | Welding/fab estimates, invoices, deposits, change orders | No iOS app in search | **$29/month** or $290/year | Phone **browser**, QBO push |
| Work Order Maker | Generic WO PDF | **183** | Sub | Not welding; support/data-loss 1-stars |
| Clearstory | Paperless T&M tags for construction | **34** @ 3.85★ | Company SaaS | GC/sub T&M, not solo welder |
| `change order` SERP | Signed extras | **0-rating** 2026 apps (ScopeProof, ScopeLock, Change Order Pro) | — | The **scope-creep query is empty** on iOS |

**VERIFIED FACT:** iTunes Search for `welding invoice` and `welder invoice` returns Invoice Fly at **#1**, then Invoice2go / Invoice Simple / Square. No welding-native invoicing app appears in the top 10.

**INFERENCE:** Invoice Fly is the correct answer to “what does a welder download after Googling invoice app?” It is the **wrong** answer to “what software is purpose-built for signed work orders and extras.” Labhouse is a Barcelona invoice mill aimed at US home-service contractors. Signature on an **invoice** is not the same as a signature on a **work authorization before extra welding**.

### The expensive small job (this time it might actually be expensive)

Mobile / shop welders lose money on:

- Verbal “while you’re here, weld this bracket too”
- Jobs quoted by text, then unfindable
- No deposit before steel is bought
- T&M hours never written down
- Customer disputes the invoice because nothing was signed

One unpaid extra on a $1,500 mobile call **does** make $20–$30/month feel trivial. That WTP is in a different class than a $4.99 shape lookup.

**Joist already sells this to contractors** at $17/mo (work orders) and $32/mo (change orders). **MyChangeOrder** sells *only* the extra-work ticket at $29/mo (or $3.99 per CO). **Jobkore** sells the welding/fab version at $29/mo. **Bead Board** sells the shop whiteboard replacement at $99/mo.

So people pay. The open question is whether **welders** pay for a **welding-named** tool, or they just use Joist/Square/Invoice Fly.

### Bead Board is the uncomfortable data point

Bead Board is the product this hypothesis describes: welding-specific, phone-first, offline in metal buildings, quote/invoice PDF, job board, 1–10 person shops.

**Five months on the App Store, 0 US ratings, $99/month.**

Possible explanations (UNKNOWN which):

1. Price is shop-tier; solo mobile welders bounce.
2. No ASO / they sell via web and Facebook, not App Store search.
3. Welding shops do not want this enough.
4. Too new; ratings lag.

Until (1) or (2) is proven, **do not assume a second welding job-tracker will do better**. $99/mo is also 3× Joist Elite. For a one-man truck, that is a bad price.

### Who actually competes, ranked by job overlap

| Rank | Product | Overlap with “fast WO + sign + stop extras + invoice” | Why they win or lose vs a welding V1 |
|---|---|---|---|
| 1 | **Joist** | High. Work orders + in-app signatures; change orders on Elite ($32/mo) | Cheaper than Bead Board. Not welding-flavored (no rod/gas/steel line defaults, no “hot work / T&M ticket” language). Reviews: price hikes, photo charges, VPN blocks, data lock-in. |
| 2 | **Jobkore** | High for fab/weld shops | $29/mo, deposits, change orders, QBO. **Not a ranked iOS app.** Browser on the phone. |
| 3 | **Bead Board** | Highest welding specificity | $99/mo, 0 ratings. Overpriced for solo. Weak on “get extras signed in 60 seconds” vs MyChangeOrder. |
| 4 | **Invoice Fly / Invoice Simple / Square** | Invoice only | Own search. Square is free. Invoice Fly weekly SKU is a trap ($8.99/week = $467/year if someone misses annual). **Do not fight them on templates.** |
| 5 | **Jobber / Housecall Pro** | Full FSM | Too much product, home-service DNA, $50–$150/mo. Welders who want this already left. |
| 6 | **MyChangeOrder / Scope Order** | Scope creep only | Proves the extra-work ticket can be a product by itself. Horizontal, not welding. |

**Closest competitor is Joist, not Invoice Fly.** Invoice Fly is the SEO/ASO gravity well.

### Search intent for this wedge

| Query | What ranks | Implication |
|---|---|---|
| `welding invoice` / `welder invoice` | Invoice Fly #1 | Any listing without “Invoice” in the title will be invisible here. A welding-named app still loses to 100k-rating mills on this head term. |
| `work order` | CMMS (MaintainX, UpKeep) + Work Order Maker (183 ratings) | Facilities maintenance, not field welding tickets. |
| `change order` | Empty / 0-rating indie apps + Clearstory | **Accessible and commercially relevant** — but tiny, and not welder-specific. |
| `Jobber` / `Joist` | Brand | People who know the category search the brand. Cold start has no brand. |

No invented volumes. The pattern is: **invoice keywords are a bloodbath; change-order keywords are empty; welding-vertical App Store demand is unproven (Bead Board = 0).**

### Review-mined pain (this job)

Invoice Fly RSS on this pass was thin on trade-specific complaints (generic “make it free” / “trash”). Broader public reviews: trial/card traps, weekly pricing, payout/Stripe confusion, “Square does this free.”

Joist (better analogue):

- “I would like them to enable a feature allowing the client to provide a genuine signature on **their own device**.”
- Subscription increases shortly after signup; charges for photo uploads.
- “Joist used to be free… pop ups and increased subscription fees.”
- Data hostage after cancel.
- Constant marketing email.

Contractor+: 1-man electrical shop calls it the first CRM that works from the van — **and** users rage when free invoice caps appear and prices double.

Work Order Maker: “created a work order in less than 10 minutes” / “great for small business” — then **all work orders gone** after reinstall. That is the SaaS support burden.

Clearstory: “field guys no longer need to worry about keeping track of **paper tags**.” That is the T&M job, sold to companies, 34 ratings.

**INFERENCE:** The “I use this constantly but I hate X” for this category is **not missing weld symbols**. It is **subscriptions, data lock-in, and signatures that aren’t really the customer’s**. A welding app that is just Invoice Fly with a bead icon inherits all of that hate plus none of the rating mass.

### Build / liability / who pays

| | |
|---|---|
| Who pays | Solo mobile welder or 2–5 person shop **owner**. App Store or Stripe. Not the union hall. |
| Pricing that fits evidence | **$15–$29/month** or **~$149–$290/year**. Joist/Jobkore band. Not $99/mo (Bead Board). Not $9.99 lifetime (won’t fund backend). |
| V1 that is actually the job | Client + line items (labor hours, mobile call-out, steel, rod/wire, gas, shop supplies) → work order PDF → **on-device customer signature** → optional extra/CO with a new signature → invoice from the signed lines → share/email. Offline draft, sync to send. Saved rate card. |
| V1 that is a trap | Pretty invoice templates, Stripe Connect, QuickBooks, scheduling, CRM, team seats, AI. That is Jobber. |
| Build time | **Not this month** if signatures + email delivery + accounts + sync are real. That is a small SaaS. A local-only PDF + signature + Files/share sheet could ship in weeks **without** payments. |
| Hidden burden | Accounts, email deliverability, e-sign evidence (ESIGN/UETA claims), payment disputes, “restore my jobs,” App Store IAP vs web billing, support when a $8,000 invoice is “lost.” |
| Liability | Low–medium. This is paperwork, not structural design. Do not claim “legally binding” without actually storing signer identity, timestamp, and hash. Square/Joist already set that bar. |
| Maintenance | High vs a calculator. This is the original kill criterion #5 (meaningful revenue wants a backend). Here the backend **is** the product. |

### Ceiling math (this wedge only)

Self-employed welders are ~6% of ~457k = **~27k** (BLS). Plus small specialty-trade / mobile / farm / trailer / ornamental shops — reachable US buyers might be **20k–60k** (SPECULATION band).

At **$29/month** after 15% Apple (if IAP): need **~406** paying accounts for $10k/mo developer revenue; **~812** for $20k; **~2,030** for $50k.

That customer count is **plausible** in a way the $4.99 AISC app never was — **if** acquisition works. Jobber did this across all home services at 250k+ pros. Welding is a thin vertical. Bead Board’s 0 ratings say the App Store will not gift those 400 accounts.

Web/Facebook welding groups could. That is a **sales/community** motion, not ASO.

### Does this beat the calculator thesis?

**Yes.** Higher WTP, clearer ROI (unsigned extras), owner pays, Invoice Fly proves people already pay ~$99/year for a worse job (invoices only).

### Does this beat Invoice Fly by being “for welders”?

**Not on search.** Vertical skin on a generic invoice app loses to 104k ratings. The only defensible wedge is **signed work authorization + extras + welding line-item defaults**, not templates.

### Does this deserve priority over Spirit Box / mileage / acres?

| vs | Result |
|---|---|
| Calculator ironwork | This is the better ironwork product. |
| Spirit Box | Higher ARPU, much heavier build/support, no exact unique keyword. **Not an automatic winner.** Cheap test first. |
| Mileage | Still smaller category; better founder-fit if we refuse GPS/tax. |
| Acreage | Stronger WTP story than acres; worse cold-start than acres’ 10k-rating SERP. |

**Not IRONWORK WINNER.** Do not pivot the repo on a hunch that Invoice Fly is weak. Invoice Fly is huge at the wrong job.

### Cheapest test (do this before any code)

**One question, ten solo/small-team welders** (mobile, farm, trailer, ornamental — not union shop floor):

1. What do you use to bill today? (Square / Invoice Fly / Joist / QuickBooks / paper / text)
2. Last time a customer added work mid-job, did you get it **signed**?
3. Roughly how much unpaid extra did you eat in the last 90 days?
4. Would you pay **$19/month** for: work order in 60 seconds, customer signs your phone, extras need a second signature, invoice from the signed lines — **no** scheduling, **no** QuickBooks?

**Kill if:** ≥7/10 already get paid fine with Square/Invoice Fly **and** do not remember losing money on unsigned extras.

**Also watch:** Bead Board ratings. If they are still ~0 after another quarter at $99/mo, drop the price in the pitch to Joist’s band or drop the vertical.

### Addendum verdict

**PROMISING — ONE CHEAP TEST** for a **signed work-order / extra-work ticket** aimed at solo welders, priced like Joist ($15–$29/mo), not like Invoice Fly (pretty invoices) and not like Bead Board ($99/mo shop OS).

**KILL** a plan whose differentiation is “Invoice Fly, but for welders.”

---

## Final Verdict

### Split: calculators INTERESTING BUT SMALL; signed welder work orders PROMISING — ONE CHEAP TEST; Invoice Fly clone KILL

This is **not** IRONWORK WINNER. Do not leave Spirit Box for a welding invoice skin.

**Calculators** still fail the original kill list (thin search, Android-free substitutes, AISC licensing, ~$5–10k/mo cap).

**Signed work orders** reopen kill criterion 5 on purpose: the backend *is* the product. ARPU can support $10k–$20k/mo with hundreds of $29/mo accounts. That is only interesting if ten welders say they currently eat unsigned extras. Bead Board’s **0 ratings at $99/mo** is the bear case until disproven.

**Park calculators. Do not staff a build.** The only live ironwork action is the ten-welder script — or nothing.

---

## Exact Next Action

1. **Do not start an Invoice Fly clone, a steel calculator, or a Bead Board clone.**  
2. **Keep Spirit Box on CONDITIONAL BUILD** (audio disproof test remains the live product gate in the canonical file).  
3. If pursuing the welder hypothesis at all: **ten conversations** using the addendum script (Square vs unsigned extras vs $19/mo). No backend until that returns a kill or a go.  
4. Mileage remains the largest proven category; it is still a separate hard bet.

---

## Appendix A — iTunes snapshot (US, 2026-09-10)

Selected rating stocks (API `userRatingCount`):

| App | Ratings | Price signal |
|---|---|---|
| MileIQ | 112,590 | Sub ~$14/mo / $140/yr on listing |
| Stride | 96,069 | Mileage + tax |
| Everlance | 51,990 | Starter ~$11/mo |
| Driversnote | 38,683 | Mileage |
| Construction Master Pro Calc | 39,716 | $39.99/yr |
| Raken | 22,266 | Company SaaS |
| GPS Fields Area Measure Map | 12,665 | Acreage leader |
| FieldCalc | 10,235 | Acreage |
| Planimeter | 2,211 | **$7.99** paid land measure |
| Stair Calculator: Construction | 739 | Stairs (DIY/carpenter) |
| RedX Stairs | 409 | ~$59/yr complaints |
| Flange Bolt Size & Torque | 370 | Pipe, not iron |
| Baluster Calculator Elite | 363 | **$8.99** |
| Steel Profiles | 323 | IAP $2.99–$4.99 |
| steelyard | 298 | Ads / $9.99 ad-remove |
| Weight calculator for metals | 263 | Free, stale |
| [steel shapes] | 113 | **$4.99** since 2009 |
| Ironworker Pro | 6 | **$2.99** (2026) |
| Fabora | 2 | **$47.99/yr** (2026-07-30) |
| Invoice Fly | 103,899 | **$8.99/wk or $98.99/yr** (2026-09-11) |
| Invoice Simple | 122,724 | Horizontal invoice mill |
| Square Invoices | 92,849 | Free + processing |
| Joist | 14,010 | **$10 / $17 / $32 per mo**; change orders on Elite |
| Jobber | 20,832 | Field-service SaaS |
| Housecall Pro | 29,639 | Field-service SaaS |
| Bead Board: Welding | **0** | **$99/mo**; released 2026-04-14 |

## Appendix B — Sources

- iTunes Search/Lookup API and RSS customer reviews, 2026-09-10, `country=us`.
- BLS OOH: Structural Iron and Steel Workers; Welders; structural metal fabricators matrix.
- BLS QCEW: NAICS 332 establishment counts.
- AISC membership page; AISC copyright permissions; AISC Shapes Database v16 page.
- Vendor pricing: bluebeam.com/pricing; steelfloai.com; metal-estimator-pro.com; calculated.com Construction Master Pro 4065 MSRP; Fabora App Store listing IAP; Construction Master Pro App Store IAP.
- Google Play listings: Pixelsdo Metal Weight Calculator; despDev Steel Weight Calculator / AppBrain.
- Reddit: r/Ironworker Ironworker Pro launch thread (2026).
- ICC/SSTC Structural Welding Quality Handbook price; IMPACT pocket guide historical $15; Builder’s Book steel detail wheel ~$18.
- Canonical Spirit Box economics: `docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md` and `docs/research/RESEARCH-REVALIDATION-2026-09-10.md`.
- Addendum 2026-09-11: Invoice Fly / Joist / Jobber / Bead Board / Jobkore / MyChangeOrder listings and pricing pages; iTunes Search `welding invoice`, `work order`, `change order`.

**UNKNOWN throughout:** true search volumes, true revenues of any steel iOS app, Fabora’s future trajectory, Apple commission actually paid by each developer.
