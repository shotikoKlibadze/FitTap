import Foundation

/// A workout the user built: name, color, type, and exercises with planned
/// sets (or cardio targets). With no date attached it lives on the Workouts
/// tab; scheduling or starting it creates a `WorkoutSession`.
struct WorkoutTemplate: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var color: WorkoutColor
    var type: WorkoutType
    /// Strength workouts only; the secondary is optional.
    var primaryMuscleGroup: MuscleGroup?
    var secondaryMuscleGroup: MuscleGroup?
    var exercises: [WorkoutExercise]

    init(
        id: UUID = UUID(),
        name: String,
        color: WorkoutColor = .green,
        type: WorkoutType = .strength,
        primaryMuscleGroup: MuscleGroup? = nil,
        secondaryMuscleGroup: MuscleGroup? = nil,
        exercises: [WorkoutExercise] = [],
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.type = type
        self.primaryMuscleGroup = primaryMuscleGroup
        self.secondaryMuscleGroup = secondaryMuscleGroup
        self.exercises = exercises
    }
}
