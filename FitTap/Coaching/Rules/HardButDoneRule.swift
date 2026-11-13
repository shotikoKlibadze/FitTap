import Foundation

/// "Done, but it was hard."
///
/// **When:** the latest session was clean (every set reached its reps,
/// nothing failed) and the user rated it hard. Example: 12.5 kg 4×10, hard.
///
/// **Why:** the sets were finished, so the weight isn't too heavy, but a
/// hard rating says there was nothing left. Repeating it until it feels
/// medium is the safe step; going up now is possible, not required.
///
/// **Source:** our own reading of the effort rating; not yet checked
/// against a source.
struct HardButDoneRule: CoachRule {
    func suggestion(for history: [ExerciseSessionLog]) -> Suggestion? {
        guard let latest = history.first, latest.isClean, latest.effort == .hard else { return nil }
        return .repeatUntilEasier
    }
}
