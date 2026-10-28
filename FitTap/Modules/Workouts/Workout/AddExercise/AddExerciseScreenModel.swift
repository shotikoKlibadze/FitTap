import FactoryKit
import Foundation

@MainActor
@Observable
final class AddExerciseScreenModel {
    @ObservationIgnored
    @Injected(\.exerciseStore) private var exerciseStore

    var filter: AddExerciseFilter
    private(set) var selectedExerciseIDs: Set<UUID> = []
    /// Shows the New Exercise sheet.
    var isCreatingExercise = false

    init(filter: AddExerciseFilter = .all) {
        self.filter = filter
    }

    var exercises: [Exercise] {
        exerciseStore.exercises
            .sorted { $0.name < $1.name }
            .filter(filter.includes)
    }

    func toggleExercise(_ id: UUID) {
        if selectedExerciseIDs.contains(id) {
            selectedExerciseIDs.remove(id)
        } else {
            selectedExerciseIDs.insert(id)
        }
    }

    /// The picked exercises in catalog order — the order they're added in.
    var pickedExerciseIDs: [UUID] {
        exerciseStore.exercises
            .sorted { $0.name < $1.name }
            .map(\.id)
            .filter(selectedExerciseIDs.contains)
    }

    var discardMessage: String {
        let count = selectedExerciseIDs.count
        return count == 1
            ? "The exercise you picked won't be added."
            : "The \(count) exercises you picked won't be added."
    }

    func didTapCreateExercise() {
        isCreatingExercise = true
    }

    /// Saves the new exercise, picks it, and closes the sheet — the Add
    /// button then takes it into the workout with the rest of the picks.
    func createExercise(_ exercise: Exercise) {
        exerciseStore.add(exercise)
        selectedExerciseIDs.insert(exercise.id)
        isCreatingExercise = false
    }
}
