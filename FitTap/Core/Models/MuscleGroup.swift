import Foundation

/// The body part an exercise primarily targets. Organizes the exercise picker
/// and labels workouts. Cardio exercises have none, so the field is optional
/// on `Exercise`.
enum MuscleGroup: String, Codable, CaseIterable, Sendable {
    case back
    case chest
    case shoulders
    case legs
    case abs
    case triceps
    case biceps
    case fullBody

    var displayName: String {
        switch self {
        case .fullBody: "Full Body"
        default: rawValue.capitalized
        }
    }
}
