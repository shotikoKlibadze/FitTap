import FactoryKit
import Foundation

/// One exercise's progression, opened from the Stats tab: its personal best
/// and every session it was logged in, newest first.
@MainActor
@Observable
final class ExerciseProgressScreenModel {
    let exerciseID: UUID

    private(set) var personalBest: PersonalBestItem?
    private(set) var sessions: [ExerciseSessionItem] = []

    @ObservationIgnored @Injected(\.statsStore) private var statsStore
    @ObservationIgnored @Injected(\.exerciseStore) private var exerciseStore

    init(exerciseID: UUID) {
        self.exerciseID = exerciseID
    }

    var title: String {
        exercise?.name ?? "Exercise"
    }

    /// Changes whenever a session is saved; the screen reloads on it.
    var dataRevision: Int { statsStore.revision }

    private var exercise: Exercise? {
        exerciseStore.exercise(id: exerciseID)
    }

    /// Reads the exercise's history again.
    func reload() {
        let logs = statsStore.history(ofExercise: exerciseID)
        sessions = logs.compactMap(sessionItem)
        let best = logs
            .compactMap { log in log.bestSet.map { (set: $0, date: log.date) } }
            .max { $0.set.rank < $1.set.rank }
        personalBest = best.map { bestItem($0.set, date: $0.date) }
    }

    // MARK: - Mapping

    private func sessionItem(_ log: ExerciseSessionLog) -> ExerciseSessionItem? {
        guard let top = log.topSet else { return nil }
        return ExerciseSessionItem(
            id: log.sessionID,
            title: log.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()),
            value: loadText(top),
            sets: exercise?.kind == .hold ? "\(log.sets.count) sets" : "\(log.sets.count)×\(top.reps)",
            failed: log.hasFailedSet,
        )
    }

    /// "20 kg /side", "BW", "BW + 5 kg", or a hold's "1 min".
    private func loadText(_ set: SetEntry) -> String {
        switch exercise?.kind {
        case .hold:
            return HoldTimeFormatter.text(set.duration ?? 0)
        case .bodyweight:
            return LoadDisplayFormatter.bodyweightDisplayString(added: set.weight, unit: .kg)
        case .weightlifting, .cardio, nil:
            return LoadDisplayFormatter.displayString(for: set.weight, loadMode: exercise?.loadMode ?? .total, unit: .kg)
        }
    }

    /// "22.5 kg × 6" per side, "BW + 5 kg × 6", "BW × 12", or "1:30 min".
    private func bestItem(_ set: SetEntry, date: Date) -> PersonalBestItem {
        let day = date.formatted(.dateTime.month(.abbreviated).day())
        switch exercise?.kind {
        case .hold:
            return PersonalBestItem(value: HoldTimeFormatter.text(set.duration ?? 0), unit: nil, date: day)
        case .bodyweight:
            let added = set.weight.flatMap { $0 > 0 ? $0 : nil }
            let load = added.map { "BW + \(LoadDisplayFormatter.trimmed($0)) kg" } ?? "BW"
            return PersonalBestItem(value: "\(load) × \(set.reps)", unit: nil, date: day)
        case .weightlifting, .cardio, nil:
            let weight = set.weight.map(LoadDisplayFormatter.trimmed) ?? "—"
            let unit: String? = switch exercise?.loadMode {
            case .perSide: "per side"
            case .perHand: "per hand"
            case .machineStack, .total, nil: nil
            }
            return PersonalBestItem(value: "\(weight) kg × \(set.reps)", unit: unit, date: day)
        }
    }
}
