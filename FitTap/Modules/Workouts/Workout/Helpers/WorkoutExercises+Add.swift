import Foundation

extension [WorkoutExercise] {
    /// Appends the exercises picked in Add Exercise, in order. Each arrives
    /// with one starter set: 10 reps, 10 kg (no weight for bodyweight moves),
    /// or a one-minute hold. Cardio has no sets — it arrives as 30 minutes
    /// with no speed yet. Ids missing from `catalog` are skipped.
    mutating func add(_ ids: [UUID], from catalog: [UUID: Exercise]) {
        let start = count
        let added = ids.enumerated().compactMap { offset, id -> WorkoutExercise? in
            guard let exercise = catalog[id] else { return nil }
            let order = start + offset
            switch exercise.kind {
            case .cardio:
                return WorkoutExercise(exerciseID: id, order: order, cardio: CardioEntry(duration: 30 * 60))
            case .hold:
                return WorkoutExercise(exerciseID: id, order: order, sets: [SetEntry(order: 0, reps: 0, duration: 60)])
            case .weightlifting:
                return WorkoutExercise(exerciseID: id, order: order, sets: [SetEntry(order: 0, reps: 10, weight: 10)])
            case .bodyweight:
                return WorkoutExercise(exerciseID: id, order: order, sets: [SetEntry(order: 0, reps: 10, weight: nil)])
            }
        }
        // One assignment, so an owner that saves on change saves once.
        self = self + added
    }
}
