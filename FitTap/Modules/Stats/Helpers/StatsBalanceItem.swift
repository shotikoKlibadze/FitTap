import DesignSystem
import Foundation

/// One tile of the Stats balance card, ready for `CountTileButton`: a muscle
/// group's name, how many sessions trained it in the last four weeks, and
/// whether that's
/// well behind the average group. "Arms" folds biceps and triceps together
/// (see `BalanceGroup`).
struct StatsBalanceItem: Identifiable, Hashable {
    let id: String
    let title: String
    let count: Int
    let status: CountTileButton.Status

    init(title: String, count: Int, status: CountTileButton.Status) {
        id = title
        self.title = title
        self.count = count
        self.status = status
    }
}

#if DEBUG
extension StatsBalanceItem {
    static let samples: [StatsBalanceItem] = [
        StatsBalanceItem(title: "Chest", count: 4, status: .onTrack),
        StatsBalanceItem(title: "Back", count: 5, status: .onTrack),
        StatsBalanceItem(title: "Shoulders", count: 3, status: .onTrack),
        StatsBalanceItem(title: "Arms", count: 4, status: .onTrack),
        StatsBalanceItem(title: "Abs", count: 12, status: .onTrack),
        StatsBalanceItem(title: "Legs", count: 1, status: .behind),
    ]
}
#endif
