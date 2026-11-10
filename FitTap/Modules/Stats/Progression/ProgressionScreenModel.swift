import FactoryKit
import Foundation

/// Every exercise the user has logged, A to Z — the Progression section's
/// "See All". Each opens its own progression.
@MainActor
@Observable
final class ProgressionScreenModel {
    var destination: ProgressionScreenDestination?

    private(set) var items: [StatsProgressionItem] = []

    @ObservationIgnored @Injected(\.statsStore) private var statsStore
    @ObservationIgnored @Injected(\.exerciseStore) private var exerciseStore

    /// Changes whenever a session is saved; the screen reloads on it.
    var dataRevision: Int { statsStore.revision }

    func reload() {
        items = statsStore.progress(from: .distantPast, to: .distantFuture).map { progress in
            StatsProgressionItem(progress: progress, exercise: exerciseStore.exercise(id: progress.exerciseID))
        }
        .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }

    func didTapExercise(id: UUID) {
        destination = .exerciseProgress(id)
    }
}
