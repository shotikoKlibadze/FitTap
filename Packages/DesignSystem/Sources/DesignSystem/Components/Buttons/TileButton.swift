import SwiftUI

/// Square-ish choice tile: icon over a short label. Selected, it gets a warm
/// fill, a yellow border and a yellow icon. A single tile is just a button —
/// which tile in a grid is selected is the owner's state.
public struct TileButton: View {
    let icon: Image
    let title: String
    let isSelected: Bool
    let action: () -> Void

    public init(icon: Image, title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public static let height: CGFloat = 64

    private let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                icon
                    .font(FTFonts.headline)
                    .foregroundStyle(isSelected ? FTColors.yellow : FTColors.textPrimary)
                    // Symbols differ in height; a fixed box keeps every label on one line.
                    .frame(height: 22)
                Text(title)
                    .font(FTFonts.caption2Semibold)
                    .foregroundStyle(isSelected ? FTColors.textPrimary : FTColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .frame(height: Self.height)
            .background(shape.fill(isSelected ? FTColors.yellowSurface : FTColors.secondary))
            .overlay {
                if isSelected {
                    shape.strokeBorder(FTColors.yellow, lineWidth: 1.5)
                }
            }
            .contentShape(shape)
        }
        .buttonStyle(.press)
    }
}

#if DEBUG
private struct TileButtonPreviewHost: View {
    @State private var selected = "Barbell"

    private let tiles = [
        ("Barbell", "figure.strengthtraining.traditional"), ("Dumbbell", "dumbbell"),
        ("Cable", "cable.connector"), ("Machine", "gearshape.2"),
        ("Kettlebell", "scalemass"), ("Bodyweight", "figure.stand"),
        ("Pull-Up Bar", "figure.strengthtraining.functional"), ("Other", "circle.grid.2x2"),
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(tiles, id: \.0) { title, symbol in
                TileButton(icon: Image(systemName: symbol), title: title, isSelected: selected == title) {
                    selected = title
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.surface)
    }
}

#Preview("Light") {
    TileButtonPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    TileButtonPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
