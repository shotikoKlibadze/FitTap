import SwiftUI

/// One workout on one day: the workout's dot and title, the date on the
/// right, a row of stats underneath. `status` says whether it happened —
/// a done session is raised with a solid border and a filled dot, a planned
/// one sits flat behind a dashed border with a ring dot, a missed one is
/// raised like done but behind a red dashed border, with a red dashed dot
/// and "Missed" leading its stats.
public struct WorkoutSessionCard: View {
    public enum Status: Hashable {
        case done
        case planned
        case missed
    }

    let title: String
    let dotColor: Color?
    let dateText: String
    let stats: [String]
    let status: Status
    let action: () -> Void

    public init(
        title: String,
        dotColor: Color?,
        dateText: String,
        stats: [String],
        status: Status,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.dotColor = dotColor
        self.dateText = dateText
        self.stats = stats
        self.status = status
        self.action = action
    }

    private let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
    private let dotSize: CGFloat = 8

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    HStack(spacing: 9) {
                        dot
                            .frame(width: dotSize, height: dotSize)
                        Text(title)
                            .font(FTFonts.headlineBold)
                            .foregroundStyle(FTColors.textPrimary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    Text(dateText)
                        .font(FTFonts.footnote)
                        .foregroundStyle(FTColors.textSecondary)
                }
                HStack(spacing: 16) {
                    if status == .missed {
                        Text("Missed")
                            .font(FTFonts.footnoteSemibold)
                            .foregroundStyle(FTColors.red)
                    }
                    ForEach(stats, id: \.self) { stat in
                        Text(stat)
                            .font(FTFonts.footnote)
                            .foregroundStyle(FTColors.textSecondary)
                            .monospacedDigit()
                    }
                }
                .lineLimit(1)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { surface }
            .overlay { border }
            .contentShape(shape)
        }
        .buttonStyle(.press)
    }

    @ViewBuilder
    private var surface: some View {
        switch status {
        case .done, .missed:
            Color.clear.elevatedSurface(in: shape)
        case .planned:
            shape.fill(FTColors.surface)
        }
    }

    @ViewBuilder
    private var border: some View {
        switch status {
        case .done:
            shape.strokeBorder(FTColors.separator, lineWidth: 1)
        case .planned:
            shape.strokeBorder(FTColors.separator, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
        case .missed:
            // The gaps between the red dashes show the screen background,
            // not the surface's lit edge — the border reads as broken.
            ZStack {
                shape.strokeBorder(FTColors.background, lineWidth: 1)
                shape.strokeBorder(FTColors.red, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
            }
        }
    }

    @ViewBuilder
    private var dot: some View {
        switch status {
        case .done:
            Circle().fill(dotColor ?? FTColors.textSecondary)
        case .planned:
            Circle().strokeBorder(dotColor ?? FTColors.separator, lineWidth: 1.5)
        case .missed:
            Circle().strokeBorder(FTColors.red, style: StrokeStyle(lineWidth: 1.5, dash: [2, 1.5]))
        }
    }
}

#if DEBUG
private struct WorkoutSessionCardPreviewHost: View {
    @State private var tapped = "Tap a card"

    var body: some View {
        VStack(spacing: 9) {
            WorkoutSessionCard(
                title: "Back",
                dotColor: .blue,
                dateText: "Mon, Sep 7",
                stats: ["58 min", "6 exercises", "21 sets"],
                status: .done,
            ) { tapped = "Back" }
            WorkoutSessionCard(
                title: "Push Day",
                dotColor: .pink,
                dateText: "Wed, Sep 9",
                stats: ["3 exercises", "7 sets", "~45 min"],
                status: .planned,
            ) { tapped = "Push Day" }
            WorkoutSessionCard(
                title: "Pull Day",
                dotColor: .purple,
                dateText: "Thu, Sep 3",
                stats: ["6 exercises", "21 sets"],
                status: .missed,
            ) { tapped = "Pull Day" }
            WorkoutSessionCard(
                title: "Running with a very long session name",
                dotColor: .mint,
                dateText: "Sat, Sep 5",
                stats: ["34 min", "6.2 km", "5:29 /km"],
                status: .done,
            ) { tapped = "Running" }
            Text(tapped)
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textSecondary)
                .padding(.top, 12)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    WorkoutSessionCardPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutSessionCardPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
