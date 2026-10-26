import Foundation

/// A workout with a date: planned for a day, done, or missed. Carries a
/// snapshot of the workout as scheduled — logging edits this copy, so later
/// template changes never rewrite history.
struct WorkoutSession: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var workout: WorkoutTemplate
    /// The day this session is planned for or was performed on.
    var scheduledFor: Date
    var startedAt: Date?
    var endedAt: Date?
    var notes: String?

    init(
        id: UUID = UUID(),
        workout: WorkoutTemplate,
        scheduledFor: Date = .now,
        startedAt: Date? = nil,
        endedAt: Date? = nil,
        notes: String? = nil,
    ) {
        self.id = id
        self.workout = workout
        self.scheduledFor = scheduledFor
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.notes = notes
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
