import SwiftUI

public extension View {
    /// Presents an `AppAlert` centered over the whole app — toolbar and tab
    /// bar included — with everything behind it dimmed. The only way the app
    /// shows alerts; never use SwiftUI's `.alert` or `.confirmationDialog`.
    ///
    /// `onConfirm` runs once the alert is fully gone, so it can safely pop or
    /// dismiss the screen. Cancel, or a tap on the dimmed background, just
    /// closes the alert.
    func appAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmTitle: String,
        confirmColor: PillButton.ButtonColor = .red,
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
    ) -> some View {
        modifier(AppAlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            confirmColor: confirmColor,
            cancelTitle: cancelTitle,
            onConfirm: onConfirm,
        ))
    }
}

/// Hosts the alert in a clear full-screen cover so the dim covers the system
/// bars too. The cover itself appears and leaves without animation; the
/// scrim fade and the alert's scale run inside it.
private struct AppAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmTitle: String
    let confirmColor: PillButton.ButtonColor
    let cancelTitle: String
    let onConfirm: () -> Void

    @State private var isCoverShown = false
    @State private var isVisible = false
    @State private var didConfirm = false

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented, initial: true) { _, shown in
                if shown, !isCoverShown {
                    withoutAnimation { isCoverShown = true }
                } else if !shown, isCoverShown {
                    close()
                }
            }
            .fullScreenCover(isPresented: $isCoverShown, onDismiss: finish) {
                ZStack {
                    if isVisible {
                        FTColors.scrim
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture(perform: close)
                            .transition(.opacity)

                        AppAlert(
                            title: title,
                            message: message,
                            confirmTitle: confirmTitle,
                            confirmColor: confirmColor,
                            cancelTitle: cancelTitle,
                            onConfirm: confirm,
                            onCancel: close,
                        )
                        // The system alert's entrance: settles from slightly large.
                        .transition(.scale(scale: 1.1).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .presentationBackground(.clear)
                .onAppear {
                    withAnimation(.smooth(duration: 0.25)) { isVisible = true }
                }
            }
    }

    private func confirm() {
        didConfirm = true
        close()
    }

    private func close() {
        withAnimation(.smooth(duration: 0.2)) {
            isVisible = false
        } completion: {
            withoutAnimation { isCoverShown = false }
        }
    }

    private func finish() {
        isPresented = false
        guard didConfirm else { return }
        didConfirm = false
        onConfirm()
    }

    private func withoutAnimation(_ change: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, change)
    }
}
