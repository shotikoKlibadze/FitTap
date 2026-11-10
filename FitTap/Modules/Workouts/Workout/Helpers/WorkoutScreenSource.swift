import Foundation

/// Where the Workout screen was opened from — it decides whether "Plan" is
/// offered and whether "Edit" asks first.
enum WorkoutScreenSource: Hashable {
    /// The Workouts tab: the workout on its own, ready to plan.
    case library
    /// A session on a day that hasn't been done — planned, or missed — by its
    /// id. The screen shows that session's workout; editing asks first, since
    /// the user may only want to move it to another day, and saving changes
    /// only that session.
    case plannedSession(UUID)
    /// A workout opened from Home's plan sheet to put on this day: one main
    /// button, "Plan for …"; the workout can still be edited first.
    case planning(Date)
    /// The same, for a past day: one main button, "Log for …", records the
    /// workout as done that day.
    case logging(Date)
    /// A session that was done, by its id. Nothing to plan or move; editing
    /// goes straight in.
    case finishedSession(UUID)
}
