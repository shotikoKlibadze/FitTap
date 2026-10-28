import Foundation

/// The hardcoded workout templates, built from `ExerciseData` by name. Each
/// strength exercise comes with three planned sets, each cardio one with a
/// duration (and distance) target, so cards and estimates have numbers.
enum WorkoutData {
    static let templates: [WorkoutTemplate] = [
        strength("Push Day", color: .rose, primary: .chest, secondary: .shoulders,
                 "Bench Press", "Incline Bench", "DB Flies", "Standing OHP", "DB Lateral Raises", "Tricep Pushdowns"),
        strength("Pull Day", color: .purple, primary: .back, secondary: .biceps,
                 "Deadlift", "Pull-Ups", "Bent-Over Row", "Low Row Machine", "DB Curls", "EZ Bar Curls"),
        strength("Leg Day", color: .gold, primary: .legs,
                 "Back Squat", "RDL", "Leg Press", "Leg Extension", "Bulgarian Split Squat"),
        strength("Back Day", color: .green, primary: .back,
                 "Deadlift", "Pull-Ups", "Bent-Over Row", "Low Row Machine", "Technogym Row Machine"),
        strength("Shoulder Day", color: .yellow, primary: .shoulders,
                 "Standing OHP", "Arnold Press", "Rear Delt Fly", "EZ Bar High Pull", "DB Lateral Raises", "Shoulder Press Machine"),
        strength("Limbs Day", color: .red, primary: .legs, secondary: .biceps,
                 "Back Squat", "RDL", "Bulgarian Split Squat", "Leg Extension", "Leg Press",
                 "DB Curls", "EZ Bar Curls", "Tricep Pushdowns", "EZ Skull Crushers"),
        strength("Abs", color: .blue, primary: .abs,
                 "Decline Sit-Ups", "Russian Twists", "Hanging Leg Raises"),
        cardio("Easy 6 km", color: .mint, exercise: "Running", minutes: 30, kilometers: 6),
        cardio("Sparring", color: .orange, exercise: "Boxing", minutes: 90),
        cardio("Morning Swim", color: .cyan, exercise: "Swimming", minutes: 40, kilometers: 1.5),
    ]

    private static func strength(
        _ name: String,
        color: WorkoutColor,
        primary: MuscleGroup,
        secondary: MuscleGroup? = nil,
        _ exerciseNames: String...,
    ) -> WorkoutTemplate {
        let exercises = exerciseNames.enumerated().map { index, exerciseName in
            let exercise = exercise(named: exerciseName)
            return WorkoutExercise(exerciseID: exercise.id, order: index, sets: plannedSets(for: exercise))
        }
        return WorkoutTemplate(name: name, color: color, type: .strength, primaryMuscleGroup: primary, secondaryMuscleGroup: secondary, exercises: exercises)
    }

    private static func cardio(
        _ name: String,
        color: WorkoutColor,
        exercise exerciseName: String,
        minutes: Double,
        kilometers: Double? = nil,
    ) -> WorkoutTemplate {
        let exercise = exercise(named: exerciseName)
        let target = CardioEntry(duration: minutes * 60, distanceMeters: kilometers.map { $0 * 1000 })
        return WorkoutTemplate(
            name: name,
            color: color,
            type: .cardio,
            primaryMuscleGroup: .fullBody,
            exercises: [WorkoutExercise(exerciseID: exercise.id, order: 0, cardio: target)],
        )
    }

    /// Three sets of ten — a plain starting point the user taps to adjust.
    private static func plannedSets(for exercise: Exercise) -> [SetEntry] {
        (0..<3).map { SetEntry(order: $0, reps: 10, weight: exercise.kind == .weightlifting ? 20 : nil) }
    }

    private static func exercise(named name: String) -> Exercise {
        guard let exercise = ExerciseData.exercises.first(where: { $0.name == name }) else {
            fatalError("Unknown exercise in WorkoutData: \(name)")
        }
        return exercise
    }
}
