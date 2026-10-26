import Foundation

/// Every exercise the app knows: the built-in catalog plus the ones the user
/// creates. In memory for now — SwiftData takes over when persistence lands.
/// One instance for the app (see `Container.exerciseStore`), so an exercise
/// created while picking is there when the workout looks it up.
@MainActor
@Observable
final class ExerciseStore {
    private(set) var exercises: [Exercise] = ExerciseData.exercises

    func exercise(id: UUID) -> Exercise? {
        exercises.first { $0.id == id }
    }

    func add(_ exercise: Exercise) {
        exercises.append(exercise)
    }
}
