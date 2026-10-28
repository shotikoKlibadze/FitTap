import Foundation

/// The app's week runs Monday to Sunday whatever the device locale says —
/// the Home strip, planning and stats all count weeks the same way.
enum WeekCalendar {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }()

    /// Midnight of the Monday on or before `date`.
    static func startOfWeek(containing date: Date) -> Date {
        let day = calendar.startOfDay(for: date)
        // weekday: 1 = Sunday … 7 = Saturday.
        let daysSinceMonday = (calendar.component(.weekday, from: day) + 5) % 7
        return calendar.date(byAdding: .day, value: -daysSinceMonday, to: day)!
    }

    /// Monday through Sunday of the week starting at `start`.
    static func days(ofWeekStarting start: Date) -> [Date] {
        (0..<7).map { calendar.date(byAdding: .day, value: $0, to: start)! }
    }
}
