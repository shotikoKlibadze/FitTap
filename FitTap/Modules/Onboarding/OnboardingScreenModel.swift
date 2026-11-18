import Foundation

/// Walks the onboarding's pages in order.
@MainActor
@Observable
final class OnboardingScreenModel {
    private(set) var step = OnboardingStep.welcome

    /// Moves to the next page. Returns true when there's none — the
    /// onboarding is done.
    func didTapContinue() -> Bool {
        guard let next = step.next else { return true }
        step = next
        return false
    }
}
