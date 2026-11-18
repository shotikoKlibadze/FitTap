import DesignSystem
import SwiftUI

/// One dot per onboarding page; the current one is lit.
struct OnboardingPageDots: View {
    let count: Int
    let current: Int

    private let dotSize: CGFloat = 6

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == current ? FTColors.textPrimary : FTColors.separator)
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .animation(.smooth(duration: 0.25), value: current)
        .accessibilityElement()
        .accessibilityLabel("Page \(current + 1) of \(count)")
    }
}

#if DEBUG
private struct OnboardingPageDotsPreviewHost: View {
    @State private var current = 0
    private let count = 7

    var body: some View {
        OnboardingPageDots(count: count, current: current)
            .padding(40)
            .contentShape(Rectangle())
            // Tap to step through the pages.
            .onTapGesture { current = (current + 1) % count }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Dark") {
    OnboardingPageDotsPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    OnboardingPageDotsPreviewHost()
        .preferredColorScheme(.light)
}
#endif
