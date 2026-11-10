import DesignSystem
import SwiftUI

/// One exercise's progression: its personal best, then "Recent Sessions",
/// newest first, six at a time. The exercise's name is the toolbar title.
struct ExerciseProgressView: View {
    let personalBest: PersonalBestItem?
    let sessions: [ExerciseSessionItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if let personalBest {
                    PersonalBestCard(item: personalBest)
                }
                if !sessions.isEmpty {
                    SectionHeader(title: "Recent Sessions")
                        .frame(minHeight: 30)
                        .padding(.top, personalBest == nil ? 0 : 8)
                    RecentSessionsCard(items: sessions)
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
        ExerciseProgressView(personalBest: .sample, sessions: ExerciseSessionItem.samples)
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
