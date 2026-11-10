import DesignSystem
import NavigatorUI
import SwiftUI

struct ProgressionScreen: View {
    @State private var screenModel = ProgressionScreenModel()
    @Environment(\.navigator) private var navigator

    var body: some View {
        ProgressionView(
            items: screenModel.items,
            onTapExercise: { screenModel.didTapExercise(id: $0) },
        )
        .navigate(to: $screenModel.destination)
        // Read on first show and whenever a session is saved.
        .task(id: screenModel.dataRevision) {
            screenModel.reload()
        }
        .appToolbar(
            title: "Progression",
            leading: AppToolbarButton(.back, action: handleBack),
        )
    }

    private func handleBack() {
        if navigator.dismiss() { return }
        navigator.pop()
    }
}
