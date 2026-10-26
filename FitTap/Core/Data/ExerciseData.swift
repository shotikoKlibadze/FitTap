import Foundation

/// The hardcoded exercise catalog, grouped by muscle group.
enum ExerciseData {
    static let exercises: [Exercise] = chest + back + shoulders + legs + arms + abs + cardio

    // MARK: - Chest

    private static let chest: [Exercise] = [
        Exercise(name: "Bench Press", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .chest, secondaryMuscleGroup: .triceps),
        Exercise(name: "Incline Bench", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .chest, secondaryMuscleGroup: .shoulders),
        Exercise(name: "Chest Dips", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .chest, secondaryMuscleGroup: .triceps),
        Exercise(name: "DB Flies", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .chest),
        Exercise(name: "DB Incline Press", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .chest, secondaryMuscleGroup: .shoulders),
        Exercise(name: "Fly Machine", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .chest),
    ]

    // MARK: - Back

    private static let back: [Exercise] = [
        Exercise(name: "Deadlift", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .back, secondaryMuscleGroup: .legs),
        Exercise(name: "Pull-Ups", kind: .bodyweight, equipment: .pullUpBar, mainMuscleGroup: .back, secondaryMuscleGroup: .biceps),
        Exercise(name: "Bent-Over Row", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .back),
        Exercise(name: "Low Row Machine", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .back),
        Exercise(name: "Technogym Row Machine", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .back),
    ]

    // MARK: - Shoulders

    private static let shoulders: [Exercise] = [
        Exercise(name: "Standing OHP", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .shoulders, secondaryMuscleGroup: .triceps),
        Exercise(name: "Push Press", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .shoulders),
        Exercise(name: "Arnold Press", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .shoulders),
        Exercise(name: "DB Lateral Raises", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .shoulders),
        Exercise(name: "Rear Delt Fly", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .shoulders),
        Exercise(name: "EZ Bar High Pull", kind: .weightlifting, loadMode: .perSide, equipment: .ezBar, mainMuscleGroup: .shoulders, secondaryMuscleGroup: .back),
        Exercise(name: "Shoulder Press Machine", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .shoulders),
    ]

    // MARK: - Legs

    private static let legs: [Exercise] = [
        Exercise(name: "Back Squat", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .legs),
        Exercise(name: "RDL", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .legs, secondaryMuscleGroup: .back),
        Exercise(name: "Bulgarian Split Squat", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .legs),
        Exercise(name: "Leg Extension", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .legs),
        Exercise(name: "Leg Press", kind: .weightlifting, loadMode: .machineStack, equipment: .machine, mainMuscleGroup: .legs),
    ]

    // MARK: - Arms

    private static let arms: [Exercise] = [
        Exercise(name: "DB Curls", kind: .weightlifting, loadMode: .perHand, equipment: .dumbbell, mainMuscleGroup: .biceps),
        Exercise(name: "EZ Bar Curls", kind: .weightlifting, loadMode: .perSide, equipment: .ezBar, mainMuscleGroup: .biceps),
        Exercise(name: "Tricep Pushdowns", kind: .weightlifting, loadMode: .machineStack, equipment: .cable, mainMuscleGroup: .triceps),
        Exercise(name: "EZ Skull Crushers", kind: .weightlifting, loadMode: .perSide, equipment: .ezBar, mainMuscleGroup: .triceps),
    ]

    // MARK: - Abs

    private static let abs: [Exercise] = [
        Exercise(name: "Sit-Ups", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .abs),
        Exercise(name: "Decline Sit-Ups", kind: .bodyweight, equipment: .bench, mainMuscleGroup: .abs),
        Exercise(name: "Crunches", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .abs),
        Exercise(name: "Bicycle Crunches", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .abs),
        Exercise(name: "Russian Twists", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .abs),
        Exercise(name: "Lying Leg Raises", kind: .bodyweight, equipment: .bodyweight, mainMuscleGroup: .abs),
        Exercise(name: "Hanging Leg Raises", kind: .bodyweight, equipment: .pullUpBar, mainMuscleGroup: .abs),
        Exercise(name: "Ab Wheel Rollout", kind: .bodyweight, equipment: .other, mainMuscleGroup: .abs),
        Exercise(name: "Cable Crunch", kind: .weightlifting, loadMode: .machineStack, equipment: .cable, mainMuscleGroup: .abs),
        // Timed hold — logged as a duration.
        Exercise(name: "Plank", kind: .cardio, equipment: .bodyweight, mainMuscleGroup: .abs),
    ]

    // MARK: - Cardio

    private static let cardio: [Exercise] = [
        Exercise(name: "Running", kind: .cardio, equipment: .bodyweight),
        Exercise(name: "Walking", kind: .cardio, equipment: .bodyweight),
        Exercise(name: "Jump Rope", kind: .cardio, equipment: .other),
        Exercise(name: "Cycling", kind: .cardio, equipment: .machine),
        Exercise(name: "Rowing", kind: .cardio, equipment: .machine),
        Exercise(name: "Elliptical", kind: .cardio, equipment: .machine),
        Exercise(name: "Stair Climber", kind: .cardio, equipment: .machine),
        Exercise(name: "Swimming", kind: .cardio, equipment: .bodyweight),
        Exercise(name: "Boxing", kind: .cardio, equipment: .other),
    ]
}
