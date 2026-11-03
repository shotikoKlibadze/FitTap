---
name: screen-layout
description: Use when building or changing how a screen, sheet, or view is laid out — gutters, padding and margins, the screen background, screen titles and section headers, horizontal scrolling rows (edge to edge, shadows cut off), scroll indicators, non-scrolling screens, and bottom-sheet content. Covers where things sit on screen and how far apart; who owns what is the architecture skill, tokens and components are the design-system skill.
paths:
  - "FitTap/**/*.swift"
---

# Screen layout

Where every screen, sheet and view sits on the screen, and how far apart things are. A layout rule is a fixed role: the same on every screen, so screens feel like one app.

Neighbours: the `architecture` skill decides which type a piece lives in (Screen, ScreenModel, View); the `design-system` skill supplies the tokens and components named here.

## Project values

The rules below use these. Another project swaps the table, not the rules.

| Role | Value |
|---|---|
| Gutter | 16 pt |
| Screen background | `FTColors.background` |
| Sheet background | `FTColors.sheetSurface`, painted by `BottomSheet` |
| Screen title | `FTFonts.largeTitleBold`, `textPrimary` |
| Sheet title | `FTFonts.title3Semibold`, `textPrimary` |
| Section header | the `SectionTitle` component (`subheadlineBold`, `textPrimary`, optional "See All") |
| Form label | the `SectionHeader` component |
| Shadow room in a scroll clip | 12 pt (fits the `.regular` elevation: radius 9, 3 pt down) |
| Bottom scroll margin | 32 pt |

## Background — hard rule

- **Nothing is left to the system.** Every screen's View paints its root with the screen background, or the screen's own painted background (the session mesh). It goes in the production `body`, never only in the preview host.
- **A sheet's View paints nothing.** `BottomSheet` fills the sheet background behind it; a fill on the View would cover it.
- Cards get their surface and shadow from `.elevatedSurface`. They're tuned for the screen background, so a system white or black under them flattens them.

## Scrolling screens — the gutter (hard rule)

- A scrolling screen is a `ScrollView` with `.contentMargins(.horizontal, 16, for: .scrollContent)`. The scroll view adds no margin of its own: the value you pass *is* the gutter.
- Never pad the scroll content horizontally on top of that, and never use a different value. Titles, section headers and cards all sit on the same 16 pt edge.
- End the content with `.contentMargins(.bottom, 32, for: .scrollContent)`.
- Bottom- or top-pinned controls in `.safeAreaInset` take `.padding(.horizontal, 16)` to line up with the content.

```swift
ScrollView {
    VStack(spacing: 8) { … }                           // no horizontal padding here
}
.contentMargins(.horizontal, 16, for: .scrollContent)  // the gutter
.contentMargins(.bottom, 32, for: .scrollContent)
.scrollIndicators(.hidden)
.background(FTColors.background)
```

## Horizontal rows inside a screen

- **They run edge to edge.** Pull the row out of the gutter with `.padding(.horizontal, -16)` and give it its own `.contentMargins(.horizontal, 16, for: .scrollContent)`. Items rest on the gutter but slide to the screen edges while scrolling; never clip them at the gutter.
- **Paged rows** use `.scrollTargetBehavior(.viewAligned)`, a 16 pt gap and `.containerRelativeFrame(.horizontal)`, so neighbours rest just off screen. They share the week strip's scroll transition (scale down 12 %, fade 30 % as an item leaves).
- **Rows of elevated cards leave shadow room.** Pad the row's content vertically by 12 pt so the scroll clip doesn't cut the shadows, and add `.padding(.top, -12)` outside so the spacing above stays the same.
- A row nested in a vertical scroll uses `HStack`, not `LazyHStack`: the lazy stack misreports its height there and overlaps what's above it.

## Titles and headers

- **A tab's root screen draws its title in content**: the screen title role, first in the scroll, then the sections. Pushed screens take their title from `.appToolbar(title:)` on the Screen instead (see the `architecture` skill).
- **A section header is always `SectionTitle`**, sitting on the gutter like the cards, with "See All" only when the section has somewhere to go. `SectionHeader` is for form labels ("Type", "Muscle Groups"), never for sections.
- **A sheet's title** uses the sheet title role, at the top of the sheet content.

## Non-scrolling screens

- The root content takes `.padding(.horizontal, 16)`: the same gutter, applied once at the root.
- The background goes on the root too, outside that padding, so it fills the screen.

## Sheets

- A sheet View is the content of a `BottomSheet` (presented through a destination; see the `navigation` skill). It paints no background.
- **Fixed height:** the sheet never measures its content. The height lives in the screen's `…Metrics` helper, and the View frames its content to it.
- **Same 16 pt gutter as screens.** A scrolling sheet uses the content-margin gutter; a fixed one pads its root by 16.
- Content that scrolls under the title keeps the title in a top `.safeAreaInset`, over `FTGradients.sheetFadeTop`, so rows dissolve under it instead of being cut at a hard edge.
- Buttons inside a sheet are the flat `PillButton`, not glass (see the `design-system` skill).

## Scroll indicators

- Hidden on every scroll view: `.scrollIndicators(.hidden)`. Calm screens: no bar flashing in while scrolling.
- **Exception: a list inside a fixed-size box** (a dropdown, an open picker) where the options are cut off and nothing else hints there's more. It uses `.scrollIndicators(.visible)` plus `.scrollIndicatorsFlash(onAppear: true)`, so the bar flashes once when it opens.

## Rules recap

1. Every screen's View paints its own background in production code; sheet Views paint nothing (the sheet does); nothing shows the system's.
2. 16 pt gutter everywhere: `.contentMargins(.horizontal, 16, …)` on scrolling screens and sheets, `.padding(.horizontal, 16)` on non-scrolling roots and pinned controls. No other value, no padding on top.
3. Horizontal rows run edge to edge (−16 out, 16 content margins back), page with `.viewAligned` and a 16 pt gap, and leave 12 pt shadow room for elevated cards.
4. Tab roots draw a large title in content; pushed screens title through `.appToolbar`; sheets use the sheet title; sections use `SectionTitle`.
5. Sheets: fixed height from Metrics, title over the sheet fade when content scrolls under it, flat buttons.
6. Scroll indicators hidden, except in a fixed-size box with cut-off options.
