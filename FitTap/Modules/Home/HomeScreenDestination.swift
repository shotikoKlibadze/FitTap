import NavigatorUI
import SwiftUI

enum HomeScreenDestination: NavigationDestination {
    /// A session's workout, read-only; the source says whether it's still to
    /// come or done.
    case workout(UUID, WorkoutScreenSource)
    /// "New workout" from the plan sheet.
    case newWorkout

    var body: some View {
        switch self {
        case .workout(let id, let source): WorkoutScreen(workoutID: id, source: source)
        case .newWorkout: WorkoutScreen()
        }
    }

    var method: NavigationMethod {
        switch self {
        case .workout, .newWorkout: .push
        }
    }
}
