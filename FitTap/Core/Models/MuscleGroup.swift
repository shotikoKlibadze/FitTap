import Foundation

/// The body part an exercise primarily targets. Organizes the exercise picker
/// and labels workouts. Cardio exercises have none, so the field is optional
/// on `Exercise`.
///
/// `arms` is for workouts only ("Shoulders + Arms"): an exercise works the
/// biceps or the triceps, so exercise pickers offer `exerciseGroups`.
enum MuscleGroup: String, Codable, CaseIterable, Sendable {
    case back
    case chest
    case shoulders
    case legs
    case abs
    case arms
    case triceps
    case biceps
    case fullBody

    /// Every group an exercise can target — all but `arms`.
    static var exerciseGroups: [MuscleGroup] {
        allCases.filter { $0 != .arms }
    }

    var displayName: String {
        switch self {
        case .fullBody: "Full Body"
        default: rawValue.capitalized
        }
    }
}
