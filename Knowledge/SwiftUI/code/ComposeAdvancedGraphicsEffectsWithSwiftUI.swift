// Compose advanced graphics effects with SwiftUI
// WWDC26 session 322 · https://developer.apple.com/videos/play/wwdc2026/322/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Sample project: ComposingAdvancedGraphicsEffectsWithSwiftUI (linked from the session page; not ingested).
// Explanations: ../README.md

// MARK: - [4:18] Cover art image

Image("CoverArt")

// MARK: - [4:24] Blurred cover art image

Image("CoverArt")
    .blur(radius: 30)

// MARK: - [7:09] Applying layer effect in SwiftUI

GeometryReader { proxy in
    CoverArtView()
        .layerEffect(
            ShaderLibrary.backgroundWarp(),
            maxSampleOffset: .zero
        )
}
.ignoresSafeArea()

// MARK: - [7:21] Writing layer effect shader in Metal

/*
[[stitchable]] half4 backgroundWarp(
    float2 position, SwiftUI::Layer layer
) {
    return layer.sample(position);
}
*/

// MARK: - [7:39] Metal shader with offset parameter

/*
[[stitchable]] half4 backgroundWarp(
    float2 position, SwiftUI::Layer layer,
    float2 offset
) {
    return layer.sample(position + offset);
}
*/

// MARK: - [7:55] SwiftUI layer effect with offset parameter

GeometryReader { proxy in
    CoverArtView()
        .layerEffect(
            ShaderLibrary.backgroundWarp(
               .float2(.init(x: 0, y: 0))
            ),
            maxSampleOffset: .zero
        )
}
.ignoresSafeArea()

// MARK: - [8:04] SwiftUI layer effect with full-width offset

GeometryReader { proxy in
    CoverArtView()
        .layerEffect(
            ShaderLibrary.backgroundWarp(
               .float2(.init(x: proxy.size.width, y: 0))
            ),
            maxSampleOffset: .zero
        )
}
.ignoresSafeArea()

// MARK: - [8:37] SwiftUI layer effect with noise sampling

GeometryReader { proxy in
    CoverArtView()
        .layerEffect(
            ShaderLibrary.backgroundWarp(
                .float2(proxy.size),
                .image(Image("NoiseTexture"))
            ),
            maxSampleOffset: .zero
        )
}
.ignoresSafeArea()

// MARK: - [8:55] Metal shader with noise sampling

/*
[[stitchable]] half4 backgroundWarp(
    float2 position, SwiftUI::Layer layer,
    float2 size, texture2d<half> noiseTex
) {
    constexpr sampler s(address::repeat, filter::linear);
    float2 uv = position / size;

    half4 n = noiseTex.sample(s, uv);
    float2 offset = (float2(n.r, n.g) - 0.5) * 200.0;

    return layer.sample(position + offset);
}
*/

// MARK: - [10:22] Metal shader with domain warping

/*
[[stitchable]] half4 backgroundWarp(
    float2 position, SwiftUI::Layer layer,
    float2 size, texture2d<half> noiseTex
) {
    constexpr sampler s(address::repeat, filter::linear);
    float2 uv = position / size;

    half4 n = noiseTex.sample(s, uv);

    float2 q = float2(n.r, n.g);
    n = noiseTex.sample(s, uv + q);

    float2 offset = (float2(n.r, n.g) - 0.5) * 200.0;

    return layer.sample(position + offset);
}
*/

// MARK: - [11:16] SwiftUI layer effect with static visual

GeometryReader { proxy in
    CoverArtView()
        .layerEffect(
            ShaderLibrary.backgroundWarp(
                .float2(proxy.size),
                .image(Image("NoiseTexture"))
            ),
            maxSampleOffset: .zero
        )
}
.ignoresSafeArea()

// MARK: - [11:37] SwiftUI layer effect with animated visual
// (Apple's snippet references `proxy` without its enclosing GeometryReader — as published.
// The matching Metal change — a `float time` parameter added to the noise-sampling
// position — is narration only; the code lives in the sample project.)

@State private var startDate = Date.now

TimelineView(.animation) { timeline in
    let elapsed = timeline.date.timeIntervalSince(
        startDate
    )
    CoverArtView()
        .layerEffect(
            ShaderLibrary.backgroundWarp(
                .float2(proxy.size),
                .image(Image("NoiseTexture")),
                .float(elapsed)
            ),
            maxSampleOffset: .zero
        )
}

// MARK: - [12:15] Basic transcript view
// (Apple's snippet is missing the `Text(line.text)` line before the modifiers — as published.)

ScrollView {
    LazyVStack(alignment: .leading, spacing: 12) {
        ForEach(sampleTranscript) { line in
                .font(.title)
                .fontWeight(.bold)
        }
    }
}

// MARK: - [12:33] Time-synced transcript view

@State private var playback = PlaybackState()

ScrollViewReader { scrollProxy in
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(sampleTranscript) { line in
                Text(line.text)
                    .transcriptLineStyle(isCurrent:
                        line.id == playback.currentLineIndex
                    )
            }
        }
    }
    .onChange(of: playback.currentLineIndex, { _, i in
        scrollProxy.scrollTo(i, anchor: .center)
    })
}

// MARK: - [13:53] Overlay with center alignment

Text(line.text)
     .overlay {
          Text(line.formattedTimestamp)
     }

// MARK: - [14:06] Overlay with bottom leading alignment

Text(line.text)
     .overlay(alignment: .bottomLeading) {
          Text(line.formattedTimestamp)
     }

// MARK: - [14:32] Overlay with alignment guide override

Text(line.text)
     .overlay(alignment: .bottomLeading) {
          Text(line.formattedTimestamp)
              .alignmentGuide(.bottom) { $0[.top] }
     }
