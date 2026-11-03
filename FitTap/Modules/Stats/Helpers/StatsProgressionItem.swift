import DesignSystem
import Foundation

/// One row of the Stats progression card, ready for `ProgressionListItem`:
/// the exercise, its latest working value as text, and the trend. There's no
/// progression logic yet, so the screen model hands out the samples.
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
