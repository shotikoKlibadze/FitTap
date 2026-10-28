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
}
