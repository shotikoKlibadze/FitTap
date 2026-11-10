import SwiftUI

/// Page indicator showing a window of seven slots — three behind the current
/// page, the current one in the middle, three ahead. The dots belong to
/// pages, so moving between pages slides the row: the current dot grows into
/// the centre slot
/// while its neighbours shrink and fade with distance, and pages past the
/// window fade out at its edges.
///
/// Give it a whole page (`current`) and each change slides there with an
/// animation, or a fractional `position` read from a scroll view (2.4 while
/// swiping from page 2 to 3) and the dots follow the finger.
public struct PageDots: View {
    let count: Int
    let position: Double
    let animated: Bool

    /// Snaps to whole pages, sliding there on each change.
    public init(count: Int, current: Int) {
        self.count = count
        position = Double(current)
        animated = true
    }

    /// Follows a fractional page continuously — no animation of its own.
    public init(count: Int, position: Double) {
        self.count = count
        self.position = position
        animated = false
    }

    private let dotSize: CGFloat = 7
    /// Centre to centre.
    private let step: CGFloat = 16
    /// Slots on each side of the current page.
    private let ahead = 3.0
    private let behind = 3.0

    public var body: some View {
        ZStack {
            ForEach(pages, id: \.self) { page in
                let distance = Double(page) - position
                Circle()
                    .fill(FTColors.textSecondary)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(scale(abs(distance)))
                    .opacity(opacity(distance))
                    // The current page sits dead centre.
                    .offset(x: distance * step)
            }
        }
        .frame(width: step * 7, height: dotSize)
        .animation(animated ? .smooth(duration: 0.3) : nil, value: position)
    }

    /// The pages near enough to the window to be drawn (fading at the edges).
    private var pages: [Int] {
        guard count > 0 else { return [] }
        let low = max(0, Int((position - behind - 1).rounded(.down)))
        let high = min(count - 1, Int((position + ahead + 1).rounded(.up)))
        return low <= high ? Array(low...high) : []
    }

    /// 1.15 on the current page, easing to 0.8, 0.55 and 0.4 a page apart.
    private func scale(_ distance: Double) -> CGFloat {
        CGFloat(interpolate(distance, [1.15, 0.8, 0.55, 0.4]))
    }

    /// 0.85 on the current page, easing to 0.3, 0.12 and 0.06; outside the
    /// window it fades to nothing over one page.
    private func opacity(_ distance: Double) -> Double {
        let base = interpolate(abs(distance), [0.85, 0.3, 0.12, 0.06])
        let edge: Double = if distance > ahead {
            max(0, 1 - (distance - ahead))
        } else if distance < -behind {
            max(0, 1 + (distance + behind))
        } else {
            1
        }
        return base * edge
    }

    /// Linear between whole-page values; past the last, the last.
    private func interpolate(_ distance: Double, _ values: [Double]) -> Double {
        let index = Int(distance.rounded(.down))
        guard index < values.count - 1 else { return values[values.count - 1] }
        let fraction = distance - Double(index)
        return values[index] + (values[index + 1] - values[index]) * fraction
    }
}

#if DEBUG
private struct PageDotsPreviewHost: View {
    @State private var current = 3
    @State private var position = 3.0
    private let count = 8

    var body: some View {
        VStack(spacing: 24) {
            PageDots(count: count, current: current)
            PageDots(count: count, position: position)
            Slider(value: $position, in: 0...Double(count - 1))
                .padding(.horizontal, 40)
            HStack {
                Button("Previous") { current = max(0, current - 1) }
                Button("Next") { current = min(count - 1, current + 1) }
            }
            .font(FTFonts.body)
            .foregroundStyle(FTColors.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    PageDotsPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    PageDotsPreviewHost()
        .preferredColorScheme(.light)
}
#endif
