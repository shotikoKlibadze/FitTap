import Foundation

/// Physical equipment the exercise uses. Enables future filtering and
/// disambiguates same-name exercises on different gear.
enum Equipment: String, Codable, CaseIterable, Sendable {
    case barbell
    case ezBar
    case dumbbell
    case cable
    case machine
    case kettlebell
    case bodyweight
    case pullUpBar
    case bench
    case other

    var displayName: String {
        switch self {
        case .ezBar: "EZ Bar"
        case .pullUpBar: "Pull-Up Bar"
        default: rawValue.capitalized
        }
    }
}
