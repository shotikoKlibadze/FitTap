import DesignSystem
import Foundation

/// One tile of the Stats balance card, ready for `SetCountButton`: a muscle
/// group's name, its sets over the last four weeks, and whether that's
/// behind the user's usual. "Arms" folds biceps and triceps together. No
/// balance logic exists yet, so the screen model hands out the samples.
struct StatsBalanceItem: Identifiable, Hashable {
    let id: String
    let title: String
    let count: Int
    let status: SetCountButton.Status

    init(title: String, count: Int, status: SetCountButton.Status) {
        id = title
        self.title = title
        self.count = count
        self.status = status
    }
}

#if DEBUG
extension StatsBalanceItem {
    static let samples: [StatsBalanceItem] = [
        StatsBalanceItem(title: "Chest", count: 48, status: .onTrack),
        StatsBalanceItem(title: "Back", count: 52, status: .onTrack),
        StatsBalanceItem(title: "Shoulders", count: 30, status: .onTrack),
        StatsBalanceItem(title: "Arms", count: 34, status: .onTrack),
        StatsBalanceItem(title: "Abs", count: 22, status: .onTrack),
        StatsBalanceItem(title: "Legs", count: 8, status: .behind),
    ]
}
#endif
