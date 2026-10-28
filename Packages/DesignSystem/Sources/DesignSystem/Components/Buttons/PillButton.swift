import SwiftUI

/// Full-width pill button with a flat fill — for actions inside sheets,
/// alerts and cards, where glass would sit on glass. On the screen itself,
/// over scrolling content, use `GlassPillButton`. A new look is a new
/// `PillStyle` case, never a restyled copy of this button.
public struct PillButton: View {
    let title: String
    let style: PillStyle
    let size: PillButtonSize
    let disabled: Bool
    let action: () -> Void

    public init(
        title: String,
        style: PillStyle = .primary,
        size: PillButtonSize = .regular,
        disabled: Bool = false,
        action: @escaping () -> Void,
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.disabled = disabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundStyle(disabled ? FTColors.textSecondary : style.text)
                .frame(maxWidth: .infinity)
                .frame(height: size.height)
                // Disabled, every style falls back to the quiet surface.
                .background(Capsule().fill(disabled ? FTColors.surfaceSecondary : style.fill))
                .contentShape(Capsule())
        }
        .buttonStyle(.press)
        .disabled(disabled)
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
            PillButton(title: "Save", disabled: isDisabled) { tapCount += 1 }
            PillButton(title: "Cancel", style: .secondary, disabled: isDisabled) { tapCount += 1 }
            PillButton(title: "Discard", style: .destructive, disabled: isDisabled) { tapCount += 1 }
            PillButton(title: "+ Add Set", style: .add, size: .compact, disabled: isDisabled) { tapCount += 1 }
            PillButton(title: isDisabled ? "Enable them" : "Disable them", style: .secondary) { isDisabled.toggle() }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.surface)
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
