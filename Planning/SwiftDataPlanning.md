# SwiftData planning

How FitTap moves from in-memory mock stores to SwiftData persistence. Decisions were agreed with Shota on 2026-10-29; nothing here is built yet, and **no code starts until he says so**. Apple facts behind these choices are in [Knowledge/SwiftData/README.md](../Knowledge/SwiftData/README.md). The project rules in [CLAUDE.md](../CLAUDE.md) win on scope.

---

## 1. Decisions

| # | Decision | Why |
|---|---|---|
| 1 | **`SwiftDataManager` is the only code that touches SwiftData.** It's injected into **stores only**. It maps both ways: value structs in, `…Entity` models stored; `…Entity` models fetched, value structs out. Stores stay the observable state screen models read. | Views and screen models keep working on plain structs: editing drafts, "Save disabled until changed", Cancel and the discard alert stay as they are. Structs cross actors freely. |
| 2 | **A session keeps its own copy of the workout**, and that copy's `id` is the template's id. No separate link field, and no relationship. | Editing a template never rewrites history. Grouping by template survives deleting the template. |
| 3 | **Session lifecycle.** A *planned* session follows its template. *Editing it from that planned session* snapshots it and detaches just that one. *Start* snapshots and freezes. *Deleting a template* snapshots its still-following planned sessions first, so they stay. | Wednesday's edit reaches Friday. Editing Friday changes only Friday. Logged history never changes. |
| 4 | **Exercise entries and sets are their own database rows.** | Stats and the coach query sets by exercise and date. A blob can't be filtered. |
| 5 | **Built-in exercises are copied into the database**, each with a **fixed id** in the seed file. Seeding inserts any id that's missing. | Ids are the same on every device and install, an update can add built-ins, and a future remote catalog (Supabase) can reuse the ids. |
| 6 | **CloudKit-compatible models from the start, with sync off.** Every property optional or defaulted, every relationship optional, no unique constraints. | Adding sync later needs no migration. iCloud sync and the Watch are planned. |
| 7 | **Profile: one database row, current weight only.** Home's header drops "this month's change" until weight history exists. | Simple first. |
| 8 | **Naming:** `…Entity` (`WorkoutSessionEntity`). Structs keep their names. Everything lives in `Core/Persistence/`. | No existing code renames. |
| 9 | **Versioning:** a `VersionedSchema` V1 plus an empty migration plan from the start. V1 stays "whatever the models are" until the first release (TestFlight or real personal data). | It's cheap now. After release, every change becomes a planned step. |

**Tabled, raise before step 6:** mock data. The proposal was: debug builds seed the real store once (sessions relative to the seed date, so they go stale), release seeds only built-ins, previews keep their struct fixtures, and a debug "reset data" action reseeds around today.

---

## 2. Database shape

All entities live in `Core/Persistence/Entities/`, one type per file. Every stored property is optional or has a default (decision 6).

| Entity | Holds | Relationships |
|---|---|---|
| `ExerciseEntity` | `id`, name, kind, load mode, equipment, main and secondary muscle, `isBuiltIn` | none. Sets refer to exercises by `exerciseID`, a plain id (see below). |
| `WorkoutTemplateEntity` | `id`, name, color, type, primary and secondary muscle | `exercises: [WorkoutExerciseEntity]?`, cascade |
| `WorkoutSessionEntity` | `id`, `templateID` (the copy's id), scheduled, started and ended dates, notes, HealthKit workout id, `isFollowingTemplate`, plus the snapshot's name, color, type and muscles | `exercises: [WorkoutExerciseEntity]?`, cascade. Empty while following. |
| `WorkoutExerciseEntity` | `id`, `exerciseID`, `order`, `effort` (Easy, Medium or Hard, stored as its raw string so stats can filter on it; empty until rated), cardio fields flattened: duration, speed, distance, count, started at | `sets: [SetEntryEntity]?` cascade, inverse optional `template` or `session` |
| `SetEntryEntity` | `id`, `order`, reps, weight, logged at, `failed` (attempted but not completed; stats mark the session) | inverse `workoutExercise` |
| `ProfileEntity` | name, age, weight | none. One row, fetched or created on first use. |

Notes:
- **Plain ids for references that must outlive the target:** `exerciseID` and `templateID`. A relationship's nullify rule would erase them when the target is deleted, and with it the history's grouping.
- **One entry type and one set type serve both templates and sessions.** The mapping and the diffing are written once.
- **Cardio is flattened** onto the entry, not stored as a nested struct. That makes "running distance over time" queryable, and avoids composite attributes under CloudKit (⚠️ unverified whether composites sync).
- **Snapshots get fresh ids.** Copying a template's entries and sets into a session gives them new `id`s, so no two rows share an id. The session's copied *workout* id stays the template id (decision 2).
- **Indexes:** `SetEntryEntity.loggedAt`, `WorkoutExerciseEntity.exerciseID`, `WorkoutSessionEntity.scheduledFor` and `.templateID`. ⚠️ Confirm `#Index` is allowed in a CloudKit-compatible schema.
- **Status stays computed** from the dates, as in the struct today.

---

## 3. The manager

`@MainActor final class SwiftDataManager` in `Core/Persistence/`, registered as a Factory singleton in `Container+Dependencies.swift` and injected into stores only. It's a concrete type with no protocol: there's no mock/live substitution today (dependency-injection skill).

- **Container:** built once from `Schema(versionedSchema: SchemaV1.self)` with `FitTapMigrationPlan` (no stages yet). It works on `mainContext`. Apple's guidance is one main-actor context and little concurrency, and that fits a logging app.
- **API per aggregate, structs only:** fetch, save (insert or update) and delete, for exercises, templates, sessions and the profile. Saving a nested struct **diffs children by `id`**: it updates existing rows, inserts new ones and deletes missing ones, and never recreates a whole subtree.
- **Explicit `save()` after every write.** The main context does autosave, but on a delay of seconds, and not at all when Xcode stops the app. A logged set must not wait.
- **Session rules live here,** so stores and screens can't get them wrong:
  - `snapshot(sessionID:)` copies the current template in.
  - `startSession` snapshots if needed, then sets `startedAt`.
  - `deleteTemplate` snapshots the planned sessions still following it, then deletes the template.
  - Mapping a following session reads its template at fetch time.
- **Change signal:** an observable `revision` counter per area (exercises, templates, sessions, profile), bumped after each save. Stores observe it and refetch. The app is the only writer until sync arrives. Then `HistoryObserver` (iOS 27) is the upgrade path for changes from other processes or iCloud, and `ResultsObserver` is the alternative if a store ever wants entity-level live results.
- **Seeding:** `seedBuiltInExercises()` at startup inserts every built-in id that's missing, so it's cheap and safe to repeat.
- **Errors:** a container that fails to open in DEBUG wipes and reseeds the store (the "models changed" case before release). In release it throws, and the app shows an error. ⚠️ Decide the release behaviour before shipping.

---

## 4. Steps

Each step ends compile-checked per file and staged. Shota checks behaviour on device. The manager, the entities, the mapping and the stores carry DocC comments per the code-style skill: the session rules especially, in plain English with the Push Day example. The [SwiftData Rules guide](../Guides/SwiftDataRules.html) is updated as steps land.

0. **Before code:** confirm the CloudKit model rules and `#Index` compatibility in Apple's documentation. Settle the tabled mock-data question.
1. **Fixed ids for built-ins.** Give all 46 entries in `ExerciseData` a literal `UUID(uuidString:)`. *Done when* ids are identical across launches.
2. **Entities, schema and plan.** The six entities, `SchemaV1`, an empty `FitTapMigrationPlan`. No callers yet.
3. **Mapping.** One extension per type, entity ↔ struct, including the child diff for entries and sets. Snapshot copying assigns fresh child ids.
4. **`SwiftDataManager`.** Container, CRUD, the session rules, revision counters, seeding, the DEBUG wipe-on-failure. Register it in Factory.
5. **Exercise store** on the manager: catalog from the database, `add` persists. Built-ins seeded at launch.
6. **Workout store** on the manager: templates persisted; deleting goes through `deleteTemplate`.
7. **Session store** on the manager: add, update, remove and query by day all persist. Logging a set saves at once (the session screen already writes on every change).
8. **Planned-session editing.** Home has to tell the workout screen *which session* it's showing: `WorkoutScreenSource.plannedSession` carries the session id, not just its date. Saving from that screen writes to the session through `snapshot`, not to the template (decision 3). Today it calls `workoutStore.update`.
9. **Start freezes.** `didTapStartWorkout` goes through `startSession`.
10. **Profile.** Home reads it from the store instead of `ProfileData`. Its header shows the weight without the monthly change.
11. **Mock data,** per the tabled decision.

---

## 5. Open questions and risks

- ⚠️ CloudKit rules and `#Index` under CloudKit: unconfirmed (step 0).
- ⚠️ `ResultsObserver` and `HistoryObserver` parameter labels weren't shown in the sessions. Check the docs when they're adopted.
- The release behaviour when the container fails to open (§3, Errors).
- Moving a session to another day ("Change Date") is still unbuilt. The data model already supports it through `scheduledFor`.
- The Supabase exercise catalog is a backend trigger: see [AgentSystemPlanning.md](AgentSystemPlanning.md), whose recorded backend stack is Python, FastAPI and Postgres.
