import Foundation

extension WorkoutTemplate {
    /// The workout as a plan: the same exercises, order and planned values,
    /// with everything from doing it removed — check times, failed flags,
    /// ratings, start times and heart rate — and fresh entry ids. What gets
    /// written back to a workout when a session's changes are kept for it.
    func asPlan() -> WorkoutTemplate {
        var plan = withFreshEntryIDs()
        for exercise in plan.exercises.indices {
            plan.exercises[exercise].effort = nil
            plan.exercises[exercise].cardio?.startedAt = nil
            plan.exercises[exercise].cardio?.averageHeartRate = nil
            for set in plan.exercises[exercise].sets.indices {
                plan.exercises[exercise].sets[set].loggedAt = nil
                plan.exercises[exercise].sets[set].failed = false
            }
        }
        return plan
    }

    /// Whether both plan the same exercises in the same order with the same
    /// sets — reps, weight and hold time — and the same cardio targets. Ids
    /// and anything logged are ignored.
    func hasSamePlan(as other: WorkoutTemplate) -> Bool {
        planOutline == other.planOutline
    }

    /// One line per exercise, in order: its id, its sets and its cardio.
    private var planOutline: [String] {
        exercises.sorted { $0.order < $1.order }.map { exercise in
            let sets = exercise.sets
                .sorted { $0.order < $1.order }
                .map { "\($0.reps)/\($0.weight.map { "\($0)" } ?? "-")/\($0.duration.map { "\($0)" } ?? "-")" }
                .joined(separator: ",")
            let cardio = exercise.cardio.map {
                "\($0.duration)/\($0.speedKmh.map { "\($0)" } ?? "-")/\($0.distanceMeters.map { "\($0)" } ?? "-")"
            } ?? "-"
            return "\(exercise.exerciseID)#\(sets)#\(cardio)"
        }
    }
}
