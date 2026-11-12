import Foundation

/// How the coaching rules read one session of an exercise.
extension ExerciseSessionLog {
    /// The weight every set used, or nil when the sets differ or carry no
    /// weight. The rules only judge these "straight" sessions for now, so
    /// mixed-weight, bodyweight and hold sessions get no nudge.
    var straightWeight: Double? {
        guard let weight = sets.first?.weight, sets.allSatisfy({ $0.weight == weight }) else { return nil }
        return weight
    }

    /// The reps the session was aiming for: the most on any set. The plan
    /// isn't stored with the log, so the best set stands in for it.
    var targetReps: Int {
        sets.map(\.reps).max() ?? 0
    }

    /// How many sets were missed: marked failed, or logged with fewer reps
    /// than the session's reps.
    ///
    /// > Important: A failed set's reps can't be trusted as "how many were
    /// > done": some users lower the number, others leave the planned one
    /// > and only mark the set failed. So a failed set counts as missed
    /// > whatever its reps say, and nothing here measures how far short it
    /// > was.
    var missedSetCount: Int {
        sets.count { $0.failed || $0.reps < targetReps }
    }

    /// A straight session where every set was done: nothing failed and
    /// every set reached the same reps, like 4×8 with nothing missed.
    var isClean: Bool {
        straightWeight != nil && missedSetCount == 0
    }
}
