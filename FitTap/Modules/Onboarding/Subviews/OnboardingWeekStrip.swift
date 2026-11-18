import DesignSystem
import SwiftUI

/// A sample week drawn with Home's own day cells: two workouts done (filled
/// dots), today selected, two planned (rings). Tapping a day moves the ring,
/// as on Home.
struct OnboardingWeekStrip: View {
    private struct Day: Identifiable {
        let number: Int
        let title: String?
        let color: WorkoutColor?
        let status: WeekStripDayCell.Status

        var id: Int { number }
    }

    private let days: [Day] = [
        Day(number: 16, title: "Full body", color: .blue, status: .done),
        Day(number: 17, title: "Chest + Abs", color: .pink, status: .done),
        Day(number: 18, title: nil, color: nil, status: .free),
        Day(number: 19, title: "Run", color: .navy, status: .planned),
        Day(number: 20, title: "Back + Abs", color: .magenta, status: .planned),
        Day(number: 21, title: nil, color: nil, status: .free),
        Day(number: 22, title: nil, color: nil, status: .free),
    ]

    /// Today, to begin with.
    @State private var selectedDay = 18
    @Namespace private var cells

    var body: some View {
        HStack(spacing: 6) {
            ForEach(days) { day in
                WeekStripDayCell(
                    day: day.number,
                    title: day.title,
                    dotColor: day.color?.color,
                    status: day.status,
                ) {
                    withAnimation(.smooth(duration: 0.35)) { selectedDay = day.id }
                }
                .matchedGeometryEffect(id: day.id, in: cells, isSource: true)
            }
        }
        .overlay {
            WeekStripDayCell.shape
                .strokeBorder(FTColors.greenAccent, lineWidth: 2)
                .matchedGeometryEffect(id: selectedDay, in: cells, isSource: false)
                .allowsHitTesting(false)
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
    }
}

#if DEBUG
private struct OnboardingWeekStripPreviewHost: View {
    var body: some View {
        OnboardingWeekStrip()
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Dark") {
    OnboardingWeekStripPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    OnboardingWeekStripPreviewHost()
        .preferredColorScheme(.light)
}
#endif
