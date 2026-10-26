import FactoryKit
import Foundation

@MainActor
@Observable
final class SetValuePickerScreenModel {
    let context: SetValuePickerContext
    var selection: Double?
    var isCustom = false
    var customText = ""

    init(context: SetValuePickerContext) {
        self.context = context
        selection = context.currentValue
    }

    var title: String {
        switch context.field {
        case .reps: "Select reps"
        case .weight: context.exerciseKind == .bodyweight ? "Select added weight" : "Select weight"
        case .duration: "Select duration"
        case .speed: "Speed"
        }
    }

    /// "Bench Press — set 1" for reps; for weight, how the number is meant:
    /// "Bench Press — per side"; for cardio, just the exercise.
    var subtitle: String {
        let name = context.exerciseName
        let set = context.setNumber.map { " — set \($0)" } ?? ""
        switch context.field {
        case .reps:
            return name + set
        case .weight:
            switch context.loadMode {
            case .perSide: return "\(name) — per side"
            case .perHand: return "\(name) — per hand"
            case .machineStack: return "\(name) — stack"
            case .total: return "\(name) — total"
            case nil: return name + set
            }
        case .duration, .speed:
            return name
        }
    }

    /// Preset values; speed has none — it's typed.
    var values: [Double] {
        switch context.field {
        case .reps: Array(1...15).map(Double.init) + [20, 25, 30]
        case .weight: Array(stride(from: 2.5, through: 50, by: 2.5))
        case .duration: Array(stride(from: 5, through: 90, by: 5))
        case .speed: []
        }
    }

    var customTitle: String {
        switch context.field {
        case .reps: "Custom Reps"
        case .weight: context.exerciseKind == .bodyweight ? "Custom Added Weight" : "Custom Weight"
        case .duration: "Custom Duration"
        case .speed: "Speed"
        }
    }

    func edit(with value: Double) -> SetValueEdit {
        SetValueEdit(
            field: context.field,
            workoutExerciseID: context.workoutExerciseID,
            setID: context.setID,
            value: value,
        )
    }
}
