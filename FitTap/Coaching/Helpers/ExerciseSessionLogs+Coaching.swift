import Foundation

/// How the coaching rules read an exercise's whole history, newest first.
extension [ExerciseSessionLog] {
    /// The reps of the latest session when the user is ready to move on
    /// from them; nil otherwise. Ready means the last two sessions were both
    /// clean, at the same weight and the same reps, and the latest didn't
    /// feel hard.
    ///
    /// Two in a row, whatever the rating: one good day doesn't count, even
    /// an easy one. This follows the "2-for-2" coaching rule, which only
    /// moves the load up after two consecutive sessions.
    var readyReps: Int? {
        guard count >= 2 else { return nil }
        let latest = self[0]
        let previous = self[1]
        guard
            latest.isClean,
            latest.effort != .hard,
            previous.isClean,
            latest.straightWeight == previous.straightWeight,
            latest.targetReps == previous.targetReps
        else { return nil }
        return latest.targetReps
    }

    /// The top of the user's rep range on this exercise, learned instead of
    /// asked: the most reps they completed cleanly in the last ten sessions.
    ///
    /// Someone who only ever does 4×8 has a top of 8, so they are pointed
    /// straight to more weight; someone who has done 4×10 is pointed to add
    /// reps until they are back at 10.
    ///
    /// > Important: This is a first, simple guess at the range and the part
    /// > of the coaching most likely to change.
    var topReps: Int? {
        prefix(10).filter(\.isClean).map(\.targetReps).max()
    }
}
