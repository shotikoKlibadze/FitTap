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

extension SetValuePickerContext {
    /// Reps or weight of one set, starting on its current value; nil when the
    /// set is gone.
    static func set(_ field: Field, of workoutExercise: WorkoutExercise, setID: UUID, exercise: Exercise) -> Self? {
        guard let setIndex = workoutExercise.sets.firstIndex(where: { $0.id == setID }) else { return nil }
        let set = workoutExercise.sets[setIndex]
        return SetValuePickerContext(
            field: field,
            workoutExerciseID: workoutExercise.id,
            setID: setID,
            exerciseName: exercise.name,
            setNumber: setIndex + 1,
            exerciseKind: exercise.kind,
            loadMode: exercise.loadMode,
            currentValue: field == .reps ? Double(set.reps) : set.weight,
        )
    }

    /// Duration or speed of a cardio exercise; nil when it isn't cardio.
    static func cardio(_ field: Field, of workoutExercise: WorkoutExercise, exercise: Exercise) -> Self? {
        guard let cardio = workoutExercise.cardio else { return nil }
        return SetValuePickerContext(
            field: field,
            workoutExerciseID: workoutExercise.id,
            setID: nil,
            exerciseName: exercise.name,
            setNumber: nil,
            exerciseKind: exercise.kind,
            loadMode: nil,
            currentValue: field == .duration ? cardio.duration / 60 : cardio.speedKmh,
        )
    }
}
