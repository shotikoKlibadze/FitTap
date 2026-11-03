import SwiftUI

/// One button in an `AppAlert`: a title, a pill style, and what it does.
/// The handler runs once the alert has fully left, so it can safely pop,
/// dismiss or start an animation; without one the button just closes it.
public struct AppAlertAction {
    let title: String
    let style: PillStyle
    let handler: (() -> Void)?

    public init(_ title: String, style: PillStyle = .secondary, action: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        handler = action
    }
}
