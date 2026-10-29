import DesignSystem
import SwiftUI

/// Weeks as horizontally paged rows of seven day cells, with page dots below.
/// The owner holds which week is showing and which day is selected; tapping
/// the selected day again clears the selection. One green ring marks the
/// selected day and slides across the week to the next tapped cell.
struct WeekStrip: View {
    let weeks: [WeekStripWeek]
    @Binding var currentWeek: WeekStripWeek.ID?
    @Binding var selectedDay: WeekStripDay.ID?

    init(weeks: [WeekStripWeek], currentWeek: Binding<WeekStripWeek.ID?>, selectedDay: Binding<WeekStripDay.ID?>) {
        self.weeks = weeks
        _currentWeek = currentWeek
        _selectedDay = selectedDay
        _scrolledWeek = State(initialValue: currentWeek.wrappedValue)
    }

    /// The page the scroll view reports. Scroll updates land without an
    /// animation, so the strip republishes them to `currentWeek` inside one —
    /// the dots and everything the owner derives from the week then animate.
    @State private var scrolledWeek: WeekStripWeek.ID?

    @Namespace private var cells

    /// Room under the cells for their shadows before the row clips, which
    /// doubles as the gap to the dots.
    private let shadowRoom: CGFloat = 14

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(weeks) { week in
                        HStack(spacing: 6) {
                            ForEach(week.days) { day in
                                WeekStripDayCell(
                                    day: day.number,
                                    title: day.title,
                                    dotColor: day.dotColor,
                                    status: day.status,
                                ) {
                                    select(day.id)
                                }
                                // Every cell is a source; the ring reads whichever matches.
                                .matchedGeometryEffect(id: day.id, in: cells, isSource: true)
                            }
                        }
                        .overlay { selectionRing(in: week) }
                        .frame(height: WeekStripDayCell.height + shadowRoom, alignment: .top)
                        .containerRelativeFrame(.horizontal)
                        // A week shrinks a little as it leaves and grows back
                        // as it settles, so paging reads as depth, not a slide.
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(1 - abs(phase.value) * 0.12)
                                .opacity(1 - abs(phase.value) * 0.3)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrolledWeek)
            .scrollIndicators(.hidden)
            PageDots(count: weeks.count, current: currentIndex)
        }
        .onChange(of: scrolledWeek) { _, week in
            guard let week, week != currentWeek else { return }
            withAnimation(.smooth(duration: 0.3)) {
                currentWeek = week
            }
        }
        .onChange(of: currentWeek) { _, week in
            // The owner moved the week itself; follow it.
            if week != scrolledWeek {
                scrolledWeek = week
            }
        }
    }

    private var currentIndex: Int {
        weeks.firstIndex { $0.id == currentWeek } ?? 0
    }

    private func select(_ day: WeekStripDay.ID) {
        withAnimation(.smooth(duration: 0.35)) {
            selectedDay = selectedDay == day ? nil : day
        }
    }

    /// The one ring in this week's row, laid over the selected cell. It is
    /// never a source, so moving the selection only changes which cell's
    /// geometry it reads — and the ring glides there.
    @ViewBuilder
    private func selectionRing(in week: WeekStripWeek) -> some View {
        if let selectedDay, week.days.contains(where: { $0.id == selectedDay }) {
            WeekStripDayCell.shape
                .strokeBorder(FTColors.greenAccent, lineWidth: 2)
                .matchedGeometryEffect(id: selectedDay, in: cells, isSource: false)
                .allowsHitTesting(false)
                .transition(.opacity)
        }
    }
}

#if DEBUG
private struct WeekStripPreviewHost: View {
    @State private var currentWeek: WeekStripWeek.ID? = WeekStripWeek.samples[1].id
    @State private var selectedDay: WeekStripDay.ID? = WeekStripWeek.samples[1].days[1].id

    var body: some View {
        WeekStrip(weeks: WeekStripWeek.samples, currentWeek: $currentWeek, selectedDay: $selectedDay)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Light") {
    WeekStripPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WeekStripPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
