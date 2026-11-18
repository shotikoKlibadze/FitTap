import DesignSystem
import SwiftUI

/// The second onboarding page: a sample week strip, "Plan your week." and
/// how planning, logging and stats fit together.
struct OnboardingPlanWeekStep: View {
    var body: some View {
        VStack(spacing: 0) {
            OnboardingWeekStrip()
            Text("Plan your week.")
                .font(FTFonts.title2Bold)
                .foregroundStyle(FTColors.textPrimary)
                .padding(.top, 36)
            Text("Put a workout on a day and swipe between weeks. Plan what's coming, or log workouts you've already done. Two or three weeks of workouts make your stats work best.")
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
private struct OnboardingPlanWeekStepPreviewHost: View {
    var body: some View {
        OnboardingPlanWeekStep()
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Dark") {
    OnboardingPlanWeekStepPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    OnboardingPlanWeekStepPreviewHost()
        .preferredColorScheme(.light)
}
#endif
