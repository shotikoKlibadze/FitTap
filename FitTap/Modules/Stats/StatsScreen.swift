import NavigatorUI
import SwiftUI

struct StatsScreen: View {
    @State private var screenModel = StatsScreenModel()

    var body: some View {
        StatsView(
            suggestion: screenModel.suggestion,
            calendarMonths: screenModel.calendarMonths,
            currentMonthID: screenModel.currentMonthID,
            progressionItems: screenModel.progressionItems,
            cardioWeekMinutes: screenModel.cardioWeekMinutes,
            cardioMonthMinutes: screenModel.cardioMonthMinutes,
            balanceItems: screenModel.balanceItems,
            onTapSuggestionsSeeAll: screenModel.didTapSuggestionsSeeAll,
            onTapSuggestion: { screenModel.didTapSuggestion(id: $0) },
            onTapCalendarSeeAll: screenModel.didTapCalendarSeeAll,
            onTapProgressionSeeAll: screenModel.didTapProgressionSeeAll,
            onTapProgression: { screenModel.didTapProgression(id: $0) },
            onTapBalance: { screenModel.didTapBalance(id: $0) },
        )
        .navigate(to: $screenModel.destination)
        // Recount on first show and whenever a session is saved.
        .task(id: screenModel.dataRevision) {
            screenModel.reload()
        }
    }
}
