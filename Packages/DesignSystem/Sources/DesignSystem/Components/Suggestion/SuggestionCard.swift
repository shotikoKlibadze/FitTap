import SwiftUI

/// Something the app noticed, said plainly: a gold ⓘ on the left and a short
/// title ("Legs are falling behind") with a sentence or two under it. Gold is
/// the colour of anything the app says on its own; nothing else on the card
/// is coloured.
///
/// With an `action` the card is a button and shows a chevron, since it opens
/// the full suggestion. Without one it is plain text: no chevron, no tap.
public struct SuggestionCard: View {
    let title: String
    let message: String
    let action: (() -> Void)?

    public init(title: String, message: String, action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.action = action
    }

    private let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    public var body: some View {
        if let action {
            Button(action: action) {
                SuggestionCardContent(title: title, message: message, showsChevron: true)
                    .contentShape(shape)
            }
            .buttonStyle(.press)
            .elevatedSurface(in: shape)
        } else {
            SuggestionCardContent(title: title, message: message, showsChevron: false)
                .elevatedSurface(in: shape)
        }
    }
}

/// The card's inside, shared by its tappable and plain forms.
private struct SuggestionCardContent: View {
    let title: String
    let message: String
    let showsChevron: Bool

    var body: some View {
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
            if showsChevron {
                FTIcons.chevronRight
                    .font(FTFonts.caption2Semibold)
                    .foregroundStyle(FTColors.textSecondary)
                    .padding(.top, 4)
            }
        }
        .padding(16)
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
            SuggestionCard(
                title: "Stay at this weight",
                message: "No action: plain text, no chevron.",
            )
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
