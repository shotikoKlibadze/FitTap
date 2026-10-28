import Foundation

/// Counts and a time estimate for a workout — shared by every screen that
/// summarizes one, so "~45 min" means the same everywhere.
extension WorkoutTemplate {
    var setCount: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    /// Cardio: the planned durations added up. Strength: about three minutes
    /// a set, rounded to the nearest five, never under five.
    var estimatedMinutes: Int {
        switch type {
        case .cardio:
            let seconds = exercises.compactMap(\.cardio).reduce(0) { $0 + $1.duration }
            return Int((seconds / 60).rounded())
        case .strength:
            return max(5, ((setCount * 3 + 2) / 5) * 5)
        }
    }

    /// Planned distance across cardio exercises, if any has one.
    var plannedDistanceMeters: Double? {
        let meters = exercises.compactMap(\.cardio?.distanceMeters).reduce(0, +)
        return meters > 0 ? meters : nil
    }
}
