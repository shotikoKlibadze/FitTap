import SwiftUI

/// Icon tokens — template-rendered vector assets from `Assets.xcassets/Icons`.
/// The only source of custom glyphs in the app; SF Symbols are fine for
/// anything not listed here.
public enum FTIcons {
    public static let caretLeft = Image("CaretLeft.outline", bundle: .module)
    public static let caretDown = Image("CaretDown.outline", bundle: .module)
    public static let close = Image("Close.outline", bundle: .module)
    public static let more = Image("More.outline", bundle: .module)
    public static let xMark = Image("X.bold", bundle: .module)
    public static let check = Image("Check.bold", bundle: .module)
    public static let plus = Image(systemName: "plus")
    public static let chevronLeft = Image(systemName: "chevron.left")
    public static let chevronRight = Image(systemName: "chevron.right")
    public static let chevronDown = Image(systemName: "chevron.down")
    public static let chevronUp = Image(systemName: "chevron.up")
    public static let trash = Image(systemName: "trash")
    /// Trend arrows — a progression row's up, flat or down.
    public static let arrowUp = Image(systemName: "arrow.up")
    public static let arrowRight = Image(systemName: "arrow.right")
    public static let arrowDown = Image(systemName: "arrow.down")
    /// The ⓘ beside something the app noticed — a suggestion's marker.
    public static let info = Image(systemName: "info.circle")
    public static let wandAndSparkles = Image(systemName: "wand.and.sparkles.inverse")
}

#if DEBUG
private struct FTIconRow: Identifiable {
    var id: String { name }
    let name: String
    let image: Image
}

private let ftIconRows: [FTIconRow] = [
    FTIconRow(name: "caretLeft", image: FTIcons.caretLeft),
    FTIconRow(name: "caretDown", image: FTIcons.caretDown),
    FTIconRow(name: "close", image: FTIcons.close),
    FTIconRow(name: "more", image: FTIcons.more),
    FTIconRow(name: "xMark", image: FTIcons.xMark),
    FTIconRow(name: "check", image: FTIcons.check),
    FTIconRow(name: "plus", image: FTIcons.plus),
    FTIconRow(name: "chevronLeft", image: FTIcons.chevronLeft),
    FTIconRow(name: "chevronRight", image: FTIcons.chevronRight),
    FTIconRow(name: "chevronDown", image: FTIcons.chevronDown),
    FTIconRow(name: "chevronUp", image: FTIcons.chevronUp),
    FTIconRow(name: "trash", image: FTIcons.trash),
]

private struct FTIconsPreviewHost: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(ftIconRows) { row in
                HStack(spacing: 12) {
                    row.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(FTColors.textPrimary)
                    Text(row.name)
                        .font(FTFonts.body)
                        .foregroundStyle(FTColors.textPrimary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(FTColors.background)
    }
}
#Preview("Dark") {
    FTIconsPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    FTIconsPreviewHost()
        .preferredColorScheme(.light)
}
#endif
