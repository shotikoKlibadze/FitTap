import Foundation

/// The hardcoded workout templates, built from `ExerciseData` by name.
enum WorkoutData {
    static let templates: [WorkoutTemplate] = [
        WorkoutTemplate(name: "Back Day", color: .green, type: .strength, primaryMuscleGroup: .back, exercises: workoutExercises(
            "Deadlift", "Pull-Ups", "Bent-Over Row", "Low Row Machine", "Technogym Row Machine",
        )),
        WorkoutTemplate(name: "Shoulder Day", color: .yellow, type: .strength, primaryMuscleGroup: .shoulders, exercises: workoutExercises(
            "Standing OHP", "Arnold Press", "Rear Delt Fly", "EZ Bar High Pull", "DB Lateral Raises", "Shoulder Press Machine",
        )),
        WorkoutTemplate(name: "Limbs Day", color: .red, type: .strength, primaryMuscleGroup: .legs, secondaryMuscleGroup: .biceps, exercises: workoutExercises(
            "Back Squat", "RDL", "Bulgarian Split Squat", "Leg Extension", "Leg Press",
            "DB Curls", "EZ Bar Curls", "Tricep Pushdowns", "EZ Skull Crushers",
        )),
        WorkoutTemplate(name: "Abs", color: .blue, type: .strength, primaryMuscleGroup: .abs, exercises: workoutExercises(
            "Decline Sit-Ups", "Russian Twists", "Hanging Leg Raises",
        )),
    ]

    private static func workoutExercises(_ names: String...) -> [WorkoutExercise] {
        names.enumerated().map { index, name in
            guard let exercise = ExerciseData.exercises.first(where: { $0.name == name }) else {
                fatalError("Unknown exercise in WorkoutData: \(name)")
            }
            return WorkoutExercise(exerciseID: exercise.id, order: index)
        }
    }
}
