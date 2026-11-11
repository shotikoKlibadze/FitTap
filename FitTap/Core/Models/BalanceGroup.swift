import Foundation

/// The muscle groups the Stats balance card compares. Biceps and triceps fold
/// into "Arms"; full-body exercises aren't counted, since they'd count
/// toward everything.
enum BalanceGroup: String, CaseIterable, Sendable {
    case chest
    case back
    case shoulders
    case arms
    case abs
    case legs

    /// The group a muscle counts toward; nil for full body.
    init?(muscle: MuscleGroup) {
        switch muscle {
        case .chest: self = .chest
        case .back: self = .back
        case .shoulders: self = .shoulders
        case .arms, .biceps, .triceps: self = .arms
        case .abs: self = .abs
        case .legs: self = .legs
        case .fullBody: return nil
        }
    }

    var displayName: String {
        rawValue.capitalized
    }

    /// Whether the name reads as plural ("Legs are", "Back is").
    var isPlural: Bool {
        switch self {
        case .shoulders, .arms, .abs, .legs: true
        case .chest, .back: false
        }
    }
}
