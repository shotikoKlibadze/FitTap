import SwiftUI

/// A square workout tile: the type icon and up to two muscle labels on top,
/// the name and a short summary at the bottom, the whole surface tinted
/// with the workout's color.
public struct WorkoutCard: View {
    let title: String
    let summary: String
    let icon: Image
    let color: Color
    let muscleLabels: [String]
    let action: () -> Void

    public init(
        title: String,
        summary: String,
        icon: Image,
        color: Color,
        muscleLabels: [String],
        action: @escaping () -> Void
    ) {
        self.title = title
        self.summary = summary
        self.icon = icon
        self.color = color
        self.muscleLabels = muscleLabels
        self.action = action
    }

    private let shape = RoundedRectangle(cornerRadius: 30, style: .continuous)

    public var body: some View {
        Button(action: action) {
            shape
                .fill(color.opacity(0.16))
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topLeading) {
                    header.padding(15)
                }
                .overlay(alignment: .bottomLeading) {
                    footer.padding(15)
                }
                .contentShape(shape)
        }
        .buttonStyle(.press)
    }

    private var header: some View {
        HStack(alignment: .top) {
            icon
                .font(FTFonts.caption2Semibold)
                .foregroundStyle(color)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                ForEach(muscleLabels.prefix(2), id: \.self) { label in
                    Text(label.uppercased())
                        .font(FTFonts.caption2Semibold)
                        .foregroundStyle(FTColors.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(FTFonts.title3Bold)
                .foregroundStyle(FTColors.textPrimary)
                .lineLimit(2)
            Text(summary)
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
private struct WorkoutCardPreviewHost: View {
    @State private var tapped = "Tap a card"

    private let cards: [(title: String, summary: String, symbol: String, color: Color, muscles: [String])] = [
        ("Push Day", "6 exercises · 18 sets", "dumbbell", .pink, ["Chest", "Shoulders"]),
        ("Leg Day", "5 exercises · 15 sets", "dumbbell", .yellow, ["Legs"]),
        ("Easy 6 km", "1 exercises", "figure.run", .mint, ["Full Body"]),
        ("A very long workout name here", "3 exercises", "dumbbell", .indigo, ["Chest", "Shoulders"]),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text(tapped)
                    .font(FTFonts.body)
                    .foregroundStyle(FTColors.textSecondary)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(cards, id: \.title) { card in
                        WorkoutCard(
                            title: card.title,
                            summary: card.summary,
                            icon: Image(systemName: card.symbol),
                            color: card.color,
                            muscleLabels: card.muscles,
                        ) {
                            tapped = card.title
                        }
                    }
                }
            }
            .padding()
        }
        .background(FTColors.background)
    }
}

#Preview("Light") {
    WorkoutCardPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutCardPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
