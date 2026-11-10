import SwiftUI

extension [WorkoutExercise] {
    /// Applies a drag-to-reorder from a `reorderContainer`: the dragged
    /// exercises move in front of the exercise they were dropped on, or to
    /// the end, then every exercise's `order` is renumbered to match. SwiftUI
    /// offers no ready-made `apply(difference:)` on arrays, so this is the
    /// documented by-hand version (Knowledge/SwiftUI/README.md §8).
    mutating func reorder(_ difference: ReorderDifference<WorkoutExercise.ID, ReorderableSingleCollectionIdentifier>) {
        let moving = difference.sources.compactMap { id in first { $0.id == id } }
        guard !moving.isEmpty else { return }
        var result = self
        result.removeAll { difference.sources.contains($0.id) }
        switch difference.destination.position {
        case .before(let target):
            let index = result.firstIndex { $0.id == target } ?? result.endIndex
            result.insert(contentsOf: moving, at: index)
        case .end:
            result.append(contentsOf: moving)
        }
        for index in result.indices {
            result[index].order = index
        }
        // One assignment, so an owner that saves on change saves once.
        self = result
    }
}
