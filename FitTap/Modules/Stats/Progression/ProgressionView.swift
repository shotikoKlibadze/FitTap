import DesignSystem
import SwiftUI

/// Every logged exercise in sections by muscle group, one card each: its
/// name, its latest best set and which way it's going. The title is in the
/// toolbar.
struct ProgressionView: View {
    let sections: [ProgressionSection]
    let onTapExercise: (UUID) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                    // Titles sit on the gutter like the cards; sections after
                    // the first get a little air above.
                    SectionHeader(title: section.title)
                        .frame(minHeight: 30)
                        .padding(.top, index == 0 ? 0 : 14)
                    ForEach(section.items) { item in
                        ProgressionExerciseCard(item: item) {
                            onTapExercise(item.id)
                        }
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
        ProgressionView(sections: ProgressionSection.samples) { lastTapped = $0 }
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
