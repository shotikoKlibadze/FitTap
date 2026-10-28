import DesignSystem
import SwiftUI

struct HomeView: View {
    let profileTitle: String
    let profileSubtitle: String
    let weeks: [WeekStripWeek]
    @Binding var currentWeek: Date?
    @Binding var selectedDay: Date?
    let weekTitle: String
    let dayTitle: String?
    let dayItem: SessionCardItem?
    let dayAddTitle: String?
    let weekListTitle: String
    let weekItems: [SessionCardItem]
    let onTapPlanWorkout: () -> Void
    let onTapSession: (UUID) -> Void

    /// Which way the last week change went, so the week list slides with
    /// the swipe: a later week comes in from the right, an earlier one from
    /// the left.
    @State private var weekForward = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ProfileHeader(image: nil, title: profileTitle, subtitle: profileSubtitle)
                    .padding(.bottom, 22)
                SectionHeader(title: weekTitle)
                    .contentTransition(.opacity)
                    .padding(.bottom, 12)
                WeekStrip(
                    weeks: weeks,
                    currentWeek: sliding($currentWeek, forward: $weekForward),
                    selectedDay: $selectedDay,
                )
                .padding(.bottom, 14)
                // A tap changes the day section in place: its header and card
                // crossfade. A swipe slides the week list as one block, so the
                // old and new weeks pass each other.
                if dayTitle != nil {
                    daySection
                        .transition(.opacity)
                }
                ZStack(alignment: .top) {
                    weekList
                        .id(currentWeek)
                        .transition(.slide(forward: weekForward))
                }
            }
            .animation(.smooth(duration: 0.3), value: selectedDay)
        }
        .contentMargins(.horizontal, 8, for: .scrollContent)
        .contentMargins(.bottom, 32, for: .scrollContent)
        .scrollIndicators(.hidden)
        .background(FTColors.background)
    }

    private var daySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: dayTitle ?? "")
                .contentTransition(.opacity)
                .padding(.bottom, 8)
            // Keyed by what the card shows, not by the day: moving between
            // two empty days keeps the same "Plan workout" card still, and
            // only a real change crossfades.
            ZStack(alignment: .top) {
                dayCard
                    .id(dayItem?.id)
                    .transition(.opacity)
            }
        }
        .padding(.bottom, 16)
    }

    /// Hands the strip a value, but holds each change back one update: the
    /// direction renders first, so the block that leaves already knows which
    /// side to leave by — a transition is read from the view's last render,
    /// not from the update that removes it.
    private func sliding(_ value: Binding<Date?>, forward: Binding<Bool>) -> Binding<Date?> {
        Binding {
            value.wrappedValue
        } set: { newValue in
            guard newValue != value.wrappedValue else { return }
            if let newValue, let oldValue = value.wrappedValue {
                forward.wrappedValue = newValue > oldValue
            }
            Task { @MainActor in
                withAnimation(.smooth(duration: 0.35)) {
                    value.wrappedValue = newValue
                }
            }
        }
    }

    private var weekList: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: weekListTitle)
                .padding(.bottom, 8)
            VStack(spacing: 9) {
                ForEach(weekItems) { item in
                    sessionCard(item)
                }
            }
        }
    }

    @ViewBuilder
    private var dayCard: some View {
        if let dayItem {
            sessionCard(dayItem)
        } else if let dayAddTitle {
            CardAddButton(title: dayAddTitle, action: onTapPlanWorkout)
        }
    }

    private func sessionCard(_ item: SessionCardItem) -> some View {
        WorkoutSessionCard(
            title: item.title,
            dotColor: item.dotColor,
            dateText: item.dateText,
            stats: item.stats,
            status: item.status,
        ) {
            onTapSession(item.id)
        }
    }
}

private extension AnyTransition {
    /// The new block slides in from the side it's heading from while the old
    /// one slides out the other way, both fading as they go.
    static func slide(forward: Bool) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
            removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity),
        )
    }
}

#if DEBUG
private struct HomeViewPreviewHost: View {
    @State private var currentWeek: Date? = WeekStripWeek.samples[1].id
    @State private var selectedDay: Date? = WeekStripWeek.samples[1].days[1].id

    var body: some View {
        HomeView(
            profileTitle: "Dan, 27",
            profileSubtitle: "78.4 kg · down 0.6 this month",
            weeks: WeekStripWeek.samples,
            currentWeek: $currentWeek,
            selectedDay: $selectedDay,
            weekTitle: "This Week",
            dayTitle: "Today",
            dayItem: nil,
            dayAddTitle: "Plan workout",
            weekListTitle: "Ongoing Week",
            weekItems: SessionCardItem.samples,
            onTapPlanWorkout: {},
            onTapSession: { _ in },
        )
    }
}
#Preview("Light") {
    HomeViewPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    HomeViewPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
