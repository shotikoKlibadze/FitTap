import Foundation

/// "Try one more rep per set."
///
/// **When:** the last two sessions were both clean at the same weight and
/// reps, the latest didn't feel hard, and those reps are still below the
/// most the user does on this exercise. Example: 20 kg 4×8 twice, when
/// they have done 4×10 before.
///
/// **Why:** double progression. Reps go up first because one more rep is a
/// smaller step than the next weight, especially on light loads.
///
/// **Source:** double progression is standard practice. "Two sessions in
/// a row" follows the 2-for-2 rule as NSCA study guides give it; see
/// `CoachingRules.md`.
struct AddRepsRule: CoachRule {
    func suggestion(for history: [ExerciseSessionLog]) -> Suggestion? {
        guard let reps = history.readyReps, let top = history.topReps, reps < top else { return nil }
        return .addReps
    }
}
