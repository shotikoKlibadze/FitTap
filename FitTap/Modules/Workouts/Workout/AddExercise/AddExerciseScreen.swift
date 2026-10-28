import DesignSystem
import NavigatorUI
import SwiftUI

struct AddExerciseScreen: View {
    @State private var screenModel: AddExerciseScreenModel
    @State private var isShowingDiscardAlert = false
    @Environment(\.navigator) private var navigator

    /// `filter` is the chip the list opens on.
    init(filter: AddExerciseFilter = .all) {
        _screenModel = State(initialValue: AddExerciseScreenModel(filter: filter))
    }

    var body: some View {
        AddExerciseView(
            filter: $screenModel.filter,
            exercises: screenModel.exercises,
            selectedIDs: screenModel.selectedExerciseIDs,
            onToggleExercise: screenModel.toggleExercise,
            onTapCreateExercise: screenModel.didTapCreateExercise,
            onTapAdd: handleConfirm,
        )
        .bottomSheet(isPresented: $screenModel.isCreatingExercise, height: NewExerciseMetrics.sheetHeight) {
            NewExerciseScreen(
                primaryMuscleGroup: screenModel.filter.muscleGroup,
                onCreate: screenModel.createExercise,
            )
        }
        .appToolbar(
            title: "Add Exercise",
            leading: AppToolbarButton(.back, action: handleBack),
            trailing: AppToolbarButton(.confirm, action: handleConfirm),
        )
        .appAlert(
            isPresented: $isShowingDiscardAlert,
            title: "Discard selection?",
            message: screenModel.discardMessage,
            confirmTitle: "Discard",
            cancelTitle: "Keep Editing",
            onConfirm: handleClose,
        )
    }

    private func handleBack() {
        guard !screenModel.selectedExerciseIDs.isEmpty else { return handleClose() }
        isShowingDiscardAlert = true
    }

    private func handleConfirm() {
        let picked = screenModel.pickedExerciseIDs
        guard !picked.isEmpty else { return handleClose() }
        // returnToCheckpoint pops back to New Workout itself.
        navigator.returnToCheckpoint(WorkoutCheckpoints.addExercises, value: picked)
    }

    private func handleClose() {
        if navigator.dismiss() { return }
        navigator.pop()
    }
}
