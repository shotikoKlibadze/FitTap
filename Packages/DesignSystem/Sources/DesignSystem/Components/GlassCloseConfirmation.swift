import SwiftUI

/// A full-screen mode's close button that asks before leaving: the glass ✕
/// morphs, at its own corner, into a glass card with a title, a message and
/// flat pill actions — one Liquid Glass shape changing size. It looks like
/// `AppAlert` and takes the same `AppAlertAction`s.
///
/// The one exception to "every alert is a centered `AppAlert`": only a mode's
/// own close button gets this (see the design-system skill's alerts rules).
///
/// Collapsed it's 40 pt; place it in an overlay pinned to the corner it should
/// grow from, over a 40 pt slot that holds its place, and draw the dim behind
/// it while `isExpanded`. A tapped action collapses the card, then runs its
/// handler once the card has settled.
public struct GlassCloseConfirmation: View {
    @Binding var isExpanded: Bool
    let title: String
    let message: String
    let actions: [AppAlertAction]

    public init(isExpanded: Binding<Bool>, title: String, message: String, actions: [AppAlertAction]) {
        _isExpanded = isExpanded
        self.title = title
        self.message = message
        self.actions = actions
    }

    public static let collapsedSize: CGFloat = 40

    @Namespace private var glass
    private let glassID = "close"
    private let cardShape = RoundedRectangle(cornerRadius: 32, style: .continuous)

    public var body: some View {
        GlassEffectContainer {
            if isExpanded {
                card
                    .glassEffect(.regular, in: cardShape)
                    .glassEffectID(glassID, in: glass)
            } else {
                Button(action: expand) {
                    FTIcons.xMark
                        .resizable()
                        .scaledToFit()
                        // As `RoundButton(.close)`, so the two can stand in for each other.
                        .frame(width: 16, height: 16)
                        .foregroundStyle(FTColors.textPrimary)
                        .frame(width: Self.collapsedSize, height: Self.collapsedSize)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
                .glassEffectID(glassID, in: glass)
            }
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(FTFonts.title3Semibold)
                    .foregroundStyle(FTColors.textPrimary)
                Text(message)
                    .font(FTFonts.body)
                    .foregroundStyle(FTColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            VStack(spacing: 10) {
                ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                    PillButton(title: action.title, style: action.style) { choose(action) }
                }
            }
        }
        .padding(20)
        .frame(width: 300)
    }

    /// A touch of bounce opening; smooth closing.
    private func expand() {
        withAnimation(.bouncy(duration: 0.45, extraBounce: 0.05)) { isExpanded = true }
    }

    private func choose(_ action: AppAlertAction) {
        withAnimation(.smooth(duration: 0.3)) {
            isExpanded = false
        } completion: {
            action.handler?()
        }
    }
}

#if DEBUG
private struct GlassCloseConfirmationPreviewHost: View {
    @State private var isExpanded = false
    @State private var last = "—"

    private let slot = GlassCloseConfirmation.collapsedSize

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Push Day")
                    .font(FTFonts.largeTitleBold)
                    .foregroundStyle(FTColors.textPrimary)
                Spacer()
                Color.clear.frame(width: slot, height: slot)
            }
            Text("Last: \(last)")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
            Spacer()
        }
        .padding()
        .overlay {
            if isExpanded {
                FTColors.scrim
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.smooth(duration: 0.3)) { isExpanded = false } }
                    .transition(.opacity)
            }
        }
        .overlay(alignment: .topTrailing) {
            GlassCloseConfirmation(
                isExpanded: $isExpanded,
                title: "End this workout?",
                message: "You've logged 3 of 7 sets. Unfinished workouts aren't saved.",
                actions: [
                    AppAlertAction("End Workout", style: .destructive) { last = "ended" },
                    AppAlertAction("Keep Going") { last = "kept going" },
                ],
            )
            .padding(.top, 16 + 1)
            .padding(.trailing, 16)
        }
        .background(FTColors.background)
    }
}

#Preview("Light") {
    GlassCloseConfirmationPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    GlassCloseConfirmationPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
