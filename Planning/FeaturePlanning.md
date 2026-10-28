# Feature planning

Candidate features for FitTap, with what each does and why it exists. A working list, not a commitment. Scope and priorities answer to [CLAUDE.md](../CLAUDE.md). AI features live in [AIFeaturePlanning.md](AIFeaturePlanning.md).

Every feature is judged by the tap test: fewer taps than the competitor, or it isn't done.

## Feature list

- **Logging:** tap-to-log chips · smart defaults from history · repeat last set · sensible increments · load modes · kg/lb · cardio and timed entries · bodyweight exercises · auto rest timer · quick notes
- **Workouts:** templates · start from template or empty · exercise catalog + custom exercises · search and recents · reorder and swap mid-session · session status · simple weekly schedule
- **Home:** today card · streak and consistency · last session glance · one nudge slot
- **Statistics:** per-exercise progress · auto PRs · volume and frequency per muscle · cardio trends · calendar · optional body weight log
- **Watch:** wrist logging · rest timer haptics · HKWorkoutSession recording · start from iPhone · mirrored session · live sync · effort rating · auto start/stop detection
- **HealthKit:** read workout metrics · write workouts · sets as workout activities · read body weight · permission on first use
- **Siri / App Intents:** core intents with App Shortcut phrases · indexed entities · `system.search` / `system.open` schemas · on-screen annotations · intent donations · dialog variants · intents testing
- **Later:** nutrition · widgets and Live Activities · iCloud sync · CSV export · plate calculator

---

## 1. Logging

The core of the app. Everything else exists to make this faster or to show what it produced.

| Feature | What it does | Why |
|---|---|---|
| **Tap-to-log sets** | For each exercise, the most-used weights and rep counts are shown as chips. One tap logs a set. Free-form entry is an escape hatch behind a second tap. | The canonical example in the constitution: 1 tap for 10 kg, not 3. |
| **Smart defaults from history** | The first chip row is pre-filled from the last session of the same exercise: same weight, same reps. | The app anticipates; the user confirms. |
| **Repeat last set** | One tap duplicates the previous set. | Most sets in a session are identical. |
| **Sensible increments** | ± buttons step by the right amount per equipment: 2.5 kg barbell, 2 kg dumbbell, one plate on a machine stack. | Faster than typing; matches what's physically in the gym. |
| **Load modes** | Weight is entered the way the user thinks about it: per side, per hand, machine stack, total. Stored normalized. (`LoadMode`, `LoadMath` exist.) | Removes the "do I count the bar?" question. |
| **Weight units** | kg / lb, per user, with correct rounding to real plates. (`WeightUnit` exists.) | Table stakes. |
| **Cardio and timed entries** | Duration, optional distance, optional count (rounds, laps). (`CardioEntry` exists.) | Running, rowing, MMA rounds, CrossFit WODs all fit one shape. |
| **Per-activity cardio metrics** | Predefined cardio exercises each carry their own metric shape: running = distance + time + pace, boxing = rounds × minutes per round, rowing = distance + intensity, and so on. The logging UI shows only that activity's fields. User-defined cardio activities maybe later. | "Rounds" on a run or "pace" on sparring is noise; each activity asks only what the user actually tracks. |
| **Bodyweight exercises** | Reps only, optional added weight. (`ExerciseKind.bodyweight`.) | Pull-ups and dips without a fake weight field. |
| **Rest timer** | Starts automatically after a set is logged. Shows on Watch and Lock Screen / Live Activity. | Zero taps; the user never opens a stopwatch. |
| **Quick notes** | Optional one-line note on a set or session ("left knee"). | Depth is opt-in; it's hidden until tapped. |

## 2. Workouts and templates

| Feature | What it does | Why |
|---|---|---|
| **Workout templates** | Named workouts with an ordered exercise list, type (strength / cardio), color, primary and secondary muscle groups. (`WorkoutTemplate` exists.) | Starting a session is one tap on a template. |
| **Start from template or empty** | Tap a template to start, or start blank and add exercises as you go. | Covers planned and improvised sessions. |
| **Exercise catalog** | Seeded list with kind, equipment, muscle groups; user can add their own. (`ExerciseSeedCatalog`, `Exercise`.) | No typing exercise names mid-set. |
| **Exercise search and recents** | Recents first, then search. | Most people rotate 20 exercises. |
| **Reorder and swap mid-session** | Drag to reorder; swap an exercise if a machine is taken. | Gym reality. |
| **Session status** | Planned, done, missed. (`WorkoutSessionStatus` exists.) | Lets Home show "today" and the calendar show consistency. |
| **Planned sessions / simple schedule** | Assign templates to days of the week. Home shows what's next. | Defaults over configuration; no periodization editor. |

## 3. Home

| Feature | What it does | Why |
|---|---|---|
| **Today card** | Next planned workout, one tap to start. If a session is in progress, resume it. | The screen shows what matters now. |
| **Streak / consistency** | Weeks trained in a row, sessions this week vs. usual. | The one metric this user cares about. |
| **Last session glance** | One line: what, how long, any PR. | Closure without opening Statistics. |
| **One nudge slot** | At most one coach nudge (see AI plan). Empty when there's nothing to say. | Calm screen. |

## 4. Statistics

Depth is opt-in: the tab is a few summaries; everything else is one tap down.

| Feature | What it does | Why |
|---|---|---|
| **Per-exercise progress** | Best set, estimated 1RM trend, volume over time. Tap an exercise to see it. | The question "am I getting stronger?" |
| **Personal records** | Auto-detected PRs (weight, reps at weight, distance, time). Marked in the session, listed per exercise. | Motivation without configuration. |
| **Volume and frequency** | Sessions per week, sets per muscle group per week. | Surfaces imbalance; feeds the "same muscle repeatedly" nudge. |
| **Cardio trends** | Pace, distance, duration per activity over time. | Same question, for runners. |
| **Calendar view** | Month grid of done / missed / planned. | Consistency at a glance. |
| **Body weight log** (optional) | Weight over time, from HealthKit if available. | One number, only if the user wants it. |

## 5. Apple Watch

The Watch logs; the phone thinks. The companion app mirrors the current session.

| Feature | What it does | Why |
|---|---|---|
| **Watch logging** | Current exercise, the same weight/rep chips, one tap per set. Crown adjusts weight. | Phone stays in the bag. |
| **Rest timer on wrist** | Haptic when rest ends. | No looking at the phone. |
| **Workout session recording** | Starts an `HKWorkoutSession` with the right activity type so HR, calories and duration are recorded by watchOS. | Gets the health data for free, shows in Fitness rings. |
| **Start from iPhone** | "Start workout" on the phone launches the Watch app and starts the session there (`startWatchApp(toHandle:)`). Requires the FitTap Watch app installed. ⚠️ Whether the Watch must be worn and unlocked: verify on device. | The user starts where the phone already is; the Watch still records. |
| **Mirrored session** | The Watch session mirrors to the iPhone (`startMirroringToCompanionDevice`): both show the same live timer and HR; pause, resume, end work from either. Only one workout session runs at a time, so FitTap replaces Apple's Workout app for that session. | Log on whichever device is in hand. |
| **Live sync** | Sets logged on either device appear on the other within seconds. During a workout, sets travel as `Data` over the mirrored session (`sendToRemoteWorkoutSession(data:)`); outside a workout (history, templates, settings), via WatchConnectivity. The Watch owns the live session's sets; no duplicates or conflicts. Reference: [Knowledge/watchOS/README.md §3](../Knowledge/watchOS/README.md). | One source of truth. |
| **Effort rating** | One tap on a 1–10 scale at the end of the session, in FitTap's own UI. Stored with the session; also written to HealthKit's workout effort score so Fitness and Training Load see it (⚠️ API not yet in Knowledge). | How hard it felt, for one tap; feeds progression nudges. |
| **Auto start/stop detection** | Suggests starting a session when motion and HR look like training; suggests ending when they stop. (Rules first; model later; see AI plan.) | Removes the Start tap. |

## 6. HealthKit

| Feature | What it does | Why |
|---|---|---|
| **Read workout metrics** | HR samples, HR zones, active calories, distance, duration from the Watch session, attached to the FitTap session. | Raw material for session interpretation and cardio stats. |
| **Write workouts** | Strength and cardio sessions written to HealthKit with exercise details where the API allows. | Appears in Fitness and other apps. |
| **Sets as workout activities** | Each logged set becomes an `HKWorkoutActivity` (same type as the workout) inside the session's `HKWorkout`, bounded by `SetEntry.loggedAt`; cardio blocks the same via `CardioEntry.startedAt` + `duration`. Exercise, weight and reps ride in activity metadata. Gaps between activities are the rest periods. Per-set and per-exercise HR come back free via `activity.statistics(for:)`. The link is `WorkoutSession.healthKitWorkoutID`. FitTap's store stays canonical; HealthKit is a projection, never a source for sets. ⚠️ Sets last seconds; per-set statistics need validation against HR sampling cadence — fall back to `HKWorkoutEvent` markers per exercise if too sparse. | The intervals pattern from [Knowledge/iOSHealthKit/README.md §2](../Knowledge/iOSHealthKit/README.md): per-set effort and rest with zero extra taps, and a well-formed workout for Fitness and other apps. |
| **Read body weight** | For the optional body weight log and for bodyweight-exercise load. | No manual entry. |
| **Permissions UX** | Asked on first relevant use, not at launch; the app works fully without HealthKit. | Design for denial. |
| **Import native Workout app sessions** | Reads `HKWorkout`s recorded by Apple's Workout app and matches them to FitTap sessions by time overlap. No FitTap Watch app needed. | Watch data on day one, before the Watch app exists. |
| **Per-exercise HR and calories** | Every FitTap set is timestamped, and so are HR and active-energy samples; slice samples by exercise time window. Segment events (double-tap markers) line up the same way. | Per-exercise effort with zero extra input. |
| **Session-window fallback** | No workout recorded on the Watch → sum all-day active-energy samples over the FitTap session's start/end. Label as estimate. | Something useful even when the user forgot to start a workout. |
| **Recovery context** | Read sleep stages, resting HR, HRV, HR recovery, VO2max, sleeping respiratory rate and wrist temperature. | Input for readiness and AI coaching later. |

### HealthKit findings (from device research)

- **What the Watch records per workout:** activity type, start/end, duration, active and total energy, distance, events (pause/resume, laps, segments), activities (multi-part sessions), metadata (indoor/outdoor, weather, elevation, METs), GPS route, effort score (user 1–10 + Watch estimate). Samples during the workout: HR every few seconds, energy, and running metrics (speed, cadence, power, stride length, ground contact time, vertical oscillation).
- **What it can't detect:** exercise identity, sets, reps, weight. That is FitTap's job.
- **Outside a workout,** active calories are still counted, but HR is sampled only every few minutes and nothing is attached to a session, so lifting is undercounted. Automatic workout detection covers cardio only (walk, run, elliptical, rower, bike, swim), never strength. → Recording a real workout during lifting is the accuracy win; later, FitTap's Start Workout should start one automatically.
- **Resting energy is a formula, not a measurement:** computed from the Health profile (age, sex, height, weight), written by the iPhone even with no Watch. Never build insights on it.
- **Read denial is invisible:** HealthKit never reveals whether read access was denied, so "no data" and "no permission" must render identically.

## 7. Siri, App Intents and Shortcuts

Every logging action becomes reachable without opening the app: Siri, Shortcuts, Spotlight, the Action button on Watch and iPhone, widgets. One intent layer feeds all of them. Reference: [Knowledge/iOSAI/GeneralKnowledge/AppleIntelligenceGroupLab.md](../Knowledge/iOSAI/GeneralKnowledge/AppleIntelligenceGroupLab.md).

| Feature | What it does | Why |
|---|---|---|
| **Core intents** | `StartWorkout(template)`, `LogSet(exercise, weight, reps)`, `RepeatLastSet`, `EndWorkout`, `StartRestTimer`. Each has an App Shortcut phrase ("Log a set", "Start push day"). | The zero-tap path: Action button, Siri, a Shortcut tile. Same intents drive the Watch complication and widgets. |
| **Entities** | `WorkoutTemplate`, `Exercise`, `WorkoutSession` as `AppEntity`, donated to the semantic index via `IndexedEntity`. | Siri can answer "when did I last do deadlifts?" and "how many workouts this week?" from indexed content, and open a session from Spotlight. |
| **Schemas** | No fitness domain exists, so adopt the generic `system.search` and `system.open`: Siri routes "find my leg day" into FitTap's search and opens the template. Timer schema for the rest timer. | Schemas are the only route into the new Siri AI; Apple supplies the phrases, confirmations and localization. |
| **On-screen context** | View annotations on the current session screen with the session and exercise entities. | "Log this again", "add 2.5 kilos" work on what's visible, no navigation. |
| **Intent donations** | Donate `LogSet` and `StartWorkout` as the user performs them in-app. | Siri learns habits: "start my workout" picks the template you use on Tuesdays. |
| **Dialog variants** | Full vs supporting dialog on each intent. | Verbose on AirPods and Watch (no screen), terse with a snippet on iPhone. |
| **Testing** | The App Intents testing framework in CI for intents, entity queries and Spotlight indexing. | The only way to keep Siri behaviour from silently breaking between OS betas. |

Not available on HomePod; existing App Shortcuts still work there. Spotlight retrieval is sandboxed to FitTap, so Siri never sees other apps' data, and vice versa.

## 8. Later / parked

| Feature | Notes |
|---|---|
| Nutrition & diet logging | Planned in the constitution; same logging model, same "tap the common thing" principle. Not before v1 logging is solid. |
| Widgets and Live Activities | Rest timer and today's workout. Cheap once the data model is stable. |
| iCloud sync | SwiftData + CloudKit. Required before Watch and iPhone can share data reliably. |
| Export | CSV of all sessions. The user owns their data. |
| Plate calculator | Tap a weight to see plates per side. |

**Explicitly not building** (constitution §5): coaching platform, social features, data console, periodization editors, RPE matrices, velocity tracking, macro micromanagement.
