# Previews — reference examples

Full code examples for the rules in [SKILL.md](SKILL.md). Read the section a task needs.

## 1. The Light / Dark preview host

```swift
#if DEBUG
private struct WeightStepperPreviewHost: View {
    @State private var weight: Double = 20

    var body: some View {
        WeightStepper(weight: $weight, increments: [2.5, 5])
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Light") {
    WeightStepperPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WeightStepperPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
```

## 2. Sample fixtures on the model

```swift
#if DEBUG
extension Item {
    static let sample = Item(name: "Bench Press", weight: 60, reps: 8)
    static let sample2 = Item(name: "5k Run", distance: 5_000, duration: .minutes(26))
}
#endif
```
