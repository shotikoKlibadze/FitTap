import DesignSystem
import SwiftUI

/// The month card on the Stats tab: the month's name with its workout count,
/// the weekday letters, then a grid of day numbers each with a dot under it —
/// the workout's color when it was done, a red dashed ring when it was
/// missed, a faint placeholder otherwise. Today's number is green; days
/// still ahead are dimmed. The card draws one `StatsCalendarMonth` and
/// decides nothing itself.
struct StatsCalendarCard: View {
    let month: StatsCalendarMonth

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let dotSize: CGFloat = 14
    /// Every cell, blank or not, stands this tall — so the month's six rows
    /// always take the same room and every month's card is the same size.
    private let cellHeight: CGFloat = 40

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            weekdays
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(month.cells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        StatsCalendarDayCell(day: day, dotSize: dotSize)
                            .frame(height: cellHeight)
                    } else {
                        Color.clear
                            .frame(height: cellHeight)
                    }
                }
            }
        }
        .padding(16)
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(month.title)
                .font(FTFonts.bodyBold)
                .foregroundStyle(FTColors.textPrimary)
            Spacer(minLength: 8)
            Text(month.summary)
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
                .monospacedDigit()
        }
    }

    private var weekdays: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Array(month.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(FTFonts.caption2)
                    .foregroundStyle(FTColors.textSecondary)
            }
        }
    }
}

/// A day number over its dot.
private struct StatsCalendarDayCell: View {
    let day: StatsCalendarDay
    let dotSize: CGFloat

    var body: some View {
        VStack(spacing: 5) {
            Text("\(day.number)")
                .font(day.isToday ? FTFonts.captionBold : FTFonts.caption)
                .foregroundStyle(numberColor)
                .monospacedDigit()
            dot
                .frame(width: dotSize, height: dotSize)
        }
    }

    private var numberColor: Color {
        if day.isToday { return FTColors.greenAccent }
        return day.isFuture ? FTColors.textSecondary : FTColors.textPrimary
    }

    @ViewBuilder
    private var dot: some View {
        switch day.mark {
        case .done(let color):
            Circle().fill(color)
        case .planned(let color):
            Circle().strokeBorder(color, lineWidth: 1.5)
        case .missed:
            Circle().strokeBorder(FTColors.red, style: StrokeStyle(lineWidth: 1.5, dash: [2, 1.5]))
        case .none:
            Circle().fill(FTColors.secondary)
        }
    }
}

#if DEBUG
private struct StatsCalendarCardPreviewHost: View {
    var body: some View {
        StatsCalendarCard(month: .sample)
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Dark") {
    StatsCalendarCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    StatsCalendarCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
