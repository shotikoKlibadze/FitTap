import DesignSystem
import SwiftUI

/// The onboarding: the current page centred, the page dots under it, and
/// the page's button pinned at the bottom. "Skip" lives in the Screen's
/// toolbar.
struct OnboardingView: View {
    let step: OnboardingStep
    let onTapContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            stepContent
                // Each page slides in from the right as the last one leaves.
                .id(step)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity),
                ))
            Spacer(minLength: 0)
            OnboardingPageDots(count: OnboardingStep.allCases.count, current: step.rawValue)
                .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bottomActionBar {
            GlassPillButton(title: step.buttonTitle, action: onTapContinue)
        }
        .background(FTColors.background)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome: OnboardingWelcomeStep()
        case .planWeek: OnboardingPlanWeekStep()
        case .checkSets: OnboardingCheckSetsStep()
        case .rate: OnboardingRateStep()
        case .progress: OnboardingProgressStep()
        }
    }
}

#if DEBUG
private struct OnboardingViewPreviewHost: View {
    @State private var step = OnboardingStep.welcome

    var body: some View {
        OnboardingView(step: step) {
            step = step.next ?? .welcome
        }
    }
}

#Preview("Dark") {
    OnboardingViewPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    OnboardingViewPreviewHost()
        .preferredColorScheme(.light)
}
#endif
