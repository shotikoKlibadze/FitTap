import Foundation

extension WorkoutTemplate {
    /// The workout with every logged set's time moved inside `session`'s
    /// span. A set checked off while fixing a finished workout is stamped
    /// "now"; brought back to the session's day, stats count it there.
    /// Times already inside the span stay as they are.
    func dated(within session: WorkoutSession) -> WorkoutTemplate {
        let start = session.startedAt ?? session.scheduledFor
        let end = max(session.endedAt ?? start, start)
        var workout = self
        for exercise in workout.exercises.indices {
            for set in workout.exercises[exercise].sets.indices {
                guard let loggedAt = workout.exercises[exercise].sets[set].loggedAt else { continue }
                workout.exercises[exercise].sets[set].loggedAt = min(max(loggedAt, start), end)
            }
        }
        return workout
    }
}
