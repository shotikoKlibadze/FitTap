import SwiftUI

/// The app's navigation bar: inline title plus an optional glass icon button
/// on each side. A nil slot shows nothing. Screens never draw their own header
/// rows — they attach this with `.appToolbar(...)`.
struct AppToolbarModifier: ViewModifier {
    let title: String?
    let leading: AppToolbarButton?
    let trailing: AppToolbarButton?

    func body(content: Content) -> some View {
        content
            // Every toolbar screen starts its content 8pt below the bar.
            .safeAreaPadding(.top, 8)
            // Fade behind the status bar + bar row: content dissolves as it
            // scrolls under. Sized to the top safe area (read from the content
            // view, which starts at the bar's bottom) and lifted above it, so
            // it never covers content at rest.
            .overlay(alignment: .top) {
                GeometryReader { proxy in
                    FTGradients.fadeTop
                        .frame(height: proxy.safeAreaInsets.top)
                        .offset(y: -proxy.safeAreaInsets.top)
                }
                .allowsHitTesting(false)
            }
            .navigationBarBackButtonHidden()
            // Hiding the system back button also switches UIKit's edge-swipe
            // off; put it back.
            .restoresInteractivePop()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            // Kill the scroll-under blur the system draws at the top edge.
            .scrollEdgeEffectHidden(true, for: .top)
            // Pushed screens cover the tab bar; it returns on pop to the tab root.
            .toolbarVisibility(.hidden, for: .tabBar)
            // The buttons are plain glyphs on the system's shared glass, never
            // glass of our own: UIKit morphs its own bar-item glass from one
            // screen to the next on push and pop, but fades custom chrome out
            // and back in.
            .toolbar {
                if let leading {
                    ToolbarItem(placement: .topBarLeading) {
                        AppToolbarIconButton(button: leading)
                    }
                }

                if let title {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(FTFonts.headline)
                            .foregroundStyle(FTColors.textPrimary)
                            .lineLimit(1)
                    }
                }

                if let trailing {
                    ToolbarItem(placement: .topBarTrailing) {
                        AppToolbarIconButton(button: trailing)
                    }
                }
            }
    }
}

/// A bar item's glyph. The system draws the glass capsule around it.
private struct AppToolbarIconButton: View {
    let button: AppToolbarButton

    public var body: some View {
        Button(action: button.action) {
            button.icon.image
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(FTColors.textPrimary)
                .frame(width: 35, height: 35)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

public extension View {
    /// Attaches `AppToolbar`. `title: nil` leaves the principal slot empty;
    /// a nil `leading`/`trailing` shows nothing on that side.
    func appToolbar(
        title: String?,
        leading: AppToolbarButton? = nil,
        trailing: AppToolbarButton? = nil,
    ) -> some View {
        modifier(AppToolbarModifier(title: title, leading: leading, trailing: trailing))
    }
}

#if DEBUG
private struct AppToolbarPreviewHost: View {
    @State private var tapped = "—"

    var body: some View {
        NavigationStack {
            Text("Tapped: \(tapped)")
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(FTColors.background)
                .appToolbar(
                    title: "Add Exercise",
                    leading: AppToolbarButton(.back) { tapped = "back" },
                    trailing: AppToolbarButton(.confirm) { tapped = "confirm" },
                )
        }
    }
}
#Preview("Light") {
    AppToolbarPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    AppToolbarPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
