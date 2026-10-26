import Foundation

/// Per-exercise display preference. Weights are stored in the unit the user
/// logs them in (this unit); conversion for cross-exercise stats lives in
/// `LoadMath`, never in the model.
enum WeightUnit: String, Codable, CaseIterable, Sendable {
    case kg
    case lbs
}
