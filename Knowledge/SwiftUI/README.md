# SwiftUI graphics and motion

Reference notes on SwiftUI's visual-effect APIs, project-agnostic. These notes describe what exists, how it behaves, and what Apple states about it. They are more current than model training data.

API names and shapes are taken from Apple's published snippets (see `code/`) and, where noted, from Apple's documentation. Items marked ⚠️ are unconfirmed. Guidance Apple did **not** give is kept apart in §7 and marked as ours.

**Platforms:** every API here is iOS 17+ (TextRenderer iOS 18+); nothing in these sessions is iOS 27-only.
**Code examples:** [`code/`](code/) — one file per ingested session, named after the video title, holding Apple's published snippets with timestamps. A file's presence means that session's transcript and code are ingested.
**Sources:** WWDC24 10151 "Create custom visual effects with SwiftUI" (+ its sample project, CreateVisualEffectsDemo) · WWDC26 322 "Compose advanced graphics effects with SwiftUI"
**Related:** the third-party MeshGradients demo (Stewart Lynch) was read for comparison; its driver is an anti-pattern, see §2.

---

## 1. Position-based effects in scroll views

→ `code/CreateCustomVisualEffectsWithSwiftUI.swift` [1:45]–[4:41]

Two mechanisms, for two different jobs:

- **`scrollTransition(axis:) { content, phase in }`** — *phase-based*, fires as an item crosses the container's leading/trailing edge. `phase.value` is −1 (off the leading edge) … 0 … +1 (off the trailing edge); `phase.isIdentity` is true while fully on screen. Built for paging carousels: rotation (`rotationEffect(.degrees(phase.value * 2.5))`), parallax (`offset(x: phase.value * -250)` on an image whose parent is `containerRelativeFrame(.horizontal)` + `clipShape`, so the clip stays put), captions that fade and slide.
- **`visualEffect { content, proxy in }`** — *continuous, geometry-based*. `proxy` is a `GeometryProxy`; read `proxy.frame(in: .scrollView(axis: .vertical))` and derive every effect from it. Apple: it changes visual properties by position and size "in a performant way, which means it's great for use in scroll views". Returns a `VisualEffect` — the closure may use `hueRotation`, `scaleEffect`, `offset`, `brightness`, `blur`, `opacity`, `layerEffect`.

**The "items dissolve as they scroll under a pinned top" pattern** (sample project, VisualEffects.swift):

```swift
.visualEffect { content, proxy in
    let frame = proxy.frame(in: .scrollView(axis: .vertical))
    let distance = min(0, frame.minY)   // 0 until the item's top passes the scroll view's top edge
    return content
        .scaleEffect(1 + distance / 700)
        .offset(y: -distance / 1.25)      // holds it near the edge: a stack, not a slide
        .brightness(-distance / 400)
        .blur(radius: -distance / 50)
}
```

With the header in `.safeAreaInset(edge: .top)`, the scroll view's coordinate space already starts under the header, so `frame.minY == 0` *is* the header's bottom edge. Keep the closure pure (no state reads).

---

## 2. MeshGradient

→ `code/CreateCustomVisualEffectsWithSwiftUI.swift` [7:30]

`MeshGradient(width:height:points:colors:)` — `width`/`height` are the control-point grid's columns/rows; `points` are `SIMD2<Float>` in 0…1 unit space; `colors` one per point, same order. Moving a point moves its color; closer points give sharper transitions. Also a `ShapeStyle` (`.foregroundStyle(MeshGradient(…))`, `Capsule().fill(MeshGradient(…))`). Extra parameters seen in the third-party demo: `background:` (shows where a warped mesh leaves gaps) and `smoothsColors: false` (bilinear, harder transitions). Apple: implemented internally with GPU shaders.

**What looks calm** (from both projects): a 3×3 grid; rows of identical or adjacent colors (Apple: black / blue / green bands); one or two *interior* points nudged off-grid (`[0.8, 0.2]`), never the edge points; a palette of 4–5 analogous hues. The counter-example is 12 rainbow colors with points that cross rows.

**Animation:** Apple's session says the points "can be moved" and a mesh animation can "signal that something has changed", but publishes **no animation code** and uses no `TimelineView` for it. The third-party demo animates only colors, with a 100 Hz `Timer.publish(every: 0.01)` re-targeting a 3 s `withAnimation` on every tick and never pausing — an anti-pattern for anything long-running (see §7).

---

## 3. Shaders in SwiftUI

→ `code/CreateCustomVisualEffectsWithSwiftUI.swift` [22:55]–[23:36] · `code/ComposeAdvancedGraphicsEffectsWithSwiftUI.swift` [7:09]–[11:37]

A shader is a per-pixel GPU program with "no awareness of its neighbors" (WWDC26). SwiftUI exposes it through three modifiers plus a fill; each has a required Metal signature, and any further parameters are forwarded from Swift in order:

| Modifier | Metal signature | Use |
|---|---|---|
| `colorEffect` | `half4 f(float2 position, half4 color, …)` | per-pixel color remap (e.g. to black and white) |
| `distortionEffect` | `float2 f(float2 position, …)` | geometric remap: "this pixel takes that pixel's color"; also takes `maxSampleOffset` |
| `layerEffect` | `half4 f(float2 position, SwiftUI::Layer layer, …)` | reads the whole layer (`layer.sample(float2)`): blur-like, warps, ripples — "a superset of the other two" |
| fill (`Shape.fill(shader)`) | `half4 f(float2 position, …)` | procedural fills (stripes, textures); returns premultiplied color (docs) |

- Metal file: `#include <metal_stdlib>`, `#include <SwiftUI/SwiftUI.h>`, `using namespace metal;`, functions marked `[[ stitchable ]]`. The function name must match the call: `ShaderLibrary.Ripple(…)` ↔ `half4 Ripple(…)`.
- Arguments from Swift: `.float(Double)`, `.float2(CGPoint/CGSize)`, `.color(Color)` → `half4`, `.colorArray([Color])` → `device const half4 *ptr, int count`, `.image(Image)` → `texture2d<half>`.
- `layerEffect(_:maxSampleOffset:isEnabled:)`: `maxSampleOffset` must cover the farthest the shader samples from `position` (Ripple passes `CGSize(width: amplitude, height: amplitude)`); `isEnabled` turns the shader off entirely — Apple gates Ripple with `0 < elapsedTime && elapsedTime < duration`. Docs: UIKit/AppKit-backed views don't render into the filtered layer. ⚠️ WWDC26 passes `.zero` while sampling up to ±100 pt — contrary to the docs; use the real offset.
- Wrap the effect in `visualEffect { view, _ in view.layerEffect(…) }` and capture values into `let`s outside the closure.

**Time.** Shaders are stateless; "shaders have no concept of time". Two drivers Apple shows:
- One-shot: `keyframeAnimator(initialValue: 0, trigger:)` with `MoveKeyframe(0)` + `LinearKeyframe(duration, duration:)` — the animator's value *is* `elapsedTime`; bumping the trigger restarts it (Ripple).
- Continuous: `TimelineView(.animation) { timeline in let elapsed = timeline.date.timeIntervalSince(startDate) … .float(elapsed) }` — "fires every frame with a timestamp" (WWDC26 background).

**Noise and domain warping** (WWDC26): a pre-rendered `NoiseTexture` image (two noise patterns in its red and green channels), sampled with `constexpr sampler s(address::repeat, filter::linear)` at `uv = position / size` so it tiles and is size-independent. Offset the layer sample by `(noise.rg − 0.5) * amount`. Domain warping = sample the noise once to get `q`, sample again at `uv + q`, use that as the offset → "organic, flowing blobs". Animate by adding time to the noise-sampling position (narration; code in the sample project).

⚠️ *Ours, learned on FitTap (2026-10-28):* the texture + layer-remap version rendered on the simulator and came out blank on a device, with no console error. Shaders with `.image` arguments and far-reaching `layer.sample` calls are the two device-sensitive inputs; a fill shader that computes its own noise (integer-hashed value noise, exact at any `time`) and paints its own colors from `.color` arguments behaves the same everywhere — see `BackgroundWarp.metal` in the design system. Check a shader on a device before trusting the simulator.

**Ripple** (WWDC24): a radial sine wave with exponential decay, delayed by `distance / speed` so it propagates outward; origin from a `UIGestureRecognizerRepresentable` wrapping `UILongPressGestureRecognizer(minimumPressDuration: 0)`; debug UI with sliders scrubbing time/amplitude/frequency/decay — Apple's advice: build such editors in previews because the modifier itself is stateless.

---

## 4. Transitions

→ `code/CreateCustomVisualEffectsWithSwiftUI.swift` [10:36]

`struct X: Transition { func body(content: Content, phase: TransitionPhase) -> some View }`. `phase.isIdentity` while shown; `.willAppear` / `.didDisappear` for direction-aware values (rotate +360 in, −360 out keeps spinning the same way). Compose `scaleEffect`, `opacity`, `blur`, `rotationEffect`, `brightness`. `.compositingGroup()` on the content applies blur/opacity once to the flattened view rather than per child. Attach with `.transition(X())`.

---

## 5. TextRenderer (iOS 18+)

→ `code/CreateCustomVisualEffectsWithSwiftUI.swift` [13:29]–[14:01]

`TextRenderer.draw(layout: Text.Layout, in: inout GraphicsContext)`; a layout is lines → runs → run slices (glyphs). Minimum: `for line in layout { context.draw(line) }`. Animate by conforming to `Animatable` with `animatableData` = elapsed time, staggering slices with a computed delay, copying the context per slice (value semantics), and drawing with `UnitCurve` for opacity/blur, `Spring.value(fromValue:toValue:initialVelocity:time:)` for position, and `.draw(slice, options: .disablesSubpixelQuantization)` to avoid jitter while a spring settles. Mark ranges with a `TextAttribute` (`Text.customAttribute(EmphasisAttribute())`, read with `run[EmphasisAttribute.self]`). Hook into a `Transition` whose body forces `transaction.animation = .linear(duration:)` so pacing stays even regardless of the caller's animation.

---

## 6. Alignment guides for floating attachments

→ `code/ComposeAdvancedGraphicsEffectsWithSwiftUI.swift` [13:53]–[14:32]

Keep an attachment in an always-present `.overlay(alignment:)` so it never affects layout; override the child's guide to place it outside its parent: `.alignmentGuide(.bottom) { $0[.top] }` makes the child's top sit on the parent's bottom edge — "a purely semantic override without manually offsetting". The closure receives `ViewDimensions`; custom alignments can be defined.

---

## 7. Power and long-running motion — *our guidance, not Apple's*

Neither session says a word about battery, frame-rate caps, pausing, or Reduce Motion. For content that runs for a whole workout:

- Drive continuous motion from `TimelineView(.animation(minimumInterval: 1/20, paused: !isActive))` (or `.periodic`), never from a `Timer` on the main run loop; pause via `scenePhase` and when the view is covered.
- Prefer a single Core Animation interpolation (`withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true))` between two point/color sets) over per-frame recomputation when the motion is a slow drift.
- Gate shaders with `isEnabled` whenever they have nothing to show, as Ripple does.
- Honor `accessibilityReduceMotion`: freeze the drift, keep the colors.
