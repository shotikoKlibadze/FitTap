import DesignSystem
import SwiftUI

/// The first onboarding page: the dumbbell mark on its tile, the app's name,
/// "Tap your fitness." and one line on what that means.
struct OnboardingWelcomeStep: View {
    private let tileSize: CGFloat = 84
    private let tileShape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    var body: some View {
        VStack(spacing: 0) {
            FTIcons.dumbbell
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(FTColors.textPrimary)
                .frame(width: tileSize, height: tileSize)
                .background(tileShape.fill(FTColors.surface))
            Text("FITTAP")
                .font(FTFonts.captionSemibold)
                .tracking(2)
                .foregroundStyle(FTColors.textSecondary)
                .padding(.top, 14)
            Text("Tap your fitness.")
                .font(FTFonts.title2Bold)
                .foregroundStyle(FTColors.textPrimary)
                .padding(.top, 28)
            Text("Log a real workout in a few taps. No typing, no spreadsheets, just what you lifted and how it felt.")
                .font(FTFonts.subheadline)
                .foregroundStyle(FTColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
private struct OnboardingWelcomeStepPreviewHost: View {
    var body: some View {
        OnboardingWelcomeStep()
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Dark") {
    OnboardingWelcomeStepPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    OnboardingWelcomeStepPreviewHost()
        .preferredColorScheme(.light)
}
#endif
