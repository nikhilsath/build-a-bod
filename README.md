# Build-a-Bod (iOS)
_A simple, offline-first walking & running tracker with smart route goals and privacy-respecting leaderboards._

[![iOS](https://img.shields.io/badge/iOS-16%2B-blue)]() [![Swift](https://img.shields.io/badge/Swift-5.9-orange)]() [![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-green)]() [![Firebase](https://img.shields.io/badge/Backend-Firebase-red)]()

> **One-liner:** Track walks/runs, auto-plan distance-fit routes (e.g., 5K), sync seamlessly when online, and compare with nearby opt-in leaderboards—no ads.

---

## Features (MVP)
- **Tracking:** time, distance, pace, calories, cadence, elevation, HR (via Apple Health/Workout).  
- **Map Goal Planner v2:** set a distance (e.g., 5K/10K); app suggests nearby loop/point-to-point routes that fit the goal.  
- **Apple Health + Activity integration:** read workouts/metrics; write completed workouts (user-approved).  
- **Offline-first:** full functionality offline; auto-merge/sync when back online.  
- **Friend comparison & leaderboards:** opt-in, privacy-preserving, coarse location buckets (e.g., “your park”).  
- **“Beat-Your-Best” alerts:** get notified when a session surpasses your best distance/pace/elevation.

### Differentiators
- **Map Goal Planner v2** (distance-fit routing with safety/elevation options).  
- **Real-Life Leaderboards** (proximity-based, weekly reset, opt-in, coarse location).  
- **Beat-a-Metric Notifications** (automatic, on-device thresholds; minimal server load).  
- **Offline-First Sync** (local store + conflict-free merges when online).

---

## Tech stack
- **App:** Swift 5.9, **SwiftUI**, Combine  
- **OS Target:** iOS **16+**  
- **Maps:** **Apple MapKit** (default)  
- **Sensors/Health:** HealthKit, CoreMotion, CoreLocation, ActivityKit (as needed)  
- **Data:** Local store (SQLite/Core Data) + **Firebase** (Auth + Firestore + optional Storage)  
- **Sync:** Background tasks + incremental Firestore sync

---

## Project structure (proposed)
```
BuildABod/
  App/
    AppEntry.swift
    DI/
  Features/
    Tracking/
    RoutePlanner/
    Leaderboards/
    Achievements/
    Settings/
  Services/
    HealthKitService.swift
    LocationService.swift
    MotionService.swift
    NotificationsService.swift
    SyncService.swift
    RoutingService.swift
  Data/
    Models/
    LocalStore/        # Core Data / SQLite
    Remote/            # Firestore clients
  UIComponents/
  Resources/
  Tests/
```

---

## Setup

### Prereqs
- Xcode 15+, iOS 16+ device/simulator.
- Apple Developer account (Health/Background modes).
- Firebase project.

### 1) Clone & open
```bash
git clone <repo-url>
cd BuildABod
open BuildABod.xcodeproj
```

### 2) Firebase
1. Create project at console.firebase.google.com.  
2. Add iOS app; download **`GoogleService-Info.plist`**; add to Xcode target.  
3. Enable **Authentication → Email/Password**.  
4. Enable **Firestore** (Native mode).  
5. Optional: **Storage** (for future screenshots/route assets).

### 3) Capabilities & permissions
- **HealthKit** (read: steps, distance, HR, cadence; write: workouts).  
- **Location** (When In Use + Precise optional; Background if needed).  
- **Motion & Fitness** (for steps/cadence).  
- **Background Modes:** location updates, background fetch, processing.  
- **Notifications:** for “Beat-a-Metric” alerts.

Add usage strings to `Info.plist`:
- `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`
- `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSMotionUsageDescription`
- `NSUserTrackingUsageDescription` (not used for ads, keep minimal)
- `UNUserNotificationCenter` usage text

---

## Running
1. Build & run in Xcode (iOS 16+).  
2. On first launch: sign up via **Email/Password** (Firebase Auth).  
3. Grant Health, Motion, Location permissions in-app flow.

---

## Privacy & Security
- **No ads. No data selling.**  
- **Data stored:** profile, workouts summary, anonymized leaderboard stats, route goals.  
- **Encryption:** TLS in transit; Firestore encrypted at rest; on-device store protected by iOS (NSFileProtection).  
- **Passwords:** handled by Firebase Auth (never stored by app).  
- **Deletion:** upon account deletion, Cloud data queued for **auto-purge after 90 days**; local device data wiped immediately on sign-out/delete.  
- **Export:** user can export their workout history as JSON/CSV (planned).

### Compliance posture (strict-first)
- **Consent:** explicit HealthKit scopes; separate toggles for Leaderboards & Notifications.  
- **Minimization:** store only needed aggregates for leaderboards (coarse geohash + week).  
- **Retention:** 90-day purge post-deletion; configurable server rule to hard-delete PII immediately and retain only anonymized aggregates where legally allowed.  
- **Access/Erasure:** in-app “Request data / Erase now” flows; support email for manual requests.  
- **Data locality:** prefer hosting in regions aligned with user locale when possible (multi-region Firestore + rules).  
- **RLS-style controls:** Firestore Security Rules enforce per-user access; leaderboards use server-computed, de-identified docs.  

---

## Leaderboards (privacy-preserving)
- Opt-in only; location hashed to coarse cells (e.g., ~1–2 km).  
- Weekly rotation; only top-N with pseudonyms.  
- No precise paths exposed; no friend lists unless mutually added.  
- Users can **hide** from boards or switch to friends-only.

---

## Offline-first sync (how it works)
- All sessions saved locally first.  
- Sync daemon batches writes to Firestore; conflict resolution: “last-writer-wins” on scalar fields + merge for arrays/counters.  
- On poor signal, routing degrades to cached tiles + dead-reckoning; session still valid.

---

## Notifications (“Beat-Your-Best”)
- On-device thresholds (personal bests cached locally).  
- Trigger while recording (pace/distance/elevation) and on save.  
- Optional weekly summary.

---

## Roadmap (high-level)
- **M1:** Tracking + HealthKit + Map Goal Planner v2 + Offline store + Email Auth  
- **M2:** Leaderboards (opt-in) + Beat-Your-Best + Export  
- **M3:** Battery-Saver GPS mode + iOS Widgets + Basic Achievements  
- **M4:** Accessibility polish (voice control, large type), multi-lang groundwork

---

## Testing
- **Unit:** XCTest (services, models).
- **UI:** XCUITest for start/stop, permission flows.
- **Health/Location fakes:** inject mock services for simulator.
- **CI:** GitHub Actions uses Xcode 16.2.0 to build the project and run all unit and UI tests on every PR. It lists available simulators with `xcrun simctl list` and targets an iPhone 14 on the latest iOS version.

### Adding UI tests to CI
1. Add tests to the `build-a-botUITests` target.
2. Ensure the tests are part of the shared `build-a-bot` scheme in Xcode (Product → Scheme → Manage Schemes… → check **Shared**).
3. Commit and push; the workflow in `.github/workflows/ci.yml` will pick them up automatically.

---

## Dev tips
- Use dependency injection for `LocationService`, `HealthKitService`, `SyncService`.  
- Keep all PII access behind a `PrivacyGate` module.  
- Feature flags for Leaderboards/Notifications to ease App Review iterations.

---

## Contributing
This is proprietary. Read-only for colleagues. Please open PRs; do not redistribute code or assets.

---

## License
Proprietary License  
© 2025 Nikhil Sathyanarayana / Build-a-Bod. All rights reserved.

---

## FAQ
**Q: Why iOS-only?** Best HealthKit/MapKit integration for v1; Android later.  
**Q: Why Firebase?** Fast Auth/Sync, good iOS SDK, minimal ops.  
**Q: Can I use it offline?** Yes—everything essential works offline; sync resumes automatically.  
**Q: Age rating?** 18+ (simplifies consent & account terms).
