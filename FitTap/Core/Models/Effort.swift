import Foundation

/// How an exercise felt, rated once all its sets are done: one tap on the
/// "How did it feel?" strip under the exercise card.
///
/// It belongs to the exercise as a whole, not to a single set, and it is
/// always optional — the user can skip it, and nothing waits on it. Later,
/// statistics can read it for nudges like "you've been at this weight for a
/// while, and it felt easy — time to go up".
enum Effort: String, Codable, CaseIterable, Sendable {
    case easy
    case medium
    case hard
}
