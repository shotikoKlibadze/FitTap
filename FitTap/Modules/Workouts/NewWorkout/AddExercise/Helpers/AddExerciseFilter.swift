import Foundation

/// Which chip narrows the Add Exercise list: everything, one muscle group,
/// or cardio activities.
enum AddExerciseFilter: Hashable, Sendable {
    case all
    case muscle(MuscleGroup)
    case cardio

    /// The muscle the New Exercise sheet starts on, if this filter names one.
    var muscleGroup: MuscleGroup? {
        guard case .muscle(let group) = self else { return nil }
        return group
    }

    func includes(_ exercise: Exercise) -> Bool {
        switch self {
        case .all: true
        case .muscle(let group): exercise.mainMuscleGroup == group || exercise.secondaryMuscleGroup == group
        case .cardio: exercise.kind == .cardio
        }
    }
}
