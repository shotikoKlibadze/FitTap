import NavigatorUI
import SwiftUI

enum WorkoutScreenDestination: NavigationDestination {
    /// Opens on the given filter chip.
    case addExercise(AddExerciseFilter)
    /// The workout being done — a mode of its own, over everything.
    /// `startedFresh`: created by tapping Start rather than planned before.
    case session(UUID, startedFresh: Bool)

    var body: some View {
        switch self {
        case .addExercise(let filter): AddExerciseScreen(filter: filter)
        case .session(let id, let startedFresh): WorkoutSessionScreen(sessionID: id, startedFresh: startedFresh)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .addExercise: .push
        case .session: .managedCover
        }
    }
}
