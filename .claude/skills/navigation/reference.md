# Navigation — reference examples

Full code examples for the rules in [SKILL.md](SKILL.md). Read the section a task needs.

## 1. Stack shape

```swift
TabView {
    Tab(value: .home) { ManagedNavigationStack { HomeScreen() } }
    Tab(value: .settings) { ManagedNavigationStack { SettingsScreen() } }
}
```

## 2. A destination enum

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

## 3. Hashing a mutable-model case by kind

```swift
extension SomeScreenDestination {
    static func == (l: Self, r: Self) -> Bool { l.kind == r.kind }
    func hash(into h: inout Hasher) { h.combine(kind) }
    private var kind: String {
        switch self { case .editor: "editor" /* … */ }
    }
}
```

## 4. ScreenModel drives, Screen binds

```swift
@MainActor
@Observable
final class SomeScreenModel {
    var destination: SomeScreenDestination?

    func didTapItem(_ item: Item) { destination = .detail(item) }
    func didTapEdit(_ item: Item) { destination = .editor(item) }
}

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

## 5. Navigator calls

```swift
@Environment(\.navigator) private var navigator

navigator.pop()            // back one pushed screen
navigator.pop(last: 2)     // back two
navigator.popToRoot()      // clear this stack
navigator.dismiss()        // close the presented sheet/cover — returns Bool

private func handleClose() {
    if navigator.dismiss() { return }   // was presented → closed
    navigator.pop()                     // was pushed → go back
}
```

## 6. Checkpoints — returning a value to a parent

```swift
// 1. Declare next to the parent screen, typed by the value returned
struct SomeCheckpoints: NavigationCheckpoints {
    static var edit: NavigationCheckpoint<ItemEdit> { checkpoint() }
    static var pickedDate: NavigationCheckpoint<Date> { checkpoint() }
}

// 2. Parent Screen registers the handler and forwards to its screen model
SomeView(...)
    .navigate(to: $screenModel.destination)
    .navigationCheckpoint(SomeCheckpoints.edit) { value in
        screenModel.applyEdit(value)
    }

// 3. Child Screen returns through it on save
private func handleSave() {
    // returnToCheckpoint pops back to the parent itself; never add dismiss()/pop() after.
    navigator.returnToCheckpoint(SomeCheckpoints.edit, value: screenModel.currentEdit)
}
```
