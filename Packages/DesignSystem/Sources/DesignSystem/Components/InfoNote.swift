import SwiftUI

/// A quiet line of small gray text that ends in an underlined link, for
/// something the user may want to know but doesn't have to act on: "This
/// is a standard suggestion. More info".
///
/// It sits above or below the thing it explains and never competes with
/// it: no icon, no colour, no surface. The whole line is tappable, not
/// only the underlined words, so a thumb doesn't have to aim at two short
/// words in small type.
public struct InfoNote: View {
    let message: String
    let linkTitle: String
    let action: () -> Void

    public init(message: String, linkTitle: String = "More info", action: @escaping () -> Void) {
        self.message = message
        self.linkTitle = linkTitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text("\(message) \(Text(linkTitle).underline())")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
        }
        .buttonStyle(.press)
    }
}

#if DEBUG
private struct InfoNotePreviewHost: View {
    @State private var taps = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoNote(message: "Turn on Apple Intelligence for suggestions written for you.") { taps += 1 }
            InfoNote(
                message: "Apple Intelligence is still getting ready on this iPhone, so this is a standard suggestion for now.",
                linkTitle: "What does that mean?",
            ) { taps += 1 }
            Text("\(taps) taps")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    InfoNotePreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    InfoNotePreviewHost()
        .preferredColorScheme(.light)
}
#endif
