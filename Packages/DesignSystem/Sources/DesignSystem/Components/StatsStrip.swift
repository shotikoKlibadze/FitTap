import SwiftUI

/// A raised bar of a few side-by-side numbers, each with a small label
/// underneath ("3 / exercises", "7 / sets", "~45 / minutes"), split by thin
/// dividers. Read-only.
public struct StatsStrip: View {
    public struct Stat: Hashable {
        let value: String
        let label: String

        public init(value: String, label: String) {
            self.value = value
            self.label = label
        }
    }

    let stats: [Stat]

    public init(stats: [Stat]) {
        self.stats = stats
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                if index > 0 {
                    Rectangle()
                        .fill(FTColors.divider)
                        .frame(width: 1)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(stat.value)
                        .font(FTFonts.title3Bold)
                        .foregroundStyle(FTColors.textPrimary)
                        .monospacedDigit()
                    Text(stat.label)
                        .font(FTFonts.footnote)
                        .foregroundStyle(FTColors.textSecondary)
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 14)
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#if DEBUG
private struct StatsStripPreviewHost: View {
    var body: some View {
        VStack(spacing: 16) {
            StatsStrip(stats: [
                StatsStrip.Stat(value: "3", label: "exercises"),
                StatsStrip.Stat(value: "7", label: "sets"),
                StatsStrip.Stat(value: "~45", label: "minutes"),
            ])
            StatsStrip(stats: [
                StatsStrip.Stat(value: "1", label: "exercise"),
                StatsStrip.Stat(value: "30", label: "minutes"),
                StatsStrip.Stat(value: "6", label: "km target"),
            ])
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    StatsStripPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    StatsStripPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
