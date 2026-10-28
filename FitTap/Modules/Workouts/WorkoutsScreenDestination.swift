import NavigatorUI
import SwiftUI

enum WorkoutsScreenDestination: NavigationDestination {
    case newWorkout
    case workout(UUID)

    var body: some View {
        switch self {
        case .newWorkout: WorkoutScreen()
        case .workout(let id): WorkoutScreen(workoutID: id)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .newWorkout: .push
        case .workout: .push
        }
    }
}
