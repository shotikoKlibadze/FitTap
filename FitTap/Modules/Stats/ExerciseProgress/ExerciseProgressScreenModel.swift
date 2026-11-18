import DesignSystem
import FactoryKit
import Foundation

/// One exercise's progression, opened from the Stats tab: the coach's
/// suggestion when it has one, the personal best, and every session the
/// exercise was logged in, newest first.
@MainActor
@Observable
final class ExerciseProgressScreenModel {
    let exerciseID: UUID

    /// What the coach suggests for the next session, as far as it has been
    /// written: the card's text grows while the language model writes it.
    /// Nil when the coach has nothing to say, and until the first word.
    private(set) var suggestion: SuggestionText?
    /// True from the moment the rules pick a suggestion until the language
    /// model's first words arrive: the card shows its loading state.
    private(set) var isWritingSuggestion = false
    /// Set when the card had to use standard wording because the language
    /// model isn't available: the small note above the card and the alert
    /// behind its "More info". Nil when the model wrote the card, and when
    /// there is no card.
    private(set) var modelHint: ModelHintItem?
    private(set) var personalBest: PersonalBestItem?
    /// The newest sessions as chart bars, oldest first.
    private(set) var chartBars: [SessionBar] = []
    private(set) var sessions: [ExerciseSessionItem] = []
    var destination: ExerciseProgressScreenDestination?

    @ObservationIgnored @Injected(\.statsStore) private var statsStore
    @ObservationIgnored @Injected(\.exerciseStore) private var exerciseStore
    @ObservationIgnored @Injected(\.coachAI) private var coachAI

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

    /// Reads the exercise's history again, then has the suggestion card
    /// written.
    ///
    /// The history and the personal best are on screen at once. The card
    /// comes after: the rules pick the suggestion straight away, but its
    /// words arrive from the language model a piece at a time, so this
    /// only returns once the card is finished. Leaving the screen, or a
    /// newly saved session, cancels it midway.
    func reload() async {
        let logs = statsStore.history(ofExercise: exerciseID)
        sessions = logs.compactMap(sessionItem)
        let best = logs
            .compactMap { log in log.bestSet.map { (set: $0, date: log.date) } }
            .max { $0.set.rank < $1.set.rank }
        personalBest = best.map { bestItem($0.set, date: $0.date) }
        chartBars = bars(for: logs)

        guard let decided = CoachEngine().suggestion(for: logs) else {
            suggestion = nil
            modelHint = nil
            isWritingSuggestion = false
            return
        }
        modelHint = coachAI.unavailableReason.map(ModelHintItem.init)
        // Only wait on screen when the model will really write: the fixed
        // text is there at once and needs no loading state.
        isWritingSuggestion = modelHint == nil
        // Whatever happens next (first words, a refusal, the screen going
        // away), the card must not be left loading.
        defer { isWritingSuggestion = false }
        let weight = logs.first?.straightWeight.map { "\(LoadDisplayFormatter.trimmed($0)) kg" }
        for await text in coachAI.card(for: decided, weight: weight) {
            suggestion = text
            isWritingSuggestion = false
        }
    }

    /// The suggestion card opens the coach's deeper analysis.
    func didTapSuggestion() {
        destination = .coachAnalysis(exerciseID: exerciseID)
    }

    // MARK: - Mapping

    /// Turns the newest sessions into chart bars, oldest first.
    ///
    /// A bar's height is the session's top set, measured the way this
    /// exercise is: seconds for a hold, kilos for a lift. A bodyweight
    /// exercise is measured in added kilos if any session on the chart
    /// added weight, and in reps otherwise, so pull-ups done without
    /// weight aren't a row of zero-height bars.
    ///
    /// A session with a failed set is red; every other one is green. The
    /// personal best gets no bar of its own: it is written above the chart.
    private func bars(for logs: [ExerciseSessionLog]) -> [SessionBar] {
        let recent = logs.prefix(SessionBarChart.maximumBars).reversed()
        let usesWeight = recent.contains { ($0.topSet?.weight ?? 0) > 0 }
        return recent.compactMap { log in
            guard let top = log.topSet else { return nil }
            let value: Double = switch exercise?.kind {
            case .hold: top.duration ?? 0
            case .bodyweight: usesWeight ? top.weight ?? 0 : Double(top.reps)
            case .weightlifting, .cardio, nil: top.weight ?? 0
            }
            return SessionBar(
                id: log.sessionID,
                value: value,
                label: log.date.formatted(.dateTime.month(.abbreviated).day()),
                kind: log.hasFailedSet ? .failed : .clean,
            )
        }
    }

    private func sessionItem(_ log: ExerciseSessionLog) -> ExerciseSessionItem? {
        guard let top = log.topSet else { return nil }
        return ExerciseSessionItem(
            id: log.sessionID,
            title: log.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()),
            value: loadText(top),
            sets: exercise?.kind == .hold ? "\(log.sets.count) sets" : "\(log.sets.count)×\(top.reps)",
            failed: log.hasFailedSet,
            effort: log.effort,
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
