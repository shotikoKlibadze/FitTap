import DesignSystem
import SwiftUI

/// A `WorkoutTemplate` reduced to what `WorkoutCard` draws: name, summary,
/// type icon, color and muscle labels.
struct WorkoutCardItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let summary: String
    let iconName: String
    let color: Color
    let muscleLabels: [String]

    init(workout: WorkoutTemplate) {
        id = workout.id
        title = workout.name
        color = workout.color.color
        iconName = switch workout.type {
        case .strength: "dumbbell"
        case .cardio: "figure.run"
        }
        muscleLabels = [workout.primaryMuscleGroup, workout.secondaryMuscleGroup]
            .compactMap { $0?.displayName }
        summary = Self.summary(for: workout)
    }

    /// "6 exercises · 18 sets", or just the exercise count when nothing has
    /// sets yet.
    private static func summary(for workout: WorkoutTemplate) -> String {
        let exerciseCount = workout.exercises.count
        let setCount = workout.exercises.reduce(0) { $0 + $1.sets.count }
        if setCount > 0 {
            return "\(exerciseCount) exercises · \(setCount) sets"
        }
        return "\(exerciseCount) exercises"
    }
}

#if DEBUG
extension WorkoutCardItem {
    static let samples: [WorkoutCardItem] = WorkoutData.templates.map { WorkoutCardItem(workout: $0) }
}
#endif
