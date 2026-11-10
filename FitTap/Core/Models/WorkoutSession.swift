import Foundation

/// A workout with a date: planned for a day, done, or missed.
///
/// While it only sits on the plan it *follows* its workout: `workout` is
/// whatever the general workout looks like now, so editing Push Day on
/// Wednesday reaches Friday. Starting it, or editing it from Home, gives it
/// its own copy for good — logging edits that copy, so later changes to the
/// workout never rewrite history.
struct WorkoutSession: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var workout: WorkoutTemplate
    /// The day this session is planned for or was performed on.
    var scheduledFor: Date
    var startedAt: Date?
    var endedAt: Date?
    var notes: String?
    /// `HKWorkout.uuid` of the workout this session was saved as (or matched
    /// to) in HealthKit. Nil until synced. Used to avoid duplicate writes and
    /// to read HR, calories and zones back; sets are never reconstructed from
    /// HealthKit. See Knowledge/iOSHealthKit/README.md §2.
    var healthKitWorkoutID: UUID?
    /// True while it follows its workout's later edits; false once it has
    /// its own copy. Only a session not yet started can follow.
    var followsWorkout: Bool

    init(
        id: UUID = UUID(),
        workout: WorkoutTemplate,
        scheduledFor: Date = .now,
        startedAt: Date? = nil,
        endedAt: Date? = nil,
        notes: String? = nil,
        healthKitWorkoutID: UUID? = nil,
        followsWorkout: Bool = false,
    ) {
        self.id = id
        self.workout = workout
        self.scheduledFor = scheduledFor
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.notes = notes
        self.healthKitWorkoutID = healthKitWorkoutID
        self.followsWorkout = followsWorkout
    }

    /// Done once finished; missed when the day passed without finishing;
    /// planned otherwise.
    var status: WorkoutSessionStatus {
        if endedAt != nil { return .done }
        let calendar = Calendar.current
        if calendar.startOfDay(for: scheduledFor) < calendar.startOfDay(for: .now) {
            return .missed
        }
        return .planned
    }
}

#if DEBUG
extension WorkoutSession {
    static let sample = WorkoutSession(
        workout: WorkoutTemplate(
            name: "Push Day",
            color: .rose,
            type: .strength,
            primaryMuscleGroup: .chest,
            secondaryMuscleGroup: .shoulders,
            exercises: [
                WorkoutExercise(
                    exerciseID: Exercise.sample.id,
                    order: 0,
                    sets: [
                        SetEntry(order: 0, reps: 6, weight: 20),
                        SetEntry(order: 1, reps: 6, weight: 20),
                        SetEntry(order: 2, reps: 5, weight: 20),
                    ],
                ),
            ],
        ),
        scheduledFor: .now,
        startedAt: .now.addingTimeInterval(-3600),
        endedAt: .now,
    )
}
#endif
