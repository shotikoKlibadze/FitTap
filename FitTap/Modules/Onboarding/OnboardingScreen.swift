import DesignSystem
import SwiftUI

/// The first-launch onboarding, shown by the root in place of the tabs. No
/// title or back button — only "Skip", which ends it from any page, as
/// finishing the last page does. The root decides what comes next.
struct OnboardingScreen: View {
    let onFinish: () -> Void

    @State private var screenModel = OnboardingScreenModel()

    var body: some View {
        OnboardingView(step: screenModel.step, onTapContinue: handleContinue)
            .appToolbar(
                title: nil,
                trailing: AppToolbarButton(title: "Skip", action: onFinish),
            )
    }

    private func handleContinue() {
        let isDone = withAnimation(.smooth(duration: 0.35)) {
            screenModel.didTapContinue()
        }
        if isDone { onFinish() }
    }
}
