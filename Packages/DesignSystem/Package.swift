// swift-tools-version: 6.2
import PackageDescription

// FitTap's design system: tokens, generic components, view helpers. It knows
// nothing about the app's models — UI that needs them lives in the app.
// Compiler settings mirror the app target.
let package = Package(
    name: "DesignSystem",
    platforms: [.iOS("27.0")],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    targets: [
        .target(
            name: "DesignSystem",
            resources: [.process("Resources")],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("MemberImportVisibility"),
            ],
        ),
    ],
    swiftLanguageModes: [.v5],
)
