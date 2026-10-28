import CoreGraphics
import DesignSystem

/// The set value picker's sheet is one fixed height for all its states —
/// reps presets, weight presets, custom entry — sized to the tallest (the
/// custom number panel). Every part is a static height, so it's computed,
/// not measured.
enum SetValuePickerMetrics {
    static let horizontalPadding: CGFloat = 20
    static let bottomPadding: CGFloat = 8
    /// Title (title3) + 4pt + subtitle (footnote) at default text size.
    static let headerHeight: CGFloat = 47

    static let contentHeight: CGFloat = headerHeight + NumberEntryPanel.Metrics.heightBelowHeader

    /// What `BottomSheet` gets: its handle strip, the content, the gap below.
    static let sheetHeight: CGFloat = BottomSheetMetrics.dragAreaHeight + contentHeight + bottomPadding

    // MARK: - Preset grid sized to fill the same content height

    static let gridRows: CGFloat = 5
    static let gridSpacing: CGFloat = 10
    static let customButtonHeight: CGFloat = PillButtonSize.regular.height
    static let sectionSpacing: CGFloat = 16

    /// Header, grid, and the Custom… button together fill `contentHeight`.
    static var gridCellHeight: CGFloat {
        let gridHeight = contentHeight - headerHeight - sectionSpacing * 2 - customButtonHeight
        return (gridHeight - gridSpacing * (gridRows - 1)) / gridRows
    }
}
