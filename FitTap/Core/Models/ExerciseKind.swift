import Foundation

/// How the exercise gets logged — determines which logging UI appears and
/// which fields are relevant on the logged entries.
enum ExerciseKind: String, Codable, CaseIterable, Sendable {
    /// Sets of reps × weight (bench press, squat, cable fly); `loadMode` says
    /// how the weight is entered.
    case weightlifting
    /// Sets of reps; the user chooses per set between pure bodyweight and
    /// added weight (weighted dips). No `loadMode`.
    case bodyweight
    /// One entry per exercise: duration required, distance and count optional.
    case cardio
}
