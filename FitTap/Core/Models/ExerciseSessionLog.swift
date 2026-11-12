import Foundation

/// One exercise as it was done in one session: the day and the sets that
/// were checked off, in order. What the exercise's progression page lists.
/// Comes from `SwiftDataManager.exerciseHistory(exerciseID:)`.
struct ExerciseSessionLog: Identifiable, Hashable, Sendable {
    let sessionID: UUID
    /// When the session started, or its planned day.
    let date: Date
    /// Logged sets only, in order; never empty.
    let sets: [SetEntry]
    /// How the exercise felt that day; nil when it wasn't rated.
    let effort: Effort?

    var id: UUID { sessionID }

    /// The heaviest set that wasn't failed, then the most reps, then the
    /// longest hold. Nil when every set failed.
    var bestSet: SetEntry? {
        sets.filter { !$0.failed }.max { $0.rank < $1.rank }
    }

    /// The top set to show for the session: its best, or — if every set
    /// failed — its heaviest attempt.
    var topSet: SetEntry? {
        bestSet ?? sets.max { $0.rank < $1.rank }
    }

    var hasFailedSet: Bool {
        sets.contains(where: \.failed)
    }
}

extension SetEntry {
    /// How sets compare when looking for a best: weight first, then reps,
    /// then how long it was held.
    var rank: (Double, Int, TimeInterval) {
        (weight ?? 0, reps, duration ?? 0)
    }
}
