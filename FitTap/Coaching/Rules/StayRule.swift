import Foundation

/// "You're close, stay here."
///
/// **When:** the latest session missed some sets, but no more than half of
/// them. Examples: 4 sets with the last one marked failed, or with the last
/// two marked failed.
///
/// **Why:** finishing most of the sets and missing the rest means the
/// weight is right at the limit, which is where it should be; the next step
/// is finishing those sets, not changing the load.
///
/// **Source:** common coaching practice; not yet checked against a source.
///
/// > Important: A failed set only says "missed". Its reps may still be the
/// > planned number, so this rule counts missed sets and never asks how many
/// > reps short they were.
struct StayRule: CoachRule {
    func nudge(for history: [ExerciseSessionLog]) -> Nudge? {
        guard let latest = history.first, latest.straightWeight != nil else { return nil }
        let missed = latest.missedSetCount
        guard missed > 0, missed * 2 <= latest.sets.count else { return nil }
        return .stay
    }
}
