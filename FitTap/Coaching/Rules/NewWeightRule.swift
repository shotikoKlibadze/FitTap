import Foundation

/// "New weight achieved."
///
/// **When:** the latest session was clean and used more weight than the
/// session before it. Example: 30 kg 4×8 last time, 32.5 kg 4×8 today with
/// nothing missed.
///
/// **Why:** one clean session at a new weight shows it can be done, not
/// that it is settled. Holding it for a session or two before the next
/// step keeps the progress from running ahead of the user.
///
/// **Source:** our own rule; not yet checked against a source.
///
/// > Important: This rule is asked before the two "add" rules, so a first
/// > session at a new weight never leads straight to "add more", even when
/// > it felt easy.
struct NewWeightRule: CoachRule {
    func suggestion(for history: [ExerciseSessionLog]) -> Suggestion? {
        guard
            history.count >= 2,
            history[0].isClean,
            let weight = history[0].straightWeight,
            let previousWeight = history[1].straightWeight,
            weight > previousWeight
        else { return nil }
        return .newWeight
    }
}
