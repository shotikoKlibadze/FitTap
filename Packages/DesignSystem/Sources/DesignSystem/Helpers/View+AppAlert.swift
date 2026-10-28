import SwiftUI

public extension View {
    /// Presents an `AppAlert` centered over the whole app — toolbar and tab
    /// bar included — with everything behind it dimmed. The only way the app
    /// shows alerts; never use SwiftUI's `.alert` or `.confirmationDialog`.
    ///
    /// Each action's handler runs once the alert is fully gone, so it can
    /// safely pop or dismiss the screen. A tap on the dimmed background just
    /// closes the alert.
    func appAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        actions: [AppAlertAction],
    ) -> some View {
        modifier(AppAlertModifier(isPresented: isPresented, title: title, message: message, actions: actions))
    }

    /// The common shape: a colored confirm over a quiet cancel. `onConfirm`
    /// runs once the alert is fully gone; cancel just closes it.
    func appAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmTitle: String,
        confirmStyle: PillStyle = .destructive,
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
    ) -> some View {
        appAlert(
            isPresented: isPresented,
            title: title,
            message: message,
            actions: [
                AppAlertAction(confirmTitle, style: confirmStyle, action: onConfirm),
                AppAlertAction(cancelTitle),
            ],
        )
    }
}

/// Hosts the alert in a clear full-screen cover so the dim covers the system
/// bars too. The cover itself appears and leaves without animation; the
/// scrim fade and the alert's scale run inside it.
private struct AppAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let actions: [AppAlertAction]

    @State private var isCoverShown = false
    @State private var isVisible = false
    /// The tapped action, run once the cover is gone.
    @State private var pendingAction: Int?

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

                        AppAlert(title: title, message: message, actions: actions, onAction: choose)
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

    private func choose(_ index: Int) {
        pendingAction = index
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
        guard let index = pendingAction else { return }
        pendingAction = nil
        actions[index].handler?()
    }

    private func withoutAnimation(_ change: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, change)
    }
}
