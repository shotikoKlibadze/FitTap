import Foundation

/// "You got all your sets."
///
/// **When:** the latest session was clean, at the same weight as the
/// session before, and that earlier session had missed sets. Example:
/// 20 kg with two sets failed last time, 20 kg 4×8 with nothing missed
/// today.
///
/// **Why:** finishing every set for the first time at a weight shows it
/// can be done, not that it is settled. A session or two more at the same
/// weight lets the body get used to it before the next step.
///
/// **Source:** our own rule; not yet checked against a source.
///
/// > Important: This rule is asked before the two "add" rules, so the
/// > first clean session after a miss never leads straight to "add more",
/// > even when it felt easy.
struct FirstCleanRule: CoachRule {
    func suggestion(for history: [ExerciseSessionLog]) -> Suggestion? {
        guard
            history.count >= 2,
            history[0].isClean,
            let weight = history[0].straightWeight,
            history[1].straightWeight == weight,
            history[1].missedSetCount > 0
        else { return nil }
        return .settleIn
    }
}
