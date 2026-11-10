import DesignSystem
import SwiftUI

/// Every logged exercise, one card each: its name, its latest best set and
/// which way it's going. The title is in the toolbar.
struct ProgressionView: View {
    let items: [StatsProgressionItem]
    let onTapExercise: (UUID) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(items) { item in
                    ProgressionExerciseCard(item: item) {
                        onTapExercise(item.id)
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .contentMargins(.bottom, 32, for: .scrollContent)
        .scrollIndicators(.hidden)
        .background(FTColors.background)
    }
}

#if DEBUG
private struct ProgressionViewPreviewHost: View {
    @State private var lastTapped: UUID?

    var body: some View {
        ProgressionView(items: StatsProgressionItem.samples) { lastTapped = $0 }
    }
}

#Preview("Dark") {
    ProgressionViewPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    ProgressionViewPreviewHost()
        .preferredColorScheme(.light)
}
#endif
