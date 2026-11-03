import SwiftUI

/// Something the app noticed, said plainly: a gold ⓘ on the left, a short
/// title ("Legs are falling behind") with a sentence or two under it, and a
/// chevron, since the card opens the full suggestion. Gold is the colour of
/// anything the app says on its own; nothing else on the card is coloured.
public struct SuggestionCard: View {
    let title: String
    let message: String
    let action: () -> Void

    public init(title: String, message: String, action: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.action = action
    }

    private let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    public var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                FTIcons.info
                    .font(FTFonts.title3)
                    .foregroundStyle(FTColors.aiGold)
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(FTFonts.subheadlineSemibold)
                        .foregroundStyle(FTColors.textPrimary)
                    Text(message)
                        .font(FTFonts.subheadline)
                        .foregroundStyle(FTColors.textSecondary)
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                FTIcons.chevronRight
                    .font(FTFonts.caption2Semibold)
                    .foregroundStyle(FTColors.textSecondary)
                    .padding(.top, 4)
            }
            .padding(16)
            .contentShape(shape)
        }
        .buttonStyle(.press)
        .elevatedSurface(in: shape)
    }
}

#if DEBUG
private struct SuggestionCardPreviewHost: View {
    @State private var taps = 0

    var body: some View {
        VStack(spacing: 12) {
            SuggestionCard(
                title: "Legs are falling behind",
                message: "1 session in 4 weeks against 7 upper-body sessions. Your usual is 10 sets a week.",
            ) { taps += 1 }
            SuggestionCard(
                title: "Back volume is up 30%",
                message: "Lat Pulldown and Cable Row both moved. Nothing to change here.",
            ) { taps += 1 }
            Text("\(taps) taps")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    SuggestionCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    SuggestionCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
