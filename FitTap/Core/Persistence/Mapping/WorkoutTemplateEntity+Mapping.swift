import Foundation
import SwiftData

extension WorkoutTemplateEntity {
    var template: WorkoutTemplate {
        WorkoutTemplate(
            id: id,
            name: name,
            color: WorkoutColor(rawValue: colorRaw) ?? .green,
            type: WorkoutType(rawValue: typeRaw) ?? .strength,
            primaryMuscleGroup: primaryMuscleRaw.flatMap(MuscleGroup.init(rawValue:)),
            secondaryMuscleGroup: secondaryMuscleRaw.flatMap(MuscleGroup.init(rawValue:)),
            exercises: (exercises ?? []).sorted { $0.order < $1.order }.map(\.workoutExercise),
        )
    }

    /// Copies the fields and syncs the exercises by id.
    func update(from template: WorkoutTemplate, in context: ModelContext) {
        name = template.name
        colorRaw = template.color.rawValue
        typeRaw = template.type.rawValue
        primaryMuscleRaw = template.primaryMuscleGroup?.rawValue
        secondaryMuscleRaw = template.secondaryMuscleGroup?.rawValue
        exercises = WorkoutExerciseEntity.sync(template.exercises, existing: exercises ?? [], in: context)
    }
}
