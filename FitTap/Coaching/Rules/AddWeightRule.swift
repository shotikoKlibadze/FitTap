import Foundation

/// "Go up one step."
///
/// **When:** the user is ready to move on (a clean session that felt easy,
/// or two clean sessions in a row at the same weight and reps that didn't
/// feel hard), and those reps are already the most the user does on this
/// exercise. Example: 20 kg 4×8 twice at medium, or once at easy, with 8 as their usual top.
///
/// **Why:** double progression. Once the top of the rep range is repeated
/// without a miss, the weight is no longer hard enough, so the load goes up
/// and the reps start again lower.
///
/// **Source:** double progression is standard practice; the "twice in a
/// row" confirmation and the use of the effort rating are not yet checked
/// against a source.
struct AddWeightRule: CoachRule {
    func nudge(for history: [ExerciseSessionLog]) -> Nudge? {
        guard let reps = history.readyReps, let top = history.topReps, reps >= top else { return nil }
        return .addWeight
    }
}
