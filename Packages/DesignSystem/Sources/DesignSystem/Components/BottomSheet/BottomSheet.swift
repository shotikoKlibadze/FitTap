import SwiftUI

/// A fixed-height sheet over a dimmed app: drag handle on top, the caller's
/// content below it. The caller gives the height — the sheet never measures
/// its content. Drag down or tap the dim to close. Never placed directly —
/// present it with `.bottomSheet(item:height:content:)`.
struct BottomSheet<Content: View>: View {
    /// True slides the sheet in (also on first appearance), false slides it
    /// out and then calls `onDismissed`.
    let isPresented: Bool
    /// Handle strip plus content, above the home indicator. The sheet's
    /// fill runs on down to the screen edge.
    let height: CGFloat
    /// A drag down or a tap on the dim asks the owner to close.
    let onClose: () -> Void
    /// The closing slide has finished.
    let onDismissed: () -> Void
    @ViewBuilder let content: Content

    @State private var isVisible = false
    @State private var dragOffset: CGFloat = 0

    private let shape = UnevenRoundedRectangle(
        topLeadingRadius: BottomSheetMetrics.cornerRadius,
        topTrailingRadius: BottomSheetMetrics.cornerRadius,
        style: .continuous,
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            FTColors.scrim
                .opacity(isVisible ? 1 : 0)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: onClose)
                .allowsHitTesting(isVisible)

            sheet
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onAppear { if isPresented { slideIn() } }
        .onChange(of: isPresented) { _, presented in
            presented ? slideIn() : slideOut()
        }
    }

    private func slideIn() {
        withAnimation(.smooth(duration: 0.3)) { isVisible = true }
    }

    private func slideOut() {
        withAnimation(.smooth(duration: 0.25)) {
            isVisible = false
        } completion: {
            dragOffset = 0
            onDismissed()
        }
    }

    private var sheet: some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: height - BottomSheetMetrics.dragAreaHeight, alignment: .top)
            .padding(.top, BottomSheetMetrics.dragAreaHeight)
            .background {
                // A raised surface like the cards: in dark mode the lit top
                // edge and hairline are what separate the sheet from a black
                // screen; in light mode it's the flat surface and its shadow.
                Color.clear
                    .elevatedSurface(in: shape)
                    .ignoresSafeArea(edges: .bottom)
            }
            .overlay(alignment: .top) { handle }
            // One rigid piece: content, fill and handle slide together instead
            // of the content landing in place while the fill animates.
            .geometryGroup()
            .contentShape(shape)
            .gesture(drag)
            .offset(y: isVisible ? dragOffset : height + hiddenOverhang)
            .allowsHitTesting(isVisible)
    }

    private var handle: some View {
        Capsule()
            .fill(FTColors.separator)
            .frame(width: BottomSheetMetrics.handleWidth, height: BottomSheetMetrics.handleHeight)
            .padding(.top, BottomSheetMetrics.handleTopPadding)
    }

    /// Pushes the fill below the home indicator out of sight too.
    private let hiddenOverhang: CGFloat = 60

    private var drag: some Gesture {
        // Measured in screen space: the sheet moves under the finger, and a
        // local translation would chase its own offset and jitter.
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                dragOffset = max(0, value.translation.height)
            }
            .onEnded { value in
                let pulled = value.translation.height > height / 4
                let flicked = value.predictedEndTranslation.height > height / 2
                if pulled || flicked {
                    onClose()
                } else {
                    withAnimation(.smooth(duration: 0.25)) { dragOffset = 0 }
                }
            }
    }
}

#if DEBUG
private struct BottomSheetPreviewHost: View {
    @State private var height: CGFloat?

    var body: some View {
        VStack(spacing: 16) {
            GlassPillButton(title: "Short sheet") { height = 240 }
            GlassPillButton(title: "Tall sheet") { height = 520 }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
        .bottomSheet(item: $height, height: { $0 }) { height in
            VStack(alignment: .leading, spacing: 4) {
                Text("Sheet content")
                    .font(FTFonts.title3Semibold)
                    .foregroundStyle(FTColors.textPrimary)
                Text("\(Int(height)) pt tall — drag down or tap the dim to close.")
                    .font(FTFonts.footnote)
                    .foregroundStyle(FTColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        }
    }
}

#Preview("Light") {
    BottomSheetPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    BottomSheetPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
