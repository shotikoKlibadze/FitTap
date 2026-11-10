import Foundation

/// How a hold's time reads: "45 s" under a minute, "1 min" on the minute,
/// "1:30 min" in between. Split into value and unit for pills that style
/// them apart.
nonisolated enum HoldTimeFormatter {
    static func parts(_ seconds: TimeInterval) -> (value: String, unit: String) {
        let total = Int(seconds.rounded())
        guard total >= 60 else { return ("\(total)", "s") }
        let minutes = total / 60
        let rest = total % 60
        return rest == 0
            ? ("\(minutes)", "min")
            : ("\(minutes):\(String(format: "%02d", rest))", "min")
    }

    /// "45 s", "1 min", "1:30 min".
    static func text(_ seconds: TimeInterval) -> String {
        let parts = parts(seconds)
        return "\(parts.value) \(parts.unit)"
    }
}
