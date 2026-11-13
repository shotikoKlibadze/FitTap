import Foundation

/// A suggestion as the user reads it: a short title and one sentence under it,
/// ready for `SuggestionCard`.
struct SuggestionText: Hashable, Sendable {
    let title: String
    let message: String
}

#if DEBUG
extension SuggestionText {
    static let sample = SuggestionWording.text(for: .addWeight)
}
#endif
