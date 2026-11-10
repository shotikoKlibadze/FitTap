import FactoryKit
import Foundation

/// Every exercise the app knows: the built-in catalog plus the ones the user
/// creates, saved in the database. One instance for the app (see
/// `Container.exerciseStore`), so an exercise created while picking is there
/// when the workout looks it up.
@MainActor
@Observable
final class ExerciseStore {
    @ObservationIgnored @Injected(\.swiftDataManager) private var database

    private(set) var exercises: [Exercise] = []

    init() {
        exercises = database.exercises()
    }

    func exercise(id: UUID) -> Exercise? {
        exercises.first { $0.id == id }
    }

    /// Saves a new exercise and adds it to the list.
    func add(_ exercise: Exercise) {
        database.save(exercise)
        exercises.append(exercise)
    }
}
