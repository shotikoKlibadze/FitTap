import SwiftUI

/// One day of the week strip: the day number on top, the workout title turned
/// on its side in the middle, the workout's color dot at the bottom. `status`
/// decides the border and the dot. The cell doesn't know it's selected — the
/// strip slides one ring in `shape` over whichever cell is.
public struct WeekStripDayCell: View {
    public enum Status: Hashable {
        /// Today or a future day with nothing planned — just the number.
        case free
        /// A past day with nothing logged — bordered, no dot.
        case passed
        /// A workout planned for a later day — dashed border, ring dot.
        case planned
        /// A logged workout — bordered, filled dot.
        case done
        /// Planned but never logged — bordered, red dashed ring.
        case missed
    }

    let day: Int
    let title: String?
    let dotColor: Color?
    let status: Status
    let action: () -> Void

    public init(
        day: Int,
        title: String?,
        dotColor: Color?,
        status: Status,
        action: @escaping () -> Void
    ) {
        self.day = day
        self.title = title
        self.dotColor = dotColor
        self.status = status
        self.action = action
    }

    public static let height: CGFloat = 150
    /// The cell's outline, so a selection ring drawn elsewhere can match it.
    public static let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    private let shape = Self.shape
    private let dotSize: CGFloat = 8

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text("\(day)")
                    .font(title == nil ? FTFonts.subheadline : FTFonts.subheadlineBold)
                    .foregroundStyle(title == nil ? FTColors.textSecondary : FTColors.textPrimary)
                    .monospacedDigit()
                VerticalTitle(title: title)
                    .frame(maxHeight: .infinity)
                dot
                    .frame(width: dotSize, height: dotSize)
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .frame(height: Self.height)
            .elevatedSurface(in: shape, elevation: .compact, dashed: status == .planned)
            .overlay { border }
            .contentShape(shape)
        }
        .buttonStyle(.press)
    }

    @ViewBuilder
    private var border: some View {
        switch status {
        case .done, .passed, .missed:
            shape.strokeBorder(FTColors.separator, lineWidth: 1)
        case .free, .planned:
            EmptyView()
        }
    }

    @ViewBuilder
    private var dot: some View {
        switch status {
        case .done:
            Circle().fill(dotColor ?? FTColors.textSecondary)
        case .planned:
            Circle().strokeBorder(dotColor ?? FTColors.separator, lineWidth: 1.5)
        case .missed:
            Circle().strokeBorder(FTColors.red, style: StrokeStyle(lineWidth: 1.5, dash: [2, 1.5]))
        case .free, .passed:
            Color.clear
        }
    }
}

/// The title read top to bottom. The text lays out as a horizontal block as
/// wide as the slot is tall, then turns a quarter clockwise into the slot —
/// so a second line sits beside the first and both stay centered.
private struct VerticalTitle: View {
    let title: String?

    var body: some View {
        GeometryReader { geometry in
            if let title {
                Text(title)
                    .font(FTFonts.caption2Bold)
                    .textCase(.uppercase)
                    .foregroundStyle(FTColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.height, height: geometry.size.width)
                    .rotationEffect(.degrees(90))
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

#if DEBUG
private struct WeekStripDayCellPreviewHost: View {
    @State private var tapped: Int?

    private let days: [(day: Int, title: String?, color: Color?, status: WeekStripDayCell.Status)] = [
        (7, "Back", .blue, .done),
        (8, "Today", nil, .free),
        (9, "Push", .pink, .planned),
        (10, nil, nil, .free),
        (11, "Easy run", .mint, .planned),
        (12, nil, nil, .passed),
        (13, "Pull day", .purple, .missed),
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 6) {
                ForEach(days, id: \.day) { entry in
                    WeekStripDayCell(
                        day: entry.day,
                        title: entry.title,
                        dotColor: entry.color,
                        status: entry.status,
                    ) {
                        tapped = entry.day
                    }
                }
            }
            Text(tapped.map { "Tapped \($0)" } ?? "Tap a day")
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    WeekStripDayCellPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WeekStripDayCellPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
