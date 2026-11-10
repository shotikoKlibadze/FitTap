import Foundation

/// A cardio effort from a finished session: what stats sum into minutes.
/// Comes from `SwiftDataManager.cardioEntries(from:to:)`.
struct LoggedCardio: Hashable, Sendable {
    let exerciseID: UUID
    let duration: TimeInterval
    let distanceMeters: Double?
    /// When its session ended.
    let date: Date
}
