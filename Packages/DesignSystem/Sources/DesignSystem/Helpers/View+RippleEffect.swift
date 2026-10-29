import SwiftUI

public extension View {
    /// Sends a ripple across the view from `origin` (in the view's own
    /// coordinates) every time `trigger` changes — a set checked off, a
    /// milestone hit. The wave is Apple's `Ripple` shader (WWDC24 10151),
    /// run as a layer effect for `duration` and switched off otherwise, so
    /// it costs nothing between ripples.
    func rippleEffect<T: Equatable>(at origin: CGPoint, trigger: T, duration: TimeInterval = 1.6) -> some View {
        modifier(RippleEffect(origin: origin, trigger: trigger, duration: duration))
    }
}

/// Restarts the shader's clock on every trigger change: a keyframe animator
/// runs `elapsedTime` linearly from 0 to `duration`, and the modifier below
/// maps it onto the shader each frame.
private struct RippleEffect<T: Equatable>: ViewModifier {
    let origin: CGPoint
    let trigger: T
    let duration: TimeInterval

    func body(content: Content) -> some View {
        let origin = origin
        let duration = duration

        content.keyframeAnimator(initialValue: 0, trigger: trigger) { view, elapsedTime in
            view.modifier(RippleModifier(origin: origin, elapsedTime: elapsedTime, duration: duration))
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }
}

/// One frame of the ripple. Stateless: the look depends only on its inputs.
private struct RippleModifier: ViewModifier {
    let origin: CGPoint
    let elapsedTime: TimeInterval
    let duration: TimeInterval

    // Gentler than Apple's photo demo: a card should flex, not splash.
    private let amplitude: Double = 8
    private let frequency: Double = 14
    private let decay: Double = 7
    private let speed: Double = 1400

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.bundle(.module).Ripple(
            .float2(origin),
            .float(elapsedTime),
            .float(amplitude),
            .float(frequency),
            .float(decay),
            .float(speed),
        )
        let maxSampleOffset = CGSize(width: amplitude, height: amplitude)
        let elapsedTime = elapsedTime
        let duration = duration

        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: maxSampleOffset,
                isEnabled: 0 < elapsedTime && elapsedTime < duration,
            )
        }
    }
}

#if DEBUG
private struct RippleEffectPreviewHost: View {
    @State private var origin = CGPoint.zero
    @State private var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Tap the card")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
            VStack(alignment: .leading, spacing: 12) {
                Text("Bench Press")
                    .font(FTFonts.title3Semibold)
                    .foregroundStyle(FTColors.textPrimary)
                ForEach(1...3, id: \.self) { set in
                    Text("Set \(set) · 10 reps · 20 kg")
                        .font(FTFonts.body)
                        .foregroundStyle(FTColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .contentShape(Rectangle())
            .onTapGesture { location in
                origin = location
                count += 1
            }
            .rippleEffect(at: origin, trigger: count)
            Text("Ripples: \(count)")
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    RippleEffectPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    RippleEffectPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
