import Foundation
import SwiftData

/// A dated workout as stored: planned, done or missed. Maps to
/// `WorkoutSession`.
///
/// While planned it follows its workout (`isFollowingTemplate`): its
/// exercises are read from the workout, so edits to Push Day reach it.
/// Starting it, editing it from Home, or deleting the workout gives it its
/// own copy (name, color, type, muscles and the exercises below), so later
/// changes never rewrite what was logged. `templateID` is the workout's id,
/// a plain id rather than a relationship, so it survives the workout being
/// deleted and stats can still group sessions by workout.
@Model
final class WorkoutSessionEntity {
    #Index<WorkoutSessionEntity>([\.scheduledFor], [\.templateID])

    var id: UUID = UUID()
    /// The id of the workout this session was made from.
    var templateID: UUID = UUID()
    /// True while planned and following the workout; its `exercises` are
    /// then empty. See Planning/SwiftDataPlanning.md, decision 3.
    var isFollowingTemplate: Bool = false
    /// The day it's planned for or was done on.
    var scheduledFor: Date = Date.now
    var startedAt: Date?
    var endedAt: Date?
    var notes: String?
    var healthKitWorkoutID: UUID?

    // The copied workout's own fields.
    var name: String = ""
    var colorRaw: String = WorkoutColor.green.rawValue
    var typeRaw: String = WorkoutType.strength.rawValue
    var primaryMuscleRaw: String?
    var secondaryMuscleRaw: String?

    /// The copied exercises and their sets — logging writes here. Empty
    /// while following.
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExerciseEntity.session)
    var exercises: [WorkoutExerciseEntity]? = []

    init(id: UUID) {
        self.id = id
    }
}
