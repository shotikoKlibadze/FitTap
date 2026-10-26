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
#Preview("Light") {
    FTIconsPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    FTIconsPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
