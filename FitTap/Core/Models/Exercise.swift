import Foundation

/// A canonical exercise template — "Bench Press" exists once and is referenced
/// by many workouts over time. Plain value type used throughout the app;
/// persistence lives in `ExerciseEntity`.
struct Exercise: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var kind: ExerciseKind
    /// How weight is entered; only `.weightlifting` exercises have one.
    var loadMode: LoadMode?
    var equipment: Equipment
    var mainMuscleGroup: MuscleGroup?
    var secondaryMuscleGroup: MuscleGroup?

    init(
        id: UUID = UUID(),
        name: String,
        kind: ExerciseKind,
        loadMode: LoadMode? = nil,
        equipment: Equipment,
        mainMuscleGroup: MuscleGroup? = nil,
        secondaryMuscleGroup: MuscleGroup? = nil,
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.loadMode = loadMode
        self.equipment = equipment
        self.mainMuscleGroup = mainMuscleGroup
        self.secondaryMuscleGroup = secondaryMuscleGroup
    }
}

#if DEBUG
extension Exercise {
    static let sample = Exercise(
        name: "Bench Press",
        kind: .weightlifting,
        loadMode: .perSide,
        equipment: .barbell,
        mainMuscleGroup: .chest,
        secondaryMuscleGroup: .triceps,
    )

    static let sampleCardio = Exercise(
        name: "Running",
        kind: .cardio,
        equipment: .bodyweight,
    )
}
#endif
