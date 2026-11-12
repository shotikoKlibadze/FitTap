import SwiftUI

public extension View {
    /// Outlines the view in `shape` with a soft line of `color`, so a card
    /// can carry a meaning ("this one felt hard") without being filled with
    /// it. The line is the colour at half strength, 1 pt, drawn inside the
    /// shape, so the layout doesn't change. A nil colour draws nothing.
    ///
    /// Goes after `.elevatedSurface(in:)`, with the same shape, so it sits
    /// over the surface's own hairline.
    func tintedEdge<S: InsettableShape>(_ color: Color?, in shape: S) -> some View {
        overlay {
            if let color {
                shape.strokeBorder(color.opacity(0.5), lineWidth: 1)
            }
        }
    }
}

#if DEBUG
private struct TintedEdgePreviewHost: View {
    private let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
    private let colors: [(String, Color?)] = [
        ("Green", FTColors.greenAccent),
        ("Yellow", FTColors.yellowFill),
        ("Red", FTColors.redAccent),
        ("None", nil),
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(colors, id: \.0) { name, color in
                Text(name)
                    .font(FTFonts.calloutSemibold)
                    .foregroundStyle(FTColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .elevatedSurface(in: shape, elevation: .compact)
                    .tintedEdge(color, in: shape)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    TintedEdgePreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    TintedEdgePreviewHost()
        .preferredColorScheme(.light)
}
#endif
