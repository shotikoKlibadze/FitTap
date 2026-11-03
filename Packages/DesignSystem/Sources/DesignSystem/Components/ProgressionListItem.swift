import SwiftUI

/// One exercise in a progression list: its name on the left, its current
/// value ("20 kg /side", "12 reps") on the right, then a small arrow saying
/// which way it's going — green up, grey flat, red down — and a chevron,
/// since the row opens the exercise. It draws no background of its own; the
/// list that stacks the rows gives them a card and the lines between.
public struct ProgressionListItem: View {
    public enum Trend {
        case up
        case flat
        case down
    }

    let title: String
    let value: String
    let trend: Trend
    let action: () -> Void

    public init(title: String, value: String, trend: Trend, action: @escaping () -> Void) {
        self.title = title
        self.value = value
        self.trend = trend
        self.action = action
    }

    public static let height: CGFloat = 52

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(FTFonts.calloutSemibold)
                    .foregroundStyle(FTColors.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(value)
                    .font(FTFonts.subheadlineSemibold)
                    .foregroundStyle(FTColors.textPrimary)
                    .monospacedDigit()
                    .lineLimit(1)
                trendArrow
                    .font(FTFonts.footnoteSemibold)
                    .frame(width: 14)
                FTIcons.chevronRight
                    .font(FTFonts.caption2Semibold)
                    .foregroundStyle(FTColors.textSecondary)
            }
            .padding(.horizontal, 16)
            .frame(height: Self.height)
            .contentShape(Rectangle())
        }
        .buttonStyle(.press)
    }

    private var trendArrow: some View {
        Group {
            switch trend {
            case .up: FTIcons.arrowUp.foregroundStyle(FTColors.greenAccent)
            case .flat: FTIcons.arrowRight.foregroundStyle(FTColors.textSecondary)
            case .down: FTIcons.arrowDown.foregroundStyle(FTColors.redAccent)
            }
        }
    }
}

#if DEBUG
private struct ProgressionListItemPreviewHost: View {
    @State private var lastTapped = "—"

    private let rows: [(String, String, ProgressionListItem.Trend)] = [
        ("Bench Press", "20 kg /side", .flat),
        ("Lat Pulldown", "60 kg", .up),
        ("Pull-Up", "12 reps", .up),
        ("Lateral Raise", "8 kg /hand", .down),
    ]

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    if index > 0 {
                        Rectangle()
                            .fill(FTColors.divider)
                            .frame(height: 1)
                    }
                    ProgressionListItem(title: row.0, value: row.1, trend: row.2) { lastTapped = row.0 }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            Text("Tapped: \(lastTapped)")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    ProgressionListItemPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ProgressionListItemPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
