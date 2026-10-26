import NavigatorUI
import SwiftUI

struct WorkoutsScreen: View {
    @State private var screenModel = WorkoutsScreenModel()

    var body: some View {
        WorkoutsView(
            onTapNewWorkout: screenModel.didTapNewWorkout,
        )
        .navigate(to: $screenModel.destination)
    }
}
