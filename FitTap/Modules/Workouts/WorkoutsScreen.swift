import NavigatorUI
import SwiftUI

struct WorkoutsScreen: View {
    @State private var screenModel = WorkoutsScreenModel()

    var body: some View {
        WorkoutsView(
            workouts: screenModel.workouts,
            onTapNewWorkout: screenModel.didTapNewWorkout,
            onTapWorkout: screenModel.didTapWorkout,
        )
        .navigate(to: $screenModel.destination)
    }
}
