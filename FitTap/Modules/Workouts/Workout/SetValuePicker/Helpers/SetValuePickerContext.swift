import Foundation

/// Everything the set value picker needs to know: which value of which
/// exercise it edits, and the value it starts on. Reps and weight belong to
/// a set; duration and speed belong to a cardio exercise as a whole.
struct SetValuePickerContext: Hashable, Sendable {
    enum Field: Hashable, Sendable {
        case reps
        case weight
        /// Cardio duration, in minutes.
        case duration
        /// Cardio speed, in km/h.
        case speed
    }

    let field: Field
    let workoutExerciseID: UUID
    /// The set being edited; nil for cardio fields.
    let setID: UUID?
    let exerciseName: String
    /// 1-based, as shown on the card; nil for cardio fields.
    let setNumber: Int?
    let exerciseKind: ExerciseKind
    let loadMode: LoadMode?
    let currentValue: Double?
}
