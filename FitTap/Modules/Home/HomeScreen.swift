import DesignSystem
import NavigatorUI
import SwiftUI

struct HomeScreen: View {
    @State private var screenModel = HomeScreenModel()

    var body: some View {
        HomeView(
            profileTitle: screenModel.profileTitle,
            profileSubtitle: screenModel.profileSubtitle,
            weeks: screenModel.weeks,
            currentWeek: $screenModel.currentWeek,
            selectedDay: $screenModel.selectedDay,
            weekTitle: screenModel.weekTitle,
            dayTitle: screenModel.dayTitle,
            dayItem: screenModel.dayItem,
            dayAddTitle: screenModel.dayAddTitle,
            weekListTitle: screenModel.weekListTitle,
            weekItems: screenModel.weekItems,
            onTapPlanWorkout: screenModel.didTapPlanWorkout,
            onTapSession: screenModel.didTapSession,
        )
        .navigate(to: $screenModel.destination)
        .bottomSheet(item: $screenModel.planningDay, height: { _ in PlanDayMetrics.sheetHeight }) { day in
            PlanDayScreen(
                day: day,
                onDone: screenModel.didFinishPlanning,
                onTapNewWorkout: screenModel.didTapNewWorkoutWhilePlanning,
            )
        }
    }
}
