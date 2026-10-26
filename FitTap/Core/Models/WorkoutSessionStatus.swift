import Foundation

/// Derived state of a scheduled workout session — drives the Home week strip
/// dots: filled = done, ring = planned, dashed red = missed.
enum WorkoutSessionStatus: String, Codable, Sendable {
    case planned
    case done
    case missed
}
