import SwiftUI

public extension View {
    /// Tells the screen's edge fades to step aside while a dimmed overlay is
    /// up.
    ///
    /// A screen has two fades: one behind the toolbar at the top (drawn by
    /// `appToolbar`) and one behind the pinned button at the bottom (drawn by
    /// `bottomActionBar`). Both sit above the screen's content. When a view
    /// dims its content with `FTColors.scrim` — the open Plan card, for
    /// example — the fades would stay undimmed on top and show as bands at the
    /// top and bottom of the screen. Pass `true` while the dim is shown and
    /// both fades fade out until it closes.
    ///
    /// Overlays presented as full-screen covers (`appAlert`) sit above the
    /// fades already and don't need this.
    func hidesEdgeFades(_ hidden: Bool) -> some View {
        preference(key: EdgeFadesHiddenKey.self, value: hidden)
    }
}

/// True when any view inside asks the edge fades to hide.
struct EdgeFadesHiddenKey: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}
