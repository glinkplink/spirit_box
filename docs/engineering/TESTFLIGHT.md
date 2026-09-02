# Internal TestFlight

How to get a Spirit Box iOS build onto a physical iPhone **without a Mac**.

GitHub Actions is the macOS/Xcode environment. This document is operational, not product scope.

## Prerequisites

Repository secrets (GitHub → Settings → Secrets and variables → Actions):

| Secret | Purpose |
|---|---|
| `APPLE_TEAM_ID` | Apple Developer Team ID |
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_ISSUER_ID` | App Store Connect API issuer ID |
| `ASC_PRIVATE_KEY` | API key `.p8` PEM body (never commit this file) |

App Store Connect application Bundle ID (authoritative):

`com.glinkplink.spiritbox`

Do **not** create another Bundle ID or a second App Store Connect app for the audio harness.

The Xcode target/scheme may still be named `SpiritBoxAudioHarness`. Display name may still be `Audio Harness`. Those names can change later.

## Running a build

1. Merge the desired code to `main`.
2. Copy the **exact full 40-character** commit SHA to test (`git rev-parse HEAD` on that commit).
3. Open the GitHub repo → **Actions**.
4. Select **Internal TestFlight**.
5. Click **Run workflow**.
6. Paste `source_sha` (full SHA only).
7. Start the run.
8. Wait until archive / sign / upload succeeds (green workflow).
9. Wait for **Apple processing** (this is extra time after GitHub is green).
10. Open [App Store Connect](https://appstoreconnect.apple.com) → Spirit Box → TestFlight.
11. Confirm the build appears under **Internal Testing**.
12. Add/confirm yourself as an internal tester if needed.
13. Open **TestFlight** on the iPhone.
14. Install or update Spirit Box / Audio Harness.

GitHub Actions success means **upload succeeded**. It does **not** mean Apple has finished processing. Processing can take several more minutes.

## What the first physical harness build is for

With **DEV fixtures**, a physical iPhone may validate:

- app launches
- START / STOP
- speaker playback
- headphone playback
- sweep-rate controls
- FWD / REV
- noise continuity
- capture plumbing
- basic device stability

It does **not** pass the canonical audio gate.

Audio gate status:

`NOT YET RUN — WAITING FOR PHASE 1 CORPUS`

The canonical 15–20 minute listening test must use the actual realistic Phase 1 human corpus. Dev fixtures cannot pass that gate.

## Workflow behavior (for operators)

- Manual only (`workflow_dispatch`). Pushes do not upload to TestFlight.
- Builds **exactly** the SHA you pass. It will not silently build `HEAD` / `main`.
- Archives **unsigned** for `generic/platform=iOS`.
- Signs for App Store distribution at `xcodebuild -exportArchive` using automatic/cloud-managed signing and the App Store Connect API key.
- Does **not** use Development signing, a `.p12`, a registered device UDID, or committed provisioning profiles.
- TestFlight build number is `GITHUB_RUN_NUMBER` (`CURRENT_PROJECT_VERSION`). The project file is not edited per upload.

Existing PR/push iOS tests remain in `.github/workflows/ios-audio-harness.yml`. This workflow does not replace them.
