# SwiftData

Reference notes on SwiftData, project-agnostic. These notes describe what exists, how it behaves, and what Apple states about it. They are more current than model training data.

API names and shapes are taken from Apple's published snippets (see `code/`) and the session transcripts, with timestamps. Items marked ⚠️ are unconfirmed — usually a parameter label nobody spoke or a snippet that doesn't compile as published. Guidance Apple did **not** give is kept apart in §11 and marked as ours.

**Platforms:** SwiftData is iOS 17+. Version tags below: **(17)** iOS 17, **(18)** iOS 18, **(26)** iOS 26, **(27)** iOS 27 ("the 2027 releases").
**Code examples:** [`code/`](code/) — one file per ingested session, named after the video title (year-suffixed where two sessions share a title), holding Apple's published snippets with timestamps. A file's presence means that session's transcript and code are ingested. WWDC23 snippets use beta-1 shapes; the files flag each one.
**Sources:**
- WWDC23 10187 "Meet SwiftData" · WWDC23 10196 "Dive deeper into SwiftData"
- WWDC24 10137 "What's new in SwiftData" (`WhatsNewInSwiftDataWWDC24.swift`) · WWDC24 10138 "Create a custom data store with SwiftData"
- WWDC25 291 "SwiftData: Dive into inheritance and schema migration"
- WWDC26 274 "What's new in SwiftData" (`WhatsNewInSwiftDataWWDC26.swift`) · WWDC26 275 "Code-along: Add persistence with SwiftData" · WWDC26 8017 "SwiftData Group Lab" (Q&A, no code; auto-captions garble API names)

**Not yet ingested, referenced by these sessions:** WWDC23 10195 "Model your schema with SwiftData", 10154 "Build an app with SwiftData", 10189 "Migrate to SwiftData"; WWDC24 10075 "Track model changes with SwiftData history". CloudKit model constraints and `@ModelActor` are not covered by any ingested session.

---

## 1. Models

→ `MeetSwiftData.swift` · `CodeAlongAddPersistenceWithSwiftData.swift` · `WhatsNewInSwiftDataWWDC24.swift` · `WhatsNewInSwiftDataWWDC26.swift` · `SwiftDataDiveIntoInheritanceAndSchemaMigration.swift`

- **`@Model` (17)** on a class makes its **stored** properties persistent; the code is the schema, with no model file [10187 1:09–2:17]. Models get `Observable` conformance for free — when converting, replace `@Observable` with `@Model` [275 3:39].
- **Value-type properties become attributes:** basic types, structs, enums and Codable types, collections included [10187 1:49–2:05]. **Model-type properties become relationships** [10187 2:08].
- **Rules learned converting an app** [275]:
  - Stored properties must be `var` (`let creationDate` → `private(set) var creationDate = Date.now`) [5:33].
  - "All model properties must be Codable" — e.g. add `Codable` to a `String` enum [5:43].
  - Remove `didSet` observers from model properties; recreate the behavior with continuous observation (§5) [4:17, 20:51].
  - Store a derived value you filter on (`isComplete`) instead of computing it, so a predicate can use it [7:47].
  - Give properties defaults (`var isComplete: Bool = false`, `var dateCreated = Date.now`).
  - Write your own initializers; `@Model` doesn't synthesize one [10187 6:15].
- **`@Attribute`** options: `.unique` (17) [10187 2:46]; `originalName:` to rename without losing data (17) [291 8:16]; `.externalStorage` for large blobs, stored in a file beside the database (17) [8017 5:50]; `.preserveValueOnDeletion` keeps the value in history after delete (18) [10137 3:45]; `hashModifier:` (18) [291 9:04]; **`.codable` (27)** — see enums below.
- **`@Transient`** excludes a stored property from persistence (17) [10187 2:40].
- **`#Unique<T>([\.a, \.b, …])` (18):** compound uniqueness. A colliding insert becomes an **upsert** — SwiftData updates the existing row instead of adding a duplicate; the unique properties are the model's identity [10137 2:43–3:42]. ⚠️ Which values win, and what happens to relationships during an upsert, isn't stated.
- **`#Index<T>([\.a], [\.b], [\.a, \.b])` (18):** single and compound indexes; index what you sort and filter by most; "substantially faster" on large sets [10137 12:07–13:04, 8017 5:29, 7:05].
- **Relationships:** `@Relationship(deleteRule: .cascade, inverse: \Activity.trip) var activities: [Activity] = []` — an array is the idiomatic to-many [275 10:14]. To-many as an array with a default, to-one optional [10137 1:32]. Real relationships replace hand-made ID joins and lookup dictionaries [275 9:59].
- **Enums:**
  - A `String` (`RawRepresentable`) Codable enum is stored natively [291 3:28, 275 6:06]. **(27)** predicates can now filter on raw-representable enums [8017 34:44].
  - **Enums with associated values** can't be mapped to a schema. Store as Codable (cheap, but opaque — no filtering or sorting on contents) or model each case out with relationships plus a computed accessor that rebuilds the enum (full predicate and sort power). Apple's rule: Codable when you don't own the type; model it out when you query by it [8017 35:52–37:06].
  - A closed set of fixed cases that users can add to or track per item becomes a model, not an enum (`enum Goal` → `class Goal`) [275 6:43].
- **`@Attribute(.codable)` (27):** stores a type through its own `Codable` conformance — for types SwiftData can't inspect, e.g. `MKMapItem.Identifier`, which otherwise crashes at launch [274 3:59–5:12]. Opaque: no predicates, no sort; shape changes don't trigger migration, so its Codable must stay forward- and backward-compatible. An "escape hatch": "avoid using codable for types that you define" [274 5:51–5:59]. A plain nested `struct Location: Codable` still persists natively without it.
- **Model inheritance (26):** `@Model class BusinessTrip: Trip { … }`; register subclasses in the schema; a base-type query returns subclasses too; filter by type with `#Predicate { $0 is PersonalTrip }` [291 1:51–7:14].
  - Use it for a real "is-a" hierarchy queried both as the base and per leaf. Only ever the base → put the subtype as a property; only ever leaves → flatten; sharing one property → a protocol [291 4:33–6:32].
  - Kind enums can become subclasses (`Goal → TripGoal / ActivityGoal`) [275 8:21]. ⚠️ Subclass initializer requirements aren't shown.
- **Images:** a small thumbnail as inline `Data?`; the full-resolution image in a separate model with external storage, loaded only where shown [275 11:02–11:14].

## 2. The container

→ `DiveDeeperIntoSwiftData.swift` · `WhatsNewInSwiftDataWWDC24.swift` · `SwiftDataDiveIntoInheritanceAndSchemaMigration.swift`

- **`ModelContainer`** is the bridge between schema and storage, and where versioning, migration and graph separation live [10196 4:01–4:17]. Passing one type infers related types through relationships [10196 4:21].
- **`ModelConfiguration`** options [10196 4:53–5:29]: in memory (`isStoredInMemoryOnly:`) or on disk; explicit `url:` or one derived from entitlements (`groupContainer:`); read-only (`allowsSave: false`) for template data; a specific CloudKit container (`cloudKitDatabase:`).
- **Several configurations in one container** separate the graph into different store files, each with its own CloudKit setting [10196 5:34–6:23].
- **Building it yourself:** for any control beyond defaults, build the container once — a `let` on the `App` built in a closure — and pass it to `.modelContainer(container)` [10137 5:03–5:36, 291 10:57, 275 13:21]. The convenience `.modelContainer(for:inMemory:isAutosaveEnabled:isUndoEnabled:)` covers the simple case [10137 4:52].
- **Outside views:** ask the container for its shared main-actor context (`container.mainContext`), or create contexts with `ModelContext(container)` [10187 4:27–4:34]. A widget does exactly that from a shared container singleton [291 13:28].
- **App Groups:** moving to a group container after shipping gives a new directory; with the default configuration the store is moved for you, with a custom URL you copy it yourself [8017 19:30–21:00].
- **Multiple processes** (app + widget + extension): one process owns the database — the app migrates and coordinates; after that others can read and write the same file [8017 3:08–3:53].

## 3. Contexts and saving

→ `DiveDeeperIntoSwiftData.swift` · `CodeAlongAddPersistenceWithSwiftData.swift`

- **`mainContext`** is "a special MainActor-aligned model context intended for working with model objects in scenes and views"; `.modelContainer` puts it in the environment as `\.modelContext` [10196 7:40–8:04].
- **A context is a working set:** edits are snapshotted, inserts and deletes tracked until `save()`; a deleted object still exists in the context until saved; after save the context clears its state [10196 8:24–9:28]. Changes are ordinary property sets [10187 6:37]. `rollback()` discards unsaved changes [10196 9:43].
- **One context = one unit of work:** everything accumulated goes to the database as a single transaction on save. Size each context's work to make sense as one transaction [8017 41:27–42:06].
- **Autosave:** on by default for the main context — on foreground/background events and periodically [10196 10:45, 275 13:32]; batching delay "a few seconds" [8017 33:17]. **Autosave is off for contexts created by hand** — they must `save()` [10196 11:15]. Stopping the app from Xcode skips autosave; save explicitly when it matters [8017 33:40].
- **Undo:** `.modelContainer(for:isUndoEnabled: true)` binds the window's undo manager to the main context [10196 9:58]. ⚠️ A container built outside SwiftUI would need its undo manager set by hand.
- **Identifiers:** a new model has a *temporary* `PersistentIdentifier` until save, when the store remaps it to a permanent one [10138 2:44–3:22].
- **Errors at runtime:** low disk space, unsupported predicates — catch, report, show an alert [275 13:32, 19:32].

## 4. Fetching and performance

→ `MeetSwiftData.swift` · `DiveDeeperIntoSwiftData.swift` · `WhatsNewInSwiftDataWWDC24.swift` · `SwiftDataDiveIntoInheritanceAndSchemaMigration.swift` · `CodeAlongAddPersistenceWithSwiftData.swift`

- **`#Predicate<T> { … }`** (17): type-checked, translated to a database query, supports to-many subqueries (`.filter { … }.count > 0`) [10187 4:43, 10196 12:16–12:56]. Capture values like `let today = Date.now` outside the closure. Combine predicates with `.evaluate($0)` [291 11:48]. **`#Expression<In, Out>` (18)** builds non-Bool sub-expressions (a count of unplanned items) usable in predicates [10137 10:19–11:51].
- **`FetchDescriptor(predicate:sortBy:)`** + `try context.fetch(_:)` (17); options `fetchLimit`, `fetchOffset`, `includePendingChanges`, `propertiesToFetch` (load only the fields you read), `relationshipKeyPathsForPrefetching` (when you'll walk that relationship) [10187 5:29–6:03, 291 12:31–13:45].
- **`fetchCount(_:)`** to count; **`fetchIdentifiers(_:)`** to get IDs without loading models [8017 25:38, 28:53]. Min/max: `fetchLimit = 1` with a sort. Sum/average have no SwiftData API yet [8017 13:59–14:51].
- **`enumerate(_:batchSize:allowEscapingMutations:)`** (17) for batch traversal; default batch 5,000; larger = less I/O, more memory. It throws if the context is dirty, because mutations trapped during a traversal are the most common large-traversal performance bug [10196 13:19–14:49].
- **Storage is slow:** orders of magnitude slower than memory. Fetch with a predicate rather than everything-then-filter; global arrays of all data inflate memory for the app's lifetime [275 14:16–16:02].
- **Large lists:** set a fetch limit, put all filtering in the predicate, cover it with an index, start from the **persistence instrument** in Instruments [8017 6:49–7:24]. Often a fetch limit (top 100/1000) beats pagination [8017 49:05].

## 5. Observing changes outside views

→ `WhatsNewInSwiftDataWWDC26.swift` · `SwiftDataDiveIntoInheritanceAndSchemaMigration.swift` · `CodeAlongAddPersistenceWithSwiftData.swift`

**The rules (26 and earlier)** [291 14:00–15:29]:
- Every model is Observable — `withObservationTracking` sees property changes made locally.
- Changes from another process or another container are not observable that way.
- Contexts on the same container see each other's changes: `@Query` applies them automatically; **results of `ModelContext.fetch` do not update until you refetch.** Refetching can be expensive — use history to decide whether it's needed.

**History (18):** every save records a transaction — what changed, its author, a token. `fetchHistory` with a token returns newer transactions; deleted models leave tombstones of their `.preserveValueOnDeletion` attributes [10137 3:45–4:26, 274 9:46]. **(26)** `HistoryDescriptor.sortBy` — get the latest token with a reverse sort and `fetchLimit = 1`; filter transactions by token and by entity name [291 16:25–18:04].

**`ResultsObserver` (27) — `@Query` outside SwiftUI:**
- Apple: "Query is great and should be your first choice in a SwiftUI view." For "a state object that derives values from your SwiftData store", or non-SwiftUI code, use `ResultsObserver` [274 7:03].
- It fetches, then observes the store through Swift Observation; supports filtering, sorting and sectioning [274 7:26–7:40]. Same performance as `@Query` — "pretty much the same under the hood" [8017 10:31].
- Shape: `try ResultsObserver<Trip, Never>(modelContext: modelContext)`, read `.results` [274 8:33]. Apple's example: an `@Observable @MainActor final class` that takes a `ModelContext` in `init`, holds a private `ResultsObserver`, and recomputes derived state when results change [274 8:20].
  - ⚠️ The second generic is presumably the section ID type (`Never` = unsectioned). Predicate, sort and section parameter labels aren't shown.
  - ⚠️ Whether a view reading `.results` through a state object updates without extra code is implied by Observation, not stated.
- Works for UIKit/AppKit too [8017 12:46].

**`HistoryObserver` (27):** observes persistent history; filter by model type and by transaction author — e.g. only `"App"`-authored changes, so sync code doesn't echo server changes back [274 10:30–11:37]. Its one observable property, `eventCounter`, increments when new transactions exist; then pull them with `fetchHistory`. Shape: `try HistoryObserver(authors: ["App"], modelContainer: modelContainer)`. Apple's example lives on a custom global actor and takes the container, not a context [274 8:21]. ⚠️ The model-type filter label isn't shown.

**`withContinuousObservation(options:)` (27, Observation framework):** `withContinuousObservation(options: .didSet) { event in … }` — read the properties to track inside the closure; `event.matches(\Activity.name)` tells which changed. It returns an `ObservationTracking.Token`; the observation lives as long as the token, so store it [274 8:44–8:57, 275 21:05]. The code-along uses it to replace `didSet`: stamp `dateEdited`, roll a parent's `isComplete` up from its children. ⚠️ Storing the token on a model presumably needs `@Transient`.

**Sectioning (27):** `@Query(sort: \Trip.startDate, sectionBy: \.destination) var trips: [Trip]`; the wrapped value is still `[Trip]`; sections via `_trips.sections`, each with an `id` (the key path's value) and itself a collection of models. Groups are computed by the store, not in memory [274 1:41–2:46, 8017 57:41–58:14]. Also on `ResultsObserver`. ⚠️ Apple says the key path "leads to a string"; whether dates or enums work, and how sections order relative to `sort`, isn't stated. The published snippet iterates `trips` inside each section; the transcript iterates the section.

**Before iOS 27, outside views:** fetch, then listen for change notifications and refetch [8017 11:13–11:49]. A hand-cached array is fine — "nothing wrong with doing it yourself" — but cache invalidation is yours [8017 27:00]. Combine `HistoryObserver` (when), `fetchCount`/`fetchIdentifiers` (cheap), and history (did the properties I care about change?) before refetching [8017 28:42].

## 6. Concurrency

→ `SwiftDataGroupLab.swift` (no code) · `CreateACustomDataStoreWithSwiftData.swift`

- **Models aren't Sendable** and "can't really be made sendable in any sane way". Across actors, pass copies: extracted values, optionally with the `PersistentIdentifier`, or deltas in a struct. Don't pass relationships or partial graphs ("there be dragons") [8017 58:49–60:28]. Internally, stores exchange Sendable, Codable `DataStoreSnapshot`s keyed by identifier [10138 3:26–4:23].
- **Less concurrency is often faster.** SQLite runs in WAL mode: one writer, many readers. Mobile storage is the bottleneck; connection pooling allows ~2–3 operations at a time and throttles beyond. "Folks tend to be surprised that they can actually get faster performance with less concurrency" [8017 42:10–46:19].
- **Short-lived contexts for batches:** new context per batch, save, let it go — don't keep a long-lived context full of work or hydrate large graphs [8017 6:09–6:30, 47:35–48:17].
- Off the main actor, "just do a fetch… you don't have to route through query" [8017 29:19]. `HistoryObserver` takes the container, which crosses actors; contexts don't [274 8:21].
- ⚠️ `@ModelActor` is named in the lab but no ingested session shows its shape.

## 7. Schema migration

→ `SwiftDataDiveIntoInheritanceAndSchemaMigration.swift`

- **`VersionedSchema`:** an enum with `versionIdentifier` (`Schema.Version(2, 0, 0)`) and `models`; older versions keep frozen copies of their `@Model` classes nested inside; the current version lists the live top-level types [291 8:26, 9:50].
- **Stages:** `MigrationStage.lightweight(fromVersion:toVersion:)` — adding subclasses needs only this; `MigrationStage.custom(fromVersion:toVersion:willMigrate:didMigrate:)` — e.g. de-duplicate in `willMigrate` and save, before adding a unique constraint [291 8:41–10:03].
- **`SchemaMigrationPlan`:** `schemas` and `stages`, ordered by release; open with `ModelContainer(for: Schema(versionedSchema: V4.self), migrationPlan: Plan.self)` [291 10:23–10:57].
- **Versioning can be added at any time**, even after shipping without it — version the current schema now; earlier versions can be added later [8017 19:26–20:33].
- **Test with a corpus of stores from every shipped version** — a device left in a drawer jumps several versions [8017 8:56–9:30].
- **Detecting a needed migration:** open without the plan; the load errors [8017 53:58]. Widgets and extensions should **not** carry the migration plan — they can't migrate (no runtime budget); show "open the app" instead [8017 4:23–4:43, 54:56].
- **Progress UI:** count stages and use `didMigrate` of custom stages ("stage N of M"); no `Progress` hook exists. Show what the migration brings, not just a spinner [8017 55:12–57:18].

## 8. CloudKit

- Per-configuration CloudKit containers (`cloudKitDatabase:`), separate store files per synced graph [10196 5:25–6:23].
- Put the CloudKit-synced store in its own configuration and a local-only one in the App Group for widgets — a widget given the CloudKit entitlement would try to sync, which widgets do badly; let the app drive sync [8017 21:41–23:17].
- Apps sharing a CloudKit container must keep schemas aligned, with no competing migrations; promote to the production environment before release [8017 24:12–25:07].
- Slow sync: read the store's logs; platforms throttle (watch on cellular, thermal); backgrounding then foregrounding syncs more aggressively; a device that never receives changes → check push entitlements first (Debug vs Release often differ) [8017 30:43–34:15].
- Non-CloudKit backends: SwiftData as the local cache + `HistoryObserver` to push changes is "a very common pattern" [8017 50:27–53:06].
- ⚠️ **Model constraints for CloudKit sync** (optional or defaulted properties, optional relationships, no unique constraints) appear in no ingested session. The WWDC23 Trip model's all-optional attributes hint at them [10196 1:45]. Confirm in Apple's documentation before relying on them.

## 9. Previews and tests

→ `WhatsNewInSwiftDataWWDC24.swift`

- **`PreviewModifier` (18):** `static func makeSharedContext() throws -> ModelContainer` (in-memory container, seeded) + `func body(content:context:)` applying it; expose it as a `PreviewTrait` (`.sampleData`) and use `#Preview(traits: .sampleData)` [10137 6:58–8:26]. Reuse one trait everywhere; make sample data varied — long names, many items, every case [8017 7:51–8:38].
- For a view that takes a model, `@Previewable @Query var trips: [Trip]` in the preview and pass `trips.first` [10137 8:40].
- `#Unique` removes the need to de-duplicate seed data [10137 7:37].
- In-memory configuration: `ModelConfiguration(isStoredInMemoryOnly: true)` [10137 7:20]. Testing itself isn't covered by any ingested session.

## 10. Custom data stores (18)

→ `CreateACustomDataStoreWithSwiftData.swift`

- Swap `ModelConfiguration` for your own `DataStoreConfiguration` (e.g. a JSON file store); models, views and `@Query` stay unchanged [10138 0:18–0:51].
- Protocols `DataStoreConfiguration`, `DataStoreSnapshot`, `DataStore`; defaults `ModelConfiguration`, `DefaultSnapshot`, `DefaultStore`. **`DefaultStore` brings migration, history and CloudKit sync and is "the best default choice"** — a custom store has none of these unless it implements them [10138 5:05–5:49].
- A simple store can throw `DataStoreError.preferInMemoryFilter` / `.preferInMemorySort` and let the context filter and sort [10138 9:29].

---

## 11. Architecture positions — Apple's, then ours

**What Apple says:**
- In a SwiftUI view, `@Query` first; in a state object or non-SwiftUI code, `ResultsObserver` (27) [274 7:03].
- The code-along deletes its edit view-model and data source because "SwiftUI views can bind directly to SwiftData models" [275 12:48–13:06] — the simplest path Apple shows, not a stated rule.
- The lab explicitly endorses fetching in your own code instead of `@Query`: "you don't have to route through query if it's inconvenient"; moving fetches out of the view gives more control, because the SwiftUI view cycle can re-run a query more often than needed [8017 26:16–29:36].
- For a screen built around one object, drive it from a root model fetched once (fetch limit, create if missing), with that logic out of `body` [8017 18:08–18:48].
- Default store unless you have a reason; one owning process; little concurrency; version the schema [10138 5:37, 8017].

**Ours — not Apple's guidance:**
- For apps whose views receive values and callbacks (no data access in views), the iOS 27 shape is: an injected `@MainActor @Observable` store or screen model owning the context and `ResultsObserver`s, exposing results or derived values. This matches Apple's own `MapCameraController` example closely.
- Start with a `VersionedSchema` V1 and a migration plan from the first release.
- Decide on CloudKit compatibility before the first release; retrofitting optional properties and dropping unique constraints is a migration.
