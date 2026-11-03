import SwiftUI

/// How far a raised surface sits off the background — the shadow's size.
/// Only the shadow changes; the flat fill and hairline are the same at
/// every level.
public enum SurfaceElevation {
    /// Cards and fields: a soft shadow, radius 9, 3 pt down
    /// (CSS `0 6px 18px` in the design mocks).
    case regular
    /// Small tiles packed close together, like the week strip's day cells.
    /// Wide shadows would overlap into one slab; a tight one keeps each
    /// tile's own edge. Scaled down from `regular` in the same proportion
    /// the old values had.
    case compact

    var shadowRadius: CGFloat {
        switch self {
        case .regular: 9
        case .compact: 4
        }
    }

    var shadowOffset: CGFloat {
        switch self {
        case .regular: 3
        case .compact: 2
        }
    }
}
