# HealthKit

Reference notes on HealthKit workouts on Apple platforms, project-agnostic. These notes describe what exists, how it behaves, and what Apple states about it. They are more current than model training data.

API names and shapes are confirmed against Apple's published sample code (see `code/`). Items marked ⚠️ are unconfirmed.

**Platforms:** iOS 27, watchOS 27 (workout zones); HealthKit itself on iOS, iPadOS, watchOS, visionOS
**Code examples:** [`code/`](code/) — one file per ingested session, named after the video title, holding Apple's published snippets with timestamps. A file's presence means that session's transcript and code are ingested.
**Sources:** WWDC26 207 "Deliver workout insights with HealthKit workout zones" · WWDC25 322 "Track workouts with HealthKit on iOS and iPadOS" · WWDC22 10005 "What's new in HealthKit"

---

## 1. Workout zones (iOS 27 / watchOS 27)

→ `code/DeliverWorkoutInsightsWithHealthKitWorkoutZones.swift`

HealthKit now computes **time in zone** for **heart rate** and **cycling power** during workouts, and exposes the user's zone configuration to apps. Zones turn raw samples into intensity: a 135 bpm sample falls in, say, Zone 3; a workout spent mostly in Zones 4–5 was a hard effort.

### Concepts
- **Heart rate zones:** typically 5, personalized from **age and resting heart rate**. **Cycling power zones:** watts, based on functional threshold power; the system defaults to 6, training apps use 5, 7 or 8.
- **Authorization:** same flow as other types; request the relevant quantity types (workouts, heart rate, cycling power) before reading zones.
- **Sources** of a configuration (`HKWorkoutZoneConfiguration.source`): **system** (calculated automatically), **user** (set manually in Health settings), **app** (custom, supplied at workout time).
- **Preferred zones** live in Health settings, sync across devices via HealthKit, and are what HealthKit uses by default, giving a consistent experience across apps.

### Types
- `HKWorkoutZoneGroup` = `configuration: HKWorkoutZoneConfiguration` + `zoneDurations: [...]` (zone + time spent, ordered by threshold).
- `HKWorkoutZoneConfiguration` = `quantityType`, `source`, `zones` ordered by boundary. Each zone has an `index` and min/max `HKQuantity`; the first has no lower bound, the last no upper bound; zones are **contiguous and non-overlapping**.

### Reading zones from a completed workout
- `workout.zoneGroupsByType?[HKQuantityType(.heartRate)]` on an `HKWorkout` **or** an individual `HKWorkoutActivity` (so multi-sport workouts can be broken down per activity). Swap the quantity type for cycling power.
- `zoneGroup.zoneDurations.map(\.duration)` gives the per-zone times for charting.

### Live zone updates during a workout
- `HKLiveWorkoutBuilderDelegate` gains `workoutBuilder(_:didUpdateWorkoutZone:)` with an `HKLiveWorkoutZoneUpdate`: current zone duration, previous zone, the whole `zoneGroup` (configuration + running totals), and the timestamp of the last processed sample (for a running "time in current zone" timer).
- Updates fire **only when the zone changes** (e.g. Zone 2 → Zone 3), as HealthKit processes incoming samples.

### Preferred vs custom configurations
- Query the preferred configuration on `HKHealthStore` or `HKWorkoutBuilder`: `try await builder.zoneConfiguration(for: HKQuantityType(.heartRate))`; `nil` means none is set.
- **Custom zones** are for apps with their own zone model. Build `[HKQuantity]` boundaries with a unit compatible with the quantity type (bpm = `HKUnit.count().unitDivided(by: .minute())`), create `HKWorkoutZoneConfiguration(quantityType:zoneBoundaries:)`, then `try await builder.setCustomZoneConfiguration(_, for:)` **before `beginCollection(at:)`**.
- Rules: the first zone starts at 0 and the last is unbounded; **3 to 9 zones**; custom configurations are stored **only within that workout**, so the app persists and syncs them itself.

### Comparing across workouts
- Zone counts and thresholds vary between workouts (especially cycling power). "Zone 3" in a 5-zone workout is not "Zone 3" in a 7-zone one. To compare time-in-zone across workouts, **re-bucket the original samples** into the app's own zone count instead of comparing zone indices.

### Apple's suggested uses
- Post-workout summary charts; live "stay in zone" coaching with notifications on zone change; long-term training dashboards; classifying workout intensity and balancing load and recovery.

---

## 2. Workout model since iOS 16 / watchOS 9

→ `code/WhatsNewInHealthKit.swift` (narration only, no published snippets)

### Multi-activity workouts
- An `HKWorkout` holds `workoutActivities: [HKWorkoutActivity]`. Each activity has its own `HKWorkoutConfiguration` (activity type), its own events, and its own statistics. Activities **cannot overlap** and need not be contiguous; gaps can be captured as activities of type `.transition`.
- **Intervals** are activities whose type equals the workout's type (a running workout with four `.running` activities), which yields per-interval statistics.
- Saving with `HKWorkoutBuilder`: create `HKWorkoutActivity(workoutConfiguration:start:end:metadata:)` and call `addWorkoutActivity`.
- Live on Apple Watch: `HKWorkoutSession` with a `.swimBikeRun` (or any) configuration → `startActivity` + `builder.beginCollection`, then `beginNewActivity(with:date:)` / `endCurrentActivity(on:)` per leg. **Update the builder's data source at the start of each activity** so only relevant types are collected. Ending the session ends any running activity; `finishWorkout` returns the `HKWorkout`.

### Reading metrics
- `totalEnergyBurned`, `totalDistance`, `totalSwimmingStrokeCount` on `HKWorkout` are **deprecated** in favour of `statistics(for: HKQuantityType)`, available on both `HKWorkout` and `HKWorkoutActivity`. Statistics are computed automatically **only for workouts built with `HKWorkoutBuilder` / `HKLiveWorkoutBuilder`**.
- New predicates: `HKQuery.predicateForWorkoutActivities(...)` (e.g. average heart rate > 150 bpm) wrapped in `predicateForWorkouts(activityPredicate:)` to find workouts by what happened inside an activity.

### Async queries (iOS 15.4+)
- Every `HKQuery` subclass has a descriptor twin: `HKStatisticsCollectionQueryDescriptor`, `HKSampleQueryDescriptor`, etc. `result(for: healthStore)` returns once; `results(for:)` returns an `AsyncSequence` that keeps delivering updates until you break out of the loop. Example: weekly calories with `.cumulativeSum`, `anchorDate` = this Sunday, interval = one week.

### Automatic metrics on Apple Watch
- Running: stride length, running power (watts) and more, Series 6 / SE and newer. Swimming: **SWOLF** per lap and segment.
- **Heart rate recovery**: quantity type `.heartRateRecoveryOneMinute`, saved automatically after an `HKLiveWorkoutBuilder` workout with metadata (test type such as `.maxExercise`, activity type, activity duration, max heart rate). Apps can save their own samples with the same metadata keys.

### Other iOS 16 additions
- **Sleep stages** (`HKCategoryValueSleepAnalysis`): `.asleepCore`, `.asleepDeep`, `.asleepREM`, `.asleepUnspecified` (replacing `.asleep`); `predicateForSamples(...)` per stage and `.allAsleepValues` to cover all.
- **Vision prescriptions** (`HKGlassesPrescription`, `HKContactsPrescription`) with PDF/image attachments via `HKAttachmentStore`, and **per-object read authorization** (`requestPerObjectReadAuthorization`).

---

## 3. Workout sessions on iPhone and iPad (iOS 26)

→ `code/TrackWorkoutsWithHealthKitOnIOSAndIPadOS.swift`

`HKWorkoutSession` + `HKLiveWorkoutBuilder`, previously Watch-only, run on iPhone and iPad with the same code and minimal changes. All activity types are available.

### Session lifecycle
1. `HKWorkoutConfiguration` with `activityType` and `locationType`.
2. `HKWorkoutSession(healthStore:configuration:)`, set `delegate`.
3. `session.associatedWorkoutBuilder()`, set its `delegate` and `dataSource = HKLiveWorkoutDataSource(healthStore:workoutConfiguration:)`.
4. `session.prepare()`, then a **3-second countdown** so sensors or an external HR monitor connect and metrics exist from the first second.
5. `session.startActivity(with:)` + `try await builder.beginCollection(at:)`.
6. Live metrics: `workoutBuilder(_:didCollectDataOf:)` → `builder.statistics(for: quantityType)`. No anchored object query needed; the builder keeps metrics in sync for the saved workout.
7. End: `session.stopActivity(with:)`, wait for the state change to `.stopped`, then `builder.endCollection(at:)`, `builder.finishWorkout()`, `session.end()`.

### Sensors and data types
- iPhone/iPad have **no heart-rate sensor**; pair any **Bluetooth heart-rate (GATT) device** (wearable monitor, Powerbeats Pro 2) and HealthKit saves its samples automatically.
- **Generated types** (system-produced: calories, distance) vs **collected types** (what the builder observes and attaches). On iOS the data source starts with **all possible types** for the activity, including heart rate even with no sensor. `enableCollection(for:)` / `disableCollection(for:)` adjust it; samples the app saves itself (e.g. dietary water) flow to the builder once collection is enabled.
- The builder delegate reveals which types the system is actually generating.

### Reading metrics after the save
- Summary: `workout.statistics(for:)`. Charts over time: `HKStatisticsCollectionQuery` with an interval.
- Fine-grained data: quantity samples attached to a workout can have `count > 1` (series); read them with **`HKQuantitySeriesSampleQuery`**. True for historical Watch workouts and iOS-saved ones.

### Locked device
- Health data is normally unavailable while locked. On the **first** session start the system prompts that workout data will be available to the app while locked. Design UI for the denied case: show duration only, hide missing metrics.
- Pair with a **Live Activity** for lock-screen metrics.
- **Siri on the lock screen** can start / pause / resume / cancel the workout via `INStartWorkoutIntent`, `INPauseWorkoutIntent`, `INResumeWorkoutIntent`, `INEndWorkoutIntent` handled by an `INExtension` **inside the main app** (not a separate extension), wired through `application(_:handlerFor:)` in a `UIApplicationDelegateAdaptor`. Return `.failureOngoingWorkout` when a session is already running. HealthKit saves the workout once the phone is unlocked.

### Crash recovery
- The system **relaunches the app** after a crash; session and builder come back in their previous state; **only the data source must be recreated**.
- iOS/iPadOS: in `application(_:configurationForConnecting:options:)`, check `options.shouldHandleActiveWorkoutRecovery`, call `healthStore.recoverActiveWorkoutSession`, then reattach delegates and a fresh `HKLiveWorkoutDataSource`.

### Apple's best practices
- With a Watch app, start the workout on the Watch (`healthStore.startWatchApp`) for the full sensor set, and **mirror** it to the iPhone (WWDC23 "Build a multi-device workout app").
- Request authorization only for types the app needs.
- **Always save through the workout builder** so Activity rings update.

---

## 4. Open questions

- Exact types of `zoneDurations` elements and `HKLiveWorkoutZoneUpdate` properties beyond those in the snippets.
- Whether zones are computed for workouts recorded by other apps or imported, and for strength workouts with sparse HR samples.
- `HKHealthStore` API name for the preferred configuration query.
- Exact signatures of `beginNewActivity` / `endCurrentActivity`, the activity-predicate API, and the heart-rate-recovery metadata keys (narration only).
- Whether `INExtension`-based workout intents coexist with App Intents, and whether the lock-screen prompt is per app or per session type.
- Not yet ingested: "Build a workout app for Apple Watch" (WWDC21 10009). WorkoutKit, mirrored sessions and watchOS 26 are covered in `../watchOS/`.
