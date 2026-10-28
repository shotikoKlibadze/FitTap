import SwiftUI

/// Content of Add Exercise's New Exercise bottom sheet. Hands the created
/// exercise back through `onCreate`; the owner saves it and closes the sheet.
struct NewExerciseScreen: View {
    @State private var screenModel: NewExerciseScreenModel
    let onCreate: (Exercise) -> Void

    init(primaryMuscleGroup: MuscleGroup?, onCreate: @escaping (Exercise) -> Void) {
        _screenModel = State(initialValue: NewExerciseScreenModel(primaryMuscleGroup: primaryMuscleGroup))
        self.onCreate = onCreate
    }

    var body: some View {
        NewExerciseView(
            name: $screenModel.name,
            primaryMuscleGroup: $screenModel.primaryMuscleGroup,
            secondaryMuscleGroup: $screenModel.secondaryMuscleGroup,
            equipment: $screenModel.equipment,
            primaryOptions: screenModel.primaryOptions,
            secondaryOptions: screenModel.secondaryOptions,
            equipmentOptions: screenModel.equipmentOptions,
            canCreate: screenModel.canCreate,
            onTapCreate: create,
        )
    }

    private func create() {
        guard let exercise = screenModel.makeExercise() else { return }
        onCreate(exercise)
    }
}
