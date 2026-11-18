import DesignSystem
import SwiftUI

/// The last onboarding page: a few Bench Press sessions laid out as on its
/// progress page, revealed oldest first, then the note they earn drops in
/// above them — over "See what moves." Plays on a loop; nothing takes
/// touches.
struct OnboardingProgressStep: View {
    /// How many sessions show, counted from the oldest.
    @State private var shownCount = 0
    @State private var showsSuggestion = false

    /// Newest first, as on an exercise's progress page.
    private static let sessions: [ExerciseSessionItem] = [
        ExerciseSessionItem(id: UUID(), title: "Wed, Nov 18", value: "20 kg /side", sets: "4×8", failed: false, effort: .easy),
        ExerciseSessionItem(id: UUID(), title: "Wed, Nov 11", value: "20 kg /side", sets: "4×8", failed: true, effort: nil),
        ExerciseSessionItem(id: UUID(), title: "Fri, Oct 30", value: "20 kg /side", sets: "4×8", failed: false, effort: .medium),
        ExerciseSessionItem(id: UUID(), title: "Wed, Oct 21", value: "17.5 kg /side", sets: "4×8", failed: false, effort: .easy),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // The full picture, unseen, holds the page's size while the
            // pieces come and go.
            ZStack(alignment: .top) {
                demo(shownCount: Self.sessions.count, showsSuggestion: true)
                    .hidden()
                demo(shownCount: shownCount, showsSuggestion: showsSuggestion)
            }
            .allowsHitTesting(false)
            Text("See what moves.")
                .font(FTFonts.title2Bold)
                .foregroundStyle(FTColors.textPrimary)
                .padding(.top, 36)
            Text("Your lifts over time, and a short note when something has stalled or slipped. Nothing you don't need.")
                .font(FTFonts.subheadline)
                .foregroundStyle(FTColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
        .task { await play() }
    }

    private func demo(shownCount: Int, showsSuggestion: Bool) -> some View {
        VStack(spacing: 8) {
            SuggestionCard(
                title: "Bench Press has sat at 20 kg for 3 weeks",
                message: "Last time felt easy. Try 22.5 kg on the first set.",
            )
            .padding(.bottom, 4)
            .opacity(showsSuggestion ? 1 : 0)
            .scaleEffect(showsSuggestion ? 1 : 0.92, anchor: .bottom)
            ForEach(Array(Self.sessions.enumerated()), id: \.element.id) { index, session in
                // The oldest sits last; it shows first.
                let isShown = index >= Self.sessions.count - shownCount
                SessionCard(item: session)
                    .opacity(isShown ? 1 : 0)
                    .offset(y: isShown ? 0 : 12)
            }
        }
    }

    /// The demo, over and over until the page goes away.
    private func play() async {
        do {
            while true {
                try await Task.sleep(for: .seconds(0.6))
                for count in 1...Self.sessions.count {
                    withAnimation(.smooth(duration: 0.35)) { shownCount = count }
                    try await Task.sleep(for: .seconds(0.45))
                }
                try await Task.sleep(for: .seconds(0.4))
                withAnimation(.bouncy(duration: 0.45, extraBounce: 0.05)) { showsSuggestion = true }
                try await Task.sleep(for: .seconds(4))
                withAnimation(.smooth(duration: 0.4)) {
                    showsSuggestion = false
                    shownCount = 0
                }
            }
        } catch {
            // Cancelled: the page left.
        }
    }
}

#if DEBUG
private struct OnboardingProgressStepPreviewHost: View {
    var body: some View {
        OnboardingProgressStep()
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Dark") {
    OnboardingProgressStepPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    OnboardingProgressStepPreviewHost()
        .preferredColorScheme(.light)
}
#endif
