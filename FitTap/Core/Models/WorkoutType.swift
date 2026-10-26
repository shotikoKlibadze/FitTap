import Foundation

/// The creation-mode of a workout: strength builds muscle-group + sets,
/// cardio builds an activity with duration/distance targets. Card labels
/// derive from this.
enum WorkoutType: String, Codable, CaseIterable, Sendable {
    case strength
    case cardio
}
