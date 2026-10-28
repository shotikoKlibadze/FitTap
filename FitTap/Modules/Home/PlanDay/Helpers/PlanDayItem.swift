import DesignSystem
import SwiftUI

/// A `WorkoutTemplate` reduced to what `WorkoutListItem` draws.
struct PlanDayItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color

    init(workout: WorkoutTemplate) {
        id = workout.id
        title = workout.name
        subtitle = workout.summaryText
        iconName = workout.type.iconName
        color = workout.color.color
    }
}

#if DEBUG
extension PlanDayItem {
    static let samples: [PlanDayItem] = WorkoutData.templates.map { PlanDayItem(workout: $0) }
}
#endif
