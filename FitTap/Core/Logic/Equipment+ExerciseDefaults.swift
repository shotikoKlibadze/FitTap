import Foundation

/// What a new exercise logs, decided by its equipment — the user picks the
/// gear, never a "kind" or a weight mode. Matches the built-in catalog.
extension Equipment {
    var defaultKind: ExerciseKind {
        switch self {
        case .bodyweight, .pullUpBar, .bench: .bodyweight
        case .barbell, .ezBar, .dumbbell, .cable, .machine, .kettlebell, .other: .weightlifting
        }
    }

    /// How weight is entered; nil for bodyweight gear.
    var defaultLoadMode: LoadMode? {
        switch self {
        case .barbell, .ezBar: .perSide
        case .dumbbell: .perHand
        case .cable, .machine: .machineStack
        case .kettlebell, .other: .total
        case .bodyweight, .pullUpBar, .bench: nil
        }
    }
}
