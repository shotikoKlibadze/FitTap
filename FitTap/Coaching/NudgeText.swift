import Foundation

/// A nudge as the user reads it: a short title and one sentence under it,
/// ready for `SuggestionCard`.
struct NudgeText: Hashable, Sendable {
    let title: String
    let message: String
}

#if DEBUG
extension NudgeText {
    static let sample = NudgeWording.text(for: .addWeight)
}
#endif
