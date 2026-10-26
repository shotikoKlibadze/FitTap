import SwiftUI

/// Round magic-wand button that opens a suggestion — "time to add weight",
/// "drop the weight, raise the reps". AI-gold wand and ring on the AI-gold
/// surface.
public struct SuggestionButton: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public static let size: CGFloat = 32

    public var body: some View {
        Button(action: action) {
            FTIcons.wandAndSparkles
                .font(FTFonts.footnoteSemibold)
                .foregroundStyle(FTColors.aiGold)
                .frame(width: Self.size, height: Self.size)
                .background(Circle().fill(FTColors.aiGoldSurface))
                .overlay(Circle().strokeBorder(FTColors.aiGold, lineWidth: 1.5))
                .contentShape(Circle())
        }
        .buttonStyle(.press)
    }
}

#if DEBUG
private struct SuggestionButtonPreviewHost: View {
    @State private var taps = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Taps: \(taps)")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
            SuggestionButton { taps += 1 }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.surface)
    }
}

#Preview("Light") {
    SuggestionButtonPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SuggestionButtonPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
