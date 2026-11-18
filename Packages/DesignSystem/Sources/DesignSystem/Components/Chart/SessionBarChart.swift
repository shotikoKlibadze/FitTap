import SwiftUI

/// An exercise's recent sessions as bars, oldest on the left: how tall a
/// bar is says how heavy (or long, or many) that session was, and its
/// colour says how it went: solid green when every set was finished,
/// hollow red when one failed. The days sit under the bars, the scale's
/// numbers down the right side, and the legend at the bottom.
///
/// It shows at most the newest fourteen bars and never scrolls: the point
/// is the trend at a glance, and a list of every session lives elsewhere.
/// How it lays them out depends on how many there are:
///
/// - Up to seven: wide bars in seven fixed places, filled from the left,
///   each with its day under it. Three sessions are three wide bars and
///   empty room to their right, not three bars stretched across the card.
/// - Eight to fourteen: the bars share the width and get thinner, and
///   only four days are written, spread from first to last.
///
/// The scale is `SessionBarScale`: it starts a step under the smallest
/// bar, not at zero, so small changes are easy to see.
public struct SessionBarChart: View {
    /// The most bars ever drawn; older ones are left out.
    public static let maximumBars = 14

    let bars: [SessionBar]
    let valueLabel: (Double) -> String

    /// Measured once the chart is on screen; the bars and the grid are
    /// placed from it.
    @State private var width: CGFloat = 0

    /// - Parameters:
    ///   - bars: the sessions, oldest first. Only the newest fourteen show.
    ///   - valueLabel: how a number on the scale is written. The default
    ///     drops a trailing ".0": 20, 22.5.
    public init(
        bars: [SessionBar],
        valueLabel: @escaping (Double) -> String = { $0.formatted(.number.precision(.fractionLength(0...1))) },
    ) {
        self.bars = bars
        self.valueLabel = valueLabel
    }

    /// Bars up to this count keep the wide layout.
    private let wideSlots = 7
    private let plotHeight: CGFloat = 132
    /// Room above the top grid line and below the bottom one, so their
    /// numbers aren't cut in half.
    private let plotInset: CGFloat = 8
    private let axisWidth: CGFloat = 34
    private let axisGap: CGFloat = 8

    private var shown: [SessionBar] {
        Array(bars.suffix(Self.maximumBars))
    }

    private var scale: SessionBarScale {
        SessionBarScale(values: shown.map(\.value))
    }

    /// The width one bar's place gets: the room left of the scale's
    /// numbers, split into seven places or, past seven bars, one per bar.
    private var slotWidth: CGFloat {
        let slots = max(shown.count, wideSlots)
        return max(0, (width - axisWidth - axisGap) / CGFloat(slots))
    }

    /// Which bars get their day written under them: all of them while
    /// they are wide, otherwise four spread evenly from first to last.
    private var labelledIndices: Set<Int> {
        guard shown.count > wideSlots else { return Set(shown.indices) }
        let last = Double(shown.count - 1)
        return Set((0...3).map { Int((Double($0) * last / 3).rounded()) })
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .bottomLeading) {
                    SessionBarChartGrid(
                        scale: scale,
                        valueLabel: valueLabel,
                        width: width,
                        height: plotHeight,
                        inset: plotInset,
                        axisWidth: axisWidth,
                        axisGap: axisGap,
                    )
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(shown) { bar in
                            SessionBarChartBar(
                                bar: bar,
                                height: max(4, scale.share(of: bar.value) * (plotHeight - plotInset * 2)),
                                valueText: valueLabel(bar.value),
                            )
                            .frame(width: slotWidth)
                        }
                    }
                    .padding(.bottom, plotInset)
                }
                .frame(height: plotHeight)

                HStack(spacing: 0) {
                    ForEach(Array(shown.enumerated()), id: \.element.id) { index, bar in
                        Text(labelledIndices.contains(index) ? bar.label : "")
                            .font(FTFonts.caption2)
                            .foregroundStyle(FTColors.textSecondary)
                            .fixedSize()
                            .frame(width: slotWidth)
                    }
                }
                .accessibilityHidden(true)
            }
            HStack(spacing: 16) {
                SessionBarLegendItem(kind: .clean, title: "Clean")
                SessionBarLegendItem(kind: .failed, title: "Failed a set")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newWidth in
            width = newWidth
        }
    }
}

/// One entry of the legend: the bar's swatch and what it means.
private struct SessionBarLegendItem: View {
    let kind: SessionBar.Kind
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            SessionBarSwatch(kind: kind)
            Text(title)
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
    }
}

/// The grid behind the bars: one faint line per number on the scale, with
/// the number at its right end.
private struct SessionBarChartGrid: View {
    let scale: SessionBarScale
    let valueLabel: (Double) -> String
    let width: CGFloat
    let height: CGFloat
    let inset: CGFloat
    let axisWidth: CGFloat
    let axisGap: CGFloat

    var body: some View {
        ZStack {
            ForEach(scale.ticks, id: \.self) { tick in
                HStack(spacing: axisGap) {
                    Rectangle()
                        .fill(FTColors.divider)
                        .frame(height: 1)
                    Text(valueLabel(tick))
                        .font(FTFonts.caption2)
                        .foregroundStyle(FTColors.textSecondary)
                        .monospacedDigit()
                        .frame(width: axisWidth, alignment: .leading)
                }
                .position(
                    x: width / 2,
                    y: inset + (1 - scale.share(of: tick)) * (height - inset * 2),
                )
            }
        }
        .frame(width: width, height: height)
        .accessibilityHidden(true)
    }
}

/// One bar in its place, standing on the bottom grid line. It is at most
/// 28 pt wide and leaves a little room each side, so neighbours never
/// touch however thin the places get.
private struct SessionBarChartBar: View {
    let bar: SessionBar
    let height: CGFloat
    let valueText: String

    private var kindText: String {
        switch bar.kind {
        case .clean: "clean"
        case .failed: "failed a set"
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(SessionBarSwatch.fill(for: bar.kind))
            .strokeBorder(SessionBarSwatch.outline(for: bar.kind), lineWidth: 1.5)
            .frame(maxWidth: 28)
            .frame(height: height)
            .padding(.horizontal, 3)
            .accessibilityElement()
            .accessibilityLabel("\(bar.label), \(valueText), \(kindText)")
    }
}

#if DEBUG
private struct SessionBarChartPreviewHost: View {
    /// Tap the chart to step through 1, 3, 7 and 14 sessions.
    @State private var step = 3

    private let counts = [1, 3, 7, 14]

    var body: some View {
        VStack(spacing: 16) {
            SessionBarChart(bars: Array(SessionBar.samples.suffix(counts[step % counts.count])))
                .padding(16)
                .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .contentShape(Rectangle())
                .onTapGesture { step += 1 }
            Text("\(counts[step % counts.count]) sessions — tap the chart for the next count")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    SessionBarChartPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    SessionBarChartPreviewHost()
        .preferredColorScheme(.light)
}
#endif
