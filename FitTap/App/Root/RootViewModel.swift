import FactoryKit
import Foundation

@MainActor
@Observable
final class RootViewModel {
    var selectedTab: AppTab = .home
}
