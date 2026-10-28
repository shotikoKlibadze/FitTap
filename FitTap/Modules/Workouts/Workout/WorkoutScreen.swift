import DesignSystem
import NavigatorUI
import SwiftUI

/// A workout read or edited in place. With an id it opens read-only and
/// "Edit" morphs it into editing, where "Edit" turns into "Cancel"; without
/// one it opens editing a new workout. Opened from a planned session, "Edit"
/// first asks whether to edit the workout or move the session.
struct WorkoutScreen: View {
    /// What confirming the discard alert does.
    private enum Discard {
        /// Back while editing: drop the changes and leave the screen.
        case leave
        /// Cancel: drop the changes and return to reading.
        case stopEditing
    }

    @State private var screenModel: WorkoutScreenModel
    @State private var isShowingDiscardAlert = false
    @State private var isShowingPlannedAlert = false
    @State private var pendingDiscard = Discard.leave
    @Environment(\.navigator) private var navigator

    init(workoutID: UUID? = nil, source: WorkoutScreenSource = .library) {
        _screenModel = State(initialValue: WorkoutScreenModel(workoutID: workoutID, source: source))
    }

    /// The one curve for switching between reading and editing.
    private let modeChange = Animation.smooth(duration: 0.4)

    var body: some View {
        WorkoutView(
            isEditing: screenModel.isEditing,
            showsPlanButton: screenModel.showsPlanButton,
            isPlanning: $screenModel.isPlanning,
            planDate: $screenModel.planDate,
            planTitle: screenModel.planTitle,
            today: screenModel.today,
            calendar: screenModel.calendar,
            name: $screenModel.name,
            type: $screenModel.type,
            color: $screenModel.color,
            primaryMuscleGroup: $screenModel.primaryMuscleGroup,
            secondaryMuscleGroup: $screenModel.secondaryMuscleGroup,
            exercises: $screenModel.exercises,
            catalog: screenModel.catalog,
            subtitle: screenModel.subtitle,
            stats: screenModel.stats,
            lastDoneText: screenModel.lastDoneText,
            saveTitle: screenModel.saveTitle,
            canSave: screenModel.canSave,
            onTapAddExercise: screenModel.didTapAddExercise,
            onTapReps: screenModel.didTapReps,
            onTapWeight: screenModel.didTapWeight,
            onTapDuration: screenModel.didTapDuration,
            onTapSpeed: screenModel.didTapSpeed,
            onRemoveExercise: screenModel.removeExercise,
            onTapSave: handleSave,
            onTapStart: screenModel.didTapStartWorkout,
            onSavePlan: screenModel.savePlan,
        )
        .navigate(to: $screenModel.destination)
        .navigationCheckpoint(WorkoutCheckpoints.addExercises) { ids in
            screenModel.addExercises(ids)
        }
        .bottomSheet(item: $screenModel.setValuePicker, height: { _ in SetValuePickerMetrics.sheetHeight }) { context in
            SetValuePickerScreen(context: context, onPick: screenModel.applySetValue)
        }
        .appToolbar(
            title: screenModel.toolbarTitle,
            leading: AppToolbarButton(.back, action: handleBack),
            trailing: trailingButton,
        )
        .appAlert(
            isPresented: $isShowingDiscardAlert,
            title: screenModel.discardTitle,
            message: screenModel.discardMessage,
            confirmTitle: "Discard",
            cancelTitle: "Keep Editing",
            onConfirm: { discard(pendingDiscard) },
        )
        .appAlert(
            isPresented: $isShowingPlannedAlert,
            title: screenModel.plannedAlertTitle,
            message: screenModel.plannedAlertMessage,
            actions: [
                AppAlertAction("Edit Workout", action: startEditing),
                AppAlertAction("Change Date", action: screenModel.didTapChangeDate),
            ],
        )
    }

    /// Reading: "Edit". Editing an existing workout: "Cancel". A new workout
    /// has nothing to return to, so nothing.
    private var trailingButton: AppToolbarButton? {
        if !screenModel.isEditing {
            return AppToolbarButton(title: "Edit", action: handleEdit)
        }
        return screenModel.isNew ? nil : AppToolbarButton(title: "Cancel", action: handleCancel)
    }

    /// A planned session asks first — the user may only want to move it.
    private func handleEdit() {
        guard screenModel.plannedDate == nil else {
            isShowingPlannedAlert = true
            return
        }
        startEditing()
    }

    private func startEditing() {
        withAnimation(modeChange) { screenModel.didTapEdit() }
    }

    /// Leaves the screen; while editing, unsaved changes ask first.
    private func handleBack() {
        guard screenModel.isEditing else { return close() }
        confirmDiscard(.leave)
    }

    /// Back to reading; unsaved changes ask first.
    private func handleCancel() {
        confirmDiscard(.stopEditing)
    }

    private func confirmDiscard(_ action: Discard) {
        guard screenModel.hasUnsavedChanges else { return discard(action) }
        pendingDiscard = action
        isShowingDiscardAlert = true
    }

    private func discard(_ action: Discard) {
        switch action {
        case .leave:
            close()
        case .stopEditing:
            withAnimation(modeChange) { screenModel.cancelEditing() }
        }
    }

    private func handleSave() {
        if screenModel.isNew {
            screenModel.save()
            return close()
        }
        withAnimation(modeChange) { screenModel.save() }
    }

    private func close() {
        if navigator.dismiss() { return }
        navigator.pop()
    }
}
