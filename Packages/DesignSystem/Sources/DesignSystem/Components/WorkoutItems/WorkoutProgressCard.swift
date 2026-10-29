import SwiftUI

/// The top of a workout in progress: a ring with the share of sets done and
/// the percentage inside, how far along in words, and the time since it
/// started — big, on the right, counting by itself.
public struct WorkoutProgressCard: View {
    /// 0…1 — sets done over sets planned.
    let progress: Double
    /// "3 of 7 sets".
    let title: String
    /// "2 exercises left".
    let subtitle: String
    let startedAt: Date

    public init(progress: Double, title: String, subtitle: String, startedAt: Date) {
        self.progress = min(max(progress, 0), 1)
        self.title = title
        self.subtitle = subtitle
        self.startedAt = startedAt
    }

    private let ringSize: CGFloat = 68
    private let ringWidth: CGFloat = 7

    public var body: some View {
        HStack(spacing: 14) {
            ring

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FTFonts.headline)
                    .foregroundStyle(FTColors.textPrimary)
                    .contentTransition(.numericText())
                Text(subtitle)
                    .font(FTFonts.footnote)
                    .foregroundStyle(FTColors.textSecondary)
                    .contentTransition(.numericText())
            }
            .lineLimit(1)

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 0) {
                // Counts up from the start on its own — no timer to drive.
                Text(timerInterval: startedAt...Date.distantFuture, countsDown: false)
                    .font(FTFonts.largeTitleBold)
                    .foregroundStyle(FTColors.textPrimary)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    // Each digit rolls to the next instead of snapping.
                    .contentTransition(.numericText(countsDown: false))
                Text("elapsed")
                    .font(FTFonts.caption)
                    .foregroundStyle(FTColors.textSecondary)
            }
            .fixedSize()
        }
        .padding(16)
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .animation(.smooth(duration: 0.4), value: progress)
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(FTColors.surfaceSecondary, lineWidth: ringWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(FTColors.greenAccent, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int((progress * 100).rounded()))%")
                .font(FTFonts.subheadlineSemibold)
                .foregroundStyle(FTColors.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .frame(width: ringSize, height: ringSize)
    }
}

#if DEBUG
private struct WorkoutProgressCardPreviewHost: View {
    @State private var done = 3
    private let total = 7
    private let startedAt = Date.now.addingTimeInterval(-(18 * 60 + 42))

    var body: some View {
        VStack(spacing: 20) {
            WorkoutProgressCard(
                progress: Double(done) / Double(total),
                title: "\(done) of \(total) sets",
                subtitle: done == total ? "All done" : "\(max(1, (total - done + 1) / 2)) exercises left",
                startedAt: startedAt,
            )
            HStack(spacing: 10) {
                PillButton(title: "− Set", style: .secondary, size: .compact) { done = max(0, done - 1) }
                PillButton(title: "+ Set", style: .secondary, size: .compact) { done = min(total, done + 1) }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    WorkoutProgressCardPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutProgressCardPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
