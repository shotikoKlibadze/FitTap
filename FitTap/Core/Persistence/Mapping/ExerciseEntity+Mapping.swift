import Foundation

extension ExerciseEntity {
    /// The struct the app works with. Nil when a stored raw value no longer
    /// matches an enum case, so a bad row is skipped instead of crashing.
    var exercise: Exercise? {
        guard let kind = ExerciseKind(rawValue: kindRaw) else { return nil }
        return Exercise(
            id: id,
            name: name,
            kind: kind,
            loadMode: loadModeRaw.flatMap(LoadMode.init(rawValue:)),
            equipment: Equipment(rawValue: equipmentRaw) ?? .other,
            mainMuscleGroup: mainMuscleRaw.flatMap(MuscleGroup.init(rawValue:)),
            secondaryMuscleGroup: secondaryMuscleRaw.flatMap(MuscleGroup.init(rawValue:)),
        )
    }

    /// Copies every field from the struct; the id stays.
    func update(from exercise: Exercise) {
        name = exercise.name
        kindRaw = exercise.kind.rawValue
        loadModeRaw = exercise.loadMode?.rawValue
        equipmentRaw = exercise.equipment.rawValue
        mainMuscleRaw = exercise.mainMuscleGroup?.rawValue
        secondaryMuscleRaw = exercise.secondaryMuscleGroup?.rawValue
    }
}
