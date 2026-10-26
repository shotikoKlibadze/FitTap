import DesignSystem
import NavigatorUI
import SwiftUI

struct NewWorkoutScreen: View {
    @State private var screenModel = NewWorkoutScreenModel()
    @State private var isShowingDiscardAlert = false
    @Environment(\.navigator) private var navigator

    var body: some View {
        NewWorkoutView(
            name: $screenModel.name,
            type: $screenModel.type,
            color: $screenModel.color,
            primaryMuscleGroup: $screenModel.primaryMuscleGroup,
            secondaryMuscleGroup: $screenModel.secondaryMuscleGroup,
            exercises: $screenModel.exercises,
            catalog: screenModel.catalog,
            canCreate: screenModel.canCreate,
            onTapAddExercise: screenModel.didTapAddExercise,
            onTapReps: screenModel.didTapReps,
            onTapWeight: screenModel.didTapWeight,
            onTapDuration: screenModel.didTapDuration,
            onTapSpeed: screenModel.didTapSpeed,
            onRemoveExercise: screenModel.removeExercise,
            onTapCreate: handleCreate,
        )
        .navigate(to: $screenModel.destination)
        .navigationCheckpoint(NewWorkoutCheckpoints.addExercises) { ids in
            screenModel.addExercises(ids)
        }
        .bottomSheet(item: $screenModel.setValuePicker, height: { _ in SetValuePickerMetrics.sheetHeight }) { context in
            SetValuePickerScreen(context: context, onPick: screenModel.applySetValue)
        }
        .appToolbar(
            title: "New Workout",
            leading: AppToolbarButton(.back, action: handleBack),
        )
        .appAlert(
            isPresented: $isShowingDiscardAlert,
            title: "Discard this workout?",
            message: screenModel.discardMessage,
            confirmTitle: "Discard",
            cancelTitle: "Keep Editing",
            onConfirm: handleClose,
        )
    }

    private func handleBack() {
        guard screenModel.hasUnsavedChanges else { return handleClose() }
        isShowingDiscardAlert = true
    }

    private func handleCreate() {
        screenModel.createWorkout()
        handleClose()
    }

    private func handleClose() {
        if navigator.dismiss() { return }
        navigator.pop()
    }
}
