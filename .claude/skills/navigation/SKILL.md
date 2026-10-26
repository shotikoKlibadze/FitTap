---
name: navigation
description: Use when adding screens, pushing or presenting views, sheets, covers, dismissing, popping, deep links, or any navigation code — the app navigates with the NavigatorUI library (hmlongco/Navigator) through destination enums, not NavigationLink or .sheet bindings.
---

# Navigation with NavigatorUI

All navigation goes through [NavigatorUI](https://github.com/hmlongco/Navigator) (SPM: `https://github.com/hmlongco/Navigator`, `import NavigatorUI`). Screens declare *where* they can go in a destination enum; screen models decide *when* by setting a destination property; the Navigator does the rest. `NavigationLink` and raw `.sheet` / `.fullScreenCover` bindings are banned in feature code.

This layers on the `architecture` skill's Screen / ScreenModel / View split:
- **View** — knows nothing about navigation; it fires callbacks.
- **ScreenModel** — owns `var destination: SomeScreenDestination?` and sets it in intent methods. Never touches the navigator.
- **Screen** — binds the destination with `.navigate(to:)`, holds `@Environment(\.navigator)` for imperative calls (pop, dismiss, checkpoint returns).

## Stack shape

`ManagedNavigationStack` (NavigatorUI's replacement for `NavigationStack` — never use the raw one) sits at the root of each tab / feature flow:

```swift
TabView {
    Tab(value: .home) { ManagedNavigationStack { HomeScreen() } }
    Tab(value: .settings) { ManagedNavigationStack { SettingsScreen() } }
}
```

No `.navigationDestination(for:)` registrations are needed — the managed stack handles rendering.

## Destinations

Every screen that navigates gets a `<Name>ScreenDestination` enum (e.g. `HomeScreenDestination`), a separate file in the screen's folder, conforming to `NavigationDestination`. Cases carry plain data; `body` constructs the child **Screen**; `method` declares how each case presents:

```swift
import NavigatorUI
import SwiftUI

enum SomeScreenDestination: NavigationDestination {
    case detail(Item)           // pushed
    case editor(Item)           // its own modal flow
    case picker                 // small modal choice

    var body: some View {
        switch self {
        case .detail(let item): DetailScreen(item: item)
        case .editor(let item): EditorScreen(item: item)
        case .picker:           PickerScreen()
        }
    }

    var method: NavigationMethod {
        switch self {
        case .detail: .push
        case .editor: .managedCover
        case .picker: .managedSheet
        }
    }
}
```

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

`NavigationDestination` is `Hashable`. Cases carrying immutable values use synthesized conformance. A case carrying a **mutable model** (an edit screen) must hash by a stable kind, or mutating the model re-presents the sheet mid-edit (keyboard drop, flicker):

```swift
extension SomeScreenDestination {
    static func == (l: Self, r: Self) -> Bool { l.kind == r.kind }
    func hash(into h: inout Hasher) { h.combine(kind) }
    private var kind: String {
        switch self { case .editor: "editor" /* … */ }
    }
}
```

## ScreenModel drives, Screen binds

The screen model owns the destination as plain optional state — setting it presents, nil tears down:

```swift
@MainActor
@Observable
final class SomeScreenModel {
    var destination: SomeScreenDestination?

    func didTapItem(_ item: Item) {
        destination = .detail(item)
    }
    func didTapEdit(_ item: Item) {
        destination = .editor(item)
    }
}
```

The Screen wires it with one modifier:

```swift
struct SomeScreen: View {
    @State private var screenModel = SomeScreenModel()

    var body: some View {
        SomeView(
            items: screenModel.items,
            onTapItem: screenModel.didTapItem,
            onTapEdit: screenModel.didTapEdit,
        )
        .navigate(to: $screenModel.destination)   // or .navigate(to: Bindable(screenModel).destination)
    }
}
```

The screen model never imports NavigatorUI's navigator and never sees a view — it only holds the enum. This keeps it testable: asserting navigation is asserting `screenModel.destination`.

## Dismiss and pop

Imperative navigation lives in the **Screen** via the environment navigator:

```swift
@Environment(\.navigator) private var navigator

navigator.pop()            // back one pushed screen
navigator.pop(last: 2)     // back two
navigator.popToRoot()      // clear this stack
navigator.dismiss()        // close the presented sheet/cover — returns Bool
```

- **Never use `@Environment(\.dismiss)`** — always the navigator, so dismissal participates in the managed context.
- `dismiss()` returns whether anything was dismissed. A screen that can arrive both pushed and presented uses the fallback chain:

```swift
private func handleClose() {
    if navigator.dismiss() { return }   // was presented → closed
    navigator.pop()                     // was pushed → go back
}
```

- A `.managedCover` has no swipe-down gesture — it must render an explicit close affordance (toolbar close button calling `navigator.dismiss()`).
- Unsaved-data guard: `.interactiveDismissDisabled(hasUnsavedChanges)` on the presented content plus an explicit close button that confirms.

## Checkpoints — returning values to a parent

When a child flow must hand a value back (an editor returning its edit), use checkpoints instead of closures threaded through destinations.

**1. Declare** the checkpoints next to the parent screen, typed by the value they return:

```swift
struct SomeCheckpoints: NavigationCheckpoints {
    static var edit: NavigationCheckpoint<ItemEdit> { checkpoint() }
    static var pickedDate: NavigationCheckpoint<Date> { checkpoint() }
}
```

**2. The parent Screen** registers handlers — receive the value, forward it to the screen model:

```swift
SomeView(...)
    .navigate(to: $screenModel.destination)
    .navigationCheckpoint(SomeCheckpoints.edit) { value in
        screenModel.applyEdit(value)
    }
```

**3. The child Screen** returns through the checkpoint on save:

```swift
private func handleSave() {
    // returnToCheckpoint pops back to the parent itself; never add dismiss()/pop() after.
    navigator.returnToCheckpoint(SomeCheckpoints.edit, value: screenModel.currentEdit)
}
```

`returnToCheckpoint` unwinds however many pushes/presents sit between child and parent. The returned payload is a plain `Hashable` value type (`struct ItemEdit: Hashable, Sendable`), never a screen model.

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
