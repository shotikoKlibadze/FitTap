import NavigatorUI
import SwiftUI

enum ProgressionScreenDestination: NavigationDestination {
    /// One exercise's progression: personal best and recent sessions.
    case exerciseProgress(UUID)

    var body: some View {
        switch self {
        case .exerciseProgress(let id): ExerciseProgressScreen(exerciseID: id)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .exerciseProgress: .push
        }
    }
}
