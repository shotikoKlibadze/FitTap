import Foundation

extension [WorkoutSession] {
    /// How long a workout usually takes: the average of its last five
    /// finished sessions, rounded to five minutes. Nil until one has been
    /// finished — callers fall back to `WorkoutTemplate.estimatedMinutes`.
    func typicalMinutes(ofWorkout id: UUID) -> Int? {
        let durations = filter { $0.workout.id == id }
            .compactMap { session -> (end: Date, seconds: TimeInterval)? in
                guard let start = session.startedAt, let end = session.endedAt, end > start else { return nil }
                return (end, end.timeIntervalSince(start))
            }
            .sorted { $0.end > $1.end }
            .prefix(5)
            .map(\.seconds)
        guard !durations.isEmpty else { return nil }
        let minutes = durations.reduce(0, +) / Double(durations.count) / 60
        return Int((minutes / 5).rounded()) * 5
    }
}
