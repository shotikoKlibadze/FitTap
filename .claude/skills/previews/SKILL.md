---
name: previews
description: Use when writing any SwiftUI view, subview, or #Preview block, or adding sample data for previews — every view and subview ships a preview, and this defines what each preview must show and where fixture data lives.
paths:
  - "FitTap/**/*.swift"
  - "Packages/**/*.swift"
---

# Preview Conventions

Every dumb view in the app carries a `#Preview`. The architecture's dumbness guarantee (see the `architecture` skill) is what makes this free: a preview is literal values and empty closures — no containers, no mocks, no setup. If a preview is hard to write, the view isn't dumb enough; fix the view, not the preview.

Full code examples: [reference.md](reference.md).

## `#if DEBUG` — always

Every `#Preview` block, and every helper that exists only for previews (private preview hosts, swatch lists, fixtures), is wrapped in `#if DEBUG … #endif` so none of it ships. One wrapper per file, placed after the last production type:

```swift
struct WeightStepper: View { … }

#if DEBUG
#Preview("Editing") {
    @Previewable @State var weight: Double = 20
    WeightStepper(weight: $weight, increments: [2.5, 5])
}
#endif
```

A `#Preview` outside `#if DEBUG` is a defect, even in a file with a single preview. *Enforced by the `check-previews-in-debug.sh` hook.*

## Exactly two previews: Light and Dark

Every file with previews has **exactly two**, named `"Light"` and `"Dark"` — never per-state variants ("Empty", "Loading", "Filled"). Both render one **full, interactive** version of the view through a private host that owns the state, so every tap, toggle and selection works live in either mode. → [reference.md §1](reference.md#1-the-light--dark-preview-host)

- The host is the one place state lives: `@State` for bindings (never `.constant`), plus small demo state where it makes the preview visibly interactive (a tap counter, a disable toggle). Want another state visible? Make it reachable by interacting with the one full preview, not by adding a variant.
- Callbacks a preview can't meaningfully perform are empty closures; a preview never does real work.
- Every `SomeView`, every `Subviews/` struct, every design-system component and every token showcase follows this. Screens (which own a screen model) don't need previews.

## Sample data

- Fixture values live as `static` extensions next to the model type, wrapped in `#if DEBUG` so they can't ship. → [reference.md §2](reference.md#2-sample-fixtures-on-the-model)

- Previews use these fixtures — never inline ad-hoc model construction repeated across preview blocks.

## Screens

Screens are not required to have previews — they own the screen model, DI, and navigation, so a screen preview buys little over running the app. If one is genuinely useful, override the container registrations locally per the `dependency-injection` skill.

## Design-system components

A design-system component's preview is a **gallery of all its states and variants** — the full convention lives in the `design-system` skill.

## Rules recap

1. Every view, subview, component and token showcase has previews; screens don't need one.
2. Exactly two previews per file — `"Light"` and `"Dark"` — never per-state variants.
3. Both render one full, interactive version through a private `…PreviewHost` that owns the `@State`; never `.constant`.
4. Fixtures are `static` extensions on the model, `#if DEBUG`-wrapped, reused across previews.
5. A hard-to-write preview means the view isn't dumb — fix the view.
6. Every `#Preview` and preview-only helper sits inside `#if DEBUG … #endif` — no exceptions.
