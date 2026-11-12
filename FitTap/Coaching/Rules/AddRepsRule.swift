import Foundation

/// "Try one more rep per set."
///
/// **When:** the user is ready to move on (a clean session that felt easy,
/// or two clean sessions in a row at the same weight and reps that didn't
/// feel hard), and those reps are still below the most the user does on this
/// exercise. Example: 20 kg 4×8 twice at medium, or once at easy, when they have done 4×10 before.
///
/// **Why:** double progression. Reps go up first because one more rep is a
/// smaller step than the next weight, especially on light loads.
///
/// **Source:** double progression is standard practice; the "twice in a
/// row" confirmation and the use of the effort rating are not yet checked
/// against a source.
struct AddRepsRule: CoachRule {
    func nudge(for history: [ExerciseSessionLog]) -> Nudge? {
        guard let reps = history.readyReps, let top = history.topReps, reps < top else { return nil }
        return .addReps
    }
}
