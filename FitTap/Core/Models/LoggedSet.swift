import Foundation

/// A set that was checked off, with the exercise it belongs to: what stats
/// read when counting sets per muscle or finding a best set. Comes from
/// `SwiftDataManager.loggedSets(from:to:)`.
struct LoggedSet: Hashable, Sendable {
    let exerciseID: UUID
    /// The session it was logged in.
    let sessionID: UUID
    let reps: Int
    let weight: Double?
    /// Seconds held, for a hold exercise.
    let duration: TimeInterval?
    let failed: Bool
    let loggedAt: Date
}

extension LoggedSet {
    /// How sets compare when looking for a best: weight first, then reps,
    /// then how long it was held.
    var rank: (Double, Int, TimeInterval) {
        (weight ?? 0, reps, duration ?? 0)
    }
}
