import Foundation

/// One exercise's best set in its latest session, against its best set the
/// session before. "Best" is the heaviest, then the most reps, then the
/// longest hold; failed sets don't count.
struct ExerciseProgress: Identifiable, Hashable, Sendable {
    let exerciseID: UUID
    let latest: LoggedSet
    /// Nil when the exercise has only been done once in the window.
    let previous: LoggedSet?

    var id: UUID { exerciseID }

    /// Heavier is up; at the same weight, more reps is up; for a hold, a
    /// longer hold is up. Flat when there's nothing to compare with.
    var trend: ProgressTrend {
        guard let previous else { return .flat }
        let now = latest.rank
        let before = previous.rank
        if now > before { return .up }
        if now < before { return .down }
        return .flat
    }
}
