import DesignSystem
import NavigatorUI
import SwiftUI

struct ExerciseProgressScreen: View {
    @State private var screenModel: ExerciseProgressScreenModel
    @Environment(\.navigator) private var navigator

    init(exerciseID: UUID) {
        _screenModel = State(initialValue: ExerciseProgressScreenModel(exerciseID: exerciseID))
    }

    var body: some View {
        ExerciseProgressView(
            personalBest: screenModel.personalBest,
            sessions: screenModel.sessions,
        )
        // Read on first show and whenever a session is saved.
        .task(id: screenModel.dataRevision) {
            screenModel.reload()
        }
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
