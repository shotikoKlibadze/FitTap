import DesignSystem
import SwiftUI

/// One page of the week strip — seven days, identified by the week's first day.
struct WeekStripWeek: Identifiable, Hashable {
    let start: Date
    let days: [WeekStripDay]

    var id: Date { start }
}

#if DEBUG
extension WeekStripWeek {
    /// Last week, this week and next week around Monday, Sep 7, 2026.
    static let samples: [WeekStripWeek] = {
        let calendar = Calendar.current
        let thisMonday = calendar.date(from: DateComponents(year: 2026, month: 9, day: 7))!

        func week(
            offset: Int,
            _ entries: [(String?, Color?, WeekStripDayCell.Status)],
        ) -> WeekStripWeek {
            let start = calendar.date(byAdding: .day, value: offset * 7, to: thisMonday)!
            let days = entries.enumerated().map { index, entry in
                WeekStripDay(
                    date: calendar.date(byAdding: .day, value: index, to: start)!,
                    title: entry.0,
                    dotColor: entry.1,
                    status: entry.2,
                )
            }
            return WeekStripWeek(start: start, days: days)
        }

        return [
            week(offset: -1, [
                ("Legs", .yellow, .done),
                (nil, nil, .passed),
                ("Chest", .pink, .done),
                ("Pull", .purple, .missed),
                ("MMA", .orange, .done),
                ("Run", .mint, .done),
                (nil, nil, .passed),
            ]),
            week(offset: 0, [
                ("Back", .blue, .done),
                ("Today", nil, .free),
                ("Push", .pink, .planned),
                (nil, nil, .free),
                ("Easy run", .mint, .planned),
                (nil, nil, .free),
                ("Legs", .yellow, .planned),
            ]),
            week(offset: 1, [
                ("Push", .pink, .planned),
                (nil, nil, .free),
                ("Pull", .purple, .planned),
                (nil, nil, .free),
                ("Legs", .yellow, .planned),
                ("Run", .mint, .planned),
                (nil, nil, .free),
            ]),
        ]
    }()
}
#endif
