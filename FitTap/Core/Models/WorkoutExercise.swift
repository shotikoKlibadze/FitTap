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

    init(
        id: UUID = UUID(),
        exerciseID: UUID,
        order: Int,
        sets: [SetEntry] = [],
        cardio: CardioEntry? = nil,
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.order = order
        self.sets = sets
        self.cardio = cardio
    }
}
