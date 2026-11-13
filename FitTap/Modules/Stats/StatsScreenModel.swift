import DesignSystem
import FactoryKit
import Foundation

@MainActor
@Observable
final class StatsScreenModel {
    var destination: StatsScreenDestination?

    @ObservationIgnored @Injected(\.workoutSessionStore) private var sessionStore
    @ObservationIgnored @Injected(\.statsStore) private var statsStore
    @ObservationIgnored @Injected(\.exerciseStore) private var exerciseStore

    /// The one suggestion the tab leads with: the muscle group furthest
    /// behind, if any is. Nil hides the section.
    private(set) var suggestion: StatsSuggestionItem?
    private(set) var progressionItems: [StatsProgressionItem] = []
    private(set) var balanceItems: [StatsBalanceItem] = []
    private(set) var cardioWeekMinutes = 0
    private(set) var cardioMonthMinutes = 0

    /// Changes whenever a session is saved; the screen reloads on it.
    var dataRevision: Int { statsStore.revision }

    /// How far back balance counts sets.
    private let balanceDays = 28
    /// A group is behind below this share of the average group.
    private let behindShare = 0.5

    /// One page per month, oldest first: from the month before the oldest
    /// logged workout's (or this month's, with nothing logged) through next
    /// month. The tab opens on this month (`currentMonthID`).
    var calendarMonths: [StatsCalendarMonth] {
        let calendar = WeekCalendar.calendar
        let sessions = sessionStore.sessions
        func monthStart(_ date: Date) -> Date {
            calendar.dateInterval(of: .month, for: date)?.start ?? date
        }
        let thisMonth = monthStart(.now)
        let oldestLog = sessions.filter { $0.status == .done }.map(\.scheduledFor).min().map(monthStart) ?? thisMonth
        let first = calendar.date(byAdding: .month, value: -1, to: min(oldestLog, thisMonth)) ?? thisMonth
        let last = calendar.date(byAdding: .month, value: 1, to: thisMonth) ?? thisMonth

        var months: [Date] = []
        var month = first
        while month <= last {
            months.append(month)
            guard let next = calendar.date(byAdding: .month, value: 1, to: month) else { break }
            month = next
        }
        return months.map { StatsCalendarMonth(month: $0, sessions: sessions) }
    }

    /// This month's page id — where the calendar opens.
    var currentMonthID: Date {
        WeekCalendar.calendar.dateInterval(of: .month, for: .now)?.start ?? .now
    }

    /// Recounts everything from the logged sessions.
    func reload() {
        let calendar = WeekCalendar.calendar
        let now = Date.now
        let today = calendar.startOfDay(for: now)
        let end = Date.distantFuture

        let balanceStart = calendar.date(byAdding: .day, value: -balanceDays, to: today) ?? today
        let counts = statsStore.exercisesPerGroup(from: balanceStart, to: end)
        loadBalance(counts)

        // Every exercise ever logged, most recently trained first; the card
        // shows six and opens the rest.
        progressionItems = statsStore.progress(from: .distantPast, to: end)
            .map(progressionItem)

        let weekStart = WeekCalendar.startOfWeek(containing: now)
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? today
        cardioWeekMinutes = statsStore.cardioMinutes(from: weekStart, to: end)
        cardioMonthMinutes = statsStore.cardioMinutes(from: monthStart, to: end)
    }

    // MARK: - Intents

    /// "See All" on suggestions — the suggestions screen isn't built yet.
    func didTapSuggestionsSeeAll() {}

    /// A suggestion card — its detail isn't built yet.
    func didTapSuggestion(id: UUID) {}

    /// "See All" on the calendar — the full calendar screen isn't built yet.
    func didTapCalendarSeeAll() {}

    /// "See All" on progression opens every logged exercise.
    func didTapProgressionSeeAll() {
        destination = .progression
    }

    /// A progression row opens that exercise's progression.
    func didTapProgression(id: UUID) {
        destination = .exerciseProgress(id)
    }

    /// A balance tile — the muscle group detail isn't built yet.
    func didTapBalance(id: String) {}

    // MARK: - Mapping

    /// One tile per group. A group is behind when it's well under the
    /// average group; with nothing logged, nothing is behind.
    private func loadBalance(_ counts: [BalanceGroup: Int]) {
        let average = Double(counts.values.reduce(0, +)) / Double(BalanceGroup.allCases.count)
        func isBehind(_ count: Int) -> Bool {
            average > 0 && Double(count) < average * behindShare
        }
        balanceItems = BalanceGroup.allCases.map { group in
            let count = counts[group] ?? 0
            return StatsBalanceItem(title: group.displayName, count: count, status: isBehind(count) ? .behind : .onTrack)
        }

        let furthestBehind = BalanceGroup.allCases
            .filter { isBehind(counts[$0] ?? 0) }
            .min { (counts[$0] ?? 0) < (counts[$1] ?? 0) }
        suggestion = furthestBehind.map { group in
            let count = counts[group] ?? 0
            let exercises = count == 1 ? "exercise" : "exercises"
            let usual = Int(average.rounded())
            return StatsSuggestionItem(
                title: "\(group.displayName) \(group.isPlural ? "are" : "is") falling behind",
                message: "\(count) \(exercises) in the last 4 weeks, against about \(usual) for each muscle group.",
            )
        }
    }

    private func progressionItem(_ progress: ExerciseProgress) -> StatsProgressionItem {
        StatsProgressionItem(progress: progress, exercise: exerciseStore.exercise(id: progress.exerciseID))
    }
}
