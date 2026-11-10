import FactoryKit
import Foundation

/// The plan-a-day sheet: every workout the user has, each opening the
/// workout so it can be planned for the day.
@MainActor
@Observable
final class PlanDayScreenModel {
    let day: Date

    @ObservationIgnored
    @Injected(\.workoutStore) private var workoutStore

    init(day: Date) {
        self.day = day
    }

    /// "Plan Workout for Today", or the day: "Plan Workout for Wed, 4 Nov".
    var title: String {
        let calendar = WeekCalendar.calendar
        if calendar.isDateInToday(day) { return "Plan Workout for Today" }
        return "Plan Workout for \(day.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))"
    }

    var items: [PlanDayItem] {
        workoutStore.templates.map { PlanDayItem(workout: $0) }
    }
}
