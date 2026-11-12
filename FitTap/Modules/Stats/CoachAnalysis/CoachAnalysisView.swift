import DesignSystem
import SwiftUI

/// The coach's deeper analysis of an exercise. For now only a "coming soon"
/// note in the middle of the screen; the title is in the toolbar.
struct CoachAnalysisView: View {
    var body: some View {
        VStack(spacing: 8) {
            FTIcons.wandAndSparkles
                .font(FTFonts.title)
                .foregroundStyle(FTColors.aiGold)
                .padding(.bottom, 4)
            Text("Coming soon")
                .font(FTFonts.title3Semibold)
                .foregroundStyle(FTColors.textPrimary)
            Text("A deeper look at this exercise: what your sessions show and what to try next.")
                .font(FTFonts.subheadline)
                .foregroundStyle(FTColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(FTColors.background)
    }
}

#if DEBUG
private struct CoachAnalysisViewPreviewHost: View {
    var body: some View {
        CoachAnalysisView()
    }
}

#Preview("Dark") {
    CoachAnalysisViewPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    CoachAnalysisViewPreviewHost()
        .preferredColorScheme(.light)
}
#endif
