import SwiftUI

/// One day of the week strip: the day number on top, the workout title turned
/// on its side in the middle, the workout's color dot at the bottom. `status`
/// decides the dot and whether the cell is raised. No cell draws a border;
/// the only outline in the strip is the green selection ring, which the strip
/// slides in `shape` over whichever cell is selected — the cell doesn't know.
///
/// A day with a workout (done, planned or missed) is a raised card with a
/// shadow. An empty day is the same fill lying flat, so the days that matter
/// stand up out of the week.
public struct WeekStripDayCell: View {
    public enum Status: Hashable {
        /// Today or a future day with nothing planned — just the number, flat.
        case free
        /// A past day with nothing logged — flat, no dot.
        case passed
        /// A workout planned for a later day — raised, ring dot.
        case planned
        /// A logged workout — raised, filled dot.
        case done
        /// Planned but never logged — raised, red dashed ring dot.
        case missed

        /// A workout sits on this day, so the cell is raised.
        var hasWorkout: Bool {
            switch self {
            case .planned, .done, .missed: true
            case .free, .passed: false
            }
        }
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
            .background { surface }
            .contentShape(shape)
        }
        .buttonStyle(.press)
    }

    @ViewBuilder
    private var surface: some View {
        if status.hasWorkout {
            Color.clear.elevatedSurface(in: shape, elevation: .compact)
        } else {
            shape.fill(FTColors.surface)
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
