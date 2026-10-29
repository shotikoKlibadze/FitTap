import SwiftUI

/// Full-width pill filled edge to edge with a shifting mesh of its `tint`
/// — for the one action that should feel alive (Start Workout, in the
/// workout's color). Not glass: a mesh under glass fights the tint. Flat
/// elsewhere, `PillButton`; over content, `GlassPillButton`.
///
/// Two soft white strokes blend over the edge for the sheen. The mesh moves
/// by toggling two sets of points and colors on `repeatForever` animations —
/// a quick one and a slow one layered, so it never settles into a visible
/// loop. Core Animation drives it: no timer, nothing per frame on our side.
/// Under Reduce Motion the mesh holds still.
public struct MeshPillButton: View {
    let title: String
    let tint: Color
    let size: PillButtonSize
    let disabled: Bool
    let action: () -> Void

    public init(
        title: String,
        tint: Color,
        size: PillButtonSize = .regular,
        disabled: Bool = false,
        action: @escaping () -> Void,
    ) {
        self.title = title
        self.tint = tint
        self.size = size
        self.disabled = disabled
        self.action = action
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var quick = false
    @State private var slow = false

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundStyle(disabled ? FTColors.textSecondary : FTCoreColors.offWhite)
                .frame(maxWidth: .infinity)
                .frame(height: size.height)
                .background { fill }
                .clipShape(Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.press)
        .disabled(disabled)
        .onAppear(perform: startMoving)
    }

    /// The mesh across the whole pill; two thin white strokes along the
    /// edge catch the light.
    private var fill: some View {
        mesh
            .overlay {
                Capsule()
                    .stroke(FTCoreColors.offWhite, lineWidth: 3)
                    .blur(radius: 2)
                    .blendMode(.overlay)
            }
            .overlay {
                Capsule()
                    .stroke(FTCoreColors.offWhite, lineWidth: 1)
                    .blur(radius: 1)
                    .blendMode(.overlay)
            }
            .opacity(disabled ? 0.5 : 1)
    }

    private var mesh: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [quick ? 0.35 : 0.65, 0], [1, 0],
                [0, slow ? 0.3 : 0.7], quick ? [0.5, 0.5] : [0.8, 0.2], [1, quick ? 0.6 : 0.4],
                [0, 1], [slow ? 0.6 : 0.4, 1], [1, 1],
            ],
            colors: colors,
        )
    }

    /// The tint with a lit shade, a slightly deeper one and a warm accent —
    /// nothing near black, so the pill never shows dark pools. A few of them
    /// swap as the states flip.
    private var colors: [Color] {
        let base = tint
        let light = base.mix(with: .white, by: 0.45)
        let deep = base.mix(with: .black, by: 0.12)
        let warm = base.mix(with: FTColors.aiGold, by: 0.5)
        return [
            quick ? light : warm, base, deep,
            slow ? base : warm, quick ? deep : light, base,
            light, slow ? deep : base, quick ? warm : deep,
        ]
    }

    private func startMoving() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { quick.toggle() }
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { slow.toggle() }
    }
}

#if DEBUG
private struct MeshPillButtonPreviewHost: View {
    @State private var tapCount = 0
    @State private var isDisabled = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Taps: \(tapCount)")
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textSecondary)
            MeshPillButton(title: "Start Workout", tint: .pink, disabled: isDisabled) { tapCount += 1 }
            MeshPillButton(title: "Start Workout", tint: .mint, disabled: isDisabled) { tapCount += 1 }
            MeshPillButton(title: "Start Workout", tint: .purple, disabled: isDisabled) { tapCount += 1 }
            PillButton(title: isDisabled ? "Enable them" : "Disable them", style: .secondary) { isDisabled.toggle() }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    MeshPillButtonPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    MeshPillButtonPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
