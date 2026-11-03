import FactoryKit
import Foundation

@MainActor
@Observable
final class StatsScreenModel {
    @ObservationIgnored @Injected(\.workoutSessionStore) private var sessionStore

    /// The one suggestion the tab leads with. Stand-in until the coach
    /// writes them; nil hides the section.
    var suggestion: StatsSuggestionItem? {
        #if DEBUG
        StatsSuggestionItem.sample
        #else
        nil
        #endif
    }

    /// Every month with a session, oldest first, through this month at
    /// least — one page each. The sample data until persistence lands.
    var calendarMonths: [StatsCalendarMonth] {
        let calendar = WeekCalendar.calendar
        let sessions = sessionStore.sessions
        func monthStart(_ date: Date) -> Date {
            calendar.dateInterval(of: .month, for: date)?.start ?? date
        }
        let thisMonth = monthStart(.now)
        let dates = sessions.map(\.scheduledFor)
        let first = dates.min().map(monthStart) ?? thisMonth
        let last = max(dates.max().map(monthStart) ?? thisMonth, thisMonth)

        var months: [Date] = []
        var month = min(first, thisMonth)
        while month <= last {
            months.append(month)
            guard let next = calendar.date(byAdding: .month, value: 1, to: month) else { break }
            month = next
        }
        return months.map { StatsCalendarMonth(month: $0, sessions: sessions) }
    }

    /// Stand-in rows until progression is worked out from logged sets.
    var progressionItems: [StatsProgressionItem] {
        #if DEBUG
        StatsProgressionItem.samples
        #else
        []
        #endif
    }

    /// Stand-in minutes until cardio is summed from logged sessions.
    let cardioWeekMinutes = 34
    let cardioMonthMinutes = 85

    /// Stand-in tiles until sets are counted per muscle group.
    var balanceItems: [StatsBalanceItem] {
        #if DEBUG
        StatsBalanceItem.samples
        #else
        []
        #endif
    }

    // MARK: - Intents

    /// "See All" on suggestions — the suggestions screen isn't built yet.
    func didTapSuggestionsSeeAll() {}

    /// A suggestion card — its detail isn't built yet.
    func didTapSuggestion(id: UUID) {}

    /// "See All" on the calendar — the full calendar screen isn't built yet.
    func didTapCalendarSeeAll() {}

    /// "See All" on progression — the charts screen isn't built yet.
    func didTapProgressionSeeAll() {}

    /// A progression row — the exercise detail isn't built yet.
    func didTapProgression(id: UUID) {}

    /// A balance tile — the muscle group detail isn't built yet.
    func didTapBalance(id: String) {}
}
