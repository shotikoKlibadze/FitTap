import DesignSystem
import SwiftUI

/// The best set an exercise has ever had: "Personal best" with the day on
/// the right, then the number large, in gold, with how the weight is meant.
struct PersonalBestCard: View {
    let item: PersonalBestItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Personal best")
                Spacer(minLength: 8)
                Text(item.date)
            }
            .font(FTFonts.subheadline)
            .foregroundStyle(FTColors.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(item.value)
                    .font(FTFonts.title2Bold)
                    .foregroundStyle(FTColors.yellow)
                    .monospacedDigit()
                if let unit = item.unit {
                    Text(unit)
                        .font(FTFonts.subheadline)
                        .foregroundStyle(FTColors.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#if DEBUG
private struct PersonalBestCardPreviewHost: View {
    var body: some View {
        PersonalBestCard(item: .sample)
            .padding(16)
            .frame(maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Dark") {
    PersonalBestCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    PersonalBestCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
