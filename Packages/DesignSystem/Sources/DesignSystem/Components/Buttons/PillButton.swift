import SwiftUI

/// Full-width pill button. Colored pills are Liquid Glass with the color in
/// the glass tint; neutral pills are a flat secondary fill for quiet actions
/// on cards and sheets. A new color is a new `ButtonColor` case — never a
/// restyled copy of this button.
public struct PillButton: View {
    /// Semantic button colors; grows as needed.
    public enum ButtonColor {
        case green
        case red
        /// Quiet secondary action: flat fill, primary text.
        case neutral
        /// Quiet action with a highlight: flat fill, yellow text ("+ Add Set").
        case neutralYellow

        /// Glass tint; nil draws the flat neutral fill instead.
        public var tint: Color? {
            switch self {
            case .green: FTColors.green
            case .red: FTColors.red
            case .neutral, .neutralYellow: nil
            }
        }

        public var text: Color {
            switch self {
            // Green and red fills stay dark in both modes.
            case .green, .red: FTCoreColors.offWhite
            case .neutralYellow: FTColors.yellow
            case .neutral: FTColors.textPrimary
            }
        }
    }

    public enum Size {
        /// Primary actions — 54 pt.
        case regular
        /// Secondary actions inside dense content — 44 pt.
        case compact

        public var height: CGFloat {
            switch self {
            case .regular: 54
            case .compact: 44
            }
        }

        public var font: Font {
            switch self {
            case .regular: FTFonts.headline
            case .compact: FTFonts.subheadlineSemibold
            }
        }
    }

    let title: String
    var color: ButtonColor = .green
    var size: Size = .regular
    var disabled = false
    let action: () -> Void

    public init(
        title: String,
        color: ButtonColor = .green,
        size: Size = .regular,
        disabled: Bool = false,
        action: @escaping () -> Void,
    ) {
        self.title = title
        self.color = color
        self.size = size
        self.disabled = disabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundStyle(disabled ? FTColors.textSecondary : color.text)
                .frame(maxWidth: .infinity)
                .frame(height: size.height)
                .modifier(PillChrome(tint: color.tint, disabled: disabled))
                .contentShape(Capsule())
        }
        .buttonStyle(.press)
        .disabled(disabled)
    }
}

private struct PillChrome: ViewModifier {
    let tint: Color?
    let disabled: Bool

    func body(content: Content) -> some View {
        if let tint {
            content.glassEffect(.regular.tint(tint.opacity(disabled ? 0.25 : 0.8)), in: .capsule)
        } else {
            content.background(Capsule().fill(FTColors.secondary))
        }
    }
}

#if DEBUG
private struct PillButtonPreviewHost: View {
    @State private var tapCount = 0
    @State private var isDisabled = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Taps: \(tapCount)")
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textSecondary)
            PillButton(title: "Create workout", disabled: isDisabled) { tapCount += 1 }
            PillButton(title: "Start Workout", color: .red, disabled: isDisabled) { tapCount += 1 }
            PillButton(title: "Keep Editing", color: .neutral, disabled: isDisabled) { tapCount += 1 }
            PillButton(title: "+ Add Set", color: .neutralYellow, size: .compact, disabled: isDisabled) { tapCount += 1 }
            PillButton(title: isDisabled ? "Enable them" : "Disable them") { isDisabled.toggle() }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}
#Preview("Light") {
    PillButtonPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    PillButtonPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
