# Design system — reference examples

Full code examples for the rules in [SKILL.md](SKILL.md). Read the section a task needs.

## 1. Making the whole shape tappable

```swift
Text(title)
    .frame(maxWidth: .infinity)
    .frame(height: 44)
    .contentShape(Capsule())   // the whole pill, not just the letters
    .onTapGesture { select() }
```

## 2. Component shape — variants as enums, states from inputs

```swift
public struct PillButton: View {
    public enum Style { case primary, secondary, destructive }

    let title: String
    var style: Style = .primary
    var isLoading = false
    let action: () -> Void

    public init(title: String, style: Style = .primary, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View { ... }
}
```

## 3. The Light / Dark gallery host

```swift
#if DEBUG
private struct PillButtonPreviewHost: View {
    @State private var tapCount = 0
    @State private var isDisabled = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Taps: \(tapCount)")
            PillButton(title: "Create workout", disabled: isDisabled) { tapCount += 1 }
            PillButton(title: "Start Workout", color: .red, disabled: isDisabled) { tapCount += 1 }
            PillButton(title: isDisabled ? "Enable them" : "Disable them") { isDisabled.toggle() }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") { PillButtonPreviewHost().preferredColorScheme(.light) }
#Preview("Dark") { PillButtonPreviewHost().preferredColorScheme(.dark) }
#endif
```
