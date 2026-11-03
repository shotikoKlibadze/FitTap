import SwiftUI

struct StatsScreen: View {
    @State private var screenModel = StatsScreenModel()

    var body: some View {
        StatsView(
            suggestion: screenModel.suggestion,
            calendarMonths: screenModel.calendarMonths,
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
    }
}
