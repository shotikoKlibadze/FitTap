import FactoryKit
import Foundation

/// The plan-a-day sheet: every workout the user has, one tap to put it on the
/// day. The pick is saved right away, so Home updates behind the sheet.
@MainActor
@Observable
final class PlanDayScreenModel {
    let day: Date
    /// The workout just planned; set once — the sheet closes shortly after.
    private(set) var pickedID: UUID?

    @ObservationIgnored
    @Injected(\.workoutStore) private var workoutStore
    @ObservationIgnored
    @Injected(\.workoutSessionStore) private var sessionStore

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

    /// Plans the workout on the day. Only the first pick counts.
    func pick(_ id: UUID) {
        guard pickedID == nil, let workout = workoutStore.template(id: id) else { return }
        pickedID = id
        sessionStore.add(WorkoutSession(workout: workout, scheduledFor: day))
    }
}
