import Foundation

/// How the user thinks about weight for this exercise. Entering "20" means
/// different things per mode; the UI shows the right label and does the right math.
enum LoadMode: String, Codable, CaseIterable, Sendable {
    /// Barbell: user enters weight per side; bar weight is added behind the
    /// scenes for totals. Display always shows per-side, never total.
    case perSide
    /// Dumbbell: user enters the weight of one dumbbell.
    case perHand
    /// Cable/machine: the number on the stack, as-is.
    case machineStack
    /// The number is simply the total weight (kettlebell, medicine ball).
    case total
}
