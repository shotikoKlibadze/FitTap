import Foundation

/// Every dated workout — planned, done or missed. In memory for now, seeded
/// with three weeks of sample sessions; SwiftData takes over when
/// persistence lands. One instance for the app (see
/// `Container.workoutSessionStore`).
@MainActor
@Observable
final class WorkoutSessionStore {
    private(set) var sessions: [WorkoutSession] = WorkoutSessionData.sessions

    func sessions(on day: Date) -> [WorkoutSession] {
        sessions.filter { WeekCalendar.calendar.isDate($0.scheduledFor, inSameDayAs: day) }
    }

    func add(_ session: WorkoutSession) {
        sessions.append(session)
    }

    func session(id: UUID) -> WorkoutSession? {
        sessions.first { $0.id == id }
    }

    /// Replaces the session with the same id; unknown ids are ignored.
    func update(_ session: WorkoutSession) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        sessions[index] = session
    }

    func remove(id: UUID) {
        sessions.removeAll { $0.id == id }
    }
}
