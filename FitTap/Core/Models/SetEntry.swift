import Foundation

/// One set of a strength or bodyweight exercise.
struct SetEntry: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    /// Position within the exercise.
    var order: Int
    var reps: Int
    /// The value the user entered, in the app's global weight unit; its meaning
    /// depends on the exercise's `loadMode` (per side, per hand, added weight…).
    /// Nil for pure bodyweight sets.
    var weight: Double?

    init(
        id: UUID = UUID(),
        order: Int,
        reps: Int,
        weight: Double? = nil
    ) {
        self.id = id
        self.order = order
        self.reps = reps
        self.weight = weight
    }
}
