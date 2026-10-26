import CoreGraphics

/// `BottomSheet`'s fixed parts. Separate from the sheet because a static on a
/// generic type reads as `BottomSheet<EmptyView>.dragAreaHeight` — callers
/// sizing a sheet want the numbers, not a placeholder generic.
public enum BottomSheetMetrics {
    /// The strip at the top holding the drag handle; content starts below it,
    /// so it doubles as the sheet's top padding.
    public static let dragAreaHeight: CGFloat = 28
    public static let handleTopPadding: CGFloat = 8
    public static let handleWidth: CGFloat = 36
    public static let handleHeight: CGFloat = 5
    public static let cornerRadius: CGFloat = 32
}
