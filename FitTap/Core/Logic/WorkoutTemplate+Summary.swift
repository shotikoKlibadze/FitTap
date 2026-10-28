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

    /// One line for tiles and list rows. Strength: "6 exercises · 18 sets"
    /// (just the exercises while nothing has sets). Cardio: "30 min · 6 km".
    var summaryText: String {
        switch type {
        case .strength:
            let exerciseText = exercises.count == 1 ? "1 exercise" : "\(exercises.count) exercises"
            return setCount > 0 ? "\(exerciseText) · \(setCount) sets" : exerciseText
        case .cardio:
            var parts = ["\(estimatedMinutes) min"]
            if let meters = plannedDistanceMeters {
                parts.append("\((meters / 1000).formatted(.number.precision(.fractionLength(0...1)))) km")
            }
            return parts.joined(separator: " · ")
        }
    }
}
