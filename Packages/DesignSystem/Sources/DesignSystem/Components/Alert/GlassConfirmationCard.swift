import SwiftUI

/// The inside of a glass close confirmation: title, message and flat pill
/// actions, 300 pt wide. The owner paints the glass around it and runs the
/// picked action (`GlassCloseConfirmation`, `GlassEditCloseMenu`).
struct GlassConfirmationCard: View {
    let title: String
    let message: String
    let actions: [AppAlertAction]
    let onChoose: (AppAlertAction) -> Void

    static let shape = RoundedRectangle(cornerRadius: 32, style: .continuous)

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
                ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                    PillButton(title: action.title, style: action.style) { onChoose(action) }
                }
            }
        }
        .padding(20)
        .frame(width: 300)
    }
}

#if DEBUG
private struct GlassConfirmationCardPreviewHost: View {
    @State private var last = "—"

    var body: some View {
        VStack(spacing: 20) {
            GlassConfirmationCard(
                title: "End this workout?",
                message: "You've logged 3 of 7 sets. Unfinished workouts aren't saved.",
                actions: [
                    AppAlertAction("End Workout", style: .destructive),
                    AppAlertAction("Keep Going", style: .primary),
                ],
                onChoose: { last = $0.title },
            )
            .glassEffect(.regular.tint(FTColors.sheetSurface), in: GlassConfirmationCard.shape)
            Text("Last: \(last)")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    GlassConfirmationCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    GlassConfirmationCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
