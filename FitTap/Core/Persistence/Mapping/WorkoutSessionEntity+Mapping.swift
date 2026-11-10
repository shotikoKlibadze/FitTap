import Foundation
import SwiftData

extension WorkoutSessionEntity {
    /// Whether this session can follow its workout: only while it's planned
    /// and nothing has been logged.
    static func canFollow(_ session: WorkoutSession) -> Bool {
        session.followsWorkout && session.startedAt == nil && session.endedAt == nil
    }

    /// The session as the app sees it. A following session shows `template`
    /// as it is now; one with its own copy, or one whose workout is gone,
    /// shows its stored copy.
    func session(template: WorkoutTemplateEntity?) -> WorkoutSession {
        let follows = isFollowingTemplate && template != nil
        return WorkoutSession(
            id: id,
            workout: follows ? (template?.template ?? storedWorkout) : storedWorkout,
            scheduledFor: scheduledFor,
            startedAt: startedAt,
            endedAt: endedAt,
            notes: notes,
            healthKitWorkoutID: healthKitWorkoutID,
            followsWorkout: follows,
        )
    }

    /// The copied workout as stored.
    var storedWorkout: WorkoutTemplate {
        WorkoutTemplate(
            id: templateID,
            name: name,
            color: WorkoutColor(rawValue: colorRaw) ?? .green,
            type: WorkoutType(rawValue: typeRaw) ?? .strength,
            primaryMuscleGroup: primaryMuscleRaw.flatMap(MuscleGroup.init(rawValue:)),
            secondaryMuscleGroup: secondaryMuscleRaw.flatMap(MuscleGroup.init(rawValue:)),
            exercises: (exercises ?? []).sorted { $0.order < $1.order }.map(\.workoutExercise),
        )
    }

    /// Copies the session in. A following session stores only its own fields
    /// plus the workout's name, color, type and muscles (a fallback should the
    /// workout disappear); its exercises live on the workout. One with its own
    /// copy stores the exercises too, synced by id.
    func update(from session: WorkoutSession, in context: ModelContext) {
        let follows = Self.canFollow(session)
        isFollowingTemplate = follows
        templateID = session.workout.id
        scheduledFor = session.scheduledFor
        startedAt = session.startedAt
        endedAt = session.endedAt
        notes = session.notes
        healthKitWorkoutID = session.healthKitWorkoutID
        name = session.workout.name
        colorRaw = session.workout.color.rawValue
        typeRaw = session.workout.type.rawValue
        primaryMuscleRaw = session.workout.primaryMuscleGroup?.rawValue
        secondaryMuscleRaw = session.workout.secondaryMuscleGroup?.rawValue
        exercises = WorkoutExerciseEntity.sync(follows ? [] : session.workout.exercises, existing: exercises ?? [], in: context)
    }
}
