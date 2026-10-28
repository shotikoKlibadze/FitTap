import SwiftUI

/// How far a raised surface sits off the background — the shadow's size.
/// Only the shadow changes; the lit gradient, highlight and hairline that
/// carry elevation in dark mode are the same at every level.
public enum SurfaceElevation {
    /// Cards and fields: a soft, wide shadow.
    case regular
    /// Small tiles packed close together, like the week strip's day cells.
    /// Wide shadows would overlap into one slab; a tight one keeps each
    /// tile's own edge.
    case compact

    var shadowRadius: CGFloat {
        switch self {
        case .regular: 14
        case .compact: 6
        }
    }

    var shadowOffset: CGFloat {
        switch self {
        case .regular: 12
        case .compact: 4
        }
    }
}
