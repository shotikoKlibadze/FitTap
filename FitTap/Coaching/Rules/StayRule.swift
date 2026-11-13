import Foundation

/// "Stay at this weight."
///
/// **When:** the latest session missed any sets. How many decides the
/// words, not the advice:
///
/// - up to half the sets missed (the last one or two of four): "you
///   finished most of your sets" (`.stay`);
/// - more than half missed (three or all of four): "stay until you finish
///   every set, or go down a step for a session or two"
///   (`.stayUntilClean`).
///
/// **Why:** missed sets mean the weight is at or past the limit for now.
/// Whether it was a near miss or a rough session, the step is the same:
/// keep the weight and come back to it until every set is done, instead of
/// going up. After a heavy miss, one step down for a session or two is
/// offered as the other way back.
///
/// **Source:** common coaching practice for the near miss; staying after a
/// heavy miss is our own rule. Neither is checked against a source yet.
///
/// > Important: A failed set only says "missed". Its reps may still be the
/// > planned number, so this rule counts missed sets and never asks how many
/// > reps short they were.
struct StayRule: CoachRule {
    func suggestion(for history: [ExerciseSessionLog]) -> Suggestion? {
        guard let latest = history.first, latest.straightWeight != nil else { return nil }
        let missed = latest.missedSetCount
        guard missed > 0 else { return nil }
        return missed * 2 <= latest.sets.count ? .stay : .stayUntilClean
    }
}
