import Foundation

extension ExerciseSessionLog {
    /// What was done, in a few words, for the "Previous" line on an
    /// exercise card: "4 × 8 · 10 kg /side". Different reps read
    /// "10, 8, 8, 6", different weights a range ("8–12.5 kg"), a hold
    /// "3 × 60 s", a bodyweight move "3 × 12 · BW" (or "BW + 10").
    func previousSummary(for exercise: Exercise, unit: WeightUnit = .kg) -> String {
        if exercise.kind == .hold {
            return volume(sets.map { Int(($0.duration ?? 0).rounded()) }, unit: " s")
        }
        return [volume(sets.map(\.reps), unit: ""), load(for: exercise, unit: unit)]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    /// "4 × 8" when every set matches, "10, 8, 8, 6" when they don't.
    private func volume(_ values: [Int], unit: String) -> String {
        guard let first = values.first else { return "" }
        if values.allSatisfy({ $0 == first }) {
            return "\(values.count) × \(first)\(unit)"
        }
        return values.map(String.init).joined(separator: ", ") + unit
    }

    /// The weight, or its range when it changed between sets. Nil for a
    /// weighted exercise with no weight entered.
    private func load(for exercise: Exercise, unit: WeightUnit) -> String? {
        let weights = sets.compactMap(\.weight).filter { $0 > 0 }
        if exercise.kind == .bodyweight {
            guard let top = weights.max() else { return "BW" }
            return "BW + \(LoadDisplayFormatter.trimmed(top))"
        }
        guard let low = weights.min(), let high = weights.max() else { return nil }
        let loadMode = exercise.loadMode ?? .total
        guard low != high else {
            return LoadDisplayFormatter.displayString(for: high, loadMode: loadMode, unit: unit)
        }
        return "\(LoadDisplayFormatter.trimmed(low))–" + LoadDisplayFormatter.displayString(for: high, loadMode: loadMode, unit: unit)
    }
}
