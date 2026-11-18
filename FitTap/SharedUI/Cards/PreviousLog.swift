import Foundation

/// The last time an exercise was done, as an exercise card's "Previous"
/// line shows it: what was done, and whether a set failed.
struct PreviousLog: Hashable, Sendable {
    /// e.g. "4 × 8 · 10 kg /side".
    let summary: String
    let failed: Bool
}

extension PreviousLog {
    init(_ log: ExerciseSessionLog, exercise: Exercise) {
        summary = log.previousSummary(for: exercise)
        failed = log.hasFailedSet
    }
}
