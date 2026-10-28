---
name: navigation
description: Use when adding screens, pushing or presenting views, sheets, covers, dismissing, popping, deep links, or any navigation code — the app navigates with the NavigatorUI library (hmlongco/Navigator) through destination enums, not NavigationLink or .sheet bindings.
paths:
  - "FitTap/**/*.swift"
---

# Navigation with NavigatorUI

All navigation goes through [NavigatorUI](https://github.com/hmlongco/Navigator) (SPM: `https://github.com/hmlongco/Navigator`, `import NavigatorUI`). Screens declare *where* they can go in a destination enum; screen models decide *when* by setting a destination property; the Navigator does the rest. `NavigationLink` and raw `.sheet` / `.fullScreenCover` bindings are banned in feature code.

This layers on the `architecture` skill's Screen / ScreenModel / View split:
- **View** — knows nothing about navigation; it fires callbacks.
- **ScreenModel** — owns `var destination: SomeScreenDestination?` and sets it in intent methods. Never touches the navigator.
- **Screen** — binds the destination with `.navigate(to:)`, holds `@Environment(\.navigator)` for imperative calls (pop, dismiss, checkpoint returns).

Full code examples: [reference.md](reference.md).

## Stack shape

→ [reference.md §1](reference.md#1-stack-shape)

`ManagedNavigationStack` (NavigatorUI's replacement for `NavigationStack` — never use the raw one) sits at the root of each tab / feature flow. No `.navigationDestination(for:)` registrations are needed — the managed stack handles rendering.

## Destinations

→ [reference.md §2](reference.md#2-a-destination-enum)

Every screen that navigates gets a `<Name>ScreenDestination` enum (e.g. `HomeScreenDestination`), a separate file in the screen's folder, conforming to `NavigationDestination`. Cases carry plain data; `body` constructs the child **Screen**; `method` declares how each case presents.

### Choosing the method

| method | use when |
|---|---|
| `.push` (default) | continuing the same task deeper — list → detail, detail → edit |
| `.managedSheet` | a secondary, dismissable choice — picker, small form |
| `.managedCover` | an orthogonal flow with its own steps — checkout, wizard, sign-in |
| *(not a destination)* `.bottomSheet(item:height:content:)` | a fixed-height picker over the current screen that never navigates further — reps / weight pickers. The design system's `BottomSheet`, driven by an optional on the screen model; its content hands the result back through a callback |

Rule of thumb: "going to X" → push, "picking X" → sheet, "switching to X mode" → cover.

**The "managed" part matters:** a `.managedSheet` / `.managedCover` destination is presented *inside its own navigation context*, so the presented screen can push further with its own destination enum. **Never wrap a managed destination's content in another `ManagedNavigationStack`** — the method already provides one. (Plain `.sheet` / `.cover` methods exist in the library for modals that never navigate; prefer the managed variants for consistency.)

### Hashable identity

→ [reference.md §3](reference.md#3-hashing-a-mutable-model-case-by-kind)

`NavigationDestination` is `Hashable`. Cases carrying immutable values use synthesized conformance. A case carrying a **mutable model** (an edit screen) must hash by a stable kind, or mutating the model re-presents the sheet mid-edit (keyboard drop, flicker).

## ScreenModel drives, Screen binds

→ [reference.md §4](reference.md#4-screenmodel-drives-screen-binds)

The screen model owns the destination as plain optional state — setting it presents, `nil` tears down. The Screen wires it with one `.navigate(to: $screenModel.destination)`. The screen model never imports NavigatorUI's navigator and never sees a view — it only holds the enum. This keeps it testable: asserting navigation is asserting `screenModel.destination`.

## Dismiss and pop

→ [reference.md §5](reference.md#5-navigator-calls)

Imperative navigation lives in the **Screen** via `@Environment(\.navigator)`: `pop()`, `pop(last:)`, `popToRoot()`, `dismiss()`.

- **Never use `@Environment(\.dismiss)`** — always the navigator, so dismissal participates in the managed context.
- `dismiss()` returns whether anything was dismissed. A screen that can arrive both pushed and presented uses the fallback chain: dismiss, else pop.
- A `.managedCover` has no swipe-down gesture — it must render an explicit close affordance (toolbar close button calling `navigator.dismiss()`).
- Unsaved-data guard: `.interactiveDismissDisabled(hasUnsavedChanges)` on the presented content plus an explicit close button that confirms.

## Checkpoints — returning values to a parent

→ [reference.md §6](reference.md#6-checkpoints--returning-a-value-to-a-parent)

When a child flow must hand a value back (an editor returning its edit), use checkpoints instead of closures threaded through destinations:
1. **Declare** the checkpoints next to the parent screen, typed by the value they return (`NavigationCheckpoints`).
2. **The parent Screen** registers `.navigationCheckpoint(...) { value in … }` and forwards the value to its screen model.
3. **The child Screen** calls `navigator.returnToCheckpoint(_, value:)` on save.

`returnToCheckpoint` unwinds however many pushes/presents sit between child and parent — never add `dismiss()`/`pop()` after it. The returned payload is a plain `Hashable` value type (`struct ItemEdit: Hashable, Sendable`), never a screen model.

## Deep linking

Cross-feature or notification-driven navigation broadcasts values: `navigator.send(value)` from the initiator, `.onNavigationReceive { (value: SomeType) in ... }` on the receiving root. Destinations, not views, travel through deep links.

## Rules recap

1. `ManagedNavigationStack` at each tab/feature root; never raw `NavigationStack`.
2. One `<Name>ScreenDestination` enum per navigating screen, in its own file in the screen's folder; cases carry data, `body` builds Screens, `method` declares presentation.
3. ScreenModel owns `var destination: ...?` and sets it; Screen binds `.navigate(to:)`. The screen model never touches the navigator.
4. Modals are a destination `method` (`.managedSheet` / `.managedCover`), not `.sheet` / `.fullScreenCover` bindings. The one exception: fixed-height pickers use the design system's `.bottomSheet(item:…)`.
5. Never nest a `ManagedNavigationStack` inside a managed sheet/cover.
6. Dismiss/pop via `navigator` in the Screen — never `@Environment(\.dismiss)`, never `NavigationLink`.
7. Values return to parents through checkpoints; `returnToCheckpoint` does the popping itself.
8. Mutable-model destination cases hash by a stable kind.
9. The navigation bar is `.appToolbar(...)` on the Screen — title + back button by default; `onBack` calls the navigator (dismiss, else pop). Never on a View, never the system back button.
