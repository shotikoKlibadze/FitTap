import Foundation

/// A value chosen in the set value picker, handed back to New Workout
/// through the picker's `onPick`.
struct SetValueEdit: Hashable, Sendable {
    let field: SetValuePickerContext.Field
    let workoutExerciseID: UUID
    /// The edited set; nil for cardio fields.
    let setID: UUID?
    let value: Double
}
