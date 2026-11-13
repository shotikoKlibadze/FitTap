import DesignSystem
import NavigatorUI
import SwiftUI

/// A workout being done, presented as a full-screen cover. No toolbar: the
/// name and a close button sit in the pinned top area instead. Leaving
/// early throws the session away — after asking, once anything is logged;
/// "Finish Workout" marks it done.
struct WorkoutSessionScreen: View {
    @State private var screenModel: WorkoutSessionScreenModel
    @Environment(\.navigator) private var navigator
    @State private var isAskingToUpdateWorkout = false

    init(sessionID: UUID, startedFresh: Bool) {
        _screenModel = State(initialValue: WorkoutSessionScreenModel(sessionID: sessionID, startedFresh: startedFresh))
    }

    var body: some View {
        WorkoutSessionView(
            title: screenModel.title,
            color: screenModel.color.color,
            isConfirmingExit: $screenModel.isConfirmingExit,
            isEditing: $screenModel.isEditing,
            hasLoggedSets: screenModel.hasLoggedSets,
            exitMessage: screenModel.exitMessage,
            progress: screenModel.progress,
            progressTitle: screenModel.progressTitle,
            progressSubtitle: screenModel.progressSubtitle,
            startedAt: screenModel.startedAt,
            exercises: $screenModel.exercises,
            catalog: screenModel.catalog,
            onTapReps: screenModel.didTapReps,
            onTapWeight: screenModel.didTapWeight,
            onTapDuration: screenModel.didTapDuration,
            onTapSpeed: screenModel.didTapSpeed,
            onRemoveExercise: screenModel.removeExercise,
            onTapAddExercise: screenModel.didTapAddExercise,
            onClose: endWorkout,
            onEndWorkout: endWorkout,
            onFinish: finish,
        )
        .navigate(to: $screenModel.destination)
        .navigationCheckpoint(WorkoutCheckpoints.addExercises) { ids in
            screenModel.addExercises(ids)
        }
        .bottomSheet(item: $screenModel.setValuePicker, height: { _ in SetValuePickerMetrics.sheetHeight }) { context in
            SetValuePickerScreen(context: context, onPick: screenModel.applySetValue)
        }
        .appAlert(
            isPresented: $isAskingToUpdateWorkout,
            title: "Update \(screenModel.title)?",
            message: "You changed reps, weights or exercises. Keep them for this session only, or for every \(screenModel.title) too?",
            actions: [
                AppAlertAction("This Session Only") {
                    screenModel.finish()
                    close()
                },
                AppAlertAction("Update \(screenModel.title)") {
                    screenModel.finish(updatingWorkout: true)
                    close()
                },
            ],
        )
        // The cover's own stack would show an empty bar; the top area replaces it.
        .toolbarVisibility(.hidden, for: .navigationBar)
    }

    /// Finishes; if the plan changed during the workout, asks first whether
    /// to keep the changes for the workout too.
    private func finish() {
        if screenModel.hasChangedPlan {
            isAskingToUpdateWorkout = true
            return
        }
        screenModel.finish()
        close()
    }

    private func endWorkout() {
        screenModel.discard()
        close()
    }

    private func close() {
        navigator.dismiss()
    }
}
