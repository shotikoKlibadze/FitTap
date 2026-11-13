import Foundation

/// What the coach suggests for an exercise's next session.
///
/// A suggestion is only the decision ("add weight"), never the sentence the user
/// reads: `CoachEngine` picks it from the logged sets, and the wording is
/// done elsewhere. No suggestion at all is `nil`, not a case here.
enum Suggestion: Hashable, Sendable {
    /// Keep the weight, aim for one more rep per set.
    case addReps
    /// Go up one weight step; fewer reps are expected at first.
    case addWeight
    /// Keep the weight and the reps: the missed sets are almost there.
    case stay
    /// Most of the sets were missed: keep the weight until every set is
    /// done, or drop a step for a session or two.
    case stayUntilClean
    /// The sets were done but felt hard: repeat until it feels medium, or
    /// go up if the user feels ready.
    case repeatUntilEasier
    /// First clean session at a heavier weight: hold it before moving up.
    case newWeight
    /// First clean session at a weight that was missed last time: hold it
    /// so the body gets used to it.
    case settleIn
    /// Reps have risen three sessions running at one weight: go heavier.
    case tryHeavier
}
