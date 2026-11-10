import DesignSystem
import SwiftUI

/// Content of the plan-a-day sheet: a title naming the day, then "New
/// workout" and every workout as a row that opens it, scrolling inside the
/// sheet.
///
/// The title floats over the list: rows scroll up under it and stay faintly
/// visible through the fade behind it, instead of being cut off at a hard
/// edge below the subtitle.
struct PlanDayView: View {
    let title: String
    let subtitle: String
    let items: [PlanDayItem]
    let onOpenWorkout: (UUID) -> Void
    let onTapNewWorkout: () -> Void

    /// How far the fade reaches past the subtitle, so a row dissolves as it
    /// passes under the title rather than at its edge.
    private let fadeOverhang: CGFloat = 14

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                AddButton(title: "New workout", layout: .inline, action: onTapNewWorkout)
                ForEach(items) { item in
                    WorkoutListItem(
                        title: item.title,
                        subtitle: item.subtitle,
                        icon: Image(systemName: item.iconName),
                        color: item.color,
                    ) {
                        onOpenWorkout(item.id)
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .contentMargins(.bottom, 24, for: .scrollContent)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top, spacing: 14) {
            header
                .background {
                    // The sheet's own fade, not a solid fill: solid behind
                    // the title's top, thinning toward the subtitle and past
                    // it, so rows show faintly as they slide under.
                    FTGradients.sheetFadeTop
                        .padding(.bottom, -fadeOverhang)
                        .allowsHitTesting(false)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(FTFonts.title3Semibold)
                .foregroundStyle(FTColors.textPrimary)
                .lineLimit(1)
            Text(subtitle)
                .font(FTFonts.subheadline)
                .foregroundStyle(FTColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#if DEBUG
private struct PlanDayViewPreviewHost: View {
    @State private var openedID: UUID?
    @State private var newWorkoutTaps = 0

    var body: some View {
        PlanDayView(
            title: "Plan Workout for Today",
            subtitle: "Open a workout to plan it.",
            items: PlanDayItem.samples,
            onOpenWorkout: { openedID = $0 },
            onTapNewWorkout: { newWorkoutTaps += 1 },
        )
        .padding(.top, 20)
        .frame(height: PlanDayMetrics.sheetHeight)
        .background(FTColors.sheetSurface)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    PlanDayViewPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    PlanDayViewPreviewHost()
        .preferredColorScheme(.light)
}
#endif
