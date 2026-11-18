import DesignSystem
import SwiftUI

/// The exercise's personal best in words, then its recent sessions as a
/// bar chart: "22.5 kg × 6 per side personal best" with the day it was
/// set, the bars under it, and the chart's legend at the bottom.
///
/// The best is only written, never drawn: no bar is singled out for it,
/// so the bars say one thing (did the session go clean) and the line
/// above them says the other. Its number is blue, the one colour here
/// that isn't used for how a session went.
struct ProgressChartCard: View {
    let bars: [SessionBar]
    let personalBest: PersonalBestItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let personalBest {
                ProgressChartBestRow(item: personalBest)
            }
            SessionBarChart(bars: bars)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

/// The line above the chart: the number in blue, how the weight is meant,
/// "personal best", and the day on the right.
private struct ProgressChartBestRow: View {
    let item: PersonalBestItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(item.value)
                .font(FTFonts.subheadlineBold)
                .foregroundStyle(FTColors.blue)
                .monospacedDigit()
            if let unit = item.unit {
                Text(unit)
                    .font(FTFonts.footnote)
                    .foregroundStyle(FTColors.textSecondary)
            }
            Text("personal best")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
            Spacer(minLength: 8)
            Text(item.date)
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .lineLimit(1)
    }
}

#if DEBUG
private struct ProgressChartCardPreviewHost: View {
    /// Tap the card to step through 1, 3, 7 and 14 sessions.
    @State private var step = 3

    private let counts = [1, 3, 7, 14]

    var body: some View {
        ProgressChartCard(
            bars: Array(SessionBar.samples.suffix(counts[step % counts.count])),
            personalBest: .sample,
        )
        .contentShape(Rectangle())
        .onTapGesture { step += 1 }
        .padding(16)
        .frame(maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    ProgressChartCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    ProgressChartCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
