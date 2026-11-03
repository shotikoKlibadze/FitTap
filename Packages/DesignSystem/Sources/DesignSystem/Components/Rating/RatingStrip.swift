import SwiftUI

/// A small "How did it feel?" strip that hangs under a card like a tab: a
/// prompt on the left, one `RatingPill` per option on the right. One tap
/// picks an option, a second tap on the same one clears it, and a light tap
/// of haptics confirms a pick.
///
/// The strip stays neutral (the card's own `surface`) until something is
/// chosen; then it takes on that option's colour — a faint wash and a fine
/// edge — so the whole tab says "easy" or "hard", not just the pill.
///
/// It's meant to sit *behind* the card above it, with only its bottom corners
/// showing. The caller places it right under the card, lets the card draw on
/// top (a higher `zIndex`), pulls it up by `cardOverlap` and insets it by
/// `sideInset` on each side:
///
/// ```swift
/// VStack(spacing: 0) {
///     card.zIndex(1)
///     if isDone {
///         RatingStrip(prompt: "How did it feel?", options: options, selectedID: $rating)
///             .padding(.horizontal, RatingStrip.sideInset)
///             .padding(.top, -RatingStrip.cardOverlap)
///             .transition(.move(edge: .top))
///     }
/// }
/// ```
///
/// > Important: The strip's own top padding already includes `cardOverlap`,
/// > so its content starts 8 pt below the card's edge. Pull it up by exactly
/// > `cardOverlap`, or the prompt slides under the card.
public struct RatingStrip: View {
    /// One choice: a stable id (what the binding holds), its label, and its
    /// accent colour.
    public struct Option: Identifiable {
        public let id: String
        public let title: String
        public let color: Color

        public init(id: String, title: String, color: Color) {
            self.id = id
            self.title = title
            self.color = color
        }
    }

    let prompt: String
    let options: [Option]
    @Binding var selectedID: String?

    public init(prompt: String, options: [Option], selectedID: Binding<String?>) {
        self.prompt = prompt
        self.options = options
        _selectedID = selectedID
    }

    /// How far the strip tucks up behind the card above it — enough to hide
    /// its square top corners behind the card's rounded bottom ones.
    public static let cardOverlap: CGFloat = 14
    /// How much narrower than the card the strip is, on each side.
    public static let sideInset: CGFloat = 8

    private let shape = UnevenRoundedRectangle(
        bottomLeadingRadius: 18,
        bottomTrailingRadius: 18,
        style: .continuous,
    )
    /// The chosen option's wash over the strip, and its edge.
    private let washAlpha = 0.16
    private let edgeAlpha = 0.30

    private var selectedColor: Color? {
        options.first { $0.id == selectedID }?.color
    }

    public var body: some View {
        HStack(spacing: 8) {
            Text(prompt)
                .font(FTFonts.footnoteSemibold)
                .foregroundStyle(FTColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Spacer(minLength: 4)
            ForEach(options) { option in
                RatingPill(title: option.title, color: option.color, isSelected: option.id == selectedID) {
                    selectedID = selectedID == option.id ? nil : option.id
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, Self.cardOverlap + 8)
        .padding(.bottom, 8)
        .background {
            ZStack {
                shape.fill(FTColors.surface)
                if let selectedColor {
                    shape.fill(selectedColor.opacity(washAlpha))
                    shape.strokeBorder(selectedColor.opacity(edgeAlpha), lineWidth: 0.5)
                }
            }
        }
        .animation(.smooth(duration: 0.25), value: selectedID)
        .sensoryFeedback(.impact(weight: .light), trigger: selectedID) { _, new in new != nil }
    }
}

#if DEBUG
private struct RatingStripPreviewHost: View {
    @State private var isDone = true
    @State private var rating: String?

    private let options = [
        RatingStrip.Option(id: "easy", title: "Easy", color: FTColors.greenAccent),
        RatingStrip.Option(id: "medium", title: "Medium", color: FTColors.yellowFill),
        RatingStrip.Option(id: "hard", title: "Hard", color: FTColors.redAccent),
    ]

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 0) {
                Text("Bench Press")
                    .font(FTFonts.headlineSemibold)
                    .foregroundStyle(FTColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .frame(height: 140, alignment: .top)
                    .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .zIndex(1)
                if isDone {
                    RatingStrip(prompt: "How did it feel?", options: options, selectedID: $rating)
                        .padding(.horizontal, RatingStrip.sideInset)
                        .padding(.top, -RatingStrip.cardOverlap)
                        .transition(.move(edge: .top))
                }
            }
            PillButton(title: isDone ? "Uncheck a set" : "Check the last set", style: .secondary) {
                withAnimation(.spring(duration: 0.4)) { isDone.toggle() }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    RatingStripPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    RatingStripPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
