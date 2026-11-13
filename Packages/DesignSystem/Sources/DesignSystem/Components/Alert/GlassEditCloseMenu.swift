import SwiftUI

/// A full-screen mode's corner menu, all one Liquid Glass group. Collapsed
/// it's a glass ⋯. Tapped, the ⋯ turns into a ✕ and an "Edit" bubble grows
/// out of it to the left. "Edit" turns on `isEditing`: the ✕ melts away and
/// the bubble becomes "Done", which turns it off and brings the ⋯ back.
///
/// The ✕ leaves through `onClose` at once — or, with a `confirmation`, the
/// ✕ morphs at its corner into a glass card asking first, like
/// `GlassCloseConfirmation`. Left alone, the open menu folds back after a
/// few seconds.
///
/// Collapsed it's 40 pt; place it in an overlay pinned to the corner it
/// should grow from, over a 40 pt slot that holds its place, and draw the
/// dim behind it while `isConfirming`.
public struct GlassEditCloseMenu: View {
    /// What the ✕ asks before leaving.
    public struct Confirmation {
        let title: String
        let message: String
        let actions: [AppAlertAction]

        public init(title: String, message: String, actions: [AppAlertAction]) {
            self.title = title
            self.message = message
            self.actions = actions
        }
    }

    @Binding var isEditing: Bool
    @Binding var isConfirming: Bool
    let confirmation: Confirmation?
    let onClose: () -> Void

    public init(
        isEditing: Binding<Bool>,
        isConfirming: Binding<Bool>,
        confirmation: Confirmation?,
        onClose: @escaping () -> Void,
    ) {
        _isEditing = isEditing
        _isConfirming = isConfirming
        self.confirmation = confirmation
        self.onClose = onClose
    }

    public static let collapsedSize: CGFloat = 40

    @State private var isOpen = false
    @Namespace private var glass

    /// The ⋯, the ✕ and the confirmation card are one glass shape changing.
    private let closeID = "close"
    /// "Edit" and "Done" are one bubble changing.
    private let editID = "edit"
    /// How long the open menu waits for a pick before folding back.
    private let autoCloseDelay: Duration = .seconds(4)

    /// A touch of bounce growing; smooth folding back.
    private let grow = Animation.bouncy(duration: 0.45, extraBounce: 0.1)
    private let fold = Animation.smooth(duration: 0.3)

    public var body: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                if isConfirming, let confirmation {
                    GlassConfirmationCard(
                        title: confirmation.title,
                        message: confirmation.message,
                        actions: confirmation.actions,
                        onChoose: choose,
                    )
                    // Tinted like the alert, but still glass so the ✕ can
                    // morph into it.
                    .glassEffect(.regular.tint(FTColors.sheetSurface), in: GlassConfirmationCard.shape)
                    .glassEffectID(closeID, in: glass)
                } else if isEditing {
                    bubble("Done", action: finishEditing)
                        .glassEffectID(editID, in: glass)
                } else {
                    if isOpen {
                        bubble("Edit", action: startEditing)
                            .glassEffectID(editID, in: glass)
                    }
                    cornerButton
                        .glassEffectID(closeID, in: glass)
                }
            }
        }
        .task(id: isOpen) {
            guard isOpen else { return }
            try? await Task.sleep(for: autoCloseDelay)
            withAnimation(fold) { isOpen = false }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: isOpen) { _, new in new }
    }

    /// ⋯ while folded, ✕ while open — the glyph swaps in the same circle.
    private var cornerButton: some View {
        Button(action: isOpen ? tapClose : open) {
            ZStack {
                if isOpen {
                    glyph(FTIcons.xMark)
                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                } else {
                    glyph(FTIcons.more)
                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                }
            }
            .frame(width: Self.collapsedSize, height: Self.collapsedSize)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
    }

    private func glyph(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
            // As `RoundButton`, so the two can stand in for each other.
            .frame(width: 16, height: 16)
            .foregroundStyle(FTColors.textPrimary)
    }

    private func bubble(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(FTFonts.bodySemibold)
                .foregroundStyle(FTColors.textPrimary)
                .padding(.horizontal, 18)
                .frame(height: Self.collapsedSize)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .capsule)
    }

    // MARK: - Actions

    private func open() {
        withAnimation(grow) { isOpen = true }
    }

    private func startEditing() {
        withAnimation(grow) {
            isOpen = false
            isEditing = true
        }
    }

    private func finishEditing() {
        withAnimation(fold) { isEditing = false }
    }

    /// With a confirmation, the ✕ grows into the card; without, it leaves.
    private func tapClose() {
        guard confirmation != nil else {
            isOpen = false
            return onClose()
        }
        withAnimation(grow) {
            isOpen = false
            isConfirming = true
        }
    }

    /// Folds the card back, then runs the action once it has settled.
    private func choose(_ action: AppAlertAction) {
        withAnimation(fold) {
            isConfirming = false
        } completion: {
            action.handler?()
        }
    }
}

#if DEBUG
private struct GlassEditCloseMenuPreviewHost: View {
    @State private var isEditing = false
    @State private var isConfirming = false
    @State private var asksFirst = true
    @State private var last = "—"

    private let slot = GlassEditCloseMenu.collapsedSize

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(isEditing ? "Editing" : "Push Day")
                    .font(FTFonts.largeTitleBold)
                    .foregroundStyle(FTColors.textPrimary)
                Spacer()
                Color.clear.frame(width: slot, height: slot)
            }
            Toggle("Ask before closing", isOn: $asksFirst)
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textPrimary)
            Text("Last: \(last)")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
            Spacer()
        }
        .padding()
        .overlay {
            if isConfirming {
                FTColors.scrim
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.smooth(duration: 0.3)) { isConfirming = false } }
                    .transition(.opacity)
            }
        }
        .overlay(alignment: .topTrailing) {
            GlassEditCloseMenu(
                isEditing: $isEditing,
                isConfirming: $isConfirming,
                confirmation: asksFirst
                    ? .init(
                        title: "End this workout?",
                        message: "You've logged 3 of 7 sets. Unfinished workouts aren't saved.",
                        actions: [
                            AppAlertAction("End Workout", style: .destructive) { last = "ended" },
                            AppAlertAction("Keep Going", style: .primary) { last = "kept going" },
                        ],
                    )
                    : nil,
                onClose: { last = "closed" },
            )
            .padding(.top, 16 + 1)
            .padding(.trailing, 16)
        }
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    GlassEditCloseMenuPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    GlassEditCloseMenuPreviewHost()
        .preferredColorScheme(.light)
}
#endif
