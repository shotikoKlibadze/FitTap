import SwiftUI

/// One row of a progression list: a title on the left, a value ("20 kg
/// /side", "12 reps") on the right, then an accessory.
///
/// - `.trend`: a small arrow saying which way an exercise is going — green
///   up, grey flat, red down.
/// - `.sets`: the session's sets and reps ("4×8"), with a red ring when a
///   set failed — a row of one exercise's history.
///
/// With an action the row is tappable and ends in a chevron; without one it
/// only reads. It draws no background of its own; the list that stacks the
/// rows gives them a card and the lines between.
public struct ProgressionListItem: View {
    public enum Trend {
        case up
        case flat
        case down
    }

    public enum Accessory {
        case trend(Trend)
        /// "4×8"; `failed` adds the red ring.
        case sets(String, failed: Bool)
    }

    let title: String
    let value: String
    let accessory: Accessory
    let action: (() -> Void)?

    public init(title: String, value: String, accessory: Accessory, action: (() -> Void)? = nil) {
        self.title = title
        self.value = value
        self.accessory = accessory
        self.action = action
    }

    /// A tappable exercise row with its trend arrow.
    public init(title: String, value: String, trend: Trend, action: @escaping () -> Void) {
        self.init(title: title, value: value, accessory: .trend(trend), action: action)
    }

    public static let height: CGFloat = 52

    public var body: some View {
        if let action {
            Button(action: action) { row }
                .buttonStyle(.press)
        } else {
            row
        }
    }

    private var row: some View {
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
            accessoryView
            if action != nil {
                FTIcons.chevronRight
                    .font(FTFonts.caption2Semibold)
                    .foregroundStyle(FTColors.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: Self.height)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .trend(let trend):
            trendArrow(trend)
                .font(FTFonts.footnoteSemibold)
                .frame(width: 14)
        case .sets(let text, let failed):
            HStack(spacing: 8) {
                Text(text)
                    .font(FTFonts.subheadline)
                    .foregroundStyle(FTColors.textSecondary)
                    .monospacedDigit()
                // The ring keeps its place when absent, so set counts line up.
                Circle()
                    .strokeBorder(FTColors.redAccent, lineWidth: 1.5)
                    .frame(width: 10, height: 10)
                    .opacity(failed ? 1 : 0)
            }
        }
    }

    private func trendArrow(_ trend: Trend) -> some View {
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

    private let trendRows: [(String, String, ProgressionListItem.Trend)] = [
        ("Bench Press", "20 kg /side", .flat),
        ("Lat Pulldown", "60 kg", .up),
        ("Pull-Up", "12 reps", .up),
        ("Lateral Raise", "8 kg /hand", .down),
    ]

    private let historyRows: [(String, String, String, Bool)] = [
        ("Wed, Sep 2", "20 kg /side", "4×10", false),
        ("Thu, Aug 27", "20 kg /side", "4×8", true),
        ("Mon, Aug 24", "22.5 kg /side", "4×6", false),
    ]

    var body: some View {
        VStack(spacing: 16) {
            card {
                ForEach(Array(trendRows.enumerated()), id: \.offset) { index, row in
                    divider(index)
                    ProgressionListItem(title: row.0, value: row.1, trend: row.2) { lastTapped = row.0 }
                }
            }
            card {
                ForEach(Array(historyRows.enumerated()), id: \.offset) { index, row in
                    divider(index)
                    ProgressionListItem(title: row.0, value: row.1, accessory: .sets(row.2, failed: row.3))
                }
            }
            Text("Tapped: \(lastTapped)")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }

    private func card(@ViewBuilder _ rows: () -> some View) -> some View {
        VStack(spacing: 0, content: rows)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    @ViewBuilder
    private func divider(_ index: Int) -> some View {
        if index > 0 {
            Rectangle()
                .fill(FTColors.divider)
                .frame(height: 1)
        }
    }
}

#Preview("Dark") {
    ProgressionListItemPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    ProgressionListItemPreviewHost()
        .preferredColorScheme(.light)
}
#endif
