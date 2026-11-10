import Foundation

extension [WorkoutExercise] {
    /// Writes a value picked in the set value picker into the set (or cardio
    /// entry) it was picked for. Unknown ids change nothing.
    mutating func apply(_ edit: SetValueEdit) {
        guard let exerciseIndex = firstIndex(where: { $0.id == edit.workoutExerciseID }) else { return }
        switch edit.field {
        case .reps, .weight, .holdTime:
            guard let setIndex = self[exerciseIndex].sets.firstIndex(where: { $0.id == edit.setID }) else { return }
            switch edit.field {
            case .reps: self[exerciseIndex].sets[setIndex].reps = Int(edit.value)
            case .holdTime: self[exerciseIndex].sets[setIndex].duration = edit.value
            default: self[exerciseIndex].sets[setIndex].weight = edit.value
            }
        case .duration:
            self[exerciseIndex].cardio?.duration = edit.value * 60
        case .speed:
            self[exerciseIndex].cardio?.speedKmh = edit.value
        }
    }
}
