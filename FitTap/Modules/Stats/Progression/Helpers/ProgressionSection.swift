import Foundation

/// One muscle group on the full progression list: its name ("Chest") and
/// its exercises, A to Z.
struct ProgressionSection: Identifiable, Hashable {
    let id: String
    let title: String
    let items: [StatsProgressionItem]

    init(title: String, items: [StatsProgressionItem]) {
        id = title
        self.title = title
        self.items = items
    }
}

#if DEBUG
extension ProgressionSection {
    static let samples: [ProgressionSection] = [
        ProgressionSection(title: "Chest", items: Array(StatsProgressionItem.samples.prefix(2))),
        ProgressionSection(title: "Back", items: Array(StatsProgressionItem.samples.dropFirst(2).prefix(2))),
        ProgressionSection(title: "Legs", items: Array(StatsProgressionItem.samples.suffix(2))),
    ]
}
#endif
