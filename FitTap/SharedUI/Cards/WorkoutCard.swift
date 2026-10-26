import DesignSystem
import SwiftUI

/// A rounded workout template card: icon and muscle groups on top, title and
/// summary at the bottom, the whole surface tinted by the workout's color.
/// Purely visual — wrap it in a `Button` at the call site to make it tappable.
struct WorkoutCard: View {
    let workout: WorkoutTemplate

    var body: some View {
        Button {

        } label: {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(workout.color.color.opacity(0.16))
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topLeading) {
                    header.padding(15)
                }
                .overlay(alignment: .bottomLeading) {
                    footer.padding(15)
                }
        }
        .buttonStyle(.press)

    }

    private var header: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .font(FTFonts.caption2Semibold)
                .foregroundStyle(workout.color.color)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let primary = workout.primaryMuscleGroup {
                    muscleLabel(primary)
                }
                if let secondary = workout.secondaryMuscleGroup {
                    muscleLabel(secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.name)
                .font(FTFonts.title3Bold)
                .foregroundStyle(FTColors.textPrimary)
                .lineLimit(2)
            Text(summary)
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func muscleLabel(_ group: MuscleGroup) -> some View {
        Text(group.displayName.uppercased())
            .font(FTFonts.caption2Semibold)
            .foregroundStyle(FTColors.textSecondary)
    }

    private var icon: String {
        switch workout.type {
        case .strength: "dumbbell"
        case .cardio: "figure.run"
        }
    }

    private var summary: String {
        let exerciseCount = workout.exercises.count
        let setCount = workout.exercises.reduce(0) { $0 + $1.sets.count }
        if setCount > 0 {
            return "\(exerciseCount) exercises · \(setCount) sets"
        }
        return "\(exerciseCount) exercises"
    }
}

#if DEBUG
private struct WorkoutCardPreviewHost: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(WorkoutData.templates) { workout in
                    WorkoutCard(workout: workout)
                }
                WorkoutCard(workout: WorkoutTemplate(
                    name: "A very long workout name here",
                    color: .indigo,
                    type: .strength,
                    primaryMuscleGroup: .chest,
                    secondaryMuscleGroup: .shoulders,
                ))
            }
            .padding()
        }
        .background(FTColors.background)
    }
}
#Preview("Light") {
    WorkoutCardPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutCardPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
