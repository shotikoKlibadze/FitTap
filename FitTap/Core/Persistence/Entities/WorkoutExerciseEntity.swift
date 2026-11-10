import Foundation
import SwiftData

/// One exercise inside a stored workout or session. Maps to
/// `WorkoutExercise`. The same type serves both, so the mapping and the
/// child diff are written once; exactly one of `template` and `session` is
/// set.
///
/// Cardio is flattened into plain columns rather than a nested value, so
/// stats can filter on it ("running distance over time").
@Model
final class WorkoutExerciseEntity {
    #Index<WorkoutExerciseEntity>([\.exerciseID])

    var id: UUID = UUID()
    /// The catalog exercise, as a plain id: history must outlive a deleted
    /// exercise, and a relationship would be cleared with it.
    var exerciseID: UUID = UUID()
    var order: Int = 0
    /// `Effort` raw value; nil until rated.
    var effortRaw: String?

    /// Cardio, present when `cardioDuration` is set. See `CardioEntry`.
    var cardioDuration: Double?
    var cardioSpeedKmh: Double?
    var cardioDistanceMeters: Double?
    var cardioCount: Int?
    var cardioStartedAt: Date?
    var cardioAverageHeartRate: Double?

    var template: WorkoutTemplateEntity?
    var session: WorkoutSessionEntity?

    @Relationship(deleteRule: .cascade, inverse: \SetEntryEntity.workoutExercise)
    var sets: [SetEntryEntity]? = []

    init(id: UUID) {
        self.id = id
    }
}
