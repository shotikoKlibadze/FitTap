import DesignSystem
import SwiftUI

/// Content of the plan-a-day sheet: a title naming the day, then "New
/// workout" and every workout as a pickable row, scrolling inside the sheet.
struct PlanDayView: View {
    let title: String
    let items: [PlanDayItem]
    let pickedID: UUID?
    let onPick: (UUID) -> Void
    let onTapNewWorkout: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(FTFonts.title3Semibold)
                    .foregroundStyle(FTColors.textPrimary)
                    .lineLimit(1)
                Text("Pick one of your workouts.")
                    .font(FTFonts.subheadline)
                    .foregroundStyle(FTColors.textSecondary)
            }
            .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 10) {
                    CardAddButton(title: "New workout", layout: .inline, action: onTapNewWorkout)
                    ForEach(items) { item in
                        WorkoutListItem(
                            title: item.title,
                            subtitle: item.subtitle,
                            icon: Image(systemName: item.iconName),
                            color: item.color,
                            isSelected: item.id == pickedID,
                        ) {
                            onPick(item.id)
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 12, for: .scrollContent)
            .contentMargins(.bottom, 24, for: .scrollContent)
            // A list cut off by the sheet: flash the indicator once so it
            // reads as more below.
            .scrollIndicators(.visible)
            .scrollIndicatorsFlash(onAppear: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#if DEBUG
private struct PlanDayViewPreviewHost: View {
    @State private var pickedID: UUID?
    @State private var newWorkoutTaps = 0

    var body: some View {
        PlanDayView(
            title: "Plan Workout for Today",
            items: PlanDayItem.samples,
            pickedID: pickedID,
            onPick: { pickedID = $0 },
            onTapNewWorkout: { newWorkoutTaps += 1 },
        )
        .padding(.top, 20)
        .frame(height: PlanDayMetrics.sheetHeight)
        .background(FTColors.surface)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    PlanDayViewPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    PlanDayViewPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
