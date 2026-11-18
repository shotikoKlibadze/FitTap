import Foundation

/// The onboarding's pages, in order. Each new step is a case here, and the
/// page dots count them.
enum OnboardingStep: Int, CaseIterable, Sendable {
    /// "Tap your fitness." — what the app is, in one breath.
    case welcome
    /// "Plan your week." — the week strip: plan, log past days, swipe weeks.
    case planWeek
    /// "Check sets as you go." — the ✓ tap and the hold to fail, played out.
    case checkSets
    /// "Say how it felt." — the rating after the last set, and what it earns.
    case rate
    /// "See what moves." — progress over time and the notes it earns.
    case progress

    /// The bottom button's title on this page.
    var buttonTitle: String {
        switch self {
        case .welcome: "Get Started"
        case .planWeek, .checkSets, .rate: "Continue"
        case .progress: "Start Logging"
        }
    }

    /// The step after this one; nil on the last.
    var next: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }
}
