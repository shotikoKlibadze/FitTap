import SwiftUI

/// Full-width Liquid Glass pill, tinted with its `PillStyle` color — for a
/// screen's own actions, pinned over scrolling content (Start Workout, Save).
/// Inside sheets, alerts and cards use the flat `PillButton`.
public struct GlassPillButton: View {
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
                .glassEffect(.regular.tint(style.fill.opacity(tintStrength)), in: .capsule)
                .contentShape(Capsule())
        }
        .buttonStyle(.press)
        .disabled(disabled)
    }

    /// How much of the color the glass shows. Green and red are toned down a
    /// little; the secondary surface is already faint, so it shows in full.
    private var tintStrength: Double {
        if disabled { return 0.25 }
        switch style {
        case .primary, .destructive: return 0.8
        case .secondary, .add: return 1
        }
    }
}

#if DEBUG
private struct GlassPillButtonPreviewHost: View {
    @State private var tapCount = 0
    @State private var isDisabled = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Taps: \(tapCount)")
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textSecondary)
            GlassPillButton(title: "Create workout", disabled: isDisabled) { tapCount += 1 }
            GlassPillButton(title: "Discard", style: .destructive, disabled: isDisabled) { tapCount += 1 }
            HStack(spacing: 10) {
                GlassPillButton(title: "Plan", style: .secondary, disabled: isDisabled) { tapCount += 1 }
                    .frame(width: 112)
                GlassPillButton(title: "Start Workout", style: .destructive, disabled: isDisabled) { tapCount += 1 }
            }
            GlassPillButton(title: isDisabled ? "Enable them" : "Disable them", style: .secondary) { isDisabled.toggle() }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    GlassPillButtonPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    GlassPillButtonPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
