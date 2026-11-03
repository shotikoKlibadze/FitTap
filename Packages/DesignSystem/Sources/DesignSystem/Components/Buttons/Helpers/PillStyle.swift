import SwiftUI

/// What a pill button means — shared by `PillButton` (flat fill) and
/// `GlassPillButton` (the same color as a glass tint), so both read the same.
public enum PillStyle {
    /// The main action: green.
    case primary
    /// The other action beside it, or a quiet one: a faint surface.
    case secondary
    /// Deletes, discards or stops: red.
    case destructive
    /// Adds one more of something inside a card ("+ Add Set"): the faint
    /// secondary surface with yellow text.
    case add

    var fill: Color {
        switch self {
        case .primary: FTColors.green
        case .secondary, .add: FTColors.surfaceSecondary
        case .destructive: FTColors.red
        }
    }

    /// Green and red stay dark in both modes, so their text is always the
    /// fixed off-white; the faint secondary surface takes the adaptive text.
    var text: Color {
        switch self {
        case .primary, .destructive: FTCoreColors.offWhite
        case .secondary: FTColors.textPrimary
        case .add: FTColors.yellow
        }
    }
}
