---
name: architecture
description: Use when creating or refactoring any SwiftUI screen, view, or screen model — defines the Screen / ScreenModel / View split, who owns what, how callbacks route, and where sheets and navigation are handled.
---

# Screen / ScreenModel / View Architecture

Every screen in the app is built from three types. The names use a shared base: `SomeScreen`, `SomeScreenModel`, `SomeView`.

```
SomeScreen        smart container — owns the ScreenModel, binds navigation & presentation
SomeScreenModel   @Observable logic — state, services, API calls, destination
SomeView          dumb view — accepts properties, propagates callbacks up
```

## Folder layout

Each screen is a feature folder holding one file per type, plus the destination enum when the screen navigates, plus a `Subviews/` folder for the view's building blocks and a `Helpers/` folder for its supporting types:

```
Home/
├── HomeScreen.swift
├── HomeScreenModel.swift
├── HomeView.swift
├── HomeScreenDestination.swift    // only when the screen navigates
├── Subviews/
│   ├── WorkoutCard.swift
│   └── StreakBadge.swift
└── Helpers/
    └── StreakSummary.swift
```

- **Helper types live in the `Helpers/` folder of the screen that uses them — a hard rule.** A helper is a supporting non-view type: a value handed back from a child screen, a context passed into one, a metrics or constants enum, a small formatter. Never leave one loose in a feature folder.
- **The consumer owns it.** A value a child screen returns to its parent belongs to the parent, so it lives in the parent's `Helpers/` (e.g. `NewWorkout/Helpers/SetValueEdit.swift`, which the set value picker returns to New Workout). A type a screen only uses itself lives in that screen's `Helpers/` (e.g. `SetValuePicker/Helpers/SetValuePickerContext.swift`).
- A helper used by several features isn't a screen helper: it moves to `Core/` (logic and models) or the design system (UI).
- The screen's own files — Screen, ScreenModel, View, Destination, Checkpoints — stay at the feature folder's root.

- **16 pt horizontal gutter on every screen — a hard rule.** A scrolling screen is a `ScrollView` with `.contentMargins(.horizontal, 8, for: .scrollContent)`: the scroll view already contributes 8, so 8 + 8 = the 16 pt gutter. Never pad the scroll content horizontally on top of that, and never use a different margin value. A non-scrolling screen gets `.padding(.horizontal, 16)` on its root content. Bottom-pinned controls in `.safeAreaInset` use `.padding(.horizontal, 16)` to line up with the content.
- **Scroll indicators are hidden on every scroll view** — `.scrollIndicators(.hidden)` (or `showsIndicators: false` on a horizontal one). Calm screens: no bar flashing in while scrolling.
- **Exception: a list inside a fixed-size box** (a dropdown, an open picker) where the options are cut off and nothing else hints there's more. It uses `.scrollIndicators(.visible)` plus `.scrollIndicatorsFlash(onAppear: true)`, so the bar flashes once when it opens.

```swift
ScrollView {
    VStack(spacing: 16) { … }           // no horizontal padding here
}
.contentMargins(.horizontal, 8, for: .scrollContent)   // 8 + system 8 = 16
.scrollIndicators(.hidden)
```

- **View files stay under 300–400 lines.** When a view grows past that, refactor — extract pieces into `Subviews/` as separate dumb `struct`s. Subviews follow all the View rules below and each gets its own `#Preview` (see the `previews` skill).
- A subview used by more than one feature graduates to the design system (see the `design-system` skill) — it doesn't stay in a feature's `Subviews/`.

## The Screen

The Screen is the smart layer and the only one that composes the other two:

- Owns the screen model: `@State private var screenModel = SomeScreenModel()`.
- Renders `SomeView`, passing it plain values from the screen model and callback closures — most callbacks forward straight into ScreenModel methods.
- **All navigation and presentation go through the screen's destination enum** (see the `navigation` skill): the ScreenModel sets `destination` in its intent methods, and the Screen binds it once with `.navigate(to:)`. Pushes, sheets, and covers are all destination cases — raw `.sheet` / `.fullScreenCover` / `NavigationLink` are banned in feature code. Views never present anything.
- **Imperative navigation** (pop, dismiss, checkpoint returns) lives in the Screen via `@Environment(\.navigator)`.
- Lifecycle wiring (`.task`, `.onAppear`, `.onChange`) lives here.
- **The toolbar is attached here, never in the View.** Every Screen ends with `.appToolbar(title:onBack:)` (see the `design-system` skill): a title and a back button are the default on every screen, and `onBack` routes to the navigator. Drop the back button or the title only when explicitly told to. Views never draw header rows, titles, cancel/back buttons, or call `.toolbar` / `.appToolbar`.

```swift
        .navigate(to: $screenModel.destination)
        .appToolbar(title: "New Workout", onBack: handleBack)
    }

    private func handleBack() {
        if navigator.dismiss() { return }
        navigator.pop()
    }
```

```swift
struct SomeScreen: View {
    @State private var screenModel = SomeScreenModel()

    var body: some View {
        SomeView(
            title: screenModel.title,
            items: screenModel.items,
            isLoading: screenModel.isLoading,
            onTapItem: screenModel.didTapItem,   // sets destination → pushes DetailScreen
            onTapAdd: screenModel.didTapAdd,     // sets destination → presents editor sheet
            onDelete: screenModel.delete,        // service/API work
            onRefresh: { await screenModel.refresh() },
        )
        .task { await screenModel.load() }
        .navigate(to: $screenModel.destination)  // one binding covers push, sheet, and cover
    }
}
```

## The ScreenModel

- `@MainActor @Observable final class`.
- Owns screen state and everything behind it: services, API calls, persistence.
- Owns `var destination: SomeScreenDestination?` and sets it in intent methods — holding the enum is just data; it never touches the navigator or builds views (see the `navigation` skill).
- Exposes presentation-ready values (formatted strings, computed flags) and action methods the Screen forwards into.
- Externally-mutated state is `var` (for bindings); everything else `private(set)`.
- Never builds or references views.

```swift
@MainActor
@Observable
final class SomeScreenModel {
    var destination: SomeScreenDestination?

    private(set) var items: [Item] = []
    private(set) var isLoading = false

    var title: String { "\(items.count) items" }

    func didTapItem(_ item: Item) { destination = .detail(item) }
    func didTapAdd() { destination = .editor }

    func load() async { ... }
    func refresh() async { ... }
    func delete(_ item: Item) { ... }
}
```

## The View

The View is dumb — a pure function of its inputs:

- Accepts only `let` properties, `@Binding`s, and callback closures. It never owns or receives the screen model.
- Propagates every user action **up through callbacks** — it doesn't know or care whether the callback changes state, hits a service, or navigates.
- No navigation, no sheets, no service or API access, no domain formatting.
- Local `@State` only for pure UI concerns (scroll position, focus, gesture state).
- Subviews are extracted as separate dumb `struct`s (never `@ViewBuilder` methods) and follow the same rules.
- Carries a `#Preview` with literal values — dumbness is what makes previews free (conventions in the `previews` skill).

```swift
struct SomeView: View {
    let title: String
    let items: [Item]
    let isLoading: Bool
    let onTapItem: (Item) -> Void
    let onTapAdd: () -> Void
    let onDelete: (Item) -> Void
    let onRefresh: () async -> Void

    var body: some View { ... }
}

#Preview {
    SomeView(
        title: "3 items",
        items: [.sample],
        isLoading: false,
        onTapItem: { _ in }, onTapAdd: {}, onDelete: { _ in }, onRefresh: {},
    )
}
```

## Rules recap

1. Screen owns the ScreenModel and is the only smart layer.
2. View accepts properties and propagates callbacks — nothing else.
3. ScreenModel drives navigation and presentation by setting `destination`; the Screen binds it with `.navigate(to:)` and handles imperative pop/dismiss via the navigator.
4. Sheets and covers are destination cases (`.managedSheet` / `.managedCover`) — never raw `.sheet` / `.fullScreenCover` bindings.
5. ScreenModel is `@MainActor @Observable final class` and never touches view code or the navigator.
6. `.appToolbar` sits on the Screen, always with a title and a back button unless told otherwise; Views never draw headers or toolbars.
7. Every screen keeps a 16 pt horizontal gutter: `ScrollView` + `.contentMargins(.horizontal, 8, for: .scrollContent)` (8 + the scroll view's own 8), or `.padding(.horizontal, 16)` when nothing scrolls. No extra horizontal padding on scroll content. Scroll indicators always hidden.
