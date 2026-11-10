import SwiftUI

/// Content of Home's plan-a-day bottom sheet. Tapping a workout hands it off
/// through `onOpenWorkout` — Home closes the sheet and opens the workout,
/// where "Plan for …" puts it on the day. "New workout" hands off through
/// `onTapNewWorkout`.
struct PlanDayScreen: View {
    @State private var screenModel: PlanDayScreenModel
    let onOpenWorkout: (UUID) -> Void
    let onTapNewWorkout: () -> Void

    init(day: Date, onOpenWorkout: @escaping (UUID) -> Void, onTapNewWorkout: @escaping () -> Void) {
        _screenModel = State(initialValue: PlanDayScreenModel(day: day))
        self.onOpenWorkout = onOpenWorkout
        self.onTapNewWorkout = onTapNewWorkout
    }

    var body: some View {
        PlanDayView(
            title: screenModel.title,
            items: screenModel.items,
            onOpenWorkout: onOpenWorkout,
            onTapNewWorkout: onTapNewWorkout,
        )
    }
}
