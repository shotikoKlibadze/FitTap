import DesignSystem
import FactoryKit
import Foundation
import SwiftUI

@MainActor
@Observable
final class HomeScreenModel {
    var destination: HomeScreenDestination?
    /// The day the plan sheet is open for; non-nil shows it.
    var planningDay: Date?
    /// The week the strip is showing — its Monday. Drives the week list.
    var currentWeek: Date?
    /// The day whose card shows under the strip; today to begin with. Only a
    /// tap changes it — paging to another week leaves it where it was.
    var selectedDay: Date?
    /// Bumped when "Today" is tapped with today already selected: the strip
    /// flashes its ring to say "you're here".
    private(set) var todayFlash = 0

    @ObservationIgnored
    @Injected(\.workoutSessionStore) private var sessionStore

    private let profile = ProfileData.profile
    private let thisWeekStart: Date
    /// Twelve weeks back, this week, three weeks ahead — about three months
    /// to look back on and enough room to plan, oldest first.
    private let weekStarts: [Date]
    private static let weeksBack = 12
    private static let weeksAhead = 3

    init() {
        let thisWeekStart = WeekCalendar.startOfWeek(containing: .now)
        self.thisWeekStart = thisWeekStart
        weekStarts = (-Self.weeksBack...Self.weeksAhead).map { WeekCalendar.calendar.date(byAdding: .day, value: $0 * 7, to: thisWeekStart)! }
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
        let offset = calendar.dateComponents([.weekOfYear], from: thisWeekStart, to: currentWeek).weekOfYear
        switch offset {
        case -1: return "Last Week"
        case 0: return "This Week"
        case 1: return "Next Week"
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
        return session(on: selectedDay).map { cardItem($0) }
    }

    /// What the add card offers on a day with nothing on it: a past day can
    /// only be logged, today and later can be planned. The section header
    /// above it names the day.
    var dayAddTitle: String? {
        guard let selectedDay, dayItem == nil else { return nil }
        return selectedDay < today ? "Log workout" : "Plan workout"
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
            .map { cardItem($0) }
    }

    // MARK: - Intents

    /// "Today" beside the week title: back to this week with today selected.
    /// Already there, the ring just flashes.
    func didTapToday() {
        if currentWeek == thisWeekStart, selectedDay == today {
            todayFlash += 1
            return
        }
        currentWeek = thisWeekStart
        selectedDay = today
    }

    /// The empty day's add card: a past day opens logging, today and later
    /// open the plan sheet.
    func didTapPlanWorkout() {
        guard let selectedDay else { return }
        if selectedDay < today {
            destination = .logWorkout(selectedDay)
        } else {
            planningDay = selectedDay
        }
    }

    /// A workout tapped in the plan sheet: the sheet closes and the workout
    /// opens, offering "Plan for …" that day.
    func didOpenWorkoutWhilePlanning(id: UUID) {
        guard let day = planningDay else { return }
        planningDay = nil
        destination = .workout(id, .planning(day))
    }

    func didTapNewWorkoutWhilePlanning() {
        planningDay = nil
        destination = .newWorkout
    }

    /// Opens the session's workout. Planned and missed ones can still move to
    /// another day; a done one can't.
    func didTapSession(id: UUID) {
        guard let session = sessionStore.sessions.first(where: { $0.id == id }) else { return }
        let source: WorkoutScreenSource = switch session.status {
        case .planned, .missed: .plannedSession(session.id)
        case .done: .finishedSession(session.id)
        }
        destination = .workout(session.workout.id, source)
    }

    // MARK: - Helpers

    /// The card for a session, its length taken from the user's own history.
    private func cardItem(_ session: WorkoutSession) -> SessionCardItem {
        SessionCardItem(session: session, typicalMinutes: sessionStore.sessions.typicalMinutes(ofWorkout: session.workout.id))
    }

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
