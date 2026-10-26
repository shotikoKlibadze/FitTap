import Foundation

/// Turns an entered weight value into the string the logging UI shows.
/// The value is displayed as entered (per side, per hand…) — never the
/// computed total — because that's how the user thinks about the exercise.
nonisolated enum LoadDisplayFormatter {
    /// "20 kg /side", "20 kg /hand", "40 kg". A nil value renders "—"
    /// (nothing entered yet).
    static func displayString(for value: Double?, loadMode: LoadMode, unit: WeightUnit) -> String {
        guard let value else { return "—" }
        switch loadMode {
        case .perSide:
            return "\(trimmed(value)) \(unit.rawValue) /side"
        case .perHand:
            return "\(trimmed(value)) \(unit.rawValue) /hand"
        case .machineStack, .total:
            return "\(trimmed(value)) \(unit.rawValue)"
        }
    }

    /// Bodyweight-kind sets: "BW" or "BW + 10 kg" when weight was added.
    static func bodyweightDisplayString(added: Double?, unit: WeightUnit) -> String {
        guard let added, added > 0 else { return "BW" }
        return "BW + \(trimmed(added)) \(unit.rawValue)"
    }

    /// "20", "12.5" — no trailing ".0", locale-independent.
    static func trimmed(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(value)
    }
}
