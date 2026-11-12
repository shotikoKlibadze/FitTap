import Foundation

/// What the coach suggests for an exercise's next session.
///
/// A nudge is only the decision ("add weight"), never the sentence the user
/// reads: `CoachEngine` picks it from the logged sets, and the wording is
/// done elsewhere. No nudge at all is `nil`, not a case here.
enum Nudge: Hashable, Sendable {
    /// Keep the weight, aim for one more rep per set.
    case addReps
    /// Go up one weight step; fewer reps are expected at first.
    case addWeight
    /// Keep the weight and the reps: the missed sets are almost there.
    case stay
    /// The sets were done but felt hard: repeat until it feels medium, or
    /// go up if the user feels ready.
    case repeatUntilEasier
}
