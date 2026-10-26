import SwiftUI

/// The app's only alert: a Liquid Glass card with a title, a message, a
/// colored confirm action, and a quiet cancel. Never placed directly —
/// present it with `.appAlert(isPresented:…)`, which centers it over a
/// dimmed app the way the system alert sits.
struct AppAlert: View {
    let title: String
    let message: String
    let confirmTitle: String
    var confirmColor: PillButton.ButtonColor = .red
    var cancelTitle = "Cancel"
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
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
                PillButton(title: confirmTitle, color: confirmColor, action: onConfirm)

                PillButton(title: cancelTitle, color: .neutral, action: onCancel)
            }
        }
        .padding(20)
        .frame(width: 300)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}

#if DEBUG
private struct AppAlertPreviewHost: View {
    @State private var isPresented = false
    @State private var lastAction = "—"

    var body: some View {
        VStack(spacing: 24) {
            AppAlert(
                title: "Discard this workout?",
                message: "Your changes to Push Day will be lost.",
                confirmTitle: "Discard",
                cancelTitle: "Keep Editing",
                onConfirm: { lastAction = "discard" },
                onCancel: { lastAction = "keep editing" },
            )
            AppAlert(
                title: "Finish workout?",
                message: "Everything you logged today will be saved.",
                confirmTitle: "Finish",
                confirmColor: .green,
                onConfirm: { lastAction = "finish" },
                onCancel: { lastAction = "cancel" },
            )
            Text("Last: \(lastAction)")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
            PillButton(title: "Present over the app") { isPresented = true }
                .frame(width: 300)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
        .appAlert(
            isPresented: $isPresented,
            title: "Discard this workout?",
            message: "Your changes to Push Day will be lost.",
            confirmTitle: "Discard",
            cancelTitle: "Keep Editing",
            onConfirm: { lastAction = "presented: discard" },
        )
    }
}

#Preview("Light") {
    AppAlertPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    AppAlertPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
