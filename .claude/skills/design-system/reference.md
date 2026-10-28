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
/// Shared by the flat and the glass pill, so both read the same.
public enum PillStyle { case primary, secondary, destructive }

public struct PillButton: View {
    let title: String
    let style: PillStyle
    let disabled: Bool
    let action: () -> Void

    public init(title: String, style: PillStyle = .primary, disabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.disabled = disabled
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
            PillButton(title: "Save", disabled: isDisabled) { tapCount += 1 }
            PillButton(title: "Cancel", style: .secondary, disabled: isDisabled) { tapCount += 1 }
            PillButton(title: "Discard", style: .destructive, disabled: isDisabled) { tapCount += 1 }
            PillButton(title: isDisabled ? "Enable them" : "Disable them", style: .secondary) { isDisabled.toggle() }
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
