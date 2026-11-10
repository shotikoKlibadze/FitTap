import DesignSystem
import SwiftUI

/// An exercise's sessions, newest first, as `ProgressionListItem` rows in
/// one card: the day, the top set's weight, sets × reps and a red ring when
/// a set failed. Six show at first; "Show more" adds the next six, "Show
/// less" takes six away.
struct RecentSessionsCard: View {
    let items: [ExerciseSessionItem]

    /// How many rows show; "Show more" and "Show less" move it by `step`.
    @State private var shownCount = 6

    private let step = 6
    private let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(shownItems.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    divider
                }
                ProgressionListItem(
                    title: item.title,
                    value: item.value,
                    accessory: .sets(item.sets, failed: item.failed),
                )
                .transition(.opacity)
            }
            if items.count > step {
                divider
                ShowMoreFooter(
                    canShowLess: shownCount > step,
                    canShowMore: shownCount < items.count,
                    onShowLess: { withAnimation(.smooth(duration: 0.35)) { shownCount = max(step, shownCount - step) } },
                    onShowMore: { withAnimation(.smooth(duration: 0.35)) { shownCount = min(items.count, shownCount + step) } },
                )
            }
        }
        .clipShape(shape)
        .elevatedSurface(in: shape)
    }

    private var shownItems: [ExerciseSessionItem] {
        Array(items.prefix(shownCount))
    }

    private var divider: some View {
        Rectangle()
            .fill(FTColors.divider)
            .frame(height: 1)
    }
}

#if DEBUG
private struct RecentSessionsCardPreviewHost: View {
    var body: some View {
        ScrollView {
            RecentSessionsCard(items: ExerciseSessionItem.samples)
                .padding(16)
        }
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    RecentSessionsCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    RecentSessionsCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
