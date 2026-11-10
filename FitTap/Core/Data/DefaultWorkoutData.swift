import Foundation

/// The workouts every install starts with: Shota's own split. Added to the
/// database once (`SwiftDataManager.seedDefaultWorkouts`), then they're the
/// user's to edit or delete like any other — nothing puts them back.
///
/// Fixed ids, so seeding never adds one twice. Weights are where Shota's
/// training stood on Nov 2, 2026 (the last session in `Planning/SeedHistory.md`);
/// bodyweight moves have none.
enum DefaultWorkoutData {
    static let templates: [WorkoutTemplate] = [chestDay, backDay, shoulderDay, limbsDay]

    private static let chestDay = WorkoutTemplate(
        id: UUID(uuidString: "FB588FA2-A8C4-498D-9C07-F1CD0AB37965")!,
        name: "Chest Day",
        color: .rose,
        primaryMuscleGroup: .chest,
        secondaryMuscleGroup: .abs,
        exercises: entries([
            ("Bench Press", .reps(4, 8, kg: 20)),
            ("Incline Bench", .reps(4, 8, kg: 12.5)),
            ("Chest Dips", .reps(4, 8, kg: nil)),
            ("Fly Machine", .reps(4, 8, kg: 40)),
            ("Chest Machine", .reps(4, 8, kg: 40)),
            ("Decline Sit-Ups", .reps(4, 12, kg: 12.5)),
            ("Russian Twists", .reps(4, 20, kg: 12.5)),
        ]),
    )

    private static let backDay = WorkoutTemplate(
        id: UUID(uuidString: "10E5D686-F7C4-47F5-93F1-7B1251FA94F3")!,
        name: "Back Day",
        color: .purple,
        primaryMuscleGroup: .back,
        secondaryMuscleGroup: .abs,
        exercises: entries([
            ("Deadlift", .reps(4, 8, kg: 30)),
            ("Pull-Ups", .reps(4, 8, kg: nil)),
            ("Bent-Over Row", .reps(4, 8, kg: 15)),
            ("Low Row Machine", .reps(4, 8, kg: 30)),
            ("Row Machine", .reps(4, 8, kg: 30)),
            ("Decline Sit-Ups", .reps(4, 12, kg: 12.5)),
            ("Hanging Leg Raises", .reps(4, 10, kg: nil)),
        ]),
    )

    private static let shoulderDay = WorkoutTemplate(
        id: UUID(uuidString: "2F0BB06C-CA0C-4C0F-9ED6-71E746A68922")!,
        name: "Shoulder Day",
        color: .gold,
        primaryMuscleGroup: .shoulders,
        secondaryMuscleGroup: .abs,
        exercises: entries([
            ("Standing OHP", .reps(4, 8, kg: 10)),
            ("Arnold Press", .reps(4, 8, kg: 10)),
            ("Rear Delt Fly", .reps(4, 8, kg: 7.5)),
            ("EZ Bar High Pull", .reps(4, 8, kg: 7.5)),
            ("DB Lateral Raises", .reps(4, 8, kg: 7.5)),
            ("Decline Sit-Ups", .reps(4, 12, kg: 12.5)),
            ("Russian Twists", .reps(4, 20, kg: 12.5)),
        ]),
    )

    private static let limbsDay = WorkoutTemplate(
        id: UUID(uuidString: "12AFFF7C-6CB4-417F-AC48-8908CE25D4B9")!,
        name: "Limbs Day",
        color: .teal,
        primaryMuscleGroup: .legs,
        secondaryMuscleGroup: .biceps,
        exercises: entries([
            ("Back Squat", .reps(4, 8, kg: 22.5)),
            ("Calf Raises", .reps(4, 15, kg: 30)),
            ("Bulgarian Split Squat", .reps(4, 8, kg: 10)),
            ("Leg Extension", .reps(4, 8, kg: 45)),
            ("Leg Curls", .reps(4, 8, kg: 40)),
            ("Wall Sit", .hold(4, seconds: 60)),
            ("DB Curls", .reps(4, 8, kg: 10)),
            ("EZ Bar Curls", .reps(4, 8, kg: 10)),
            ("Tricep Pushdowns", .reps(4, 8, kg: 20)),
            ("Tricep Overhead Extension", .reps(4, 8, kg: 15)),
        ]),
    )

    // MARK: - Building

    /// What one exercise is planned as: sets of reps, or sets of a hold.
    private enum Plan {
        /// Sets, reps, and the weight entered (nil for bodyweight).
        case reps(Int, Int, kg: Double?)
        case hold(Int, seconds: TimeInterval)
    }

    /// Looks each exercise up by name in the built-in catalog, in order. A
    /// name that isn't there is a typo here, so it stops the app in testing.
    private static func entries(_ plans: [(name: String, plan: Plan)]) -> [WorkoutExercise] {
        plans.enumerated().map { order, item in
            guard let exercise = ExerciseData.exercises.first(where: { $0.name == item.name }) else {
                fatalError("Unknown exercise in DefaultWorkoutData: \(item.name)")
            }
            let sets: [SetEntry] = switch item.plan {
            case .reps(let count, let reps, let weight):
                (0..<count).map { SetEntry(order: $0, reps: reps, weight: weight) }
            case .hold(let count, let seconds):
                (0..<count).map { SetEntry(order: $0, reps: 0, duration: seconds) }
            }
            return WorkoutExercise(exerciseID: exercise.id, order: order, sets: sets)
        }
    }
}
