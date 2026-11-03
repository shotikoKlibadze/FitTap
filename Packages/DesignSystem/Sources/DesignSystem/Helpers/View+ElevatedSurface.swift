import SwiftUI

public extension View {
    /// Draws the view on a raised surface in `shape`: a flat `surface` fill,
    /// a 0.5 pt hairline inside the shape, and one drop shadow. Dark and
    /// light use the same recipe; only the token values differ. On the dark
    /// gray background a single black shadow is enough to lift a card, so
    /// there is no gradient and no lit top edge.
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
                    .fill(FTColors.surface)
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
    }
}
