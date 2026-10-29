//
// BackgroundWarp — liquid, marbled motion in a few colors.
//
// A shape-style shader: it paints every pixel itself, so it needs no
// texture and samples no layer — the same on the simulator and on a device.
//
// It is a domain warp of a small color field: two passes of 2-D noise pick,
// for every pixel, where in a 3×3 grid of colors to read (the second pass
// is bent by the first, which folds the field into veins). The grid is
// mostly `background` with pools of `pool` and a `core` in the middle, so
// the folds show as tendrils of the tint over the background. The noise is
// value noise on an integer lattice hashed with integer math, exact however
// long `time` runs.
//
// `size` is the view size in points, `time` is seconds, `spread` (around
// 1.5) is how far the remap reaches across the grid — 1 keeps its layout,
// more pulls colors from further away. Used through `MeshBackground`.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace {

/// Exact hash of a lattice point: no float products that drift with
/// magnitude.
float hash(float2 p, uint seed) {
    uint2 q = uint2(int2(floor(p))) * uint2(1597334673u, 3812015801u);
    uint n = (q.x ^ q.y ^ seed) * 1597334673u;
    return float(n) * (1.0 / 4294967295.0);
}

float valueNoise(float2 p, uint seed) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i, seed);
    float b = hash(i + float2(1, 0), seed);
    float c = hash(i + float2(0, 1), seed);
    float d = hash(i + float2(1, 1), seed);
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

/// `octaves` octaves (each is four hashes per pixel, so this is the cost
/// knob), normalized, then stretched over 0…1 the way an equalized noise
/// texture is — a plain octave sum bunches around the middle.
float fbm(float2 p, uint seed, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float total = 0.0;
    for (int octave = 0; octave < octaves; octave++) {
        value += amplitude * valueNoise(p, seed);
        total += amplitude;
        p = p * 2.03 + float2(17.1, 31.7);
        amplitude *= 0.5;
    }
    return smoothstep(0.2, 0.8, value / total);
}

/// Two independent channels of noise, like the two channels of a texture.
float2 noise2(float2 p, int octaves) {
    return float2(
        fbm(p, 0x9E3779B9u, octaves),
        fbm(p + float2(37.2, 11.9), 0x85EBCA6Bu, octaves)
    );
}

/// The 3×3 color grid, read at `r` in 0…1 with smooth interpolation
/// between the nine entries — the stand-in for a still mesh gradient.
half4 colorField(float2 r, half4 background, half4 pool, half4 core) {
    half4 grid[9] = {
        background, pool, background,
        pool, core, background,
        background, background, pool,
    };
    float2 cell = min(r * 2.0, 1.999);
    int2 i = int2(floor(cell));
    float2 f = fract(cell);
    f = f * f * (3.0 - 2.0 * f);
    half4 top = mix(grid[i.y * 3 + i.x], grid[i.y * 3 + i.x + 1], half(f.x));
    half4 bottom = mix(grid[(i.y + 1) * 3 + i.x], grid[(i.y + 1) * 3 + i.x + 1], half(f.x));
    return mix(top, bottom, half(f.y));
}

}

[[stitchable]] half4 BackgroundWarp(
    float2 position,
    float2 size,
    float time,
    float spread,
    half4 background,
    half4 pool,
    half4 core
) {
    float2 uv = position / size;

    // First pass: a slow, large-scale drift, about one cell across the
    // screen so the folds are broad — two octaves are all that shows.
    float2 q = noise2(uv * 1.1 + float2(time * 0.12, time * 0.08), 2);

    // Second pass, bent by the first — this is what makes the marbling.
    // Three octaves: the finest detail the folds need. This runs on every
    // pixel of the screen every frame, so each octave costs.
    float2 r = noise2(uv * 1.6 + q * 2.8 + float2(-time * 0.06, time * 0.1), 3);

    r = (r - float2(0.5)) * spread + float2(0.5);
    r = clamp(r, float2(0), float2(1));

    return colorField(r, background, pool, core);
}
