import Foundation

/// A cardio effort: duration required; speed, distance and count optional
/// (count covers jump-rope style logging).
struct CardioEntry: Hashable, Codable, Sendable {
    var duration: TimeInterval
    /// Average speed in km/h.
    var speedKmh: Double?
    var distanceMeters: Double?
    var count: Int?
    /// When the effort started. Nil on templates. With `duration` it bounds the
    /// `HKWorkoutActivity` this entry becomes on HealthKit sync.
    /// See Knowledge/iOSHealthKit/README.md §2.
    var startedAt: Date?

    init(
        duration: TimeInterval,
        speedKmh: Double? = nil,
        distanceMeters: Double? = nil,
        count: Int? = nil,
        startedAt: Date? = nil,
    ) {
        self.duration = duration
        self.speedKmh = speedKmh
        self.distanceMeters = distanceMeters
        self.count = count
        self.startedAt = startedAt
    }
}
