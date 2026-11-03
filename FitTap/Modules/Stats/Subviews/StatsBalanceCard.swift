import DesignSystem
import SwiftUI

/// The balance card on the Stats tab: "Sets in the last 4 weeks" over a
/// four-column grid of `CountTileButton` tiles, one per muscle group. Tapping
/// a tile reports its id.
struct StatsBalanceCard: View {
    let items: [StatsBalanceItem]
    let onTap: (String) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sets in the last 4 weeks")
                .font(FTFonts.subheadline)
                .foregroundStyle(FTColors.textSecondary)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(items) { item in
                    CountTileButton(title: item.title, count: item.count, status: item.status) {
                        onTap(item.id)
                    }
                }
            }
        }
        .padding(16)
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#if DEBUG
private struct StatsBalanceCardPreviewHost: View {
    @State private var lastTapped = "—"

    var body: some View {
        VStack(spacing: 16) {
            StatsBalanceCard(items: StatsBalanceItem.samples) { lastTapped = $0 }
            Text("Tapped: \(lastTapped)")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    StatsBalanceCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    StatsBalanceCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
