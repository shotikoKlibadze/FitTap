import DesignSystem
import SwiftUI

/// One exercise's progression: the coach's suggestion when there is one (a
/// tap opens its deeper analysis; a small note sits above it when the
/// language model couldn't write it), a chart of its recent sessions with
/// its personal best under it, then "Recent
/// Sessions": one small card per session, newest first, six at a time. The
/// exercise's name is the toolbar title.
struct ExerciseProgressView: View {
    let suggestion: SuggestionText?
    /// True while the suggestion is decided but its words haven't started.
    let isWritingSuggestion: Bool
    /// The small note above the card when it uses standard wording.
    let modelHint: ModelHintItem?
    let personalBest: PersonalBestItem?
    /// The newest sessions as chart bars, oldest first.
    let chartBars: [SessionBar]
    let sessions: [ExerciseSessionItem]
    let onTapSuggestion: () -> Void
    let onTapModelHint: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if isWritingSuggestion || suggestion != nil {
                    if let modelHint, !isWritingSuggestion {
                        InfoNote(message: modelHint.note, action: onTapModelHint)
                    }
                    // One card for both states, so the loading bars turn
                    // into text in place instead of one card replacing
                    // another.
                    SuggestionCard(
                        title: suggestion?.title ?? "",
                        message: suggestion?.message ?? "",
                        isLoading: isWritingSuggestion,
                        action: onTapSuggestion,
                    )
                }
                if !chartBars.isEmpty {
                    ProgressChartCard(bars: chartBars, personalBest: personalBest)
                }
                if !sessions.isEmpty {
                    SectionHeader(title: "Recent Sessions")
                        .frame(minHeight: 30)
                        .padding(.top, chartBars.isEmpty ? 0 : 8)
                    RecentSessionsList(items: sessions)
                }
            }
            // The card grows while its text is being written; this lets
            // everything under it slide down instead of jumping.
            .animation(.smooth(duration: 0.25), value: suggestion)
            .animation(.smooth(duration: 0.25), value: isWritingSuggestion)
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .contentMargins(.bottom, 32, for: .scrollContent)
        .scrollIndicators(.hidden)
        .background(FTColors.background)
    }
}

#if DEBUG
private struct ExerciseProgressViewPreviewHost: View {
    /// Each tap on the card moves to the next state: the note above the
    /// card, the card loading, then the plain card.
    @State private var step = 0

    var body: some View {
        ExerciseProgressView(
            suggestion: .sample,
            isWritingSuggestion: step % 3 == 1,
            modelHint: step % 3 == 0 ? .sample : nil,
            personalBest: .sample,
            chartBars: SessionBar.samples,
            sessions: ExerciseSessionItem.samples,
            onTapSuggestion: { step += 1 },
            onTapModelHint: {},
        )
    }
}

#Preview("Dark") {
    ExerciseProgressViewPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    ExerciseProgressViewPreviewHost()
        .preferredColorScheme(.light)
}
#endif
