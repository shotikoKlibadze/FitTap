import SwiftUI

/// Semantic color tokens — the only source of colors in the app.
/// Feature code and components never use raw `Color` values directly.
public enum FTColors {
    // MARK: - Backgrounds

    /// App screen background — the ground everything else sits on.
    /// Used for: every screen's root (Home, Workouts, the workout screen),
    /// and the base the session's mesh background mixes into, and the end
    /// colour of the top and bottom fades. Dark mode is a dark gray, not pure
    /// black: one black shadow is then enough to lift a card.
    /// rgb(18, 18, 18) dark / rgb(242, 242, 247) light.
    public static let background = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 18 / 255, green: 18 / 255, blue: 18 / 255, alpha: 1)
            : UIColor(red: 242 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1)
    })
    /// Cards and controls sitting on the screen background — flat, lifted
    /// only by a hairline and one shadow (see `elevatedSurface(in:)`).
    /// Used for: workout session cards on Home, workout list items, the plan
    /// calendar card, the set value pickers (reps, weight, duration, speed),
    /// round buttons (✕, back), flat pills, unselected chips, tiles.
    /// rgb(28, 28, 30) dark / rgb(255, 255, 255) light.
    public static let surface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    })
    /// The body of every overlay — the darkest thing on screen in dark mode,
    /// so it reads as the focus over the lightened screen behind it.
    /// Used for: every bottom sheet (Plan Day, the set value pickers, Add
    /// Exercise, New Exercise), the app alert, and as the glass tint of the
    /// "End this workout?" card and the Plan pill and its calendar card.
    /// rgb(8, 8, 8) dark / rgb(255, 255, 255) light.
    public static let sheetSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 8 / 255, green: 8 / 255, blue: 8 / 255, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    })

    // MARK: - Text

    /// Main text and icons.
    /// Used for: titles ("Push Day"), card names, set values ("10 reps"),
    /// toolbar icons, the selected chip's fill.
    /// `FTCoreColors.offWhite` in dark mode, `.nearBlack` in light.
    public static let textPrimary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(FTCoreColors.offWhite)
            : UIColor(FTCoreColors.nearBlack)
    })
    /// Secondary text — subtitles, hints, placeholders.
    /// Used for: section headers ("This Week", "Exercises"), card stats
    /// ("55 min · 5 exercises"), units ("kg /side"), set numbers, an
    /// unchecked set's checkmark, disabled pill text.
    /// rgba(255, 255, 255, 0.42) dark / rgba(0, 0, 0, 0.45) light.
    public static let textSecondary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.42)
            : UIColor(white: 0, alpha: 0.45)
    })

    // MARK: - Semantic

    /// Brand green — primary actions, selection states.
    /// Used for: primary pills ("Finish Workout", "Save Workout"), the
    /// "Plan workout" + circle, the selected segment of the type toggle, the
    /// selected day in the month calendar.
    /// rgb(47, 90, 70) dark / rgb(56, 112, 86) light.
    public static let green = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 47 / 255, green: 90 / 255, blue: 70 / 255, alpha: 1)
            : UIColor(red: 56 / 255, green: 112 / 255, blue: 86 / 255, alpha: 1)
    })
    
    /// Checkmarks, selected states, green text — lighter than the button
    /// green so a selection doesn't read as a tappable button.
    /// Used for: a checked set's checkmark, the session progress ring, the
    /// selected day's ring in the week strip, today in the month calendar,
    /// the picked workout in Plan Day, the selected value in a value grid.
    /// rgb(111, 164, 135) dark / rgb(56, 112, 86) light.
    public static let greenAccent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 111 / 255, green: 164 / 255, blue: 135 / 255, alpha: 1)
            : UIColor(red: 56 / 255, green: 112 / 255, blue: 86 / 255, alpha: 1)
    })

    /// Destructive red — delete and stop states.
    /// Used for: destructive pills ("End Workout"), a missed session — its
    /// dashed card border, "Missed" label and dot, and its dot in the week
    /// strip.
    /// rgb(160, 60, 64) dark / rgb(196, 64, 70) light.
    public static let red = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 160 / 255, green: 60 / 255, blue: 64 / 255, alpha: 1)
            : UIColor(red: 196 / 255, green: 64 / 255, blue: 70 / 255, alpha: 1)
    })

    /// Red as a *state*, not an action — lighter than `red` in dark mode so a
    /// "Hard" rating doesn't read as a destructive button.
    /// Used for: the Hard option on the "How did it feel?" strip.
    /// rgb(192, 86, 91) dark / rgb(196, 64, 70) light.
    public static let redAccent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 192 / 255, green: 86 / 255, blue: 91 / 255, alpha: 1)
            : UIColor(red: 196 / 255, green: 64 / 255, blue: 70 / 255, alpha: 1)
    })

    /// Yellow that works as a fill. In light mode `yellow` is a text colour
    /// and turns orange when filled; this is a cleaner gold.
    /// Used for: the Medium option on the "How did it feel?" strip.
    /// rgb(224, 193, 136) dark / rgb(201, 162, 39) light.
    public static let yellowFill = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 224 / 255, green: 193 / 255, blue: 136 / 255, alpha: 1)
            : UIColor(red: 201 / 255, green: 162 / 255, blue: 39 / 255, alpha: 1)
    })

    /// Text on a solid accent fill — `greenAccent`, `yellowFill`,
    /// `redAccent`. Those fills are light in dark mode and deep in light mode,
    /// so the text flips the other way.
    /// Used for: the selected option's label on the "How did it feel?" strip.
    /// rgb(14, 14, 16) dark / rgba(255, 255, 255, 0.95) light.
    public static let textOnAccent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 14 / 255, green: 14 / 255, blue: 16 / 255, alpha: 1)
            : UIColor(white: 1, alpha: 0.95)
    })

    /// A surface sitting on another surface — icon circles, inner chips.
    /// Used for: the icon circle in exercise and workout list rows, the name
    /// field's capsule, secondary pills ("Plan", "Cancel", "+ Add Set"),
    /// disabled pills, the empty track of the session progress ring.
    /// rgba(255, 255, 255, 0.08) dark / rgba(0, 0, 0, 0.06) light.
    public static let surfaceSecondary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.08)
            : UIColor(white: 0, alpha: 0.06)
    })

    /// Secondary button fill on cards — tappable values inside a card.
    /// Used for: the reps and weight pills on an exercise card, unselected
    /// cells in a value grid and tiles, the number entry capsule, the chip
    /// picker's fill.
    /// rgba(255, 255, 255, 0.06) dark / rgba(0, 0, 0, 0.05) light.
    public static let secondary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.06)
            : UIColor(white: 0, alpha: 0.05)
    })

    /// Warm yellow — highlights and attention states.
    /// Used for: the "+ Add Set" pill's text, the + icon on Add Exercise, a
    /// selected tile's border and label.
    /// rgb(224, 193, 136) dark / rgb(143, 107, 30) light.
    public static let yellow = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 224 / 255, green: 193 / 255, blue: 136 / 255, alpha: 1)
            : UIColor(red: 143 / 255, green: 107 / 255, blue: 30 / 255, alpha: 1)
    })

    /// AI gold — suggestions and anything the coach says. A warmer metallic
    /// tone than `yellow`, the same `FTCoreColors.aiGold` in both modes.
    /// Used for: the suggestion (magic wand) button on each exercise card —
    /// its glyph and ring.
    public static let aiGold = FTCoreColors.aiGold

    /// Fill behind `aiGold` glyphs. On light grounds a gray fill dulls the
    /// gold to olive; a warm cream lets it read as metal.
    /// Used for: the fill inside the suggestion button.
    /// rgba(255, 255, 255, 0.06) dark / rgb(251, 243, 219) light.
    public static let aiGoldSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.06)
            : UIColor(red: 251 / 255, green: 243 / 255, blue: 219 / 255, alpha: 1)
    })

    /// Warm fill under a yellow border — the selected tile.
    /// Used for: the selected tile button (e.g. a picked option in New
    /// Exercise).
    /// rgb(52, 45, 33) dark / rgb(250, 243, 226) light.
    public static let yellowSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 52 / 255, green: 45 / 255, blue: 33 / 255, alpha: 1)
            : UIColor(red: 250 / 255, green: 243 / 255, blue: 226 / 255, alpha: 1)
    })

    /// Flat divider lines between list rows — a third of the separator's
    /// brightness.
    /// Used for: the line under an exercise card's title, the vertical lines
    /// between stats in the stats strip ("5 exercises | 15 sets"), rows in
    /// exercise lists and the chip picker.
    /// rgba(255, 255, 255, 0.06) dark / rgba(0, 0, 0, 0.06) light.
    public static let divider = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.06)
            : UIColor(white: 0, alpha: 0.06)
    })

    /// Dashed borders and strokes.
    /// Used for: a planned session's dashed card border, the dashed "Plan
    /// workout" card, day-cell borders in the week strip, an unchecked set's
    /// ring, past days in the month calendar, the bottom sheet's grabber.
    /// rgba(255, 255, 255, 0.18) dark / rgba(60, 60, 67, 0.3) light.
    public static let separator = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.18)
            : UIColor(red: 60 / 255, green: 60 / 255, blue: 67 / 255, alpha: 0.3)
    })

    // MARK: - Elevated surfaces

    // Raised surfaces on the screen background — see `elevatedSurface(in:)`.
    // Used for: exercise cards, Home's session cards, the session summary
    // card, week strip day cells, the stats strip, the profile avatar, the
    // type toggle, the chip picker. Both modes use the same flat recipe: the
    // surface colour, a 0.5 pt hairline and one drop shadow. Only the token
    // values differ between dark and light.

    /// Top of `FTGradients.elevatedSurfaceBackground` — equal to the bottom
    /// stop now that cards are flat; kept so the gradient API still works.
    /// rgb(28, 28, 30) dark / rgb(255, 255, 255) light.
    public static let elevatedSurfaceTop = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    })
    /// Bottom of `FTGradients.elevatedSurfaceBackground` — same as the top.
    /// rgb(28, 28, 30) dark / rgb(255, 255, 255) light.
    public static let elevatedSurfaceBottom = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    })
    /// Retired top-edge highlight from the pure-black theme. Clear in both
    /// modes and drawn nowhere; kept so the token name still resolves.
    public static let elevatedSurfaceHighlight = Color(uiColor: UIColor { _ in
        UIColor(white: 1, alpha: 0)
    })
    /// Hairline edge drawn inside every raised surface.
    /// rgba(255, 255, 255, 0.05) dark / rgba(0, 0, 0, 0.06) light.
    public static let elevatedSurfaceHairline = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.05)
            : UIColor(white: 0, alpha: 0.06)
    })
    /// The one drop shadow under a raised surface.
    /// rgba(0, 0, 0, 0.50) dark / rgba(0, 0, 0, 0.08) light.
    public static let elevatedSurfaceShadow = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0, alpha: 0.50)
            : UIColor(white: 0, alpha: 0.08)
    })

    // MARK: - Overlays

    /// Covers the app behind an overlay. In dark mode it is a gray that
    /// *lightens* what's behind it, so a near-black sheet or alert reads as
    /// the focus; in light mode it darkens, as usual.
    /// Used for: behind app alerts, the "End this workout?" card, the open
    /// Plan calendar on the workout screen, and bottom sheets.
    /// rgba(77, 77, 77, 0.30) dark / rgba(0, 0, 0, 0.30) light.
    public static let scrim = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 77 / 255, green: 77 / 255, blue: 77 / 255, alpha: 0.30)
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
    FTColorSwatch(name: "sheetSurface", color: FTColors.sheetSurface),
    FTColorSwatch(name: "surfaceSecondary", color: FTColors.surfaceSecondary),
    FTColorSwatch(name: "secondary", color: FTColors.secondary),
    FTColorSwatch(name: "textPrimary", color: FTColors.textPrimary),
    FTColorSwatch(name: "textSecondary", color: FTColors.textSecondary),
    FTColorSwatch(name: "green", color: FTColors.green),
    FTColorSwatch(name: "greenAccent", color: FTColors.greenAccent),
    FTColorSwatch(name: "red", color: FTColors.red),
    FTColorSwatch(name: "redAccent", color: FTColors.redAccent),
    FTColorSwatch(name: "yellowFill", color: FTColors.yellowFill),
    FTColorSwatch(name: "textOnAccent", color: FTColors.textOnAccent),
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
#Preview("Dark") {
    FTColorsPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    FTColorsPreviewHost()
        .preferredColorScheme(.light)
}
#endif
