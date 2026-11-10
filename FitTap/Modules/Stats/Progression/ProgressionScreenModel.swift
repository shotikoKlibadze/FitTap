import FactoryKit
import Foundation

/// Every exercise the user has logged, in sections by main muscle (Chest,
/// Back, …) and A to Z within each — the Progression section's "See All".
/// Each opens its own progression.
@MainActor
@Observable
final class ProgressionScreenModel {
    var destination: ProgressionScreenDestination?

    private(set) var sections: [ProgressionSection] = []

    /// The order sections appear in; exercises with no muscle (cardio) last,
    /// under "Other".
    private let sectionOrder: [MuscleGroup] = [.chest, .back, .shoulders, .legs, .biceps, .triceps, .abs, .fullBody]

    @ObservationIgnored @Injected(\.statsStore) private var statsStore
    @ObservationIgnored @Injected(\.exerciseStore) private var exerciseStore

    /// Changes whenever a session is saved; the screen reloads on it.
    var dataRevision: Int { statsStore.revision }

    func reload() {
        let rows = statsStore.progress(from: .distantPast, to: .distantFuture).map { progress in
            let exercise = exerciseStore.exercise(id: progress.exerciseID)
            return (muscle: exercise?.mainMuscleGroup, item: StatsProgressionItem(progress: progress, exercise: exercise))
        }
        let byMuscle = Dictionary(grouping: rows) { $0.muscle }
        let alphabetical: ([StatsProgressionItem]) -> [StatsProgressionItem] = { items in
            items.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        }
        var sections = sectionOrder.compactMap { muscle -> ProgressionSection? in
            guard let rows = byMuscle[muscle], !rows.isEmpty else { return nil }
            return ProgressionSection(title: muscle.displayName, items: alphabetical(rows.map(\.item)))
        }
        if let other = byMuscle[nil], !other.isEmpty {
            sections.append(ProgressionSection(title: "Other", items: alphabetical(other.map(\.item))))
        }
        self.sections = sections
    }

    func didTapExercise(id: UUID) {
        destination = .exerciseProgress(id)
    }
}
