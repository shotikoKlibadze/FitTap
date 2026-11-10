import NavigatorUI
import SwiftUI

enum StatsScreenDestination: NavigationDestination {
    /// One exercise's progression: personal best and recent sessions.
    case exerciseProgress(UUID)
    /// Every logged exercise — the Progression section's "See All".
    case progression

    var body: some View {
        switch self {
        case .exerciseProgress(let id): ExerciseProgressScreen(exerciseID: id)
        case .progression: ProgressionScreen()
        }
    }

    var method: NavigationMethod {
        switch self {
        case .exerciseProgress, .progression: .push
        }
    }
}
