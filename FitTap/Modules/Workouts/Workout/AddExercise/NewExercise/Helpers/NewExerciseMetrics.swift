import CoreGraphics
import DesignSystem

/// The New Exercise sheet is one fixed height. Every part is a static
/// height, so it's computed, not measured.
enum NewExerciseMetrics {
    static let horizontalPadding: CGFloat = 20
    static let bottomPadding: CGFloat = 8
    static let sectionSpacing: CGFloat = 16
    /// "New Exercise" in title3 at default text size.
    static let headerHeight: CGFloat = 25
    static let fieldHeight: CGFloat = 48
    static let chipHeight: CGFloat = 36
    static let gridColumns = 4
    static let gridRows: CGFloat = 2
    static let gridSpacing: CGFloat = 8

    static var gridHeight: CGFloat {
        TileButton.height * gridRows + gridSpacing * (gridRows - 1)
    }

    static var contentHeight: CGFloat {
        headerHeight + fieldHeight + chipHeight + gridHeight + PillButtonSize.regular.height
            + sectionSpacing * 4
    }

    /// What `BottomSheet` gets: its handle strip, the content, the gap below.
    static var sheetHeight: CGFloat {
        BottomSheetMetrics.dragAreaHeight + contentHeight + bottomPadding
    }
}
