import SwiftUI

/// Scrim gradients. Two stops band visibly on OLED, so the ramp is nine
/// eased stops: flat at the clear end so it dissolves instead of stepping,
/// steep through the middle, fully opaque at 65% of the run so the last
/// third is solid cover.
public enum FTGradients {
    /// Bottom scrim behind pinned bottom actions. It spans the button plus
    /// the home-indicator area; content fades out over the button's top part
    /// and is fully hidden from just past the button's vertical middle down.
    public static var fadeBottom: LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: FTColors.background.opacity(0), location: 0.00),
                Gradient.Stop(color: FTColors.background.opacity(0.5), location: 0.18),
                Gradient.Stop(color: FTColors.background.opacity(0.9), location: 0.30),
                // ~32pt into a 54pt button over an ~88pt run: just past its middle.
                Gradient.Stop(color: FTColors.background, location: 0.37),
                Gradient.Stop(color: FTColors.background, location: 1.00),
            ],
            startPoint: .top,
            endPoint: .bottom,
        )
    }

    /// The old lit fill of raised surfaces. Both stops are now the surface
    /// colour, so it draws flat; `elevatedSurface(in:)` fills with
    /// `FTColors.surface` directly. Kept for API compatibility — prefer the
    /// flat fill.
    public static var elevatedSurfaceBackground: LinearGradient {
        LinearGradient(
            colors: [FTColors.elevatedSurfaceTop, FTColors.elevatedSurfaceBottom],
            startPoint: .top,
            endPoint: .bottom,
        )
    }

    /// The top fade — behind the toolbar and behind floating controls like
    /// the filter chips. Clear at the bottom edge, 50% a quarter of the way
    /// up, 90% at 45%, solid from 60% to the top.
    public static var fadeTop: LinearGradient {
        fadeTop(to: FTColors.background)
    }

    /// `fadeTop` for content inside a bottom sheet: the same stops, ending on
    /// the sheet's body colour instead of the screen background, so it
    /// doesn't show as a lighter band on the sheet. Used behind a sheet's
    /// floating title (Plan Day).
    public static var sheetFadeTop: LinearGradient {
        fadeTop(to: FTColors.sheetSurface)
    }

    private static func fadeTop(to color: Color) -> LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: color.opacity(0), location: 0.00),
                Gradient.Stop(color: color.opacity(0.5), location: 0.25),
                Gradient.Stop(color: color.opacity(0.9), location: 0.45),
                Gradient.Stop(color: color, location: 0.60),
                Gradient.Stop(color: color, location: 1.00),
            ],
            startPoint: UnitPoint(x: 0.5, y: 1),
            endPoint: UnitPoint(x: 0.5, y: 0),
        )
    }
}

#if DEBUG
private struct GradientsPreviewHost: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<20, id: \.self) { index in
                    Text("Row \(index)")
                        .font(FTFonts.body)
                        .foregroundStyle(FTColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(RoundedRectangle(cornerRadius: 12).fill(FTColors.surface))
                }
            }
            .padding()
        }
        .overlay(alignment: .top) {
            FTGradients.fadeTop
                .frame(height: 101)
                .allowsHitTesting(false)
                .ignoresSafeArea(edges: .top)
        }
        .background(FTColors.background)
    }
}
#Preview("Dark") {
    GradientsPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    GradientsPreviewHost()
        .preferredColorScheme(.light)
}
#endif
