import Foundation

/// Logging a workout on a past day. A placeholder for now: the screen only
/// names the day and says logging is coming.
@MainActor
@Observable
final class LogWorkoutScreenModel {
    let day: Date

    init(day: Date) {
        self.day = day
    }

    /// "Log Workout for Mon, 2 Nov".
    var title: String {
        "Log Workout for \(day.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))"
    }
}
