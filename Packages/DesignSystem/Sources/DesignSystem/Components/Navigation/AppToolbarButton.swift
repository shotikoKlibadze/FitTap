import SwiftUI

/// A toolbar slot: a glyph or a short word ("Edit"), and what its tap does.
public struct AppToolbarButton {
    enum Label {
        case icon(RoundButton.Icon)
        case text(String)
    }

    let label: Label
    let action: () -> Void

    public init(_ icon: RoundButton.Icon, action: @escaping () -> Void) {
        label = .icon(icon)
        self.action = action
    }

    /// A word instead of a glyph. Keep it to one short verb — the system
    /// glass capsule grows with it.
    public init(title: String, action: @escaping () -> Void) {
        label = .text(title)
        self.action = action
    }
}
