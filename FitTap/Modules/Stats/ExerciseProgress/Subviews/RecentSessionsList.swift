import DesignSystem
import SwiftUI

/// An exercise's sessions, newest first, one `SessionCard` each. Six show
/// at first; "Show more" under the list adds the next six, and once more
/// than six show, "Show less" appears beside it and takes six away.
struct RecentSessionsList: View {
    let items: [ExerciseSessionItem]

    /// How many sessions show; the buttons move it by `step`.
    @State private var shownCount = 6

    private let step = 6

    var body: some View {
        VStack(spacing: 8) {
            ForEach(items.prefix(shownCount)) { item in
                SessionCard(item: item)
                    .transition(.opacity)
            }
            if items.count > step {
                HStack(spacing: 8) {
                    if shownCount > step {
                        PillButton(title: "Show less", style: .secondary, size: .compact, action: showLess)
                            .transition(.opacity)
                    }
                    if shownCount < items.count {
                        PillButton(title: "Show more", style: .secondary, size: .compact, action: showMore)
                            .transition(.opacity)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private func showLess() {
        withAnimation(.smooth(duration: 0.35)) { shownCount = max(step, shownCount - step) }
    }

    private func showMore() {
        withAnimation(.smooth(duration: 0.35)) { shownCount = min(items.count, shownCount + step) }
    }
}

#if DEBUG
private struct RecentSessionsListPreviewHost: View {
    var body: some View {
        ScrollView {
            RecentSessionsList(items: ExerciseSessionItem.samples)
                .padding(16)
        }
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    RecentSessionsListPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    RecentSessionsListPreviewHost()
        .preferredColorScheme(.light)
}
#endif
