import Foundation

/// The vertical scale of a `SessionBarChart`: where it starts, where it
/// ends, and the round numbers drawn as grid lines in between.
///
/// The scale does not start at zero. Bars for 17.5, 20 and 22.5 kg drawn
/// from zero look almost the same height; drawn from 15 the steps are
/// plain to see, which is the whole point of the chart. So the bottom is
/// one step under the smallest value, and the top is the largest value
/// rounded up to a step.
///
/// The step is the smallest "round" size that needs at most four steps to
/// cover the values: 15 to 22.5 kg gets 2.5 kg steps (12.5, 15, 17.5, 20,
/// 22.5), 20 to 60 kg gets 10 kg steps.
struct SessionBarScale: Hashable {
    let lower: Double
    let upper: Double
    /// Grid-line values from `lower` to `upper`, lowest first.
    let ticks: [Double]

    private static let steps: [Double] = [0.5, 1, 2.5, 5, 10, 20, 25, 50, 100, 250, 500, 1000]

    init(values: [Double]) {
        let smallest = values.min() ?? 0
        let largest = values.max() ?? 0
        let span = largest - smallest
        let step = Self.steps.first { span / $0 <= 4 } ?? 1000

        // One step under the smallest value, but never below zero.
        let lower = max(0, (smallest / step).rounded(.down) * step - step)
        // At least one step above the bottom, so a flat run of equal
        // values still has a scale to sit on.
        let upper = max((largest / step).rounded(.up) * step, lower + step)

        self.lower = lower
        self.upper = upper
        ticks = Array(stride(from: lower, through: upper, by: step))
    }

    /// How far up the scale a value sits: 0 at the bottom, 1 at the top.
    func share(of value: Double) -> Double {
        guard upper > lower else { return 0 }
        return min(1, max(0, (value - lower) / (upper - lower)))
    }
}
