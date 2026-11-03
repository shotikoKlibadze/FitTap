import SwiftUI

/// A bare text action — "See All" beside a section title, a quiet link at
/// the end of a card. Green text, nothing around it, a press dims it. The
/// whole label is tappable, with a little room past the glyphs so a thumb
/// lands.
public struct TextButton: View {
    let title: String
    let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(FTFonts.subheadlineSemibold)
                .foregroundStyle(FTColors.greenAccent)
                .padding(.vertical, 6)
                .padding(.horizontal, 4)
                .contentShape(Rectangle())
        }
        .buttonStyle(.press)
    }
}

#if DEBUG
private struct TextButtonPreviewHost: View {
    @State private var taps = 0

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                SectionHeader(title: "Progression")
                Spacer()
                TextButton(title: "See All") { taps += 1 }
            }
            TextButton(title: "Show more") { taps += 1 }
            Text("\(taps) taps")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    TextButtonPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    TextButtonPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
