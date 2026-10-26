import SwiftUI

/// Round 40pt icon button. The icon picks the glyph, the style picks the
/// chrome (solid circle or Liquid Glass); the caller decides what the tap
/// means and can tint the icon and background.
public struct RoundButton: View {
    public enum Icon {
        case back
        case close
        case confirm
        case add

        public var image: Image {
            switch self {
            case .back: FTIcons.caretLeft
            case .close: FTIcons.xMark
            case .confirm: FTIcons.check
            case .add: FTIcons.plus
            }
        }
    }

    public enum Style {
        case normal
        case glass
    }

    public enum Size {
        /// 40 pt — toolbar-sized actions.
        case regular
        /// 22 pt — inline actions inside a field, like clearing it.
        case small

        public var diameter: CGFloat {
            switch self {
            case .regular: 40
            case .small: 22
            }
        }

        public var glyph: CGFloat {
            switch self {
            case .regular: 16
            case .small: 8
            }
        }
    }

    let icon: Icon
    var style: Style = .glass
    var size: Size = .regular
    var iconColor: Color = FTColors.textPrimary
    var backgroundColor: Color = FTColors.surface
    let action: () -> Void

    public init(
        icon: Icon,
        style: Style = .glass,
        size: Size = .regular,
        iconColor: Color = FTColors.textPrimary,
        backgroundColor: Color = FTColors.surface,
        action: @escaping () -> Void,
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            icon.image
                .resizable()
                .scaledToFit()
                .frame(width: size.glyph, height: size.glyph)
                .foregroundStyle(iconColor)
                .frame(width: size.diameter, height: size.diameter)
                // Chrome lives inside the label so the press scale moves the
                // whole circle, not just the glyph.
                .modifier(RoundButtonChrome(style: style, backgroundColor: backgroundColor))
                .contentShape(Circle())
        }
        .buttonStyle(.press)
    }
}

private struct RoundButtonChrome: ViewModifier {
    let style: RoundButton.Style
    let backgroundColor: Color

    func body(content: Content) -> some View {
        switch style {
        case .normal:
            content.background(Circle().fill(backgroundColor))
        case .glass:
            content.glassEffect(.regular.interactive())
        }
    }
}

#if DEBUG
private struct RoundButtonPreviewHost: View {
    @State private var tapped = "—"

    var body: some View {
        VStack(spacing: 24) {
            Text("Tapped: \(tapped)")
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textSecondary)
            HStack(spacing: 16) {
                RoundButton(icon: .back) { tapped = "back" }
                RoundButton(icon: .close) { tapped = "close" }
                RoundButton(icon: .confirm) { tapped = "confirm" }
                RoundButton(icon: .add) { tapped = "add" }
            }
            HStack(spacing: 16) {
                RoundButton(icon: .close, style: .normal, iconColor: FTColors.textSecondary) { tapped = "close normal" }
                RoundButton(icon: .add, style: .normal, iconColor: FTColors.yellow) { tapped = "add normal" }
                RoundButton(
                    icon: .close,
                    style: .normal,
                    size: .small,
                    iconColor: FTColors.surface,
                    backgroundColor: FTColors.textSecondary,
                ) { tapped = "close small" }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}
#Preview("Light") {
    RoundButtonPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    RoundButtonPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
