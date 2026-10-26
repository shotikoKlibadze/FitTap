import SwiftUI

/// Semantic color tokens — the only source of colors in the app.
/// Feature code and components never use raw `Color` values directly.
public enum FTColors {
    // MARK: - Backgrounds

    /// App screen background. rgb(0, 0, 0) dark / rgb(242, 242, 247) light.
    public static let background = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            : UIColor(red: 242 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1)
    })
    /// Cards and grouped content surfaces. rgb(15, 15, 17) dark / rgb(250, 250, 252) light.
    public static let surface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 15 / 255, green: 15 / 255, blue: 17 / 255, alpha: 1)
            : UIColor(red: 250 / 255, green: 250 / 255, blue: 252 / 255, alpha: 1)
    })

    // MARK: - Text

    /// `FTCoreColors.offWhite` in dark mode, `.nearBlack` in light.
    public static let textPrimary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(FTCoreColors.offWhite)
            : UIColor(FTCoreColors.nearBlack)
    })
    /// Secondary text — subtitles, hints, placeholders.
    /// rgba(255, 255, 255, 0.42) dark / rgba(0, 0, 0, 0.45) light.
    public static let textSecondary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.42)
            : UIColor(white: 0, alpha: 0.45)
    })

    // MARK: - Semantic

    /// Brand green — primary actions, selection states.
    /// rgb(47, 90, 70) dark / rgb(56, 112, 86) light.
    public static let green = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 47 / 255, green: 90 / 255, blue: 70 / 255, alpha: 1)
            : UIColor(red: 56 / 255, green: 112 / 255, blue: 86 / 255, alpha: 1)
    })
    
    /// Checkmarks, selected states, green text — lighter than the button
    /// green so a selection doesn't read as a tappable button.
    /// rgb(111, 164, 135) dark / rgb(56, 112, 86) light.
    public static let greenAccent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 111 / 255, green: 164 / 255, blue: 135 / 255, alpha: 1)
            : UIColor(red: 56 / 255, green: 112 / 255, blue: 86 / 255, alpha: 1)
    })

    /// Destructive red — delete and stop states.
    /// rgb(160, 60, 64) dark / rgb(196, 64, 70) light.
    public static let red = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 160 / 255, green: 60 / 255, blue: 64 / 255, alpha: 1)
            : UIColor(red: 196 / 255, green: 64 / 255, blue: 70 / 255, alpha: 1)
    })

    /// A surface sitting on another surface — icon circles, inner chips.
    /// rgba(255, 255, 255, 0.08) dark / rgba(0, 0, 0, 0.06) light.
    public static let surfaceSecondary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.08)
            : UIColor(white: 0, alpha: 0.06)
    })

    /// Secondary button fill on cards — reps/weight pills, "+ Add Set".
    /// rgba(255, 255, 255, 0.06) dark / rgba(0, 0, 0, 0.05) light.
    public static let secondary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.06)
            : UIColor(white: 0, alpha: 0.05)
    })

    /// Warm yellow — highlights and attention states.
    /// rgb(224, 193, 136) dark / rgb(143, 107, 30) light.
    public static let yellow = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 224 / 255, green: 193 / 255, blue: 136 / 255, alpha: 1)
            : UIColor(red: 143 / 255, green: 107 / 255, blue: 30 / 255, alpha: 1)
    })

    /// AI gold — suggestions and anything the coach says. A warmer metallic
    /// tone than `yellow`, the same `FTCoreColors.aiGold` in both modes.
    public static let aiGold = FTCoreColors.aiGold

    /// Fill behind `aiGold` glyphs. On light grounds a gray fill dulls the
    /// gold to olive; a warm cream lets it read as metal.
    /// rgba(255, 255, 255, 0.06) dark / rgb(251, 243, 219) light.
    public static let aiGoldSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.06)
            : UIColor(red: 251 / 255, green: 243 / 255, blue: 219 / 255, alpha: 1)
    })

    /// Warm fill under a yellow border — the selected tile.
    /// rgb(52, 45, 33) dark / rgb(250, 243, 226) light.
    public static let yellowSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 52 / 255, green: 45 / 255, blue: 33 / 255, alpha: 1)
            : UIColor(red: 250 / 255, green: 243 / 255, blue: 226 / 255, alpha: 1)
    })

    /// Flat divider lines between list rows — a third of the separator's
    /// brightness. rgba(255, 255, 255, 0.06) dark / rgba(0, 0, 0, 0.06) light.
    public static let divider = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.06)
            : UIColor(white: 0, alpha: 0.06)
    })

    /// Dashed borders and strokes.
    /// rgba(255, 255, 255, 0.18) dark / rgba(60, 60, 67, 0.3) light.
    public static let separator = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.18)
            : UIColor(red: 60 / 255, green: 60 / 255, blue: 67 / 255, alpha: 0.3)
    })

    // MARK: - Elevated surfaces

    // Raised surfaces on the screen background (cards, fields, the type
    // switcher) — see `elevatedSurface(in:)`. Dark mode can't show a shadow
    // on pure black, so the surface gets lighter instead: a lit top, a lit
    // edge. Light mode keeps the flat surface color and lets the shadow lift.

    /// Top of `FTGradients.elevatedSurfaceBackground`.
    /// rgb(25, 25, 28) dark / rgb(250, 250, 252) light.
    public static let elevatedSurfaceTop = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 25 / 255, green: 25 / 255, blue: 28 / 255, alpha: 1)
            : UIColor(red: 250 / 255, green: 250 / 255, blue: 252 / 255, alpha: 1)
    })
    /// Bottom of `FTGradients.elevatedSurfaceBackground`.
    /// rgb(18, 18, 20) dark / rgb(250, 250, 252) light.
    public static let elevatedSurfaceBottom = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 18 / 255, green: 18 / 255, blue: 20 / 255, alpha: 1)
            : UIColor(red: 250 / 255, green: 250 / 255, blue: 252 / 255, alpha: 1)
    })
    /// Light catching the top edge, fading out by the middle.
    /// rgba(255, 255, 255, 0.12) dark / clear light.
    public static let elevatedSurfaceHighlight = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.12)
            : UIColor(white: 1, alpha: 0)
    })
    /// Hairline separating the surface from the background.
    /// rgba(255, 255, 255, 0.10) dark / clear light.
    public static let elevatedSurfaceHairline = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.10)
            : UIColor(white: 1, alpha: 0)
    })
    /// Drop shadow. rgba(0, 0, 0, 0.65) dark / rgba(0, 0, 0, 0.07) light.
    public static let elevatedSurfaceShadow = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0, alpha: 0.65)
            : UIColor(white: 0, alpha: 0.07)
    })

    // MARK: - Overlays

    /// Dims the whole app behind an alert.
    /// rgba(0, 0, 0, 0.55) dark / rgba(0, 0, 0, 0.3) light.
    public static let scrim = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0, alpha: 0.55)
            : UIColor(white: 0, alpha: 0.3)
    })
}

#if DEBUG
private struct FTColorSwatch: Identifiable {
    var id: String { name }
    let name: String
    let color: Color
}

private let ftColorSwatches: [FTColorSwatch] = [
    FTColorSwatch(name: "background", color: FTColors.background),
    FTColorSwatch(name: "surface", color: FTColors.surface),
    FTColorSwatch(name: "surfaceSecondary", color: FTColors.surfaceSecondary),
    FTColorSwatch(name: "secondary", color: FTColors.secondary),
    FTColorSwatch(name: "textPrimary", color: FTColors.textPrimary),
    FTColorSwatch(name: "textSecondary", color: FTColors.textSecondary),
    FTColorSwatch(name: "green", color: FTColors.green),
    FTColorSwatch(name: "greenAccent", color: FTColors.greenAccent),
    FTColorSwatch(name: "red", color: FTColors.red),
    FTColorSwatch(name: "yellow", color: FTColors.yellow),
    FTColorSwatch(name: "yellowSurface", color: FTColors.yellowSurface),
    FTColorSwatch(name: "aiGold", color: FTColors.aiGold),
    FTColorSwatch(name: "aiGoldSurface", color: FTColors.aiGoldSurface),
    FTColorSwatch(name: "divider", color: FTColors.divider),
    FTColorSwatch(name: "separator", color: FTColors.separator),
    FTColorSwatch(name: "elevatedSurfaceTop", color: FTColors.elevatedSurfaceTop),
    FTColorSwatch(name: "elevatedSurfaceBottom", color: FTColors.elevatedSurfaceBottom),
    FTColorSwatch(name: "elevatedSurfaceHighlight", color: FTColors.elevatedSurfaceHighlight),
    FTColorSwatch(name: "elevatedSurfaceHairline", color: FTColors.elevatedSurfaceHairline),
    FTColorSwatch(name: "elevatedSurfaceShadow", color: FTColors.elevatedSurfaceShadow),
    FTColorSwatch(name: "scrim", color: FTColors.scrim),
]

private struct FTColorsPreviewHost: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(ftColorSwatches) { swatch in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(swatch.color)
                            .stroke(FTColors.separator, lineWidth: 1)
                            .frame(width: 56, height: 36)
                        Text(swatch.name)
                            .font(FTFonts.body)
                            .foregroundStyle(FTColors.textPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(FTColors.background)
    }
}
#Preview("Light") {
    FTColorsPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    FTColorsPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
