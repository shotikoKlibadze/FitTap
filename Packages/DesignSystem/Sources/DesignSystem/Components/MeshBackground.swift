import SwiftUI

/// A screen background that breathes: the app background with the `tint`
/// pooled into it, folded slowly into liquid, marbled tendrils — alive, but
/// never competing with the cards on top.
///
/// Everything is painted by the `BackgroundWarp` shader as a shape style:
/// procedural noise, warped and mapped onto three colors, on the GPU —
/// nothing is laid out per frame and nothing is sampled from a texture or
/// a layer, so it renders the same on a device as on the simulator. Built
/// for screens that stay open a long time: it pauses while the app isn't
/// active, and holds still under Reduce Motion (colors stay, the warp
/// freezes).
public struct MeshBackground: View {
    let tint: Color

    public init(tint: Color) {
        self.tint = tint
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var startDate = Date.now

    private var isPaused: Bool {
        reduceMotion || scenePhase != .active
    }

    /// Every tick repaints the whole screen through the shader; the drift
    /// is slow enough that 20 fps reads as continuous, at two thirds of the
    /// cost of 30.
    private static let frameInterval = 1.0 / 20

    public var body: some View {
        // Resolved once per body, not once per tick: pools of the tint
        // pulled toward the background — dark enough to sit behind cards —
        // rising to a stronger core.
        let background = FTColors.background
        let pool = tint.mix(with: background, by: 0.72)
        let core = tint.mix(with: background, by: 0.45)
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: Self.frameInterval, paused: isPaused)) { timeline in
                let time = timeline.date.timeIntervalSince(startDate)
                Rectangle()
                    .fill(
                        ShaderLibrary.bundle(.module).BackgroundWarp(
                            .float2(proxy.size),
                            .float(time),
                            .float(1.5),
                            .color(background),
                            .color(pool),
                            .color(core),
                        )
                    )
            }
        }
        .ignoresSafeArea()
    }
}

#if DEBUG
private struct MeshBackgroundPreviewHost: View {
    @State private var tint = Color.pink

    private let tints: [Color] = [.pink, .mint, .yellow, .purple]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(tints, id: \.self) { color in
                PillButton(title: "Tint", style: .secondary, size: .compact) { tint = color }
                    .frame(width: 120)
                    .overlay(alignment: .leading) {
                        Circle().fill(color).frame(width: 12, height: 12).padding(.leading, 12)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { MeshBackground(tint: tint) }
        .animation(.smooth(duration: 1), value: tint)
    }
}

#Preview("Light") {
    MeshBackgroundPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    MeshBackgroundPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
