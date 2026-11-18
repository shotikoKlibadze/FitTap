import FactoryKit
import Foundation

@MainActor
@Observable
final class RootViewModel {
    var selectedTab: AppTab = .home
    /// First launch: onboarding shows instead of the tabs until it's
    /// finished or skipped. Remembered, so it shows once.
    private(set) var showsOnboarding = RootViewModel.alwaysShowsOnboarding
        || !UserDefaults.standard.bool(forKey: RootViewModel.onboardingDoneKey)

    private static let onboardingDoneKey = "onboardingDone"

    /// TEMPORARY while onboarding is being built: every debug run opens on
    /// it, finished or not. Set to false (or remove) when it's done.
    #if DEBUG
    private static let alwaysShowsOnboarding = true
    #else
    private static let alwaysShowsOnboarding = false
    #endif

    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: Self.onboardingDoneKey)
        showsOnboarding = false
    }
}
