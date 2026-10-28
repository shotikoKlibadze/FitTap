import SwiftUI

/// The app's only alert: a Liquid Glass card with a title, a message, and a
/// column of flat pill buttons — a colored confirm over a quiet cancel, or
/// several equal choices. Never placed directly — present it with
/// `.appAlert(isPresented:…)`, which centers it over a dimmed app the way the
/// system alert sits.
struct AppAlert: View {
    let title: String
    let message: String
    let actions: [AppAlertAction]
    /// The index of the tapped action.
    let onAction: (Int) -> Void

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
                ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                    PillButton(title: action.title, style: action.style) { onAction(index) }
                }
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
    @State private var isChoicePresented = false
    @State private var lastAction = "—"

    var body: some View {
        VStack(spacing: 24) {
            AppAlert(
                title: "Discard this workout?",
                message: "Your changes to Push Day will be lost.",
                actions: [
                    AppAlertAction("Discard", style: .destructive),
                    AppAlertAction("Keep Editing"),
                ],
            ) { lastAction = $0 == 0 ? "discard" : "keep editing" }
            AppAlert(
                title: "Planned for Thu, Sep 10",
                message: "Edit Push Day or move it to another day.",
                actions: [AppAlertAction("Edit Workout"), AppAlertAction("Change Date")],
            ) { lastAction = $0 == 0 ? "edit" : "change date" }
            Text("Last: \(lastAction)")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
            HStack(spacing: 10) {
                PillButton(title: "Confirm", style: .secondary, size: .compact) { isPresented = true }
                PillButton(title: "Choice", style: .secondary, size: .compact) { isChoicePresented = true }
            }
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
        .appAlert(
            isPresented: $isChoicePresented,
            title: "Planned for Thu, Sep 10",
            message: "Edit Push Day or move it to another day.",
            actions: [
                AppAlertAction("Edit Workout") { lastAction = "presented: edit" },
                AppAlertAction("Change Date") { lastAction = "presented: change date" },
            ],
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
