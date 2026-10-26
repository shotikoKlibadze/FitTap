import Foundation

/// Pure weight math. Unit-agnostic: values come back in the same unit they
/// were entered in.
enum LoadMath {
    private static let lbsPerKg = 2.204_622_621_85
    /// Standard Olympic bar, assumed for every `.perSide` exercise.
    static let barWeightKg = 20.0

    /// The effective total load behind an entered value. Only `.perSide` does
    /// real math (2× entered + bar). For the remaining modes the entered value
    /// already is the load (for `.perHand` per-hand) — progression compares
    /// like with like, so no multiplication is invented.
    static func totalLoad(entered: Double?, loadMode: LoadMode) -> Double? {
        switch loadMode {
        case .perSide:
            guard let entered else { return nil }
            return entered * 2 + barWeightKg
        case .perHand, .machineStack, .total:
            return entered
        }
    }

    static func kgToLbs(_ kg: Double) -> Double { kg * lbsPerKg }

    static func lbsToKg(_ lbs: Double) -> Double { lbs / lbsPerKg }
}
