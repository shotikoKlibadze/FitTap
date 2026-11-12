import Foundation

/// How the coaching rules read an exercise's whole history, newest first.
extension [ExerciseSessionLog] {
    /// The reps of the latest session when the user is ready to move on
    /// from them; nil otherwise. Ready means the latest session was clean
    /// and either:
    ///
    /// - it felt easy: one such session is enough, or
    /// - the session before was clean too, at the same weight and reps, and
    ///   the latest didn't feel hard. Two in a row, so one good day at
    ///   medium (or unrated) doesn't trigger a nudge.
    var readyReps: Int? {
        guard let latest = first, latest.isClean, latest.effort != .hard else { return nil }
        if latest.effort == .easy { return latest.targetReps }
        guard count >= 2 else { return nil }
        let previous = self[1]
        guard
            previous.isClean,
            latest.straightWeight == previous.straightWeight,
            latest.targetReps == previous.targetReps
        else { return nil }
        return latest.targetReps
    }

    /// The top of the user's rep range on this exercise, learned instead of
    /// asked: the most reps they completed cleanly in the last ten sessions.
    ///
    /// Someone who only ever does 4×8 has a top of 8, so they are nudged
    /// straight to more weight; someone who has done 4×10 is nudged to add
    /// reps until they are back at 10.
    ///
    /// > Important: This is a first, simple guess at the range and the part
    /// > of the coaching most likely to change.
    var topReps: Int? {
        prefix(10).filter(\.isClean).map(\.targetReps).max()
    }
}
