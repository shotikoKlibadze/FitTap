import DesignSystem
import SwiftUI

/// The workout's summary at the top of the workout screen in view mode: a
/// raised bar of a few side-by-side numbers, each with a small label
/// underneath ("3 / exercises", "7 / sets", "~45 / minutes"), split by thin
/// dividers. Read-only.
struct WorkoutSummaryStrip: View {
    struct Stat: Hashable {
        let value: String
        let label: String
    }

    let stats: [Stat]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                if index > 0 {
                    Rectangle()
                        .fill(FTColors.divider)
                        .frame(width: 1)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(stat.value)
                        .font(FTFonts.title3Bold)
                        .foregroundStyle(FTColors.textPrimary)
                        .monospacedDigit()
                    Text(stat.label)
                        .font(FTFonts.footnote)
                        .foregroundStyle(FTColors.textSecondary)
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            }
        }
        // As tall as its numbers and labels, never taller: the dividers
        // would otherwise take every bit of height they're offered.
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 14)
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#if DEBUG
private struct WorkoutSummaryStripPreviewHost: View {
    var body: some View {
        VStack(spacing: 16) {
            WorkoutSummaryStrip(stats: [
                WorkoutSummaryStrip.Stat(value: "3", label: "exercises"),
                WorkoutSummaryStrip.Stat(value: "7", label: "sets"),
                WorkoutSummaryStrip.Stat(value: "~45", label: "minutes"),
            ])
            WorkoutSummaryStrip(stats: [
                WorkoutSummaryStrip.Stat(value: "1", label: "exercise"),
                WorkoutSummaryStrip.Stat(value: "30", label: "minutes"),
                WorkoutSummaryStrip.Stat(value: "6", label: "km target"),
            ])
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    WorkoutSummaryStripPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    WorkoutSummaryStripPreviewHost()
        .preferredColorScheme(.light)
}
#endif
