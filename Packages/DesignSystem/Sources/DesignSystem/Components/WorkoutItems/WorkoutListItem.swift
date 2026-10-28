import SwiftUI

/// One workout to pick from a list: its icon in a circle, name and a short
/// summary, a radio on the right, all on a wash of the workout's color.
/// Picked, the radio fills and a green border runs around the row. Which row
/// is picked is the owner's state.
public struct WorkoutListItem: View {
    let title: String
    let subtitle: String
    let icon: Image
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    public init(
        title: String,
        subtitle: String,
        icon: Image,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }

    private let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
    private let radioSize: CGFloat = 26

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                icon
                    .font(FTFonts.subheadlineSemibold)
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(FTColors.surfaceSecondary))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(FTFonts.headline)
                        .foregroundStyle(FTColors.textPrimary)
                    Text(subtitle)
                        .font(FTFonts.footnote)
                        .foregroundStyle(FTColors.textSecondary)
                        .monospacedDigit()
                }
                .lineLimit(1)

                Spacer(minLength: 8)

                radio
            }
            .padding(.horizontal, 16)
            .frame(height: 76)
            // The workout's color as a wash, as on its tile.
            .background(shape.fill(color.opacity(0.16)))
            .overlay {
                if isSelected {
                    shape.strokeBorder(FTColors.greenAccent, lineWidth: 2)
                }
            }
            .contentShape(shape)
        }
        .buttonStyle(.press)
        .animation(.smooth(duration: 0.25), value: isSelected)
    }

    private var radio: some View {
        Circle()
            .strokeBorder(isSelected ? FTColors.greenAccent : FTColors.textSecondary, lineWidth: 2.5)
            .frame(width: radioSize, height: radioSize)
            .overlay {
                if isSelected {
                    Circle()
                        .fill(FTColors.greenAccent)
                        .frame(width: 12, height: 12)
                        .transition(.scale.combined(with: .opacity))
                }
            }
    }
}

#if DEBUG
private struct WorkoutListItemPreviewHost: View {
    @State private var selected = "Push day"

    private let rows: [(title: String, subtitle: String, symbol: String, color: Color)] = [
        ("Pull day", "6 exercises · 21 sets", "dumbbell", .green),
        ("Push day", "5 exercises · 18 sets", "dumbbell", .pink),
        ("Leg day", "5 exercises · 19 sets", "dumbbell", .yellow),
        ("Easy 6 km", "30 min · 6 km", "figure.run", .mint),
        ("A very long workout name that won't fit", "4 exercises · 12 sets", "dumbbell", .indigo),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(rows, id: \.title) { row in
                    WorkoutListItem(
                        title: row.title,
                        subtitle: row.subtitle,
                        icon: Image(systemName: row.symbol),
                        color: row.color,
                        isSelected: selected == row.title,
                    ) {
                        selected = row.title
                    }
                }
            }
            .padding()
        }
        .background(FTColors.surface)
    }
}

#Preview("Light") {
    WorkoutListItemPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutListItemPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
