import Foundation

/// One suggestion on the Stats tab, ready for `SuggestionCard`: a title and
/// the sentence under it. The coach that writes these isn't built yet, so
/// the screen model hands out the sample.
struct StatsSuggestionItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let message: String

    init(id: UUID = UUID(), title: String, message: String) {
        self.id = id
        self.title = title
        self.message = message
    }
}

#if DEBUG
extension StatsSuggestionItem {
    static let sample = StatsSuggestionItem(
        title: "Legs are falling behind",
        message: "1 session in 4 weeks against 7 upper-body sessions. Your usual is 10 sets a week.",
    )
}
#endif
