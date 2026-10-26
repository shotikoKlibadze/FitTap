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

    /// Fill of every raised surface (`elevatedSurface(in:)`): lighter at the
    /// top as if lit from above in dark mode; flat in light mode, where both
    /// stops are the surface color.
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
        LinearGradient(
            stops: [
                Gradient.Stop(color: FTColors.background.opacity(0), location: 0.00),
                Gradient.Stop(color: FTColors.background.opacity(0.5), location: 0.25),
                Gradient.Stop(color: FTColors.background.opacity(0.9), location: 0.45),
                Gradient.Stop(color: FTColors.background, location: 0.60),
                Gradient.Stop(color: FTColors.background, location: 1.00),
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
#Preview("Light") {
    GradientsPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    GradientsPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
