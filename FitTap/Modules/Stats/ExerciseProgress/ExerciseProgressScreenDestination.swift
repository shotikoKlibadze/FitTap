import NavigatorUI
import SwiftUI

enum ExerciseProgressScreenDestination: NavigationDestination {
    /// The coach's deeper look at this exercise, opened from the suggestion.
    case coachAnalysis(exerciseID: UUID)

    var body: some View {
        switch self {
        case .coachAnalysis(let exerciseID): CoachAnalysisScreen(exerciseID: exerciseID)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .coachAnalysis: .push
        }
    }
}
