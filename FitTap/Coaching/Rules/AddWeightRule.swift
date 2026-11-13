import Foundation

/// "Go up one step."
///
/// **When:** the last two sessions were both clean at the same weight and
/// reps, the latest didn't feel hard, and those reps are already the most
/// the user does on this exercise. Example: 20 kg 4×8 twice, with 8 as
/// their usual top.
///
/// **Why:** double progression. Once the top of the rep range is repeated
/// without a miss, the weight is no longer hard enough, so the load goes up
/// and the reps start again lower.
///
/// **Source:** double progression is standard practice. "Two sessions in
/// a row" follows the 2-for-2 rule as NSCA study guides give it; see
/// `CoachingRules.md`.
struct AddWeightRule: CoachRule {
    func suggestion(for history: [ExerciseSessionLog]) -> Suggestion? {
        guard let reps = history.readyReps, let top = history.topReps, reps >= top else { return nil }
        return .addWeight
    }
}
