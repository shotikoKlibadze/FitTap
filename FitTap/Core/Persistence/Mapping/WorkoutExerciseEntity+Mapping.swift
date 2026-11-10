import Foundation
import SwiftData

extension WorkoutExerciseEntity {
    var workoutExercise: WorkoutExercise {
        WorkoutExercise(
            id: id,
            exerciseID: exerciseID,
            order: order,
            sets: (sets ?? []).sorted { $0.order < $1.order }.map(\.setEntry),
            cardio: cardio,
            effort: effortRaw.flatMap(Effort.init(rawValue:)),
        )
    }

    private var cardio: CardioEntry? {
        guard let cardioDuration else { return nil }
        return CardioEntry(
            duration: cardioDuration,
            speedKmh: cardioSpeedKmh,
            distanceMeters: cardioDistanceMeters,
            count: cardioCount,
            startedAt: cardioStartedAt,
            averageHeartRate: cardioAverageHeartRate,
        )
    }

    /// Copies the fields and syncs the sets by id.
    func update(from exercise: WorkoutExercise, in context: ModelContext) {
        exerciseID = exercise.exerciseID
        order = exercise.order
        effortRaw = exercise.effort?.rawValue
        cardioDuration = exercise.cardio?.duration
        cardioSpeedKmh = exercise.cardio?.speedKmh
        cardioDistanceMeters = exercise.cardio?.distanceMeters
        cardioCount = exercise.cardio?.count
        cardioStartedAt = exercise.cardio?.startedAt
        cardioAverageHeartRate = exercise.cardio?.averageHeartRate
        sets = SetEntryEntity.sync(exercise.sets, existing: sets ?? [], in: context)
    }

    /// Brings a workout's or session's stored exercises in line with
    /// `exercises`, matched by id within that parent: updated, inserted or
    /// deleted, sets included. Used by both templates and sessions.
    static func sync(_ exercises: [WorkoutExercise], existing: [WorkoutExerciseEntity], in context: ModelContext) -> [WorkoutExerciseEntity] {
        var leftover = Dictionary(existing.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let rows = exercises.map { exercise in
            let row = leftover.removeValue(forKey: exercise.id) ?? {
                let row = WorkoutExerciseEntity(id: exercise.id)
                context.insert(row)
                return row
            }()
            row.update(from: exercise, in: context)
            return row
        }
        leftover.values.forEach(context.delete)
        return rows
    }
}
