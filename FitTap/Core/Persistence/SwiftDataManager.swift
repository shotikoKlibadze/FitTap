import Foundation
import OSLog
import SwiftData

/// The only code that touches SwiftData. Stores call it with plain structs
/// and get plain structs back; screens and screen models never see the
/// database. One instance for the app (`Container.swiftDataManager`).
///
/// Every write saves at once. The main context autosaves too, but seconds
/// later and not at all when Xcode stops the app, and a logged set must not
/// wait.
///
/// Session rules live here, so no screen can get them wrong (Planning/
/// SwiftDataPlanning.md, decision 3): a planned session follows its workout;
/// editing it from Home or starting it gives it its own copy for good; and
/// deleting a workout copies it into the planned sessions still following
/// it first. Logged history never changes when a workout does.
@MainActor
@Observable
final class SwiftDataManager {
    /// Bumped after every exercise write.
    private(set) var exercisesRevision = 0
    /// Bumped after every workout write.
    private(set) var templatesRevision = 0
    /// Bumped after every session write. Stats reload on it.
    private(set) var sessionsRevision = 0

    @ObservationIgnored private let container: ModelContainer
    @ObservationIgnored private let logger = Logger(subsystem: "FitTap", category: "Persistence")

    private var context: ModelContext { container.mainContext }

    init() {
        container = Self.makeContainer()
        seedBuiltInExercises()
        seedDefaultWorkouts()
        #if DEBUG
        // Switched off 2026-11-04 after the v4 import (history with efforts);
        // kept for later. Turn it back on (and bump `seedHistoryImportedKey`)
        // to import again.
        // importSeedHistory()
        fillDefaultWorkoutWeights()
        #endif
    }

    // MARK: - Exercises

    func exercises() -> [Exercise] {
        fetch(FetchDescriptor<ExerciseEntity>(sortBy: [SortDescriptor(\.name)])).compactMap(\.exercise)
    }

    /// Inserts or updates the exercise with this id.
    func save(_ exercise: Exercise) {
        let row = exerciseRow(id: exercise.id) ?? insert(ExerciseEntity(id: exercise.id))
        row.update(from: exercise)
        persist()
        exercisesRevision += 1
    }

    /// Copies every built-in from `ExerciseData` into the database: inserts
    /// the ones that are missing and refreshes the rest, so an update can add
    /// or correct built-ins. Cheap and safe on every launch.
    private func seedBuiltInExercises() {
        let rows = Dictionary(
            fetch(FetchDescriptor<ExerciseEntity>()).map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first },
        )
        for exercise in ExerciseData.exercises {
            let row = rows[exercise.id] ?? insert(ExerciseEntity(id: exercise.id))
            row.update(from: exercise)
            row.isBuiltIn = true
        }
        persist()
    }

    // MARK: - Workouts

    /// Remembers that the default workouts were added, so a deleted one
    /// doesn't come back. Cleared when a DEBUG store is wiped.
    private static let defaultWorkoutsSeededKey = "defaultWorkoutsSeeded"

    /// Adds `DefaultWorkoutData` once per database, ahead of anything the
    /// user makes. From then on they're ordinary workouts.
    private func seedDefaultWorkouts() {
        guard !UserDefaults.standard.bool(forKey: Self.defaultWorkoutsSeededKey) else { return }
        for (index, template) in DefaultWorkoutData.templates.enumerated() where templateRow(id: template.id) == nil {
            let row = insert(WorkoutTemplateEntity(id: template.id))
            row.update(from: template, in: context)
            // Oldest first on the Workouts tab, in the order listed.
            row.createdAt = Date(timeIntervalSinceReferenceDate: Double(index))
        }
        persist()
        UserDefaults.standard.set(true, forKey: Self.defaultWorkoutsSeededKey)
    }

    /// Every workout, in the order they were made.
    func templates() -> [WorkoutTemplate] {
        fetch(FetchDescriptor<WorkoutTemplateEntity>(sortBy: [SortDescriptor(\.createdAt)])).map(\.template)
    }

    /// Inserts or updates the workout with this id, exercises and sets
    /// included.
    func save(_ template: WorkoutTemplate) {
        let row = templateRow(id: template.id) ?? insert(WorkoutTemplateEntity(id: template.id))
        row.update(from: template, in: context)
        persist()
        templatesRevision += 1
    }

    /// Deletes the workout. Planned sessions still following it take their
    /// own copy first, so they stay on the calendar; the rest already have
    /// one.
    func deleteTemplate(id: UUID) {
        guard let row = templateRow(id: id) else { return }
        let following = fetch(FetchDescriptor<WorkoutSessionEntity>(predicate: #Predicate {
            $0.templateID == id && $0.isFollowingTemplate
        }))
        following.forEach { snapshot($0, from: row) }
        context.delete(row)
        persist()
        templatesRevision += 1
        if !following.isEmpty { sessionsRevision += 1 }
    }

    // MARK: - Sessions

    /// Every session, earliest day first. Following sessions show their
    /// workout as it is now.
    func sessions() -> [WorkoutSession] {
        let templates = Dictionary(
            fetch(FetchDescriptor<WorkoutTemplateEntity>()).map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first },
        )
        return fetch(FetchDescriptor<WorkoutSessionEntity>(sortBy: [SortDescriptor(\.scheduledFor)]))
            .map { $0.session(template: templates[$0.templateID]) }
    }

    /// Inserts or updates the session with this id. One that follows its
    /// workout stores only its own fields; one with its own copy stores the
    /// exercises and sets too. Returns it as it now reads.
    @discardableResult
    func save(_ session: WorkoutSession) -> WorkoutSession {
        let row = sessionRow(id: session.id) ?? insert(WorkoutSessionEntity(id: session.id))
        row.update(from: session, in: context)
        persist()
        sessionsRevision += 1
        return row.session(template: templateRow(id: row.templateID))
    }

    /// Starts the session: a following one takes its own copy of the workout
    /// first, then `startedAt` is stamped. From here on it's frozen —
    /// whatever is logged stays as it was done. Returns it as it now reads.
    func startSession(id: UUID, at date: Date) -> WorkoutSession? {
        guard let row = sessionRow(id: id) else { return nil }
        if row.isFollowingTemplate, let template = templateRow(id: row.templateID) {
            snapshot(row, from: template)
        }
        row.isFollowingTemplate = false
        if row.startedAt == nil { row.startedAt = date }
        persist()
        sessionsRevision += 1
        return row.session(template: nil)
    }

    /// Gives a following session its own copy of `template`, with fresh ids
    /// for its entries and sets.
    private func snapshot(_ row: WorkoutSessionEntity, from template: WorkoutTemplateEntity) {
        var session = row.session(template: template)
        session.workout = template.template.withFreshEntryIDs()
        session.followsWorkout = false
        row.update(from: session, in: context)
    }

    func deleteSession(id: UUID) {
        guard let row = sessionRow(id: id) else { return }
        context.delete(row)
        persist()
        sessionsRevision += 1
    }

    // MARK: - Seed history (DEBUG, temporary)

    #if DEBUG
    /// Remembers which version of the six-month history was imported, so a
    /// session the user deletes doesn't come back. Bump it when the log
    /// changes; cleared when a DEBUG store is wiped.
    private static let seedHistoryImportedKey = "seedHistoryImported.v4"

    /// TEMPORARY: imports `SeedHistoryImporter.sessions()` once per version,
    /// in one save. Any earlier version of the history is removed first, so
    /// changing the log replaces it; sessions the user made are untouched.
    private func importSeedHistory() {
        guard !UserDefaults.standard.bool(forKey: Self.seedHistoryImportedKey) else { return }
        removeSeedSessions()
        for session in SeedHistoryImporter.sessions() {
            insert(WorkoutSessionEntity(id: session.id)).update(from: session, in: context)
        }
        persist()
        UserDefaults.standard.set(true, forKey: Self.seedHistoryImportedKey)
        sessionsRevision += 1
    }

    /// TEMPORARY: deletes every imported session in one call, sets and all.
    /// It isn't imported again afterwards. Stores reload on next launch.
    func deleteSeedHistory() {
        removeSeedSessions()
        persist()
        sessionsRevision += 1
    }

    /// The default workouts were first added without weights.
    private static let defaultWorkoutWeightsFilledKey = "defaultWorkoutWeightsFilled"

    /// TEMPORARY: fills every empty set weight in the stored default
    /// workouts from `DefaultWorkoutData`, once. Weights already entered stay.
    private func fillDefaultWorkoutWeights() {
        guard !UserDefaults.standard.bool(forKey: Self.defaultWorkoutWeightsFilledKey) else { return }
        for defaults in DefaultWorkoutData.templates {
            guard let row = templateRow(id: defaults.id) else { continue }
            let weights = Dictionary(
                defaults.exercises.map { ($0.exerciseID, $0.sets.first?.weight) },
                uniquingKeysWith: { first, _ in first },
            )
            var template = row.template
            for exercise in template.exercises.indices {
                guard let weight = weights[template.exercises[exercise].exerciseID] ?? nil else { continue }
                for set in template.exercises[exercise].sets.indices where template.exercises[exercise].sets[set].weight == nil {
                    template.exercises[exercise].sets[set].weight = weight
                }
            }
            row.update(from: template, in: context)
        }
        persist()
        UserDefaults.standard.set(true, forKey: Self.defaultWorkoutWeightsFilledKey)
        templatesRevision += 1
        sessionsRevision += 1
    }

    private func removeSeedSessions() {
        let ids = SeedHistoryImporter.possibleSessionIDs
        for row in fetch(FetchDescriptor<WorkoutSessionEntity>()) where ids.contains(row.id) {
            context.delete(row)
        }
    }
    #endif

    // MARK: - Stats reads

    /// Every set checked off in `start..<end`, failed ones included, with its
    /// exercise id. Planned sets have no `loggedAt`, so they never match.
    func loggedSets(from start: Date, to end: Date) -> [LoggedSet] {
        let never = Date.distantPast
        let rows = fetch(FetchDescriptor<SetEntryEntity>(predicate: #Predicate { set in
            (set.loggedAt ?? never) >= start && (set.loggedAt ?? never) < end
        }))
        return rows.compactMap { row in
            guard
                let loggedAt = row.loggedAt,
                let exerciseID = row.workoutExercise?.exerciseID,
                let sessionID = row.workoutExercise?.session?.id
            else { return nil }
            return LoggedSet(exerciseID: exerciseID, sessionID: sessionID, reps: row.reps, weight: row.weight, duration: row.duration, failed: row.failed, loggedAt: loggedAt)
        }
    }

    /// Every session this exercise was logged in, newest first: the day and
    /// its checked-off sets. Planned sessions and the workouts themselves
    /// (no logged sets) don't appear.
    func exerciseHistory(exerciseID: UUID) -> [ExerciseSessionLog] {
        let rows = fetch(FetchDescriptor<WorkoutExerciseEntity>(predicate: #Predicate { $0.exerciseID == exerciseID }))
        return rows.compactMap { row -> ExerciseSessionLog? in
            guard let session = row.session else { return nil }
            let sets = (row.sets ?? [])
                .sorted { $0.order < $1.order }
                .map(\.setEntry)
                .filter { $0.loggedAt != nil }
            guard !sets.isEmpty else { return nil }
            return ExerciseSessionLog(sessionID: session.id, date: session.startedAt ?? session.scheduledFor, sets: sets, effort: row.effortRaw.flatMap(Effort.init(rawValue:)))
        }
        .sorted { $0.date > $1.date }
    }

    /// Every cardio effort from a session that ended in `start..<end`.
    func cardioEntries(from start: Date, to end: Date) -> [LoggedCardio] {
        let never = Date.distantPast
        let rows = fetch(FetchDescriptor<WorkoutExerciseEntity>(predicate: #Predicate { entry in
            entry.cardioDuration != nil
                && (entry.session?.endedAt ?? never) >= start
                && (entry.session?.endedAt ?? never) < end
        }))
        return rows.compactMap { row in
            guard let duration = row.cardioDuration, let date = row.session?.endedAt else { return nil }
            return LoggedCardio(exerciseID: row.exerciseID, duration: duration, distanceMeters: row.cardioDistanceMeters, date: date)
        }
    }

    // MARK: - Rows

    private func exerciseRow(id: UUID) -> ExerciseEntity? {
        fetch(FetchDescriptor<ExerciseEntity>(predicate: #Predicate { $0.id == id })).first
    }

    private func templateRow(id: UUID) -> WorkoutTemplateEntity? {
        fetch(FetchDescriptor<WorkoutTemplateEntity>(predicate: #Predicate { $0.id == id })).first
    }

    private func sessionRow(id: UUID) -> WorkoutSessionEntity? {
        fetch(FetchDescriptor<WorkoutSessionEntity>(predicate: #Predicate { $0.id == id })).first
    }

    private func insert<Row: PersistentModel>(_ row: Row) -> Row {
        context.insert(row)
        return row
    }

    private func fetch<Row: PersistentModel>(_ descriptor: FetchDescriptor<Row>) -> [Row] {
        do {
            return try context.fetch(descriptor)
        } catch {
            // Logged, not fatal: a read that fails shows empty, the app goes on.
            logger.error("Fetch failed: \(error.localizedDescription)")
            return []
        }
    }

    private func persist() {
        do {
            try context.save()
        } catch {
            logger.error("Save failed: \(error.localizedDescription)")
            assertionFailure("Save failed: \(error)")
        }
    }

    // MARK: - Container

    /// The on-disk database with sync off. In DEBUG, a store that won't open
    /// (the models changed before the first release) is wiped and made fresh.
    private static func makeContainer() -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, migrationPlan: FitTapMigrationPlan.self, configurations: configuration)
        } catch {
            #if DEBUG
            deleteStore(at: configuration.url)
            do {
                return try ModelContainer(for: schema, migrationPlan: FitTapMigrationPlan.self, configurations: configuration)
            } catch {
                fatalError("The database couldn't be created: \(error)")
            }
            #else
            // ⚠️ Release behaviour is still open (Planning/SwiftDataPlanning.md §3).
            fatalError("The database couldn't be opened: \(error)")
            #endif
        }
    }

    private static func deleteStore(at url: URL) {
        for suffix in ["", "-wal", "-shm"] {
            try? FileManager.default.removeItem(at: URL(filePath: url.path() + suffix))
        }
        // A fresh store gets the default workouts, and in DEBUG the seed
        // history, again.
        UserDefaults.standard.removeObject(forKey: defaultWorkoutsSeededKey)
        #if DEBUG
        UserDefaults.standard.removeObject(forKey: seedHistoryImportedKey)
        #endif
    }
}
