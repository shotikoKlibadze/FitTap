import DesignSystem
import SwiftUI

/// One exercise's progression: the coach's suggestion when there is one (a
/// tap opens its deeper analysis), its personal best, then "Recent
/// Sessions": one small card per session, newest first, six at a time. The
/// exercise's name is the toolbar title.
struct ExerciseProgressView: View {
    let suggestion: SuggestionText?
    let personalBest: PersonalBestItem?
    let sessions: [ExerciseSessionItem]
    let onTapSuggestion: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if let suggestion {
                    SuggestionCard(title: suggestion.title, message: suggestion.message, action: onTapSuggestion)
                }
                if let personalBest {
                    PersonalBestCard(item: personalBest)
                }
                if !sessions.isEmpty {
                    SectionHeader(title: "Recent Sessions")
                        .frame(minHeight: 30)
                        .padding(.top, personalBest == nil ? 0 : 8)
                    RecentSessionsList(items: sessions)
                }
            }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .contentMargins(.bottom, 32, for: .scrollContent)
        .scrollIndicators(.hidden)
        .background(FTColors.background)
    }
}

#if DEBUG
private struct ExerciseProgressViewPreviewHost: View {
    var body: some View {
        ExerciseProgressView(suggestion: .sample, personalBest: .sample, sessions: ExerciseSessionItem.samples, onTapSuggestion: {})
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
