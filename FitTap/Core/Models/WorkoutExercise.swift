import Foundation

/// One exercise inside a workout (template or logged session), referencing the
/// canonical `Exercise` by id. Strength/bodyweight exercises fill `sets`;
/// cardio fills `cardio` and leaves `sets` empty.
struct WorkoutExercise: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var exerciseID: UUID
    /// Position within the workout.
    var order: Int
    var sets: [SetEntry]
    var cardio: CardioEntry?
    /// How it felt, rated after its last set is done; `nil` until rated (or
    /// if the user skips it). Only meaningful in a logged session.
    var effort: Effort?

    init(
        id: UUID = UUID(),
        exerciseID: UUID,
        order: Int,
        sets: [SetEntry] = [],
        cardio: CardioEntry? = nil,
        effort: Effort? = nil,
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.order = order
        self.sets = sets
        self.cardio = cardio
        self.effort = effort
    }

    /// Every set is checked off, so the exercise is finished and can be
    /// rated. An exercise without sets (cardio) never counts as done here.
    var allSetsLogged: Bool {
        !sets.isEmpty && sets.allSatisfy { $0.loggedAt != nil }
    }

    /// Every set checked off and none failed. Only then is "How did it
    /// feel?" asked: a failed set already says it was hard.
    var allSetsCompleted: Bool {
        allSetsLogged && !sets.contains(where: \.failed)
    }
}
