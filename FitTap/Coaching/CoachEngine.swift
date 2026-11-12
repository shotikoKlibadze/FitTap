import Foundation

/// Decides which nudge, if any, an exercise gets from its logged history.
///
/// It asks each rule in order and takes the first answer, so the order is
/// the priority: "stay" and "hard but done" are checked before the two
/// "add" rules. The same
/// history always gives the same nudge; there is no model in the decision.
///
/// It only reads plain logged sets. It must not touch SwiftData, the
/// stores, or any view code.
struct CoachEngine {
    /// With fewer sessions than this there is too little to judge, so the
    /// engine says nothing.
    static let minimumSessions = 3

    private let rules: [any CoachRule] = [StayRule(), HardButDoneRule(), AddWeightRule(), AddRepsRule()]

    /// - Parameter history: the exercise's sessions, newest first (as
    ///   `StatsStore.history(ofExercise:)` returns them).
    /// - Returns: the first nudge a rule gives, or nil for "say nothing".
    func nudge(for history: [ExerciseSessionLog]) -> Nudge? {
        guard history.count >= Self.minimumSessions else { return nil }
        return rules.lazy.compactMap { $0.nudge(for: history) }.first
    }
}
