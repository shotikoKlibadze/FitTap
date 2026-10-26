import SwiftUI

/// Press feedback for tappable surfaces: a slight grow while pressed.
/// Use as `.buttonStyle(.press)`.
public struct PressButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.smooth(duration: 0.2), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == PressButtonStyle {
    static var press: PressButtonStyle { PressButtonStyle() }
}

#if DEBUG
private struct PressButtonStylePreviewHost: View {
    @State private var tapCount = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Taps: \(tapCount)")
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textSecondary)
            Button {
                tapCount += 1
            } label: {
                Text("Press me")
                    .font(FTFonts.headline)
                    .foregroundStyle(FTColors.textPrimary)
                    .frame(width: 180, height: 54)
                    .background(RoundedRectangle(cornerRadius: 27).fill(FTColors.surface))
            }
            .buttonStyle(.press)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}
#Preview("Light") {
    PressButtonStylePreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    PressButtonStylePreviewHost()
        .preferredColorScheme(.dark)
}
#endif
