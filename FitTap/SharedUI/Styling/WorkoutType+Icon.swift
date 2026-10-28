import Foundation

/// The SF Symbol each workout type is drawn with, everywhere it appears.
extension WorkoutType {
    var iconName: String {
        switch self {
        case .strength: "dumbbell"
        case .cardio: "figure.run"
        }
    }
}
