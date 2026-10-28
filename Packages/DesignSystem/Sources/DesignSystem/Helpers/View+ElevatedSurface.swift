import SwiftUI

public extension View {
    /// Draws the view on a raised surface in `shape`: the elevated-surface
    /// gradient fill, a top highlight and a hairline edge inside the shape,
    /// and a drop shadow. Every value is an adaptive token, so one call gives
    /// dark mode its lit gradient and edges, and light mode a flat surface
    /// with a soft shadow.
    ///
    /// For surfaces that sit on the screen background — cards, fields, the
    /// type switcher. Never for controls inside them (pills, ✕, + Add Set).
    /// `elevation` sizes the shadow — `.compact` for small tiles packed
    /// together, whose regular shadows would merge into one.
    /// `dashed` swaps the hairline for the dashed "nothing chosen yet" border.
    /// Lines are drawn inside the shape, so the layout doesn't change.
    func elevatedSurface<S: InsettableShape>(
        in shape: S,
        elevation: SurfaceElevation = .regular,
        dashed: Bool = false,
    ) -> some View {
        modifier(ElevatedSurface(shape: shape, elevation: elevation, dashed: dashed))
    }
}

private struct ElevatedSurface<S: InsettableShape>: ViewModifier {
    let shape: S
    let elevation: SurfaceElevation
    let dashed: Bool

    func body(content: Content) -> some View {
        content
            .background {
                // The shadow belongs to the fill alone, so text and icons on
                // the surface don't cast their own.
                shape
                    .fill(FTGradients.elevatedSurfaceBackground)
                    .shadow(
                        color: FTColors.elevatedSurfaceShadow,
                        radius: elevation.shadowRadius,
                        x: 0,
                        y: elevation.shadowOffset,
                    )
            }
            .overlay {
                if dashed {
                    shape.strokeBorder(FTColors.separator, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                } else {
                    shape.strokeBorder(FTColors.elevatedSurfaceHairline, lineWidth: 0.5)
                }
            }
            .overlay {
                shape.strokeBorder(
                    LinearGradient(
                        colors: [FTColors.elevatedSurfaceHighlight, .clear],
                        startPoint: .top,
                        endPoint: .center,
                    ),
                    lineWidth: 1,
                )
            }
    }
}
