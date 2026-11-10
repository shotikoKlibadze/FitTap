import DesignSystem
import SwiftUI

/// The progression card on the Stats tab: the exercises stacked as
/// `ProgressionListItem` rows with a hairline between each, inside one
/// rounded card. Six show at first; "Show more" adds the next six, "Show
/// less" takes six away. Tapping a row reports its id.
struct StatsProgressionCard: View {
    let items: [StatsProgressionItem]
    let onTap: (UUID) -> Void

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
                ProgressionListItem(title: item.title, value: item.value, trend: item.trend) {
                    onTap(item.id)
                }
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
        // Clip the rows' press highlight to the corners; the surface and its
        // shadow sit under the clip, untouched.
        .clipShape(shape)
        .elevatedSurface(in: shape)
    }

    private var shownItems: [StatsProgressionItem] {
        Array(items.prefix(shownCount))
    }

    private var divider: some View {
        Rectangle()
            .fill(FTColors.divider)
            .frame(height: 1)
    }
}

#if DEBUG
private struct StatsProgressionCardPreviewHost: View {
    @State private var lastTapped: UUID?

    var body: some View {
        VStack(spacing: 16) {
            StatsProgressionCard(items: StatsProgressionItem.samples) { lastTapped = $0 }
            Text("Tapped: \(StatsProgressionItem.samples.first { $0.id == lastTapped }?.title ?? "—")")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    StatsProgressionCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    StatsProgressionCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
