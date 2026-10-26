import DesignSystem
import SwiftUI

struct WorkoutsView: View {
    let onTapNewWorkout: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Workouts")
                    .font(FTFonts.largeTitle)
                    .foregroundStyle(FTColors.textPrimary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    CardAddButton(title: "New workout", action: onTapNewWorkout)
                }
            }
        }
        .contentMargins(.horizontal, 8, for: .scrollContent)
        .scrollIndicators(.hidden)
        .background(FTColors.background)
    }
}

#if DEBUG
private struct WorkoutsViewPreviewHost: View {
    var body: some View {
        NavigationStack {
            WorkoutsView(onTapNewWorkout: {})
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
