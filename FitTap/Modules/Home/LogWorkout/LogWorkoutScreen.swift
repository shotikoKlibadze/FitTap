import DesignSystem
import NavigatorUI
import SwiftUI

struct LogWorkoutScreen: View {
    @State private var screenModel: LogWorkoutScreenModel
    @Environment(\.navigator) private var navigator

    init(day: Date) {
        _screenModel = State(initialValue: LogWorkoutScreenModel(day: day))
    }

    var body: some View {
        LogWorkoutView()
            .appToolbar(
                title: screenModel.title,
                leading: AppToolbarButton(.back, action: handleBack),
            )
    }

    private func handleBack() {
        if navigator.dismiss() { return }
        navigator.pop()
    }
}
