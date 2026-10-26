import NavigatorUI
import SwiftUI

enum NewWorkoutScreenDestination: NavigationDestination {
    /// Opens on the given filter chip.
    case addExercise(AddExerciseFilter)

    var body: some View {
        switch self {
        case .addExercise(let filter): AddExerciseScreen(filter: filter)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .addExercise: .push
        }
    }
}
