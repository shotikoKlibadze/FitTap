import DesignSystem
import SwiftUI

/// How much cardio got done: a "Cardio" label, this week's minutes large
/// with "min this week" beside them, and this month's total small on the
/// right. Plain numbers in, nothing to tap.
struct CardioSummaryCard: View {
    let weekMinutes: Int
    let monthMinutes: Int

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cardio")
                    .font(FTFonts.subheadline)
                    .foregroundStyle(FTColors.textSecondary)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(weekMinutes)")
                        .font(FTFonts.titleBold)
                        .foregroundStyle(FTColors.textPrimary)
                        .monospacedDigit()
                    Text("min this week")
                        .font(FTFonts.subheadline)
                        .foregroundStyle(FTColors.textSecondary)
                }
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(monthMinutes) min")
                    .font(FTFonts.bodyBold)
                    .foregroundStyle(FTColors.textPrimary)
                    .monospacedDigit()
                Text("this month")
                    .font(FTFonts.footnote)
                    .foregroundStyle(FTColors.textSecondary)
            }
        }
        .padding(16)
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#if DEBUG
private struct CardioSummaryCardPreviewHost: View {
    @State private var weekMinutes = 34

    var body: some View {
        VStack(spacing: 16) {
            CardioSummaryCard(weekMinutes: weekMinutes, monthMinutes: 85)
            PillButton(title: "+ 20 min run", style: .secondary) { weekMinutes += 20 }
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    CardioSummaryCardPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    CardioSummaryCardPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
