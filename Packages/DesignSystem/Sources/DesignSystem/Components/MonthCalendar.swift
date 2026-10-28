import SwiftUI

/// A month of days to pick one from: the month's name with arrows to page
/// through months, the weekday initials, and the days in a grid. Days before
/// `today` are dimmed and can't be picked; today is green; the picked day
/// sits in a green circle. Paging never goes back past today's month.
public struct MonthCalendar: View {
    @Binding var selection: Date?
    let today: Date
    let calendar: Calendar

    /// `calendar` decides the week's first day — pass the app's.
    public init(selection: Binding<Date?>, today: Date, calendar: Calendar) {
        _selection = selection
        self.today = calendar.startOfDay(for: today)
        self.calendar = calendar
        _month = State(initialValue: calendar.dateInterval(of: .month, for: selection.wrappedValue ?? today)?.start ?? today)
    }

    /// The first day of the month on show.
    @State private var month: Date

    private let cellHeight: CGFloat = 36
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    public var body: some View {
        VStack(spacing: 12) {
            header
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdaySymbols.indices, id: \.self) { index in
                    Text(weekdaySymbols[index])
                        .font(FTFonts.caption2Semibold)
                        .foregroundStyle(FTColors.textSecondary)
                        .frame(height: 20)
                }
                ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        MonthCalendarDay(
                            number: calendar.component(.day, from: day),
                            isToday: day == today,
                            isSelected: selection.map { calendar.isDate($0, inSameDayAs: day) } ?? false,
                            isPast: day < today,
                            height: cellHeight,
                        ) {
                            selection = day
                        }
                    } else {
                        Color.clear.frame(height: cellHeight)
                    }
                }
            }
        }
        .animation(.smooth(duration: 0.25), value: selection)
    }

    private var header: some View {
        HStack(spacing: 0) {
            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(FTFonts.headline)
                .foregroundStyle(FTColors.textPrimary)
                .contentTransition(.opacity)
            Spacer(minLength: 8)
            RoundButton(
                icon: .previous,
                style: .normal,
                size: .regular,
                iconColor: canGoBack ? FTColors.greenAccent : FTColors.separator,
                backgroundColor: .clear,
            ) { page(by: -1) }
            .disabled(!canGoBack)
            RoundButton(icon: .next, style: .normal, iconColor: FTColors.greenAccent, backgroundColor: .clear) {
                page(by: 1)
            }
        }
    }

    // MARK: - Days

    /// Weekday initials in the calendar's order — "M T W T F S S".
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }

    /// The month's days, led by blanks so the first lands under its weekday.
    private var cells: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: month)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7
        let days = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month) }
        return Array(repeating: nil, count: leading) + days
    }

    private var canGoBack: Bool {
        guard let todaysMonth = calendar.dateInterval(of: .month, for: today)?.start else { return false }
        return month > todaysMonth
    }

    private func page(by months: Int) {
        guard let next = calendar.date(byAdding: .month, value: months, to: month) else { return }
        withAnimation(.smooth(duration: 0.25)) { month = next }
    }
}

/// One day in the grid: its number, green when it's today, in a green circle
/// when picked, dimmed and untappable when it's already gone.
private struct MonthCalendarDay: View {
    let number: Int
    let isToday: Bool
    let isSelected: Bool
    let isPast: Bool
    let height: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("\(number)")
                .font(isToday || isSelected ? FTFonts.bodySemibold : FTFonts.body)
                .foregroundStyle(textColor)
                .monospacedDigit()
                .frame(width: height, height: height)
                .background {
                    if isSelected {
                        Circle()
                            .fill(FTColors.green)
                            .transition(.scale(scale: 0.6).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isPast)
    }

    private var textColor: Color {
        if isSelected { return FTCoreColors.offWhite }
        if isPast { return FTColors.separator }
        if isToday { return FTColors.greenAccent }
        return FTColors.textPrimary
    }
}

#if DEBUG
private struct MonthCalendarPreviewHost: View {
    @State private var selection: Date? = Calendar.current.date(byAdding: .day, value: 2, to: .now)

    private var mondayFirst: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }

    var body: some View {
        VStack(spacing: 20) {
            MonthCalendar(selection: $selection, today: .now, calendar: mondayFirst)
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(FTColors.surface))
            Text(selection.map { "Picked \($0.formatted(date: .abbreviated, time: .omitted))" } ?? "Nothing picked")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    MonthCalendarPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    MonthCalendarPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
