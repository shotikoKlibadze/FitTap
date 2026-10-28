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
        summary = workout.summaryText
        iconName = workout.type.iconName
        color = workout.color.color
        muscleLabels = [workout.primaryMuscleGroup, workout.secondaryMuscleGroup]
            .compactMap { $0?.displayName }
    }
}

#if DEBUG
extension WorkoutCardItem {
    static let samples: [WorkoutCardItem] = WorkoutData.templates.map { WorkoutCardItem(workout: $0) }
}
#endif
