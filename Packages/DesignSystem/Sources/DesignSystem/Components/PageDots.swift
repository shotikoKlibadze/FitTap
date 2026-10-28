import SwiftUI

/// Page indicator with six slots — three behind the current page, the current
/// one, two ahead. Dots shrink and fade with distance from the current page;
/// slots past either end stay invisible so the current dot never shifts.
public struct PageDots: View {
    let count: Int
    let current: Int

    public init(count: Int, current: Int) {
        self.count = count
        self.current = current
    }

    private static let offsets = -3...2
    private let dotSize: CGFloat = 7

    public var body: some View {
        HStack(spacing: 9) {
            ForEach(Self.offsets, id: \.self) { offset in
                let page = current + offset
                let distance = abs(offset)
                Circle()
                    .fill(FTColors.textSecondary)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(scale(forDistance: distance))
                    .opacity((0..<count).contains(page) ? opacity(forDistance: distance) : 0)
            }
        }
        .animation(.smooth(duration: 0.25), value: current)
    }

    private func scale(forDistance distance: Int) -> CGFloat {
        switch distance {
        case 0: 1.15
        case 1: 0.8
        case 2: 0.55
        default: 0.4
        }
    }

    private func opacity(forDistance distance: Int) -> Double {
        switch distance {
        case 0: 0.85
        case 1: 0.3
        case 2: 0.12
        default: 0.06
        }
    }
}

#if DEBUG
private struct PageDotsPreviewHost: View {
    @State private var current = 3
    private let count = 8

    var body: some View {
        VStack(spacing: 24) {
            PageDots(count: count, current: current)
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

#Preview("Light") {
    PageDotsPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    PageDotsPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
