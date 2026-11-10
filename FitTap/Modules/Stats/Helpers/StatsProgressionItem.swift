import DesignSystem
import Foundation

/// One row of the Stats progression card, ready for `ProgressionListItem`:
/// the exercise, its latest best set as text, and the trend against the
/// session before (from `StatsStore.progress`). Used by the Stats card and
/// the full progression list.
struct StatsProgressionItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let value: String
    let trend: ProgressionListItem.Trend

    init(id: UUID = UUID(), title: String, value: String, trend: ProgressionListItem.Trend) {
        self.id = id
        self.title = title
        self.value = value
        self.trend = trend
    }
}

extension StatsProgressionItem {
    /// An exercise's progress as a row: its name, the latest best set, and
    /// which way it's going. Shared by the Stats card and the full
    /// progression list.
    init(progress: ExerciseProgress, exercise: Exercise?) {
        self.init(
            id: progress.exerciseID,
            title: exercise?.name ?? "Exercise",
            value: Self.valueText(progress.latest, exercise: exercise),
            trend: Self.trend(progress.trend),
        )
    }

    /// "20 kg /side", "BW + 10 kg", "1:30 min" for a hold, or "12 reps"
    /// when no weight was used.
    private static func valueText(_ set: LoggedSet, exercise: Exercise?) -> String {
        if exercise?.kind == .hold, let duration = set.duration {
            return HoldTimeFormatter.text(duration)
        }
        guard let weight = set.weight, weight > 0 else { return "\(set.reps) reps" }
        if exercise?.kind == .bodyweight {
            return LoadDisplayFormatter.bodyweightDisplayString(added: weight, unit: .kg)
        }
        return LoadDisplayFormatter.displayString(for: weight, loadMode: exercise?.loadMode ?? .total, unit: .kg)
    }

    private static func trend(_ trend: ProgressTrend) -> ProgressionListItem.Trend {
        switch trend {
        case .up: .up
        case .flat: .flat
        case .down: .down
        }
    }
}

#if DEBUG
extension StatsProgressionItem {
    static let samples: [StatsProgressionItem] = [
        StatsProgressionItem(title: "Bench Press", value: "20 kg /side", trend: .flat),
        StatsProgressionItem(title: "Lat Pulldown", value: "60 kg", trend: .up),
        StatsProgressionItem(title: "Cable Row", value: "55 kg", trend: .up),
        StatsProgressionItem(title: "Leg Press", value: "120 kg", trend: .flat),
        StatsProgressionItem(title: "Pull-Up", value: "12 reps", trend: .up),
        StatsProgressionItem(title: "Lateral Raise", value: "8 kg /hand", trend: .flat),
    ]
}
#endif
