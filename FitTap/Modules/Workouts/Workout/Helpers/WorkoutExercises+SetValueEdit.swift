import Foundation

extension [WorkoutExercise] {
    /// Writes a value picked in the set value picker into the set (or cardio
    /// entry) it was picked for. Reps, weight and hold time carry down to
    /// every set after it too — change set 2 and sets 3, 4… follow; the sets
    /// above stay. Unknown ids change nothing.
    mutating func apply(_ edit: SetValueEdit) {
        guard let exerciseIndex = firstIndex(where: { $0.id == edit.workoutExerciseID }) else { return }
        switch edit.field {
        case .reps, .weight, .holdTime:
            let sets = self[exerciseIndex].sets
            guard let setIndex = sets.firstIndex(where: { $0.id == edit.setID }) else { return }
            for index in setIndex..<sets.endIndex {
                switch edit.field {
                case .reps: self[exerciseIndex].sets[index].reps = Int(edit.value)
                case .holdTime: self[exerciseIndex].sets[index].duration = edit.value
                default: self[exerciseIndex].sets[index].weight = edit.value
                }
            }
        case .duration:
            self[exerciseIndex].cardio?.duration = edit.value * 60
        case .speed:
            self[exerciseIndex].cardio?.speedKmh = edit.value
        }
    }
}
