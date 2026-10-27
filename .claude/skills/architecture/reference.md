# Architecture — reference examples

Full code examples for the rules in [SKILL.md](SKILL.md). Read the section a task needs.

## 1. A complete Screen

```swift
struct SomeScreen: View {
    @State private var screenModel = SomeScreenModel()
    @Environment(\.navigator) private var navigator

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
        .appToolbar(title: "Items", onBack: handleBack)
    }

    private func handleBack() {
        if navigator.dismiss() { return }   // was presented → close
        navigator.pop()                     // was pushed → go back
    }
}
```

## 2. A complete ScreenModel

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

## 3. A complete View with its previews

```swift
struct SomeView: View {
    let title: String
    let items: [Item]
    let isLoading: Bool
    let onTapItem: (Item) -> Void
    let onTapAdd: () -> Void
    let onDelete: (Item) -> Void
    let onRefresh: () async -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) { ... }        // no horizontal padding here
        }
        .contentMargins(.horizontal, 8, for: .scrollContent)   // 8 + system 8 = 16
        .scrollIndicators(.hidden)
        .background(FTColors.background)
    }
}

#if DEBUG
private struct SomeViewPreviewHost: View {
    var body: some View {
        SomeView(
            title: "3 items",
            items: [.sample],
            isLoading: false,
            onTapItem: { _ in }, onTapAdd: {}, onDelete: { _ in }, onRefresh: {},
        )
    }
}

#Preview("Light") { SomeViewPreviewHost().preferredColorScheme(.light) }
#Preview("Dark") { SomeViewPreviewHost().preferredColorScheme(.dark) }
#endif
```
