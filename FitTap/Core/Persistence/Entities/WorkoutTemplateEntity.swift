import Foundation
import SwiftData

/// A workout the user built, as stored: what the Workouts tab lists and Home
/// plans from. Maps to `WorkoutTemplate`.
@Model
final class WorkoutTemplateEntity {
    var id: UUID = UUID()
    var name: String = ""
    /// `WorkoutColor` raw value.
    var colorRaw: String = WorkoutColor.green.rawValue
    /// `WorkoutType` raw value.
    var typeRaw: String = WorkoutType.strength.rawValue
    /// `MuscleGroup` raw values.
    var primaryMuscleRaw: String?
    var secondaryMuscleRaw: String?
    /// Keeps the Workouts tab in the order workouts were made.
    var createdAt: Date = Date.now

    /// Its exercises with their planned sets. Deleting the workout deletes
    /// them; sessions keep their own copies, so history is untouched.
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExerciseEntity.template)
    var exercises: [WorkoutExerciseEntity]? = []

    init(id: UUID) {
        self.id = id
    }
}
