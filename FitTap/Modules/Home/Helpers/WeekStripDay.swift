import DesignSystem
import SwiftUI

/// What the week strip knows about one day: its date, the workout title and
/// color if any, and the status that picks the cell's border and dot.
struct WeekStripDay: Identifiable, Hashable {
    let date: Date
    let title: String?
    let dotColor: Color?
    let status: WeekStripDayCell.Status

    init(date: Date, title: String? = nil, dotColor: Color? = nil, status: WeekStripDayCell.Status) {
        self.date = date
        self.title = title
        self.dotColor = dotColor
        self.status = status
    }

    var id: Date { date }

    var number: Int { Calendar.current.component(.day, from: date) }
}
