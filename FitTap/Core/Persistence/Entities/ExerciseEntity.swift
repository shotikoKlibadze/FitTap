import Foundation
import SwiftData

/// An exercise in the database: a built-in one copied from `ExerciseData`, or
/// one the user created. The app works on `Exercise`; only
/// `SwiftDataManager` sees this type.
///
/// Every property has a default, and enums are stored as their raw strings,
/// so the model stays CloudKit-compatible and filterable.
@Model
final class ExerciseEntity {
    var id: UUID = UUID()
    var name: String = ""
    /// `ExerciseKind` raw value.
    var kindRaw: String = ExerciseKind.weightlifting.rawValue
    /// `LoadMode` raw value; weightlifting exercises only.
    var loadModeRaw: String?
    /// `Equipment` raw value.
    var equipmentRaw: String = Equipment.other.rawValue
    /// `MuscleGroup` raw values.
    var mainMuscleRaw: String?
    var secondaryMuscleRaw: String?
    /// Copied from `ExerciseData`. Seeding keeps these in step with the code.
    var isBuiltIn: Bool = false

    init(id: UUID) {
        self.id = id
    }
}
