import DesignSystem
import SwiftUI

struct WorkoutsView: View {
    let workouts: [WorkoutCardItem]
    let onTapNewWorkout: () -> Void
    let onTapWorkout: (UUID) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Workouts")
                    .font(FTFonts.largeTitle)
                    .foregroundStyle(FTColors.textPrimary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    CardAddButton(title: "New workout", action: onTapNewWorkout)
                        .aspectRatio(1, contentMode: .fit)
                    ForEach(workouts) { workout in
                        WorkoutCard(
                            title: workout.title,
                            summary: workout.summary,
                            icon: Image(systemName: workout.iconName),
                            color: workout.color,
                            muscleLabels: workout.muscleLabels,
                        ) {
                            onTapWorkout(workout.id)
                        }
                    }
                }
            }
        }
        .contentMargins(.horizontal, 8, for: .scrollContent)
        .contentMargins(.bottom, 32, for: .scrollContent)
        .scrollIndicators(.hidden)
        .background(FTColors.background)
    }
}

#if DEBUG
private struct WorkoutsViewPreviewHost: View {
    var body: some View {
        NavigationStack {
            WorkoutsView(workouts: WorkoutCardItem.samples, onTapNewWorkout: {}, onTapWorkout: { _ in })
        }
    }
}
#Preview("Light") {
    WorkoutsViewPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutsViewPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
