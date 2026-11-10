import Foundation

/// One suggestion on the Stats tab, ready for `SuggestionCard`: a title and
/// the sentence under it. For now the screen model writes one from the
/// balance counts; the coach takes over later.
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
        message: "1 session in the last 4 weeks, against about 5 for each muscle group.",
    )
}
#endif
