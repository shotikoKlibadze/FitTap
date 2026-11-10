import Foundation
import SwiftData

extension SetEntryEntity {
    var setEntry: SetEntry {
        SetEntry(id: id, order: order, reps: reps, weight: weight, loggedAt: loggedAt, failed: failed, duration: duration)
    }

    func update(from set: SetEntry) {
        order = set.order
        reps = set.reps
        weight = set.weight
        loggedAt = set.loggedAt
        failed = set.failed
        duration = set.duration
    }

    /// Brings stored sets in line with `sets`, matched by id: existing rows
    /// are updated, new ones inserted, missing ones deleted. Returns the rows
    /// in the order given. Never rebuilds the whole list, so unchanged sets
    /// stay untouched.
    static func sync(_ sets: [SetEntry], existing: [SetEntryEntity], in context: ModelContext) -> [SetEntryEntity] {
        var leftover = Dictionary(existing.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let rows = sets.map { set in
            let row = leftover.removeValue(forKey: set.id) ?? {
                let row = SetEntryEntity(id: set.id)
                context.insert(row)
                return row
            }()
            row.update(from: set)
            return row
        }
        leftover.values.forEach(context.delete)
        return rows
    }
}
