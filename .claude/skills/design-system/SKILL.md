---
name: design-system
description: Use when writing ANY view code — screens, subviews, or reusable components — the design system (the local DesignSystem package: FTColors, FTFonts, its components) is mandatory everywhere; also defines where components live (package vs. the app's SharedUI), how they're named (no FT prefix), and its Light/Dark gallery preview.
---

# Design System

The design system is **mandatory, not optional**. Every color, font, and reusable piece of UI anywhere in the app comes from the `DesignSystem` package (or, for UI that needs app models, `SharedUI/`) — this is a hard rule with no "just this once" exceptions.

Full code examples: [reference.md](reference.md).

## Where it lives

The design system is a **local Swift package**, linked to the app target. Files use it with `import DesignSystem`.

```
Packages/DesignSystem/
├── Package.swift                   // compiler settings mirror the app target
└── Sources/DesignSystem/
    ├── Tokens/                     // FTColors, FTFonts, FTGradients, FTIcons
    ├── Components/                 // Buttons/, Chip/, Input/, Navigation/, BottomSheet/, …
    ├── Helpers/                    // View+AppAlert, View+BottomSheet, View+ElevatedSurface, …
    └── Resources/Media.xcassets    // icon assets — load with Image(_:bundle: .module)

FitTap/SharedUI/                    // reusable UI that needs the app's models
├── Cards/                          // ExerciseCard
├── ExerciseListItem.swift
└── Styling/                        // WorkoutColor+Color, Equipment+Icon
```

## Hard rules — the package boundary

- **The package never knows the app's models.** No `Exercise`, `MuscleGroup`, `Equipment`, formatters or stores inside it — it takes plain values (`String`, `Image`, `Double`, closures such as a `label: (Double) -> String`). Previews in the package use plain sample data.
- **UI that needs a model lives in `FitTap/SharedUI/`**, built from package components and tokens. Same naming, preview and token rules as the package.
- **The test is "model-free", not "reused".** A component that can take plain values belongs in the package even if one screen uses it — it previews fast and outlives the model. It goes to `SharedUI/` only when it must read or edit a model (`ExerciseCard` edits a `WorkoutExercise` binding).
- **A screen maps its model to a package component through an `…Item`** in its `Helpers/` (`SessionCardItem`, `WorkoutCardItem`): an `init(model:)` that does all formatting, then the View passes the item's fields to the component.
- **A package component's API is `public`:** the type, an explicit `public init` (memberwise inits are internal), `public var body`, and any nested enums or constants the app reads. Implementation details stay `private`. A component that's only reached through a modifier (`AppAlert`, `BottomSheet`) stays internal and its modifier is public.
- **Package assets load with `bundle: .module`.**

`AppToolbar` is attached by the **Screen**, never by a View, and always carries a title and a back button unless the task says otherwise (see the `architecture` skill).

## Hard rules — tokens

- **Never build a `Font` or `Color` in feature code or components.** No `.font(.caption2.weight(.semibold))`, no `Color.red`, no `.opacity()` color tweaks, no hex. Always `FTFonts.label`, `FTColors.accent`, etc.
- **Two color layers.** `FTCoreColors` are fixed values that never adapt to light/dark (`offWhite`, `nearBlack`); the semantic `FTColors` are built from them and adapt. Views use `FTColors`. A core color is only for a spot that must stay one color in both modes — text on a fill that doesn't adapt, like the selected green cell. A new fixed value goes into `FTCoreColors` first, then semantic tokens reference it.
- **Text and icons on green or red fills are always `FTCoreColors.offWhite`**, in both modes — those fills stay dark, so the adaptive `textPrimary` turns near-black on them in light mode. Applies to `green`, `greenAccent` and `red` fills (pills, the selected toggle segment, selected grid cells, checkmarks, the add circle).
- Fonts are named by **role** (`cardTitle`, `subtitle`, `label`), not by size — pick the role, not the look.
- **Missing token → add the token** (or ask), never inline the value. A one-off value in a view is a defect.
- The user-assignable `WorkoutColor` palette maps to rendered colors only through `SharedUI/Styling/WorkoutColor+Color.swift`.

## Hard rules — components

- **Never change existing component code unless explicitly told to.** Existing components are settled: no refactors, no restyling, no architectural rewrites, no "improvements" as a side effect of another task. A request that *uses* a component is not permission to edit it. If a task seems to require changing one, stop and ask first.
- **Check the package's `Components/` (and `SharedUI/`) before writing any view.** If a component exists for the job, use it — never build a detached look-alike in a feature folder.
- One file per component, named plainly after what it is: `WorkoutCard`, `SegmentedToggle`, `ListItem`. **No `FT` prefix on components** — the `FT` prefix belongs to the token namespaces only (`FTColors`, `FTFonts`, `FTIcons`). When the plain name collides with a SwiftUI type (`Button`, `Toolbar`, `Label`), prefix with `App`: `AppToolbar`. Otherwise find a plain descriptive name (`PillButton`). Button styles and helpers are plain too (`PressButtonStyle`).
- **Promotion rule:** a view used by two or more features — or obviously generic (any button, any input) — belongs in the package, or in `SharedUI/` if it needs app models. A view specific to one screen stays in that feature's `Subviews/` (and still uses tokens).

## Hard rules — buttons

- **Never hand-build a button. Every button comes from the package's `Components/Buttons/`** (`PillButton`, `GlassPillButton`, `RoundButton`, `CardAddButton`, …) — in screens, subviews, and new components alike. No inline `Button { … } label: { Text(…).background(Capsule()…) }`, no restyled copies of an existing one.
- **Pill buttons: pick the surface, then the meaning.** `GlassPillButton` for a screen's own actions pinned over its content (Start Workout, Save, Add); the flat `PillButton` inside sheets, alerts and cards — glass there would sit on glass. Both take the same `PillStyle`: `.primary` (green), `.secondary` (faint surface), `.destructive` (red), `.add` (faint surface, yellow text — "+ Add Set"), and the same `PillButtonSize`.
- **Another look goes inside the shared enums.** A new meaning → a case on `PillStyle` (both pills get it); a size → `PillButtonSize`; another button kind's variant → its own enum. Never a restyled copy outside them.
- **No button fits at all → stop and ask.** The answer is a new variant or a new component in `Buttons/` — never a one-off styled `Button` in place. Asking is mandatory because changing an existing button is a component change (see below).
- **The one exception: `AppToolbar`'s bar items.** They're plain glyphs on the system's shared glass, drawn inside `AppToolbar` — our own button chrome there breaks the push/pop morph.
- A tappable surface that isn't a button — a card, a list row, a grid cell, a picker tile — is its own component and may wrap a `Button` around its content. The rule targets button-shaped controls: pills, capsules, circles, text actions.

## Hard rules — elevation

- **A raised surface on the screen background uses `.elevatedSurface(in: shape)`** — cards, input fields, the type switcher, picker cards. Never a hand-rolled fill + shadow.
- Its look comes only from adaptive tokens (`FTColors.elevatedSurface*`, `FTGradients.elevatedSurfaceBackground`): dark mode gets the lit gradient, top highlight and hairline (a shadow can't show on black); light mode resolves to the flat surface with a soft shadow. Never branch on `colorScheme` for it — change the tokens.
- Controls *inside* a raised surface (pills, ✕, + Add Set) stay flat — no elevation on elevation.

## Hard rules — alerts

- **The app has one alert: `AppAlert`, presented with `.appAlert(isPresented:…)`.** Never use SwiftUI's `.alert`, `.confirmationDialog`, or a hand-rolled overlay or card for a question to the user.
- It sits where the system alert does (centered) over a dimmed app (`FTColors.scrim`, covering toolbar and tab bar too). Don't morph, anchor, or attach confirmations to the control that triggered them.
- The screen owns an `isShowing…Alert` `@State`; the action that needs confirming sets it to `true`. Put destructive or navigating work in the action's handler (`onConfirm`) — it runs after the alert has fully left, so popping or dismissing is safe there.
- **Two shapes, one alert.** A yes/no question uses the shortcut `.appAlert(…, confirmTitle:, confirmStyle:, cancelTitle:, onConfirm:)` — a colored confirm over a quiet cancel. A choice between equal paths passes `actions: [AppAlertAction]` — each its own title, `PillStyle` and handler (e.g. "Edit Workout" / "Change Date", both `.secondary`). A tap on the dimmed background always just closes it.
- An alert need neither shape covers (an input field, a list) → ask before extending `AppAlert`; never build a second alert.

## How components are built

- Dumb, like every view (see the `architecture` skill): `let` properties, bindings, and callbacks. No models, services, or navigation.
- **The whole visible shape is tappable — hard rule.** Every tappable element (`Button` label, `.onTapGesture` target) declares `.contentShape(...)` matching its visible shape — `Capsule()`, `Circle()`, `RoundedRectangle(...)`, or `Rectangle()` for rows — applied after the frame, before the tap handler. Without it only the glyphs or filled pixels are hittable: a segment, pill, or row whose background is clear (or drawn by a parent) ignores taps on its empty area. → [reference.md §1](reference.md#1-making-the-whole-shape-tappable)
- **Selection state is a `@Binding`, not a callback.** A component whose job is choosing a value (segmented toggle, chips, color swatch, picker row) takes `@Binding var selection`, mutates it itself, and the owner observes the change. Callbacks (`onTap`) are only for *action events* — taps that trigger behavior rather than change a selectable value.
- **Variants are enums, not boolean soup.** `style: .primary` / `.secondary` / `.destructive`, `size: .regular` / `.compact` — never `isPrimary: Bool, isDestructive: Bool, ...`.
- **States derive from inputs**, not from parallel component copies: disabled via `.disabled(...)` + `@Environment(\.isEnabled)`, loading via an `isLoading` property. One component renders all its states.
- Tokens only, per the rules above.
- Shape of a component: [reference.md §2](reference.md#2-component-shape--variants-as-enums-states-from-inputs).

## The gallery preview — Light and Dark

A component's previews follow the `previews` skill: **exactly two, `"Light"` and `"Dark"`**, both rendering one private `…PreviewHost`. For a component, that one host *is* the gallery — every variant laid out together, and interactive so states are reached by tapping rather than by extra previews. → [reference.md §3](reference.md#3-the-light--dark-gallery-host)

- The host covers every variant and lets you reach every state (enabled/disabled, selected, loading) by interacting; include extreme content (longest realistic label) when the component holds text.
- Changing a component means updating its host in the same change — a variant that isn't in the host doesn't exist.

## Rules recap

1. FTColors / FTFonts are the only sources of color and type, everywhere — no inline `Font`/`Color` ever.
2. Missing token → add it to Tokens/ (or ask); never inline the value.
3. Check Components/ first; never build a detached duplicate of an existing component.
4. Reusable UI lives in the `DesignSystem` package (`SharedUI/` when it needs app models), plainly named (no `FT`; `App` only on SwiftUI collisions), one per file; one-screen views stay in feature `Subviews/`.
5. Variants are enums; states derive from inputs; one component renders all its states.
6. Every token set and component has exactly two previews, `"Light"` and `"Dark"`, rendering one interactive gallery host kept current with every change (see the `previews` skill).
7. Components are dumb: properties, bindings, callbacks — nothing else.
8. Every tappable element declares a `.contentShape(...)` matching its visible shape — taps land anywhere on it, never only on the text.
9. Every alert is `.appAlert(...)` — centered over a dimmed app; never `.alert`, `.confirmationDialog`, or a custom overlay.
10. Every button is a `Buttons/` component (toolbar items excepted); a missing color or size is a new case inside the button; nothing fits → ask, never hand-build.
11. The `DesignSystem` package never sees app models; its API is `public` with explicit `public init`s; its assets load with `bundle: .module`.
