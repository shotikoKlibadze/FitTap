import SwiftUI

/// One option of a rating row — "Easy", "Medium", "Hard" — drawn in its own
/// colour. Unchosen, it's an outline: colour text inside a softened colour
/// border, on nothing. Chosen, it fills solid with that colour and the text
/// flips to `textOnAccent`, so the pick reads at a glance from across the gym.
///
/// The colour is the option's meaning (green easy, yellow medium, red hard),
/// so it comes from the caller as an accent token — `greenAccent`,
/// `yellowFill`, `redAccent`. The softer border is derived from it here,
/// because it's one recipe for any accent rather than a colour of its own.
public struct RatingPill: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    public init(title: String, color: Color, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }

    public static let height: CGFloat = 30

    /// The outline of an unchosen pill: present, but quieter than its text.
    private let restingBorderAlpha = 0.55

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(FTFonts.footnoteSemibold)
                .foregroundStyle(isSelected ? FTColors.textOnAccent : color)
                .lineLimit(1)
                .padding(.horizontal, 13)
                .frame(height: Self.height)
                .background(Capsule().fill(isSelected ? color : .clear))
                .overlay(
                    Capsule().strokeBorder(color.opacity(isSelected ? 1 : restingBorderAlpha), lineWidth: 1),
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.press)
        .animation(.smooth(duration: 0.2), value: isSelected)
    }
}

#if DEBUG
private struct RatingPillPreviewHost: View {
    @State private var selected: String?

    private let options: [(String, Color)] = [
        ("Easy", FTColors.greenAccent),
        ("Medium", FTColors.yellowFill),
        ("Hard", FTColors.redAccent),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.0) { title, color in
                RatingPill(title: title, color: color, isSelected: selected == title) {
                    selected = selected == title ? nil : title
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    RatingPillPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    RatingPillPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
