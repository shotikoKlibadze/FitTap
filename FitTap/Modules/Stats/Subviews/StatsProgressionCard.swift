import DesignSystem
import SwiftUI

/// The progression card on the Stats tab: the exercises stacked as
/// `ProgressionListItem` rows with a hairline between each, inside one
/// rounded card. Tapping a row reports its id.
struct StatsProgressionCard: View {
    let items: [StatsProgressionItem]
    let onTap: (UUID) -> Void

    private let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Rectangle()
                        .fill(FTColors.divider)
                        .frame(height: 1)
                }
                ProgressionListItem(title: item.title, value: item.value, trend: item.trend) {
                    onTap(item.id)
                }
            }
        }
        // Clip the rows' press highlight to the corners; the surface and its
        // shadow sit under the clip, untouched.
        .clipShape(shape)
        .elevatedSurface(in: shape)
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

#Preview("Light") {
    StatsProgressionCardPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    StatsProgressionCardPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
