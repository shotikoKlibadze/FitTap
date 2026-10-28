import DesignSystem
import FactoryKit
import Foundation
import SwiftUI

@MainActor
@Observable
final class HomeScreenModel {
    var destination: HomeScreenDestination?
    /// The week the strip is showing — its Monday. Drives the week list.
    var currentWeek: Date?
    /// The day whose card shows under the strip; today to begin with. Only a
    /// tap changes it — paging to another week leaves it where it was.
    var selectedDay: Date?

    @ObservationIgnored
    @Injected(\.workoutSessionStore) private var sessionStore

    private let profile = ProfileData.profile
    private let thisWeekStart: Date
    /// Last week, this week, next week.
    private let weekStarts: [Date]

    init() {
        let thisWeekStart = WeekCalendar.startOfWeek(containing: .now)
        self.thisWeekStart = thisWeekStart
        weekStarts = (-1...1).map { WeekCalendar.calendar.date(byAdding: .day, value: $0 * 7, to: thisWeekStart)! }
        currentWeek = thisWeekStart
        selectedDay = WeekCalendar.calendar.startOfDay(for: .now)
    }

    private var calendar: Calendar { WeekCalendar.calendar }
    private var today: Date { calendar.startOfDay(for: .now) }

    // MARK: - Profile

    var profileTitle: String {
        profile.age.map { "\(profile.name), \($0)" } ?? profile.name
    }

    /// "78.4 kg · down 0.6 this month" — whichever parts the profile has.
    var profileSubtitle: String {
        var parts: [String] = []
        if let weight = profile.weightKg {
            parts.append("\(weight.formatted(.number.precision(.fractionLength(1)))) kg")
        }
        if let change = profile.weightChangeKgThisMonth, change != 0 {
            let amount = abs(change).formatted(.number.precision(.fractionLength(1)))
            parts.append("\(change < 0 ? "down" : "up") \(amount) this month")
        }
        return parts.joined(separator: " · ")
    }

    // MARK: - Week strip

    var weeks: [WeekStripWeek] {
        weekStarts.map { start in
            WeekStripWeek(start: start, days: WeekCalendar.days(ofWeekStarting: start).map { stripDay($0) })
        }
    }

    private func stripDay(_ date: Date) -> WeekStripDay {
        if let session = session(on: date) {
            return WeekStripDay(
                date: date,
                title: session.workout.name,
                dotColor: session.workout.color.color,
                status: cellStatus(for: session.status),
            )
        }
        return WeekStripDay(date: date, title: date == today ? "Today" : nil, status: date < today ? .passed : .free)
    }

    private func cellStatus(for status: WorkoutSessionStatus) -> WeekStripDayCell.Status {
        switch status {
        case .done: .done
        case .planned: .planned
        case .missed: .missed
        }
    }

    /// "Last Week" / "This Week" / "Next Week", or the dates for any other.
    var weekTitle: String {
        guard let currentWeek else { return "" }
        switch weekStarts.firstIndex(of: currentWeek) {
        case 0: return "Last Week"
        case 1: return "This Week"
        case 2: return "Next Week"
        default: return rangeText(forWeekStarting: currentWeek)
        }
    }

    // MARK: - Selected day

    var dayTitle: String? {
        guard let selectedDay else { return nil }
        return selectedDay == today ? "Today" : dateText(selectedDay)
    }

    var dayItem: SessionCardItem? {
        guard let selectedDay else { return nil }
        return session(on: selectedDay).map { SessionCardItem(session: $0) }
    }

    /// What the add card offers on a day with nothing on it. Always the
    /// same words — the section header above it names the day.
    var dayAddTitle: String? {
        guard selectedDay != nil, dayItem == nil else { return nil }
        return "Plan workout"
    }

    // MARK: - Week list

    var weekListTitle: String {
        guard let currentWeek else { return "" }
        return currentWeek == thisWeekStart ? "Ongoing Week" : rangeText(forWeekStarting: currentWeek)
    }

    var weekItems: [SessionCardItem] {
        guard let currentWeek else { return [] }
        let end = calendar.date(byAdding: .day, value: 7, to: currentWeek)!
        return sessionStore.sessions
            .filter { $0.scheduledFor >= currentWeek && $0.scheduledFor < end }
            .sorted { $0.scheduledFor < $1.scheduledFor }
            .map { SessionCardItem(session: $0) }
    }

    // MARK: - Intents

    func didTapPlanWorkout() {
        // The plan-workout sheet comes next: this is where it opens.
    }

    /// Opens the session's workout. Planned and missed ones can still move to
    /// another day; a done one can't.
    func didTapSession(id: UUID) {
        guard let session = sessionStore.sessions.first(where: { $0.id == id }) else { return }
        let source: WorkoutScreenSource = switch session.status {
        case .planned, .missed: .plannedSession(session.scheduledFor)
        case .done: .finishedSession
        }
        destination = .workout(session.workout.id, source)
    }

    // MARK: - Helpers

    private func session(on day: Date) -> WorkoutSession? {
        sessionStore.sessions(on: day).first
    }

    private func dateText(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    /// "Sep 14 – 20", or "Aug 31 – Sep 6" when the week crosses a month.
    private func rangeText(forWeekStarting start: Date) -> String {
        let end = calendar.date(byAdding: .day, value: 6, to: start)!
        let startText = start.formatted(.dateTime.month(.abbreviated).day())
        let endText = calendar.isDate(start, equalTo: end, toGranularity: .month)
            ? end.formatted(.dateTime.day())
            : end.formatted(.dateTime.month(.abbreviated).day())
        return "\(startText) – \(endText)"
    }
}
