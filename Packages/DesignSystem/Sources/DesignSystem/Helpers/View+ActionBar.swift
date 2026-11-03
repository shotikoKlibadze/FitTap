import SwiftUI

public extension View {
    /// Pins a screen's primary action to the bottom edge over a fade, so
    /// content scrolling beneath dissolves instead of running sharp past the
    /// button. The content is inset above the bar, so a list's last row
    /// clears it. Simplest version of Guile's `bottomActionBar`.
    ///
    /// ```swift
    /// .bottomActionBar {
    ///     GlassPillButton(title: "Create workout", action: create)
    /// }
    /// ```
    func bottomActionBar(@ViewBuilder content: () -> some View) -> some View {
        modifier(BottomActionBarModifier(bar: content()))
    }
}

private struct BottomActionBarModifier<Bar: View>: ViewModifier {
    let bar: Bar

    /// A dimmed overlay inside is up (`hidesEdgeFades`): the fade steps aside
    /// so it doesn't sit undimmed on top of the dim as a band.
    @State private var fadeHidden = false

    func body(content: Content) -> some View {
        content
            .onPreferenceChange(EdgeFadesHiddenKey.self) { hidden in
                MainActor.assumeIsolated {
                    withAnimation(.smooth(duration: 0.3)) { fadeHidden = hidden }
                }
            }
            .safeAreaInset(edge: .bottom) {
                bar
                    .padding(.horizontal, 16)
                    .background {
                        // Runs down past the home indicator so nothing shows below the button.
                        FTGradients.fadeBottom
                            .ignoresSafeArea(edges: .bottom)
                            .opacity(fadeHidden ? 0 : 1)
                            .allowsHitTesting(false)
                    }
            }
    }
}

#if DEBUG
private struct BottomActionBarPreviewHost: View {
    @State private var tapCount = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<20, id: \.self) { index in
                    Text("Row \(index)")
                        .font(FTFonts.body)
                        .foregroundStyle(FTColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(RoundedRectangle(cornerRadius: 16).fill(FTColors.surface))
                }
            }
            .padding()
        }
        .bottomActionBar {
            GlassPillButton(title: "Taps: \(tapCount)") { tapCount += 1 }
        }
        .background(FTColors.background)
    }
}

#Preview("Light") {
    BottomActionBarPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    BottomActionBarPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
