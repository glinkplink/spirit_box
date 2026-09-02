# Spirit Box — Commerce & Analytics Implementation Spec

**Status:** Implementation contract (documentation only)  
**Audience:** Future commerce engineering PR after audio-harness/scaffold merge  
**Authority:** `docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md` wins on product scope, pricing, and workflow  
**Companion QA:** `docs/engineering/QA_AND_FIELD_TEST_PLAN.md`  
**Paywall copy:** `docs/launch/APP-STORE-CONVERSION-AND-ASO-PLAYBOOK.md` §10  

This document answers: **What exactly should the future commerce engineering agent build?**  
It does **not** implement StoreKit, RevenueCat, analytics SDKs, Xcode project changes, audio harness changes, MVP UI, or pricing/product-scope changes.

---

## Document legend

| Label | Meaning |
| --- | --- |
| **VERIFIED PLATFORM FACT** | Grounded in current official Apple (or named provider) documentation as of authorship |
| **OUR IMPLEMENTATION DECISION** | Spirit Box V1 choice within platform constraints and canonical product rules |

---

# 1. Executive architecture decision

## V1 commerce architecture (locked for this spec)

**OUR IMPLEMENTATION DECISION: StoreKit 2 direct only. No RevenueCat in V1.**

### Chosen stack

| Layer | Choice |
| --- | --- |
| Purchases / entitlements | **StoreKit 2** only |
| Commerce middleware | **None** (no RevenueCat, no Adapty, no Superwall) |
| Product backend | **None** (canonical: no account, no product backend) |
| Analytics | See §18 (StoreKit + App Store Connect + Apple crash tooling + one minimal product-analytics provider) |

### Why not RevenueCat for V1

Canonical allows RevenueCat **only if** it materially improves entitlement/paywall analytics (`docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md` §20). For V1 it does **not** clear that bar.

| Criterion | StoreKit 2 direct | StoreKit 2 + RevenueCat |
| --- | --- | --- |
| Reliability | Native Apple path; fewer moving parts | Adds RC network + SDK failure modes |
| Offline behavior | Cached entitlements under our control | Extra dependency when RC sync expected |
| Implementation complexity | Two products, no auto-renew | SDK, dashboard, API keys, paywall config optional |
| Entitlement handling | Lifetime = non-consumable; Tonight = non-renewing with app-owned expiry | Still need custom 24h expiry logic for non-renewing |
| Analytics value | Purchase events via StoreKit + thin product analytics | Better commerce dashboards, but duplicates Apple sales data we already get |
| Privacy / “Private by design” | One fewer third-party network | Extra SDK → privacy labels + trust-copy review |
| Maintenance / solo burden | Lower | Higher (upgrade churn, dashboard, support surface) |
| No-backend requirement | Fits | RC works without our backend, but still adds a vendor dependency we do not need |

**RevenueCat is not forbidden later.** Revisit only if post-launch evidence shows we cannot answer monetization questions with App Store Connect + StoreKit + the minimal analytics stack in §18.

### What native StoreKit 2 already covers cheaply enough

- Product loading and localized prices  
- Purchase / pending / cancel / failure  
- Verified transactions (`VerificationResult`)  
- Lifetime ownership via `Transaction.currentEntitlements`  
- Latest finished non-renewing purchase via `Transaction.currentEntitlements` (**VERIFIED PLATFORM FACT** — Apple documents that current entitlements include the latest non-renewing subscription transaction, including finished ones)  
- Restore UX via StoreKit 2 sync + entitlement refresh  
- Revocation absence from current entitlements after refund (**VERIFIED PLATFORM FACT** — refunded/revoked products do not appear in `currentEntitlements`)

---

# 2. Product definitions

## 2.1 App Store product map

| Internal concept | Apple product type | Repurchase | Restore expectation |
| --- | --- | --- | --- |
| **Tonight Pass** | **Non-Renewing Subscription** | Yes, after expiry (and when allowed by our gate) | App-owned restore/reconcile from StoreKit transaction history + local cache |
| **Lifetime** | **Non-Consumable** | No (already owned) | Restorable via StoreKit entitlement / restore flow |

### Tonight Pass — product type decision

**OUR IMPLEMENTATION DECISION: Non-Renewing Subscription.**

**VERIFIED PLATFORM FACT** (App Store Connect Help — In-App Purchase types):

- **Non-Renewing Subscription:** limited duration; does not renew automatically; content may be static.  
- **Consumable:** used once, then depleted; must be purchased again.  
- **Non-Consumable:** purchased once; does not expire.  
- **Auto-Renewable Subscription:** renews unless cancelled — **forbidden for V1**.

Tonight Pass requirements (24h, does not auto-renew, may be purchased again, deterministic expiry) match **Non-Renewing Subscription**, not consumable or non-consumable.

**VERIFIED PLATFORM FACT** (Apple — Handling Subscriptions Billing):

For non-renewing subscriptions:

1. The **app** calculates the active time period.  
2. The **app** detects approaching expiry and can prompt repurchase.  
3. The **app** is responsible for making purchases available across devices and for restore. Apple notes that most such subscriptions use a server to associate purchases with a user.

**Platform constraint (material):** Perfect cross-device Tonight Pass continuity without an account/backend is **not** something Apple guarantees. V1 accepts **best-effort same–Apple ID StoreKit reconciliation** plus durable local cache. We do **not** add a backend solely for Tonight Pass clock fraud or multi-device sync.

**Rejected alternative:** Modeling Tonight Pass as a **Consumable** would force all duration state into local storage only and remove it from `currentEntitlements` after finish, weakening reinstall recovery.

### Lifetime — product type decision

**OUR IMPLEMENTATION DECISION: Non-Consumable.**

**VERIFIED PLATFORM FACT:** Non-consumables are purchased once and do not expire or decrease with use; they appear in `Transaction.currentEntitlements` while owned and disappear if refunded/revoked.

## 2.2 Proposed product identifiers

**OUR IMPLEMENTATION DECISION** (implementation identifiers; changeable before App Store Connect creation):

| Product | Proposed product ID | Type |
| --- | --- | --- |
| Tonight Pass | `spiritbox.tonight.24h` | Non-Renewing Subscription |
| Lifetime | `spiritbox.lifetime` | Non-Consumable |

Rationale: reverse-DNS style; Tonight ID encodes duration to avoid future ambiguity if a different timed SKU is ever added (post-V1 only with product-owner approval).

Display names / review metadata are App Store Connect copy — see §21. In-app prices come from StoreKit (`Product.displayPrice`), never hard-coded.

## 2.3 Launch price hypotheses (canonical; not to hardcode in UI)

| Product | Launch hypothesis |
| --- | --- |
| Tonight Pass | $1.99 (24 hours, does not renew) |
| Lifetime | $9.99 (one-time) |

Pricing iteration remains a post-launch product decision (`docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md` §15.6).

---

# 3. Entitlement state model

## 3.1 Access entitlement states (smallest useful set)

These describe **whether the user may start a new full session**.

| State | Meaning |
| --- | --- |
| `FREE_AVAILABLE` | Free complete session not yet consumed |
| `FREE_IN_PROGRESS` | Free session started; not yet consumed |
| `FREE_CONSUMED` | Free session consumed; no paid entitlement |
| `TONIGHT_ACTIVE` | Verified Tonight Pass within 24h window |
| `TONIGHT_EXPIRED` | Tonight Pass window ended; no Lifetime |
| `LIFETIME` | Verified non-consumable Lifetime owned |

## 3.2 Commerce transient states (orthogonal UI/process flags)

Do **not** invent dozens of entitlement enums. Keep these as **process flags** on the commerce layer:

| Flag | Meaning |
| --- | --- |
| `isPurchasePending` | Ask to Buy / pending approval |
| `isRestoring` | User-initiated restore in flight |
| `isVerifying` | Launch/foreground reconciliation in flight |
| `lastPurchaseFailure` | Optional last failure reason for UI |

`UNKNOWN` is only allowed briefly during cold-start verify; UI must not treat unknown as paid.

## 3.3 Precedence (highest wins)

1. `LIFETIME`  
2. `TONIGHT_ACTIVE`  
3. Else trial path: `FREE_AVAILABLE` → `FREE_IN_PROGRESS` → `FREE_CONSUMED` / `TONIGHT_EXPIRED`

`LIFETIME` **always** overrides any Tonight state.  
Expired Tonight never impersonates Lifetime.

## 3.4 Derived capability: `canStartFullSession`

```
canStartFullSession =
  LIFETIME
  OR TONIGHT_ACTIVE
  OR FREE_AVAILABLE
  OR FREE_IN_PROGRESS
```

`FREE_CONSUMED` and `TONIGHT_EXPIRED` → `canStartFullSession = false` → paywall on START attempt.

## 3.5 Sources of truth

| Concern | Source of truth | Local cache |
| --- | --- | --- |
| Lifetime ownership | StoreKit verified `Transaction.currentEntitlements` for `spiritbox.lifetime` | Cached `lifetimeOwned: Bool` + last verified transaction id/date |
| Tonight window | Verified latest Tonight transaction `purchaseDate` + **24h absolute duration** | Cached `tonightExpiresAt` (UTC absolute) derived from that purchase |
| Free trial accounting | Local `TrialStore` (Keychain-backed; see §4) | Same |
| Recordings | Local session store (filesystem) | Never gated by entitlement expiry |

### Reconciliation moments

| Moment | Action |
| --- | --- |
| App launch | Start `Transaction.updates` listener; reconcile `currentEntitlements`; refresh trial/entitlement caches |
| Foreground | Light reconcile if last verify > N minutes (suggested 15) or clock jumped materially |
| Purchase completion | Verify → update cache → `finish()` → dismiss paywall only after verified grant |
| Restore | `AppStore.sync()` (or StoreKit 2 equivalent restore) → reconcile entitlements → update cache |
| Conflict | Prefer **verified StoreKit state** over stale local paid cache when StoreKit reachable; when offline, honor last **verified** cache (see §10) |

---

# 4. Free session accounting

Canonical: **one complete real 3-minute session** with full product (sweep, rate, Forward/Reverse, REC, MARK, replay). Paywall only after that experience. Existing free-session recording remains usable.

QA open item E-04 (crash fairness) is **closed by this section**.

## 4.1 Definitions

| Term | Definition |
| --- | --- |
| **STARTED** | A free-session attempt has begun: START succeeded, a session ID exists, and the sweep renderer is actually running |
| **CONSUMED** | The free entitlement is spent; next full START requires paid access |
| **Valid runtime** | Continuous time while session is active and not in a hard technical-failure abort |

## 4.2 Recommended consumption rule (locked)

**OUR IMPLEMENTATION DECISION:**

1. **STARTED** when START succeeds (sweep running + session record created). Enter `FREE_IN_PROGRESS`.  
2. **CONSUMED** when **any** of the following occurs during that free attempt:  
   - Session reaches the designed **180-second** free-session end (complete trial), **or**  
   - User manually stops after **≥ 60 seconds** of valid runtime, **or**  
   - Session is successfully finalized with duration **≥ 60 seconds**.  
3. **Not consumed** when:  
   - START fails before the session begins,  
   - App crashes / iOS kills the app with valid runtime **< 60 seconds**,  
   - Immediate technical abort (e.g. recording pipeline hard-fails at launch) within the first **~15 seconds** and the session is discarded as failed,  
   - User cancels/stops with valid runtime **< 60 seconds**.

### Edge-case answers

| Scenario | Outcome |
| --- | --- |
| START tapped | STARTED only if session actually begins |
| Crash after 30s | Not consumed; `FREE_AVAILABLE` again |
| Recording fails at t≈0 | Not consumed if treated as technical abort |
| User stops after 20s | Not consumed |
| User stops after 90s | Consumed |
| iOS kills after 2+ minutes | Consumed (threshold met) |
| Full 3 minutes | Consumed |
| After consume | Replay/export of saved session still works |

### Why 60s (not “only at 180s” and not “on first START”)

- Consuming on first START punishes crash/launch failure (conversion poison).  
- Consuming only at exact 180s enables unlimited short free sessions (abuse).  
- 60s is long enough to hear the real product and short enough to stop free-session farming.

Do **not** optimize for theoretical fraud at the expense of legitimate conversion.

## 4.3 Persistence (no account / no backend)

| Store | What | Why |
| --- | --- | --- |
| **Keychain** | `trialConsumed`, optional `trialStartedCount`, schema version | Survives app delete/reinstall better than `UserDefaults` |
| **UserDefaults / app support files** | In-progress session id, valid runtime accumulator for current attempt | Fine for ephemeral in-progress state |

**OUR IMPLEMENTATION DECISION:** Persist **consumption** in Keychain. Do not invent DeviceCheck/App Attest anti-fraud for V1.

### Reinstall behavior

| Event | Expected |
| --- | --- |
| Reinstall, Keychain intact | Trial remains consumed if previously consumed |
| Reinstall after Keychain wipe / new device / erased device | Trial may reset — **accepted** without account/backend |
| Same Apple ID, new device | Lifetime restores via StoreKit; trial state does **not** sync (no account) |

**Honesty clause:** Perfect anti-abuse identity is impossible without accounts. For a $1.99 Tonight / $9.99 Lifetime product, Keychain + fairness threshold is the smallest sensible approach.

---

# 5. Paywall trigger

Canonical: **no paywall before the user hears the real product**; recordings not held hostage; START of another full session requires paid access after free session.

## 5.1 When paywall appears

**OUR IMPLEMENTATION DECISION:**

```
User taps START (new full session)
→ entitlement check
→ if !canStartFullSession → present paywall
→ else start session
```

Also allow opening paywall from an explicit Settings/Help “Unlock” entry **after** trial consumption (optional), but **never** as a blocking first-launch gate.

## 5.2 When paywall must NOT appear / must NOT block

Paywall must **not** block:

- Session history  
- Replay of existing recordings  
- MARK navigation on saved sessions  
- Export/share of existing recordings  
- Powered-off instrument browse / trust copy / settings that do not start a full session  

## 5.3 After free session

User may still:

- Replay free-session recording  
- Inspect MARKs  
- Export/share  

Matches canonical §12.6 / §15.2 and ASO playbook free-trial completion explanation.

---

# 6. Tonight Pass semantics

## 6.1 Clock start

**OUR IMPLEMENTATION DECISION:**

- 24-hour window starts at the **verified StoreKit transaction `purchaseDate`** for that Tonight purchase.  
- Duration = **exactly 24 hours** = `purchaseDate + 24 * 60 * 60` seconds (absolute), not calendar “tonight” or local midnight.

**VERIFIED PLATFORM FACT:** Apple requires the app to calculate non-renewing active periods; Apple does not auto-expire non-renewing products the way auto-renewable subscriptions expose `expiresDate`.

Prefer absolute `Date` math over wall-clock “days” to reduce DST/timezone surprises.

## 6.2 Authoritative timestamp

| Priority | Source |
| --- | --- |
| 1 | Verified transaction `purchaseDate` |
| 2 | Local cache of derived `tonightExpiresAt` written only after verified grant |
| 3 | Device clock used only to compare `now` vs `tonightExpiresAt` |

## 6.3 Behavior matrix

| Scenario | Behavior |
| --- | --- |
| App restart | Recompute active from cached expiry and/or `currentEntitlements` latest Tonight tx |
| Device restart | Same |
| Timezone / DST change | Absolute expiry unchanged |
| Device clock manipulation | Accepted residual fraud risk for $1.99; no backend anti-fraud |
| Reinstall | Prefer StoreKit latest Tonight transaction if present; else Keychain/local cache if still valid |
| Offline launch | Honor last verified active cache until absolute expiry by device clock |
| StoreKit unavailable | Do not revoke a still-unexpired verified cache; block **new** purchase |
| Verification temporarily unavailable | Keep prior verified cache; set `isVerifying`; never invent success |
| Repurchase after expiry | Allowed; new `purchaseDate` starts a new 24h window |
| Purchase while Tonight still active | Prefer prevent duplicate UX (“Already active until …”); if StoreKit still sells, reconcile to **latest** verified purchase without stacking overlapping paid windows as Lifetime |
| Lifetime while Tonight active | Grant `LIFETIME`; Tonight becomes irrelevant for gating |

## 6.4 Commercially acceptable client-side abuse

Acceptable for V1: clock rollback, Keychain wipe + reinstall trial reset, shared Apple ID edge cases.  
Unacceptable: false purchase success, locking owned recordings, requiring network for already-verified entitled use.

Do **not** build a backend merely to solve clock fraud.

---

# 7. Lifetime semantics

## 7.1 Purchase → access

1. User completes StoreKit purchase for `spiritbox.lifetime`.  
2. App accepts only `VerificationResult.verified`.  
3. Persist local `lifetimeOwned = true`.  
4. `transaction.finish()` after durable grant.  
5. Entitlement state → `LIFETIME`.

## 7.2 Persistence / reinstall / restore

- Survives reinstall via Apple purchase history + StoreKit entitlements (**VERIFIED PLATFORM FACT** for non-consumables).  
- Restore button reconciles Lifetime (primary restore promise in UI helper copy).  
- Offline after verified ownership: allowed via cached verified flag (§10).

## 7.3 Refund / revocation

**VERIFIED PLATFORM FACT:** Refunded/revoked products do not appear in `Transaction.currentEntitlements`.

**OUR IMPLEMENTATION DECISION:** On reconcile, if Lifetime missing from verified entitlements after previously owned → clear `LIFETIME` access for **new sessions**. **Never** delete or lock local recordings.

## 7.4 Family Sharing

**VERIFIED PLATFORM FACT:** Family Sharing is supported for **auto-renewable subscriptions** and **non-consumable** IAPs; **not** for non-renewing subscriptions. Enabling Family Sharing in App Store Connect is **irreversible** for that product.

**OUR IMPLEMENTATION DECISION (recommended default):**

- Lifetime (`spiritbox.lifetime`): **Enable Family Sharing** at App Store Connect setup (goodwill; matches one-time unlock). Confirm product-owner OK before flipping (irreversible).  
- Tonight Pass: **N/A** (not eligible).

Open question listed in §24 only if product owner wants Family Sharing off.

## 7.5 Precedence

Lifetime overrides Tonight for all session-start gating.

---

# 8. Purchase flow

## 8.1 Shared flow (Tonight and Lifetime)

```
Tap CTA (USE IT TONIGHT / OWN IT FOREVER)
→ disable duplicate taps / show loading
→ Product.purchase()
→ handle PurchaseResult
→ on success: require VerificationResult.verified
→ update EntitlementStore
→ finish transaction
→ dismiss paywall only after verified success
→ never show false success
```

## 8.2 Result handling

| Result | UX | Entitlement | Analytics |
| --- | --- | --- | --- |
| Verified success | Success; dismiss paywall | Grant | `purchase_completed` |
| `.userCancelled` | Return to paywall; no error drama | Unchanged | optional `purchase_failed` with reason `canceled` **or** omit (prefer omit noise) |
| `.pending` (Ask to Buy) | “Waiting for approval” | `isPurchasePending`; no grant | `purchase_started` already fired; complete later via `Transaction.updates` |
| Failure / StoreKit unavailable | Clear recoverable error | Unchanged | `purchase_failed` |
| Unverified transaction | Treat as failure; do not grant | Unchanged | `purchase_failed` reason `unverified` |
| Already owned Lifetime | Unlock Lifetime; friendly copy | `LIFETIME` | restore-like completion |
| Network loss mid-purchase | Rely on `Transaction.updates` + unfinished transactions on next launch | No optimistic grant | failure only if truly failed |
| Background during purchase | Keep listener alive; reconcile on foreground | No optimistic grant | — |
| Rapid duplicate taps | Ignore while `isPurchasing` | — | — |

**Never** grant on unverified or pending-only.

No manipulative purchase UX (no fake timers, fake discounts, preselected dark patterns) — matches canonical §15.7 and ASO §10.

---

# 9. Restore / reconciliation

## 9.1 What Restore Purchases does

**OUR IMPLEMENTATION DECISION (StoreKit 2):**

1. Set `isRestoring`.  
2. Call StoreKit 2 account sync (`AppStore.sync()` or current documented equivalent).  
3. Re-read `Transaction.currentEntitlements`.  
4. Recompute Lifetime + Tonight expiry.  
5. Update local caches.  
6. Clear `isRestoring` and show result messaging.

**VERIFIED PLATFORM FACT:** Apple requires a restore mechanism for customers; do **not** automatically restore on every launch in a way that interrupts with credential prompts. Launch may **silently** read `currentEntitlements` without a full credentialed sync.

**VERIFIED PLATFORM FACT:** For non-renewing subscriptions, **the app is responsible** for the restoration process.

## 9.2 What restore can and cannot promise

| Product | Restore promise |
| --- | --- |
| Lifetime | Restore / reinstall recovery expected via Apple purchase history |
| Active Tonight Pass | Best-effort: latest non-renewing transaction in `currentEntitlements` + expiry math; **not** a server-backed multi-device guarantee |
| Expired Tonight | Does not unlock new sessions; may inform “previous pass expired” |
| Free trial | **Not** an App Store purchase; restore does not reset or grant trial |

## 9.3 Messaging

| Outcome | Message direction |
| --- | --- |
| Lifetime restored | “Lifetime unlocked.” |
| Tonight still active | “Tonight Pass active until {localized absolute/local time}.” |
| Nothing to restore | “No purchases found for this Apple ID.” |
| Failure | “Couldn’t restore right now. Check connection and try again.” |

Paywall helper (ASO): **Already unlocked Lifetime? Restore your purchase.**  
Do not imply Tonight renews.

---

# 10. Offline entitlement behavior

Core instrument is offline-first. Purchases may need network; entitled use must not.

## 10.1 Rules

| Situation | Behavior |
| --- | --- |
| Verified Lifetime + offline launch | Allow full sessions from cache |
| Verified active Tonight + offline launch | Allow until cached absolute expiry |
| Tonight expires while offline | Local clock crosses `tonightExpiresAt` → lock **new** sessions; keep recordings |
| Cannot contact StoreKit | No new purchase/restore; honor verified cache; replay always works |
| Local cache vs fresh StoreKit | When online, StoreKit verified wins (including revocation) |
| Stale cached Tonight beyond expiry | Treat expired even if StoreKit temporarily unreachable |

## 10.2 Cache trust policy

Write paid cache **only** after verified transaction grant/reconcile.  
Include: product id, transaction id, `purchaseDate`, derived `expiresAt` (Tonight), `lastVerifiedAt`.

Do **not** require permanent network for normal entitled use.

---

# 11. Recording ownership

**Absolute rule (canonical §12.6):**

> Entitlement expiration must not lock existing recordings.  
> Paid access controls ability to start **new** full sessions, not ownership of already-created local recordings.

| State | New full session | Replay / MARK nav / export |
| --- | --- | --- |
| `FREE_CONSUMED` | No (paywall on START) | Yes for saved sessions |
| `TONIGHT_EXPIRED` | No | Yes for all saved |
| `LIFETIME` | Yes (unless revoked) | Yes |
| Revoked Lifetime | No | **Yes** — recordings remain |

No paywall may sit in front of opening an existing recording.

---

# 12. Paywall contract

Use locked conversion copy from `docs/launch/APP-STORE-CONVERSION-AND-ASO-PLAYBOOK.md` §10.

### Structure

- **Headline:** `USE IT TONIGHT. OWN IT FOREVER.`  
- **Explanation:** `Your free session is saved.` + supporting sentence (real sweep/REC/MARK/replay; no ads; nothing renews automatically).  
- **Tonight first**, Lifetime second with stronger visual hierarchy (amber outline / `ONE-TIME` badge OK).  
- **Tonight:** `TONIGHT PASS` / `24 HOURS — DOES NOT RENEW` / CTA `USE IT TONIGHT`  
- **Lifetime:** `LIFETIME` / `ONE-TIME PURCHASE` / CTA `OWN IT FOREVER`  
- **Restore Purchases** visible  

### Hard rules

- Prices from StoreKit localization only  
- No hardcoded `$1.99` / `$9.99` in production UI  
- No 7-day tier, subscription, fake sale, fake discount, countdown, preselected dark pattern, fake BEST VALUE  

---

# 13. StoreKit abstraction

Small separation only — no giant protocol factories.

## 13.1 Components

| Type | Owns | Touches StoreKit? | Persist? | Testable? |
| --- | --- | --- | --- | --- |
| `ProductCatalog` | Load/cache `Product`s for Tonight + Lifetime; expose `displayPrice` | Yes (`Product.products`) | Memory/session cache | Thin wrapper + fake |
| `PurchaseService` | `purchase`, listen `Transaction.updates`, verify, `finish`, restore/sync | Yes | No business state | Fake purchase results |
| `EntitlementStore` | Derive access state; Tonight expiry math; precedence; `canStartFullSession` | No (consumes verified tx snapshots) | Yes (verified cache) | **Pure / highly unit-testable** |
| `TrialStore` | STARTED/CONSUMED rules; Keychain persistence | No | Yes (Keychain) | **Pure + persistence tests** |
| Paywall UI | Copy + CTAs + loading/error | No direct StoreKit | No | Snapshot/UI tests |

UI calls `PurchaseService` / reads `EntitlementStore` + `TrialStore`. UI must not parse transactions.

Suggested single façade optional: `CommerceController` coordinating the four — keep thin.

---

# 14. Analytics objective

Profitability is the objective. Track the **smallest** set that answers:

1. Do installers start the free session?  
2. Do they complete it?  
3. Do they use REC?  
4. Do they use MARK?  
5. Do they open replay?  
6. Do they see the paywall?  
7. Do they buy Tonight?  
8. Do they buy Lifetime?  
9. What is payer conversion?  
10. Are recording/save failures hurting users?  
11. Are purchasers returning for repeat sessions?

Do not collect “might be useful someday” data.

---

# 15. Analytics source map

Prefer Apple-provided metrics when they already answer the question.

| Metric | Cheapest reliable source | In-app SDK? |
| --- | --- | --- |
| **Acquisition** | | |
| App Store impressions | App Store Connect Analytics | No |
| Product-page views | App Store Connect | No |
| Installs | App Store Connect | No |
| Search rank (`spirit box`, secondary) | Manual / ASO tooling, not SDK | No |
| **Activation** | | |
| First app open | In-app event | Yes |
| Free session start/complete | In-app event | Yes |
| REC used | In-app event | Yes |
| MARK used | In-app event | Yes |
| Replay opened | In-app event | Yes |
| **Monetization** | | |
| Paywall view | In-app event | Yes |
| Tonight / Lifetime purchase | Verified StoreKit completion → in-app event **and** App Store proceeds reports | Thin yes |
| Restore | In-app event | Yes |
| Refund/revocation | App Store Connect / future server notifications if ever added; client sees entitlement disappear | Prefer Apple; optional `entitlement_revoked` |
| Payer conversion / RPI | App Store Connect + cohort from in-app funnel | Hybrid |
| **Quality** | | |
| Recording-save failure | In-app event | Yes |
| Crash-free use | Xcode Organizer / MetricKit / Apple crash reports | Prefer Apple |
| Session duration | Optional coarse bucket in-app | Minimal |
| Sessions with MARK / replayed | Derived from events | Yes |
| Repeat paid sessions | `paid_session_started` count | Yes |
| **Reputation** | | |
| Rating / count / themes | App Store Connect + manual review reading | No |

Do not duplicate Apple sales dashboards inside the app.

---

# 16. Minimal event taxonomy

**OUR IMPLEMENTATION DECISION: 13 in-app events.**

| Event | When | Properties (only these) |
| --- | --- | --- |
| `app_first_open` | First launch after install | — |
| `free_session_started` | Free session STARTED | — |
| `free_session_completed` | Free session CONSUMED via full 180s path | `completion`: `full` \| `early_stop` |
| `recording_started` | User successfully starts REC | `session_type`: `free` \| `paid` |
| `recording_save_failed` | Finalize/save fails | `category`: coarse enum (`disk`, `permission`, `codec`, `unknown`) |
| `mark_used` | MARK tapped successfully | — |
| `replay_opened` | User opens a saved session replay | — |
| `paywall_viewed` | Paywall becomes visible | `trigger`: `start_blocked` \| `settings` |
| `purchase_started` | CTA begins StoreKit purchase | `product_id` |
| `purchase_completed` | Verified success only | `product_id`, `entitlement`: `tonight` \| `lifetime` |
| `purchase_failed` | Failure / unverified (not cancel) | `product_id`, `reason` |
| `restore_completed` | Restore finished | `result`: `lifetime` \| `tonight_active` \| `none` \| `failed` |
| `paid_session_started` | Full session starts while Tonight or Lifetime | `entitlement`: `tonight` \| `lifetime` |

### Do not collect

- Microphone audio / transcripts / spoken questions  
- MARK audio content  
- Paranormal interpretations / “what they heard”  
- Exact location, contacts, IDFA, fingerprinting  
- Per-fragment audio IDs as surveillance  

---

# 17. Analytics privacy / offline rules

Canonical marketing may say **Private by design** and **Works offline**. Analytics must not make those claims misleading.

Canonical already: do not claim Private by design until implementation/analytics verified.

## 17.1 Rules

| Rule | Decision |
| --- | --- |
| Offline queue | Events may queue locally and flush later |
| Analytics failure | **Never** blocks sweep, REC, MARK, replay, export, or cached entitlement use |
| Identifiers | Prefer provider anonymous install/session ids; no account id; no IDFA |
| Minimization | Only §16 events/properties |
| ATT | **Do not** require ATT for V1 analytics; do not use tracking/advertising APIs |
| Privacy Nutrition Labels | Declare accurately for any third-party SDK (typically Product Interaction / Usage Data — confirm against chosen SDK’s disclosure) |
| Trust copy | If third-party analytics ships, revise privacy paragraph before submission so it remains true (recordings local; sweep on-device; analytics = minimal anonymized product events) |

---

# 18. Analytics provider decision

## Options compared (enough to decide)

| Option | Effort | Cost @ small scale | Purchases | Product events | Offline queue | Privacy | Disclosure | Solo burden |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A. StoreKit + ASC + Apple crashes + **TelemetryDeck** (or equivalent privacy-first) | Low–med | Free/cheap tier | ASC + our events | Yes | Yes (SDK caches) | Strong fit | Modest | Low |
| B. StoreKit + RevenueCat + product analytics | Higher | RC + analytics | Strong RC charts | Split brain | Extra SDKs | Weaker for trust copy | Heavier | Higher |
| C. StoreKit + ASC only (no product SDK) | Lowest | Free | ASC only | Missing funnel | N/A | Best | Minimal | Can’t answer activation funnel well |

## V1 recommendation (locked)

**OUR IMPLEMENTATION DECISION: Option A**

```
StoreKit 2 (commerce)
+ App Store Connect Analytics / sales (acquisition & revenue)
+ Apple crash / energy reports via Xcode Organizer (stability)
+ One privacy-friendly product analytics provider (default recommendation: TelemetryDeck)
```

**No RevenueCat.**  
**No second product-analytics SDK.**  
**No advertising attribution SDK.**

If TelemetryDeck is unavailable or unacceptable at implementation time, substitute **one** equivalent privacy-first provider with the same constraints (no IDFA, offline non-blocking, minimal events). Do not silently expand scope to Firebase Analytics + ATT.

---

# 19. Analytics interface

Tiny app-facing API:

```text
Analytics.track(_ event: AnalyticsEvent)
```

- Central enum/struct for the §16 taxonomy  
- Single implementation module talks to the provider  
- Debug/test sink records events in-memory without network  
- Kill-switch / no-op mode if provider misconfigured  

Benefits: swap/disable provider, privacy audit in one file, test without network, keep instrument code free of SDK calls.

---

# 20. StoreKit test plan (maps to QA doc)

Do not duplicate `docs/engineering/QA_AND_FIELD_TEST_PLAN.md`. Extend it with these implementation details.

| QA IDs | Spec detail to implement/verify |
| --- | --- |
| E-01…E-03 | Full free session; no premature paywall; second START gated |
| E-04 | Apply §4 60s fairness rule |
| E-10…E-17 | Non-renewing purchase; 24h from `purchaseDate`; no auto-renew; expiry locks START only; restart persistence; restore best-effort; timezone absolute math; no Lifetime bleed |
| E-20…E-22 | Non-consumable Lifetime; restore; reinstall |
| E-30…E-32 | Recordings remain accessible |
| E-40…E-48 | Cancel/fail/pending/offline/unavailable/dup taps/interrupt/already-owned/Lifetime supersedes Tonight |
| O-01…O-09 | Offline instrument vs online commerce split; cached entitlement honored |

### Additional automation targets (`UNIT`)

- Tonight expiry math (`purchaseDate + 24h`)  
- Entitlement precedence  
- Trial STARTED/CONSUMED transitions  
- `canStartFullSession` matrix  

### Sandbox / TestFlight

- StoreKit Configuration file for local  
- Sandbox Apple ID for device  
- Ask to Buy / pending if available  
- Refund simulation where tooling allows; else manual revocation reconcile test

---

# 21. StoreKit configuration checklist

## 21.1 Local StoreKit Configuration (development)

- [ ] `.storekit` file in app project (future engineering PR)  
- [ ] Products: `spiritbox.tonight.24h` (Non-Renewing Subscription), `spiritbox.lifetime` (Non-Consumable)  
- [ ] Local prices matching launch hypotheses for US storefront testing  
- [ ] Clear/renew purchase helpers for iterative QA  
- [ ] Never ship production relying only on local config  

## 21.2 Real App Store Connect products

- [ ] Create Non-Renewing Subscription: Tonight Pass  
- [ ] Create Non-Consumable: Lifetime  
- [ ] Product IDs match app constants (or constants updated before submit)  
- [ ] Display name / localized description (honest duration / one-time language)  
- [ ] Price tiers for launch hypotheses  
- [ ] Availability / storefronts  
- [ ] Review screenshot / review notes if ASC requires for IAP  
- [ ] Tax category as required by ASC at setup time (do not invent; follow current ASC prompts)  
- [ ] Family Sharing decision for Lifetime (§7.4) — irreversible if enabled  
- [ ] Sandbox testers  
- [ ] TestFlight commerce verification  
- [ ] Production smoke: purchase, restore, offline entitled launch, recording access after expiry  

Separate **local config products** from **ASC products** in checklists and engineering notes.

---

# 22. Failure / recovery matrix

| Failure | Expected UX | Local state | StoreKit action | Analytics | Blocks session? |
| --- | --- | --- | --- | --- | --- |
| StoreKit unavailable | Can’t purchase; explain connection | Unchanged | Retry later | `purchase_failed` if attempted | Only **new paid purchase**; entitled/cached OK; replay OK |
| Transaction unverified | Error; no unlock | No grant | Do not finish as success | `purchase_failed` `unverified` | No false unlock |
| Pending purchase | Waiting for approval | `isPurchasePending` | Wait `Transaction.updates` | `purchase_started` | Until approved |
| Canceled purchase | Return to paywall | Unchanged | None | Prefer no event | No |
| Entitlement reconcile failure | Keep last verified cache; subtle retry | Last verified | Retry on foreground | Optional | No for cached entitled |
| Stale cached Tonight (past expiry) | Lock new sessions | Mark expired | Reconcile when online | — | New sessions only |
| Analytics unavailable | Silent | Unchanged | None | Queue/drop | **Never** |
| Recording saved, analytics failed | None visible | Recording kept | None | Drop/queue event | **Never** |
| Offline paid user | Full instrument | Cached entitlement | No purchase | Queue events | **No** |
| Trial persistence read failure | Fail **open** toward allowing one free session rather than hard-lock; log | Conservative `FREE_AVAILABLE` once + attempt rewrite | None | `recording_save_failed`-style quality only if needed | Prefer allow trial over permanent lockout |

Bias: **never break the core instrument because analytics failed.**

---

# 23. Implementation PR breakdown

After audio/scaffold work is merged and commerce is authorized:

### Recommended sequence (3 small PRs)

| PR | Scope | Depends on | Why separate |
| --- | --- | --- | --- |
| **PR A — Commerce foundation** | `ProductCatalog`, `PurchaseService`, `EntitlementStore`, StoreKit config file, unit tests for expiry/precedence | Merged scaffold | Review StoreKit correctness without UI |
| **PR B — Trial gate + paywall** | `TrialStore` (Keychain), START gating, paywall UI/copy, restore button, recording-access guarantees | PR A | Product behavior reviewable alone |
| **PR C — Minimal analytics** | `Analytics` façade + TelemetryDeck (or chosen provider) + §16 events only | PR B (so funnel events exist) | Privacy/disclosure review isolated |

**Not recommended:** one giant commerce+analytics PR.  
**Not recommended:** analytics before gating (useless/noisy).  
**Optional merge of A+B** only if staffing forces speed — still keep analytics separate for privacy review.

---

# 24. Open questions

Only items that still need product-owner input or cannot be fully closed from canonical + Apple docs:

| # | Question | Why it matters | Cheapest resolution | Recommended default |
| --- | --- | --- | --- | --- |
| 1 | Enable Family Sharing on Lifetime? | Irreversible ASC setting; affects shared household access | Product-owner yes/no before ASC product finalization | **Yes** enable for Lifetime |
| 2 | Exact privacy sentence once analytics ships | Trust copy must stay true | Draft App Privacy answers from TelemetryDeck disclosures; revise canonical privacy paragraph if needed | Keep “recordings stay on device”; disclose anonymized product analytics if present |
| 3 | Soft paywall entry from Settings before any START after consume? | UX only; not required by canonical | Decide during paywall UI PR | Optional Unlock entry **after** consume only |

### Explicitly not open

- Pricing ($1.99 / $9.99 hypotheses)  
- Presence of Tonight + Lifetime  
- No 7-day / no auto-renewing subscription / no ads  
- No account / no backend for V1  
- Paywall after real free session, not before  
- Recordings remain accessible after expiry  
- RevenueCat for V1 (**No**)  
- Tonight product type (**Non-Renewing Subscription**)  
- Lifetime product type (**Non-Consumable**)  
- Free-session fairness rule (§4)

---

## Platform constraints that materially affect implementation (not product intent)

1. **Non-renewing expiry is app-calculated** — Apple will not enforce our 24h window for us.  
2. **Non-renewing cross-device restore is app-responsible** — without a server/account, V1 is best-effort via StoreKit on the user’s Apple ID + local cache.  
3. **Family Sharing is not available for Tonight Pass** — only Lifetime (non-consumable) is eligible.  
4. **“Private by design” is conditional** — third-party analytics require honest privacy copy and Nutrition Labels even when recordings remain local.

These constraints do **not** change canonical pricing or the START → LISTEN → MARK → REPLAY loop; they constrain how entitlement persistence is engineered.

---

## Verification checklist (docs PR)

- [x] Canonical product SoT not modified by this task  
- [x] No Swift / Xcode / app code changes in this task  
- [x] No SDK/dependency added in this task  
- [x] No 7-day tier  
- [x] No auto-renewing subscription  
- [x] Recordings remain accessible after entitlement expiry  
- [x] No paywall before first real free session  
- [x] Platform claims cited from current Apple docs  
- [x] Product types explicit  
- [x] RevenueCat decision explicit: **NO for V1**  
- [x] Analytics stack explicit  
- [x] Analytics cannot block core offline use  
- [x] Minimal user-data collection  

---

## References (authoritative / verification)

1. `docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md` — product, pricing, privacy, analytics goals, technical direction  
2. `docs/launch/APP-STORE-CONVERSION-AND-ASO-PLAYBOOK.md` §10 — paywall copy  
3. `docs/engineering/QA_AND_FIELD_TEST_PLAN.md` §8–9 — entitlement/offline QA IDs  
4. Apple App Store Connect Help — [In-App Purchase types](https://developer.apple.com/help/app-store-connect/reference/in-app-purchases-and-subscriptions/in-app-purchase-types/)  
5. Apple StoreKit — [Transaction.currentEntitlements](https://developer.apple.com/documentation/storekit/transaction/currententitlements)  
6. Apple StoreKit — [Handling Subscriptions Billing](https://developer.apple.com/documentation/storekit/handling-subscriptions-billing) (non-renewing app responsibilities)  
7. Apple StoreKit — [Restoring purchased products](https://developer.apple.com/documentation/storekit/restoring-purchased-products)  
8. Apple App Store Connect Help — [Family Sharing for IAPs](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/turn-on-family-sharing-for-in-app-purchases)  
