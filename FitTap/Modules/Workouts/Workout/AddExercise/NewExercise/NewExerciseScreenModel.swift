import Foundation

@MainActor
@Observable
final class NewExerciseScreenModel {
    var name = ""
    var primaryMuscleGroup: MuscleGroup?
    var secondaryMuscleGroup: MuscleGroup?
    var equipment: Equipment?

    /// The gear offered for a new exercise, in grid order.
    let equipmentOptions: [Equipment] = [
        .barbell, .dumbbell, .cable, .machine,
        .kettlebell, .bodyweight, .pullUpBar, .other,
    ]

    let primaryOptions = MuscleGroup.allCases

    /// The primary muscle can't also be the secondary.
    var secondaryOptions: [MuscleGroup] {
        MuscleGroup.allCases.filter { $0 != primaryMuscleGroup }
    }

    /// Starts on the muscle the exercise list is filtered to, if any.
    init(primaryMuscleGroup: MuscleGroup?) {
        self.primaryMuscleGroup = primaryMuscleGroup
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    /// A name, a primary muscle and the gear — everything else is optional.
    var canCreate: Bool {
        !trimmedName.isEmpty && primaryMuscleGroup != nil && equipment != nil
    }

    /// The exercise to save; what it logs follows from the equipment.
    func makeExercise() -> Exercise? {
        guard canCreate, let equipment else { return nil }
        return Exercise(
            name: trimmedName,
            kind: equipment.defaultKind,
            loadMode: equipment.defaultLoadMode,
            equipment: equipment,
            mainMuscleGroup: primaryMuscleGroup,
            secondaryMuscleGroup: secondaryMuscleGroup == primaryMuscleGroup ? nil : secondaryMuscleGroup,
        )
    }
}
