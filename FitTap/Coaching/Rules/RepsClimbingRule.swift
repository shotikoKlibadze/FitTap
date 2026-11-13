import Foundation

/// "Try heavier, you can do it."
///
/// **When:** the last three sessions were all clean at the same weight, and
/// the reps went up each time. Example: 20 kg for 4×8, then 4×9, then 4×10.
///
/// **Why:** double progression. Reps that keep rising at one weight show
/// the weight has become too light; the next step is more load, with the
/// reps starting again lower.
///
/// **Source:** double progression is standard practice; "three sessions,
/// rising each time" as the trigger is our own rule, not yet checked
/// against a source.
struct RepsClimbingRule: CoachRule {
    func suggestion(for history: [ExerciseSessionLog]) -> Suggestion? {
        guard history.count >= 3 else { return nil }
        let recent = history.prefix(3)
        guard
            let weight = recent[0].straightWeight,
            recent.allSatisfy({ $0.isClean && $0.straightWeight == weight }),
            recent[0].targetReps > recent[1].targetReps,
            recent[1].targetReps > recent[2].targetReps
        else { return nil }
        return .tryHeavier
    }
}
