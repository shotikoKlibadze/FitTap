import DesignSystem
import SwiftUI

/// One month of the Stats calendar, worked out from the sessions: the title
/// ("October"), the count line ("14 workouts · 1 missed"), the weekday
/// letters, and one cell per day with the dot it should show. The card only
/// draws what's here; every rule about what a day means lives in this type.
///
/// Days before the 1st are `nil` cells, so the first row lines up with the
/// weekday the month starts on. Weeks run Monday to Sunday (`WeekCalendar`).
struct StatsCalendarMonth: Identifiable, Hashable {
    /// The month's first day, at midnight.
    let id: Date
    let title: String
    let summary: String
    /// Seven one-letter labels, starting on the calendar's first weekday.
    let weekdaySymbols: [String]
    /// Always six rows of seven: leading `nil`s pad the days before the
    /// 1st, trailing ones fill out the last rows — so every month's card
    /// stands the same height, whether it needs five rows or six.
    let cells: [StatsCalendarDay?]

    static let rowCount = 6

    init(
        month: Date,
        sessions: [WorkoutSession],
        today: Date = .now,
        calendar: Calendar = WeekCalendar.calendar,
    ) {
        let start = calendar.dateInterval(of: .month, for: month)?.start ?? month
        let today = calendar.startOfDay(for: today)
        let dayCount = calendar.range(of: .day, in: .month, for: start)?.count ?? 0
        let days = (0..<dayCount).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        let inMonth = sessions.filter { calendar.isDate($0.scheduledFor, equalTo: start, toGranularity: .month) }

        id = start
        title = start.formatted(.dateTime.month(.wide))
        summary = Self.summary(for: inMonth)
        weekdaySymbols = Self.weekdaySymbols(calendar)

        let leading = (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7
        let dayCells = days.map { date in
            StatsCalendarDay(
                date: date,
                number: calendar.component(.day, from: date),
                isToday: date == today,
                isFuture: date > today,
                mark: Self.mark(for: inMonth.first { calendar.isDate($0.scheduledFor, inSameDayAs: date) }),
            )
        }
        let filled = Array(repeating: nil, count: leading) + dayCells
        let trailing = max(Self.rowCount * 7 - filled.count, 0)
        cells = filled + Array(repeating: nil, count: trailing)
    }

    /// "14 workouts · 1 missed" — the done count, and the missed count only
    /// when there is one. Planned sessions don't count yet.
    private static func summary(for sessions: [WorkoutSession]) -> String {
        let done = sessions.filter { $0.status == .done }.count
        let missed = sessions.filter { $0.status == .missed }.count
        var text = "\(done) \(done == 1 ? "workout" : "workouts")"
        if missed > 0 {
            text += " · \(missed) missed"
        }
        return text
    }

    private static func weekdaySymbols(_ calendar: Calendar) -> [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }

    private static func mark(for session: WorkoutSession?) -> StatsCalendarDay.Mark {
        guard let session else { return .none }
        return switch session.status {
        case .done: .done(session.workout.color.color)
        case .planned: .planned(session.workout.color.color)
        case .missed: .missed
        }
    }
}

/// One day in the Stats calendar: its number, whether it's today or still
/// ahead, and the dot under it.
struct StatsCalendarDay: Identifiable, Hashable {
    enum Mark: Hashable {
        /// Nothing on this day — a faint placeholder dot.
        case none
        /// A logged workout — filled with the workout's color.
        case done(Color)
        /// A workout still ahead — a ring in the workout's color.
        case planned(Color)
        /// Planned but never logged — a red dashed ring.
        case missed
    }

    let date: Date
    let number: Int
    let isToday: Bool
    let isFuture: Bool
    let mark: Mark

    var id: Date { date }
}

#if DEBUG
extension StatsCalendarMonth {
    /// This month, from the sample sessions around today.
    static let sample = StatsCalendarMonth(month: .now, sessions: WorkoutSessionData.sessions)

    /// Last month and this month, for paging.
    static let samples: [StatsCalendarMonth] = [
        StatsCalendarMonth(
            month: WeekCalendar.calendar.date(byAdding: .month, value: -1, to: .now)!,
            sessions: WorkoutSessionData.sessions,
        ),
        sample,
    ]
}
#endif
