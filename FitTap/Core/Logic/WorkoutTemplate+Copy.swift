import Foundation

extension WorkoutTemplate {
    /// The same workout with new ids for every exercise entry and set — what
    /// a session keeps when it takes its own copy, so its rows never share
    /// ids with the workout's. The workout's own id stays: it's how the
    /// session remembers which workout it came from.
    func withFreshEntryIDs() -> WorkoutTemplate {
        var copy = self
        copy.exercises = exercises.map { exercise in
            WorkoutExercise(
                exerciseID: exercise.exerciseID,
                order: exercise.order,
                sets: exercise.sets.map { set in
                    SetEntry(order: set.order, reps: set.reps, weight: set.weight, loggedAt: set.loggedAt, failed: set.failed, duration: set.duration)
                },
                cardio: exercise.cardio,
                effort: exercise.effort,
            )
        }
        return copy
    }
}
