import NavigatorUI
import SwiftUI

enum WorkoutsScreenDestination: NavigationDestination {
    case newWorkout

    var body: some View {
        switch self {
        case .newWorkout: NewWorkoutScreen()
        }
    }

    var method: NavigationMethod {
        switch self {
        case .newWorkout: .push
        }
    }
}
