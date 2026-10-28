import SwiftUI

/// A glass pill that morphs into a glass card holding `content` — one Liquid
/// Glass shape changing size, not two views crossfading.
///
/// Collapsed it looks like a `.secondary` `GlassPillButton` of
/// `collapsedWidth`; tapped, it opens. Expanded it takes the width it's
/// offered and grows from its anchor, so place it in an overlay pinned to the
/// corner it should grow from, over a slot of `collapsedWidth` that holds its
/// place in the layout:
///
/// ```swift
/// HStack { Color.clear.frame(width: 112, height: 54); GlassPillButton(…) }
///     .overlay(alignment: .bottomLeading) {
///         GlassExpander(title: "Plan", isExpanded: $isPlanning, collapsedWidth: 112) { … }
///     }
/// ```
///
/// The owner closes it — set `isExpanded` to false inside `withAnimation`.
public struct GlassExpander<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    let collapsedWidth: CGFloat
    let content: Content

    public init(
        title: String,
        isExpanded: Binding<Bool>,
        collapsedWidth: CGFloat,
        @ViewBuilder content: () -> Content,
    ) {
        self.title = title
        _isExpanded = isExpanded
        self.collapsedWidth = collapsedWidth
        self.content = content()
    }

    @Namespace private var glass
    private let glassID = "expander"
    private let cardShape = RoundedRectangle(cornerRadius: 32, style: .continuous)

    public var body: some View {
        GlassEffectContainer {
            if isExpanded {
                content
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.regular.tint(FTColors.surfaceSecondary), in: cardShape)
                    .glassEffectID(glassID, in: glass)
            } else {
                Button(action: expand) {
                    Text(title)
                        .font(PillButtonSize.regular.font)
                        .foregroundStyle(FTColors.textPrimary)
                        .frame(width: collapsedWidth, height: PillButtonSize.regular.height)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(FTColors.surface).interactive(), in: .capsule)
                .glassEffectID(glassID, in: glass)
            }
        }
    }

    /// A touch of bounce opening; the owner closes with a smooth curve.
    private func expand() {
        withAnimation(.bouncy(duration: 0.45, extraBounce: 0.05)) { isExpanded = true }
    }
}

#if DEBUG
private struct GlassExpanderPreviewHost: View {
    @State private var isExpanded = false
    @State private var picked = "Nothing yet"

    private let slotWidth: CGFloat = 112

    var body: some View {
        VStack {
            Text(picked)
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textSecondary)
            Spacer()
            HStack(spacing: 10) {
                Color.clear.frame(width: slotWidth, height: PillButtonSize.regular.height)
                GlassPillButton(title: "Start Workout", style: .destructive) {}
            }
            .overlay(alignment: .bottomLeading) {
                GlassExpander(title: "Plan", isExpanded: $isExpanded, collapsedWidth: slotWidth) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Plan Push Day")
                            .font(FTFonts.title3Semibold)
                            .foregroundStyle(FTColors.textPrimary)
                        PillButton(title: "Tomorrow") { close("Tomorrow") }
                        PillButton(title: "Cancel", style: .secondary) { close("Cancelled") }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }

    private func close(_ result: String) {
        picked = result
        withAnimation(.smooth(duration: 0.35)) { isExpanded = false }
    }
}

#Preview("Light") {
    GlassExpanderPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    GlassExpanderPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
