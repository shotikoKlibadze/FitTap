import FactoryKit
import Foundation

/// The plan-a-day sheet: every workout the user has, each opening the
/// workout so it can be planned for the day — or, on a past day, logged.
@MainActor
@Observable
final class PlanDayScreenModel {
    let day: Date

    @ObservationIgnored
    @Injected(\.workoutStore) private var workoutStore

    init(day: Date) {
        self.day = day
    }

    /// A past day is logged, not planned.
    private var isPast: Bool {
        day < WeekCalendar.calendar.startOfDay(for: .now)
    }

    /// "Plan Workout for Today", or the day: "Plan Workout for Wed, 4 Nov";
    /// a past day: "Log Workout for Mon, 2 Nov".
    var title: String {
        let calendar = WeekCalendar.calendar
        if calendar.isDateInToday(day) { return "Plan Workout for Today" }
        let verb = isPast ? "Log" : "Plan"
        return "\(verb) Workout for \(day.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))"
    }

    var subtitle: String {
        isPast ? "Open a workout to log it." : "Open a workout to plan it."
    }

    var items: [PlanDayItem] {
        workoutStore.templates.map { PlanDayItem(workout: $0) }
    }
}
