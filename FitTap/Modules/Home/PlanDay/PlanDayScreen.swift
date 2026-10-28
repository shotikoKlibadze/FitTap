import SwiftUI

/// Content of Home's plan-a-day bottom sheet. A pick is saved at once; the
/// sheet stays a second so the selection reads, then `onDone` closes it.
/// "New workout" hands off through `onTapNewWorkout`.
struct PlanDayScreen: View {
    @State private var screenModel: PlanDayScreenModel
    let onDone: () -> Void
    let onTapNewWorkout: () -> Void

    init(day: Date, onDone: @escaping () -> Void, onTapNewWorkout: @escaping () -> Void) {
        _screenModel = State(initialValue: PlanDayScreenModel(day: day))
        self.onDone = onDone
        self.onTapNewWorkout = onTapNewWorkout
    }

    /// How long the picked row shows before the sheet closes.
    private let closeDelay = Duration.seconds(1)

    var body: some View {
        PlanDayView(
            title: screenModel.title,
            items: screenModel.items,
            pickedID: screenModel.pickedID,
            onPick: screenModel.pick,
            onTapNewWorkout: onTapNewWorkout,
        )
        .task(id: screenModel.pickedID) {
            guard screenModel.pickedID != nil else { return }
            try? await Task.sleep(for: closeDelay)
            onDone()
        }
    }
}
