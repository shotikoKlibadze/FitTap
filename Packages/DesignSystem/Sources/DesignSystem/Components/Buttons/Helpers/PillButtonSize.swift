import SwiftUI

/// Height and type of a pill button — shared by `PillButton` and
/// `GlassPillButton`.
public enum PillButtonSize {
    /// Primary actions — 54 pt.
    case regular
    /// Secondary actions inside dense content — 44 pt.
    case compact

    public var height: CGFloat {
        switch self {
        case .regular: 54
        case .compact: 44
        }
    }

    var font: Font {
        switch self {
        case .regular: FTFonts.headline
        case .compact: FTFonts.subheadlineSemibold
        }
    }
}
