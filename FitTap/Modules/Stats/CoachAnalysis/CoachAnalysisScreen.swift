import DesignSystem
import NavigatorUI
import SwiftUI

struct CoachAnalysisScreen: View {
    @State private var screenModel: CoachAnalysisScreenModel
    @Environment(\.navigator) private var navigator

    init(exerciseID: UUID) {
        _screenModel = State(initialValue: CoachAnalysisScreenModel(exerciseID: exerciseID))
    }

    var body: some View {
        CoachAnalysisView()
            .appToolbar(
                title: "Analysis",
                leading: AppToolbarButton(.back, action: handleBack),
            )
    }

    private func handleBack() {
        if navigator.dismiss() { return }
        navigator.pop()
    }
}
