import FactoryKit
import Foundation

/// Every dated workout — planned, done or missed — saved in the database,
/// earliest day first. Every change saves at once, so a logged set survives
/// the app closing. One instance for the app (see
/// `Container.workoutSessionStore`).
///
/// A planned session follows its workout until it's started or edited from
/// Home; the database enforces that (see `SwiftDataManager`), this store
/// just asks for it.
@MainActor
@Observable
final class WorkoutSessionStore {
    @ObservationIgnored @Injected(\.swiftDataManager) private var database

    private(set) var sessions: [WorkoutSession] = []

    init() {
        sessions = database.sessions()
    }

    /// Reads every session again — after a workout changed, so the planned
    /// sessions following it show the change.
    func reload() {
        sessions = database.sessions()
    }

    func sessions(on day: Date) -> [WorkoutSession] {
        sessions.filter { WeekCalendar.calendar.isDate($0.scheduledFor, inSameDayAs: day) }
    }

    func session(id: UUID) -> WorkoutSession? {
        sessions.first { $0.id == id }
    }

    /// Saves a new session and slots it in by day.
    func add(_ session: WorkoutSession) {
        let saved = database.save(session)
        let index = sessions.firstIndex { $0.scheduledFor > saved.scheduledFor } ?? sessions.endIndex
        sessions.insert(saved, at: index)
    }

    /// Saves the session with the same id; unknown ids are ignored.
    func update(_ session: WorkoutSession) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        sessions[index] = database.save(session)
    }

    /// Changes this one session's workout and nothing else: it takes its own
    /// copy (fresh entry ids if it was following) and stops following, so
    /// the general workout and other days stay as they are.
    func updateWorkout(ofSession id: UUID, to workout: WorkoutTemplate) {
        guard var session = session(id: id) else { return }
        session.workout = session.followsWorkout ? workout.withFreshEntryIDs() : workout
        session.followsWorkout = false
        update(session)
    }

    /// Starts the session: it takes its own copy and freezes. Returns it as
    /// it now reads.
    @discardableResult
    func start(id: UUID) -> WorkoutSession? {
        guard
            let index = sessions.firstIndex(where: { $0.id == id }),
            let started = database.startSession(id: id, at: .now)
        else { return nil }
        sessions[index] = started
        return started
    }

    func remove(id: UUID) {
        database.deleteSession(id: id)
        sessions.removeAll { $0.id == id }
    }
}
