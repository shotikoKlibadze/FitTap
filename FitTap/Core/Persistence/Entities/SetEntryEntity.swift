import Foundation
import SwiftData

/// One set as stored. Maps to `SetEntry`. Its own row, so stats can fetch
/// sets by date without loading whole sessions.
@Model
final class SetEntryEntity {
    #Index<SetEntryEntity>([\.loggedAt])

    var id: UUID = UUID()
    var order: Int = 0
    var reps: Int = 0
    var weight: Double?
    /// When it was checked off; nil on planned sets. Stats read sets by this.
    var loggedAt: Date?
    var failed: Bool = false
    /// Seconds held; hold exercises only.
    var duration: Double?

    var workoutExercise: WorkoutExerciseEntity?

    init(id: UUID) {
        self.id = id
    }
}
