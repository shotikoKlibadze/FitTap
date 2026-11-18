import DesignSystem
import NavigatorUI
import SwiftUI

struct ExerciseProgressScreen: View {
    @State private var screenModel: ExerciseProgressScreenModel
    @Environment(\.navigator) private var navigator
    @Environment(\.openURL) private var openURL
    @State private var isShowingModelAlert = false

    init(exerciseID: UUID) {
        _screenModel = State(initialValue: ExerciseProgressScreenModel(exerciseID: exerciseID))
    }

    var body: some View {
        ExerciseProgressView(
            suggestion: screenModel.suggestion,
            isWritingSuggestion: screenModel.isWritingSuggestion,
            modelHint: screenModel.modelHint,
            personalBest: screenModel.personalBest,
            chartBars: screenModel.chartBars,
            sessions: screenModel.sessions,
            onTapSuggestion: screenModel.didTapSuggestion,
            onTapModelHint: { isShowingModelAlert = true },
        )
        .navigate(to: $screenModel.destination)
        // Read on first show and whenever a session is saved.
        .task(id: screenModel.dataRevision) {
            await screenModel.reload()
        }
        .appToolbar(
            title: screenModel.title,
            leading: AppToolbarButton(.back, action: handleBack),
        )
        .appAlert(
            isPresented: $isShowingModelAlert,
            title: screenModel.modelHint?.alertTitle ?? "",
            message: screenModel.modelHint?.alertMessage ?? "",
            actions: modelAlertActions,
        )
    }

    /// "Settings" over "Cancel" when Settings can help; a single "OK" when
    /// it can't, such as on an iPhone without Apple Intelligence.
    private var modelAlertActions: [AppAlertAction] {
        guard screenModel.modelHint?.offersSettings == true else {
            return [AppAlertAction("OK")]
        }
        return [
            AppAlertAction("Settings", style: .primary, action: openSettings),
            AppAlertAction("Cancel"),
        ]
    }

    /// Opens the Settings app at its first page, from where the user goes
    /// to Siri.
    ///
    /// > Important: `App-prefs:` is not a documented link. Apple only
    /// > documents opening an app's own Settings page, and has rejected
    /// > apps in review for links like this one. It can also stop working
    /// > in a new iOS version, which is why FitTap's own Settings page is
    /// > the fallback when iOS refuses it. `App-prefs:SIRI` was tried
    /// > first and landed on the Apps list, not on Siri.
    private func openSettings() {
        guard let settings = URL(string: "App-prefs:") else { return }
        openURL(settings) { accepted in
            guard !accepted, let appSettings = URL(string: UIApplication.openSettingsURLString) else { return }
            openURL(appSettings)
        }
    }

    private func handleBack() {
        if navigator.dismiss() { return }
        navigator.pop()
    }
}
