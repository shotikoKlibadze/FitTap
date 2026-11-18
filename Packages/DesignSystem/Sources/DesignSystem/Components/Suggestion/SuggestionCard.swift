import SwiftUI

/// Something the app noticed, said plainly: a gold ⓘ on the left and a short
/// title ("Legs are falling behind") with a sentence or two under it. Gold is
/// the colour of anything the app says on its own; nothing else on the card
/// is coloured.
///
/// With an `action` the card is a button and shows a chevron, since it opens
/// the full suggestion. Without one it is plain text: no chevron, no tap.
///
/// The text may change while the card is on screen, for instance when it is
/// written a few words at a time. Changes animate: new words fade in and the
/// card grows to fit.
///
/// While `isLoading` is true the text isn't there yet: a thicker bar stands
/// in for the title and two thinner ones for the message, each in a faint
/// wash of its text's colour. A band of light sweeps across them, the ⓘ
/// breathes, and the chevron is hidden. Each bar's row is exactly as tall as
/// the line it stands for, so the card keeps its place when the first words
/// arrive. A card that has loaded never gets shorter than that: a short
/// answer leaves it the same height, a long one makes it grow.
public struct SuggestionCard: View {
    let title: String
    let message: String
    let isLoading: Bool
    let action: (() -> Void)?

    /// - Parameter isLoading: true while the text is still on its way. The
    ///   title and message are ignored until it turns false.
    public init(title: String, message: String, isLoading: Bool = false, action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.isLoading = isLoading
        self.action = action
    }

    private let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    public var body: some View {
        if let action {
            Button(action: action) {
                SuggestionCardContent(title: title, message: message, isLoading: isLoading, showsChevron: true)
                    .contentShape(shape)
            }
            .buttonStyle(.press)
            .elevatedSurface(in: shape)
        } else {
            SuggestionCardContent(title: title, message: message, isLoading: isLoading, showsChevron: false)
                .elevatedSurface(in: shape)
        }
    }
}

/// The card's inside, shared by its tappable and plain forms.
private struct SuggestionCardContent: View {
    let title: String
    let message: String
    let isLoading: Bool
    let showsChevron: Bool

    /// Turns true the first time the card loads and stays true. From then
    /// on the text area keeps the height of the loading bars as its
    /// minimum, so a short answer can't make the card shrink; it can only
    /// grow. A card that never loads is left to fit its text.
    @State private var keepsLoadingHeight = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            FTIcons.info
                .font(FTFonts.title3)
                .foregroundStyle(FTColors.aiGold)
                .symbolEffect(.breathe, isActive: isLoading)
                .padding(.top, 1)
            ZStack(alignment: .topLeading) {
                if keepsLoadingHeight {
                    SuggestionCardLoadingHeight()
                }
                VStack(alignment: .leading, spacing: 4) {
                    if isLoading {
                        SuggestionCardPlaceholder()
                            .transition(.opacity)
                    } else {
                        Text(title)
                            .font(FTFonts.subheadlineSemibold)
                            .foregroundStyle(FTColors.textPrimary)
                        Text(message)
                            .font(FTFonts.subheadline)
                            .foregroundStyle(FTColors.textSecondary)
                    }
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: isLoading, initial: true) {
                if isLoading { keepsLoadingHeight = true }
            }
            // Text that is still being written arrives a few words at a
            // time: the words already there stay put and the new ones fade
            // in, instead of the whole line jumping.
            .contentTransition(.interpolate)
            .animation(.smooth(duration: 0.25), value: title)
            .animation(.smooth(duration: 0.25), value: message)
            // Nothing to open while the text is still on its way.
            if showsChevron, !isLoading {
                FTIcons.chevronRight
                    .font(FTFonts.caption2Semibold)
                    .foregroundStyle(FTColors.textSecondary)
                    .padding(.top, 4)
                    .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.25), value: isLoading)
        .padding(16)
    }
}

/// Invisible, and exactly as tall as the loading bars: a title line and
/// two message lines in the real fonts. Laid under the text, it stops the
/// text area from ever being shorter than the loading state was.
private struct SuggestionCardLoadingHeight: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(" ")
                .font(FTFonts.subheadlineSemibold)
            Text(" \n ")
                .font(FTFonts.subheadline)
        }
        .hidden()
    }
}

/// What a loading card shows where its text will be: a bar for the
/// title and two for the message, each in a faint wash of the colour its
/// text will have, with a band of light crossing them over and over.
///
/// The title's bar is thicker than the message's, the way the title's
/// type is heavier, so the two read as a title and a body even before
/// there is a word. One switch drives both groups, so the light crosses
/// them together. With Reduce Motion on the bars stay still.
private struct SuggestionCardPlaceholder: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSweeping = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SuggestionCardPlaceholderBars(
                font: FTFonts.subheadlineSemibold,
                widthShares: [0.45],
                heightShare: 0.72,
                fill: FTColors.textPrimaryPlaceholder,
                light: FTGradients.shimmer(of: FTColors.textPrimary),
                isSweeping: isSweeping && !reduceMotion,
            )
            SuggestionCardPlaceholderBars(
                font: FTFonts.subheadline,
                widthShares: [1, 0.65],
                heightShare: 0.5,
                fill: FTColors.textSecondaryPlaceholder,
                light: FTGradients.shimmer(of: FTColors.textSecondary),
                isSweeping: isSweeping && !reduceMotion,
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                isSweeping = true
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Writing a suggestion")
    }
}

/// One group of bars in one colour: the faint bars, and over them the
/// band of light cut to the bars' shape so only they light up.
///
/// The band is half the group's width. It rests off the left edge and,
/// when `isSweeping` turns true, slides to off the right edge.
private struct SuggestionCardPlaceholderBars: View {
    let font: Font
    /// One entry per bar: how much of the row's width it fills.
    let widthShares: [CGFloat]
    /// How much of a text line's height a bar fills.
    let heightShare: CGFloat
    let fill: Color
    let light: LinearGradient
    let isSweeping: Bool

    var body: some View {
        SuggestionCardPlaceholderLines(font: font, widthShares: widthShares, heightShare: heightShare)
            .foregroundStyle(fill)
            .overlay {
                GeometryReader { proxy in
                    light
                        .frame(width: proxy.size.width / 2)
                        .offset(x: isSweeping ? proxy.size.width : -proxy.size.width / 2)
                }
                .mask {
                    SuggestionCardPlaceholderLines(font: font, widthShares: widthShares, heightShare: heightShare)
                }
            }
    }
}

/// The bars themselves, drawn in whatever foreground style the caller
/// sets, so the same shape serves as the faint fill and as the cut-out
/// for the light.
private struct SuggestionCardPlaceholderLines: View {
    let font: Font
    let widthShares: [CGFloat]
    let heightShare: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(widthShares.indices, id: \.self) { index in
                SuggestionCardPlaceholderLine(font: font, widthShare: widthShares[index], heightShare: heightShare)
            }
        }
    }
}

/// One bar, standing in for one line of text.
///
/// A hidden one-character `Text` in the real font sets the height, so the
/// bar's row is exactly as tall as the line it stands for at any text size.
/// The bar fills `heightShare` of that height and `widthShare` of the row's
/// width.
private struct SuggestionCardPlaceholderLine: View {
    let font: Font
    let widthShare: CGFloat
    let heightShare: CGFloat

    var body: some View {
        Text(" ")
            .font(font)
            .hidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                GeometryReader { proxy in
                    Capsule()
                        .fill(.foreground)
                        .frame(width: proxy.size.width * widthShare, height: proxy.size.height * heightShare)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
            }
    }
}

#if DEBUG
private struct SuggestionCardPreviewHost: View {
    @State private var taps = 0

    private let growingWords = "Give it one or two more sessions before moving up, since one full session shows it can be done."
        .split(separator: " ")

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
            // Loading, then growing text: it shimmers until the first tap on
            // a card above, and every tap after that adds a few words.
            SuggestionCard(
                title: "Hold 32.5 kg",
                message: growingWords.prefix(min(taps * 3, growingWords.count)).joined(separator: " "),
                isLoading: taps == 0,
            )
            // Loading for good: the state on its own. It has an action, and
            // still shows no chevron until there is text.
            SuggestionCard(title: "", message: "", isLoading: true) { taps += 1 }
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
