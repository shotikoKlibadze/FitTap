import DesignSystem
import SwiftUI

/// The Stats tab: the title, then sections stacked in one scroll, each a
/// `SectionHeader` and a card. Suggestions, Calendar, Progression, Cardio and
/// Balance. The calendar's months sit in a horizontal scroll, oldest first.
struct StatsView: View {
    let suggestion: StatsSuggestionItem?
    /// Oldest first; the view opens on the last.
    let calendarMonths: [StatsCalendarMonth]
    let progressionItems: [StatsProgressionItem]
    let cardioWeekMinutes: Int
    let cardioMonthMinutes: Int
    let balanceItems: [StatsBalanceItem]
    let onTapSuggestionsSeeAll: () -> Void
    let onTapSuggestion: (UUID) -> Void
    let onTapCalendarSeeAll: () -> Void
    let onTapProgressionSeeAll: () -> Void
    let onTapProgression: (UUID) -> Void
    let onTapBalance: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Statistics")
                    .font(FTFonts.largeTitleBold)
                    .foregroundStyle(FTColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                if let suggestion {
                    sectionTitle("Suggestions", isFirst: true, seeAllAction: onTapSuggestionsSeeAll)
                    SuggestionCard(title: suggestion.title, message: suggestion.message) {
                        onTapSuggestion(suggestion.id)
                    }
                }
                sectionTitle("Calendar", isFirst: suggestion == nil, seeAllAction: onTapCalendarSeeAll)
                calendarPager
                sectionTitle("Progression", seeAllAction: onTapProgressionSeeAll)
                StatsProgressionCard(items: progressionItems, onTap: onTapProgression)
                sectionTitle("Cardio")
                CardioSummaryCard(weekMinutes: cardioWeekMinutes, monthMinutes: cardioMonthMinutes)
                sectionTitle("Balance")
                StatsBalanceCard(items: balanceItems, onTap: onTapBalance)
            }
        }
        .contentMargins(.horizontal, gutter, for: .scrollContent)
        .contentMargins(.bottom, 32, for: .scrollContent)
        .scrollIndicators(.hidden)
        .background(FTColors.background)
    }

    /// The months side by side in a horizontal scroll, one card wide each,
    /// snapping to a card. The scroll runs the full screen width, so cards
    /// slide to the edges; its content margins rest each card on the gutter,
    /// and a gap of one gutter keeps the neighbours just off screen.
    private var calendarPager: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: gutter) {
                ForEach(calendarMonths) { month in
                    StatsCalendarCard(month: month)
                        .containerRelativeFrame(.horizontal)
                        // As on the Home week strip: a month shrinks a little
                        // as it leaves and grows back as it settles, so the
                        // swipe reads as depth, not a slide.
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(1 - abs(phase.value) * 0.12)
                                .opacity(1 - abs(phase.value) * 0.3)
                        }
                }
            }
            .scrollTargetLayout()
            // Room above and below the cards so their shadow isn't cut by
            // the scroll view's clip.
            .padding(.vertical, shadowRoom)
        }
        .contentMargins(.horizontal, gutter, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        // Out of the screen gutter to the edges.
        .padding(.horizontal, -gutter)
        // The room above overlaps the title's spacing instead of adding to it.
        .padding(.top, -shadowRoom)
    }

    /// The screen gutter.
    private let gutter: CGFloat = 16

    /// Room for a card's shadow (radius 9, 3 pt down) inside a scroll clip.
    private let shadowRoom: CGFloat = 12

    /// Titles line up with the cards on the 16 pt gutter. Sections after the
    /// first get a little air above their title.
    private func sectionTitle(_ title: String, isFirst: Bool = false, seeAllAction: (() -> Void)? = nil) -> some View {
        SectionHeader(title: title, seeAllAction: seeAllAction)
            .frame(minHeight: 30)
            .padding(.top, isFirst ? 0 : 8)
    }
}

#if DEBUG
private struct StatsViewPreviewHost: View {
    var body: some View {
        StatsView(
            suggestion: .sample,
            calendarMonths: StatsCalendarMonth.samples,
            progressionItems: StatsProgressionItem.samples,
            cardioWeekMinutes: 34,
            cardioMonthMinutes: 85,
            balanceItems: StatsBalanceItem.samples,
            onTapSuggestionsSeeAll: {},
            onTapSuggestion: { _ in },
            onTapCalendarSeeAll: {},
            onTapProgressionSeeAll: {},
            onTapProgression: { _ in },
            onTapBalance: { _ in },
        )
    }
}
#Preview("Dark") {
    StatsViewPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    StatsViewPreviewHost()
        .preferredColorScheme(.light)
}
#endif
