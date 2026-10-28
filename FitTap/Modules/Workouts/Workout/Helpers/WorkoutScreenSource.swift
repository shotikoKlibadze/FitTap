import Foundation

/// Where the Workout screen was opened from — it decides whether "Plan" is
/// offered and whether "Edit" asks first.
enum WorkoutScreenSource: Hashable {
    /// The Workouts tab: the workout on its own, ready to plan.
    case library
    /// A session on a day that hasn't been done — planned, or missed. Editing
    /// asks first, since the user may only want to move it to another day.
    case plannedSession(Date)
    /// A session that was done. Nothing to plan or move; editing goes straight in.
    case finishedSession
}
