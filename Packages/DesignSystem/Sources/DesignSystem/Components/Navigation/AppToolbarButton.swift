import SwiftUI

/// A toolbar slot: which glyph to show and what its tap does.
public struct AppToolbarButton {
    let icon: RoundButton.Icon
    let action: () -> Void

    public init(_ icon: RoundButton.Icon, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
}
