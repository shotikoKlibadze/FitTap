# watchOS

Reference notes on building workout experiences for Apple Watch, project-agnostic. These notes describe what exists, how it behaves, and what Apple states about it. They are more current than model training data.

API names are taken from Apple's sessions; where a session publishes no code the names come from narration and are marked as such. Items marked ⚠️ are unconfirmed.

**Code examples:** [`code/`](code/) — one file per ingested session, named after the video title. A file's presence means that session's transcript and code are ingested.
**Sources:** WWDC25 334 "What's new in watchOS 26" · WWDC23 10023 "Build a multi-device workout app" (+ its sample project, MirroringWorkoutsSample) · WWDC23 10016 "Build custom workouts with WorkoutKit"
**Related:** [`../iOSHealthKit/`](../iOSHealthKit/README.md) for `HKWorkoutSession`, builders, zones and statistics.

---

## 1. WorkoutKit (iOS 17 / watchOS 10)

→ `code/BuildCustomWorkoutsWithWorkoutKit.swift` (narration only, no published snippets)

A Swift framework that lets an app **create the same workout types a user can build in the Workout app** and hand them to the Watch: preview them, save them into the Workout app, or **schedule** them so the Workout app shows them under the app's own name. It is the bridge *into* Apple's Workout app; health data from the performed workout still comes back through HealthKit.

### Workout types
- **Goal** (single target: distance, energy or time), **Pacer** (pace/speed), **Swim-bike-run**, **Custom** (structured steps with goals and alerts).
- Constraints: swimming is **not** supported in custom workouts (use a goal composition); **alerts exist only in custom workouts**; not every activity type supports distance goals or every alert type (elliptical has no pace), so fall back to time/open goals or heart-rate-zone alerts.

### Custom workout structure
- `CustomWorkoutComposition(activity:location:displayName:warmup:blocks:cooldown:)` ⚠️ (parameter names from narration): a **warmup step**, an ordered list of **`IntervalBlock`s**, a **cooldown step**.
- `IntervalBlock(steps:iterations:)`: any number of `BlockStep`s of type `.work` or `.rest`, repeated `iterations` times.
- Every step has **one goal** (`WorkoutGoal`: `.time`, `.distance`, or open) that decides when the step ends, and **optionally one alert**.
- `WorkoutAlert(target:type:)` with `WorkoutAlertTargetType` `.target(HKQuantity)`, `.range(...)` or heart-rate **zone**, and `WorkoutAlertType` `.currentPace`, `.currentPower`, cadence, heart rate. Goals and alert values use `HKQuantity` / `HKUnit`, so `import HealthKit` too.
- On the Watch during the workout: current step, goal progress, the step's alert metric (or heart rate when none), and a preview of the next step.

### Validation and files
- Initializers `throw`: compositions are validated (e.g. distance goal on a non-distance activity, pace alert on an unsupported activity). Validation also runs on export and preview; errors are granular.
- `WorkoutComposition` wraps any composition type for extra operations: `dataRepresentation` exports **JSON or binary** (binary recommended, smaller), importable from a `.workout` file for sharing across devices.

### Preview
- `try await composition.presentPreview()`:
  - **iOS**: an out-of-process sheet over the app showing the full composition, with **"Add to Watch"** to save into the Workout app.
  - **watchOS**: launches the Workout app with the composition; the user can start it or save it.

### Scheduling (`WorkoutPlan`)
- `WorkoutPlan.authorizationState` / `WorkoutPlan.requestAuthorization()` (user opts into syncing; changeable in Watch settings).
- `WorkoutPlan.current` holds `scheduledCompositions: [ScheduledWorkoutComposition]` (composition + `scheduledDate` + completion state). Append and `save()` to sync locally to the Watch.
- The app gets a **dedicated slot at the top of the Workout app** with its icon and name and today's next workout; tapping starts it, the ellipsis shows the schedule.
- Limits: the user sees **±7 days**; **up to 15 workouts** synced at a time.
- Completion state updates when the user finishes the workout in the Workout app; query `WorkoutPlan.current` to read it, and write completion back if the user completed it in your app. Scheduled workouts carry **no health data**: read the `HKWorkout` from HealthKit, which gains an extension to retrieve the originating composition.
- Apple's guidance: keep the schedule fresh using any foreground or background runtime.

---

## 2. watchOS 26 platform changes

→ `code/WhatsNewInWatchOS26.swift`

### Design and architecture
- New system design (Liquid Glass): toolbar and control styles update automatically for apps built for watchOS 10+; audit custom styles for legibility. App icons via **Icon Composer**; the iOS icon shows in forwarded notifications, the Watch icon in the grid and direct notifications.
- **arm64** on Apple Watch Series 9+ and Ultra 2. Use the "Standard Architectures" build setting; watch for `Float`/`Int`/pointer differences; the simulator has been arm64 on Apple Silicon all along.

### Controls (WidgetKit)
- Controls appear in **Control Center, the Smart Stack, and on the Ultra's Action button**. Built with the same `ControlWidget` API as iOS.
- An **iPhone app's controls can be placed on the Watch with no Watch app**; the action runs on the iPhone (controls that foreground the iPhone app don't appear). With a Watch app, controls run on the Watch.
- Configurable widgets and controls: return `[]` from `recommendations()` (gated with `#available(watchOS 26, *)` for older versions); controls use `AppIntentControlConfiguration` + `AppIntentControlValueProvider` + `.promptsForUserConfiguration()`.
- Choosing: **control** when the purpose is an action, **widget** for information through the day, **Live Activity** for events with a start and end.

### Workout app suggestions
- Watch apps that record workouts with HealthKit can be **suggested in the Smart Stack** based on routine; a tap starts the workout. To qualify: correct `HKWorkoutActivityType`, accurate start/end times, and `HKWorkoutRouteBuilder` location data through the workout.

### RelevanceKit and relevant widgets
- `RelevantContext` types: date, sleep schedule, fitness information, location, and (new) **point-of-interest categories** (`RelevantContext.location(category:)`, returns `nil` if unsupported). Return `WidgetRelevance` with `WidgetRelevanceAttribute`s.
- **Relevant widget** (`RelevanceConfiguration` + `RelevanceEntriesProvider` + `RelevanceEntry`): Smart Stack-only; the system may show **several cards at once**, one per relevant configuration, instead of one truncated timeline entry. Provider methods: `relevance()`, `entry(configuration:context:)` (handle `context.isPreview`), `placeholder(context:)`.
- `.associatedKind(_:)` links a relevant widget to its timeline twin so the Smart Stack shows one card per event, not two.
- Previews: `#Preview` with `relevanceEntries:`, `relevance:`, or `relevanceProvider:` blocks.

### Other
- **Push updates for widgets via APNs**, on every WidgetKit platform; the reason to finish migrating ClockKit complications.
- MapKit on watchOS: local search, routes by transport type, route overlays in SwiftUI.

## 3. Mirrored workout sessions, Watch ↔ iPhone (iOS 17 / watchOS 10)

→ `code/BuildAMultiDeviceWorkoutApp.swift` (excerpts from Apple's sample project; API names below are confirmed by it)

The Watch runs the **primary** `HKWorkoutSession`; the iPhone holds a **mirrored** session. HealthKit keeps their **states in sync** (pause on one pauses the other), and either side can control the workout.

### Flow
1. iPhone, at every launch (foreground or background): set **`healthStore.workoutSessionMirroringStartHandler`** so it can receive a session.
2. iPhone: `try await healthStore.startWatchApp(toHandle: configuration)` launches the Watch app with an `HKWorkoutConfiguration`; the Watch receives it in `WKApplicationDelegate.handle(_ workoutConfiguration:)` (via `@WKApplicationDelegateAdaptor`).
3. Watch: create the primary session and its `HKLiveWorkoutBuilder` + `HKLiveWorkoutDataSource`, call **`try await startMirroringToCompanionDevice()`**, then `startActivity(with:)` and `beginCollection(at:)`. HealthKit launches the iPhone app in the background and gives it **10 seconds** to start a Live Activity and receive the session via the handler.
4. Both sides set session delegates for state changes and events. **Keep a strong reference** to the mirrored session on the iPhone.
5. Controls (`pause()`, `resume()`, `stopActivity(with:)`) work on either session; the state change reaches both delegates.
6. End on the Watch only after the delegate reports `.stopped`: `builder.endCollection(at:)` → `builder.finishWorkout()` → `session.end()`.

### Data between devices
- `try await session.sendToRemoteWorkoutSession(data:)` on either session; the other side's delegate gets `workoutSession(_:didReceiveDataFromRemoteWorkoutSession: [Data])`. Apple's example: `HKStatistics` Watch → iPhone for display, a water `HKQuantity` iPhone → Watch saved with `builder.addSamples`. Both are encoded with `NSKeyedArchiver` (secure coding); the sample also sends a `Codable` elapsed-time stamp so the iPhone timer matches the Watch.
- While an app is suspended, HealthKit buffers incoming data and delivers it as one array, in arrival order, on resume.
- `stopMirroringToCompanionDevice` ends mirroring; the mirrored side gets `workoutSession(_:didDisconnectFromRemoteDeviceWithError:)`.
- End and save on the Watch (finish the builder); the `HKWorkout` syncs to iPhone and iPad for the summary.

### From the sample project
- Setup: HealthKit capability on both targets, Health usage descriptions, Watch `WKBackgroundModes` = `workout-processing`, `WKCompanionAppBundleIdentifier`. Physical devices only.
- Session and builder delegates run on an **anonymous serial background queue**: mark them `nonisolated` and hop to the main actor. The sample funnels state changes through an `AsyncStream` with `.bufferingNewest(1)` because actor tasks aren't FIFO.
- Authorization: iPhone/iPad use `.healthDataAccessRequest`; the Watch calls `healthStore.requestAuthorization(toShare:read:)`.
- A custom `TimelineSchedule` that returns no entries while paused drives the live elapsed-time display (30 fps, 1 fps in always-on).

### Also in this session
- Cycling data types: speed, power, cadence, **FTP** (auto-calculated by the Watch from paired Bluetooth sensors). Bluetooth cycling sensors pair directly, like HR monitors.
- HealthKit and the Health app on **iPad** (iOS 17): authorization must present over the right scene. SwiftUI: `import HealthKitUI`, `.healthDataAccessRequest(store:shareTypes:readTypes:trigger:)`; UIKit: `healthStore.authorizationViewControllerPresenter`.
- Use sync identifiers and version numbers to keep data consistent across a server and devices.

## 4. Open questions

- Exact initializer labels for `CustomWorkoutComposition`, `BlockStep`, `WorkoutAlert`, and the HKWorkout → composition extension name.
- Whether strength-training activity types work meaningfully with custom compositions (goals are time/distance/open; no rep or set concepts).
- WorkoutKit changes after watchOS 10 (WWDC24 added pool swimming and step `displayName`; WWDC25/26 not yet ingested).
- Whether Smart Stack workout suggestions apply to strength workouts without route data.
- Not yet ingested: "Build a workout app for Apple Watch" (WWDC21 10009), WWDC26 watchOS Group Lab, "Extend your app's controls across the system", "What's new in widgets".
