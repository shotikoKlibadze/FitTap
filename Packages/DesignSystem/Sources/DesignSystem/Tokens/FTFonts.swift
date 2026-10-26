import SwiftUI

/// Typography tokens, named after Apple's text styles, each with semibold and
/// bold variants — the only source of fonts in the app.
public enum FTFonts {
    public static let largeTitle = Font.largeTitle
    public static let largeTitleSemibold = Font.largeTitle.weight(.semibold)
    public static let largeTitleBold = Font.largeTitle.weight(.bold)

    public static let title = Font.title
    public static let titleSemibold = Font.title.weight(.semibold)
    public static let titleBold = Font.title.weight(.bold)

    public static let title2 = Font.title2
    public static let title2Semibold = Font.title2.weight(.semibold)
    public static let title2Bold = Font.title2.weight(.bold)

    public static let title3 = Font.title3
    public static let title3Semibold = Font.title3.weight(.semibold)
    public static let title3Bold = Font.title3.weight(.bold)

    public static let headline = Font.headline
    public static let headlineSemibold = Font.headline.weight(.semibold)
    public static let headlineBold = Font.headline.weight(.bold)

    public static let subheadline = Font.subheadline
    public static let subheadlineSemibold = Font.subheadline.weight(.semibold)
    public static let subheadlineBold = Font.subheadline.weight(.bold)

    public static let body = Font.body
    public static let bodySemibold = Font.body.weight(.semibold)
    public static let bodyBold = Font.body.weight(.bold)

    public static let callout = Font.callout
    public static let calloutSemibold = Font.callout.weight(.semibold)
    public static let calloutBold = Font.callout.weight(.bold)

    public static let footnote = Font.footnote
    public static let footnoteSemibold = Font.footnote.weight(.semibold)
    public static let footnoteBold = Font.footnote.weight(.bold)

    public static let caption = Font.caption
    public static let captionSemibold = Font.caption.weight(.semibold)
    public static let captionBold = Font.caption.weight(.bold)

    public static let caption2 = Font.caption2
    public static let caption2Semibold = Font.caption2.weight(.semibold)
    public static let caption2Bold = Font.caption2.weight(.bold)
}

#if DEBUG
private struct FTFontRow: Identifiable {
    var id: String { name }
    let name: String
    let regular: Font
    let semibold: Font
    let bold: Font
}

private let ftFontRows: [FTFontRow] = [
    FTFontRow(name: "largeTitle", regular: FTFonts.largeTitle, semibold: FTFonts.largeTitleSemibold, bold: FTFonts.largeTitleBold),
    FTFontRow(name: "title", regular: FTFonts.title, semibold: FTFonts.titleSemibold, bold: FTFonts.titleBold),
    FTFontRow(name: "title2", regular: FTFonts.title2, semibold: FTFonts.title2Semibold, bold: FTFonts.title2Bold),
    FTFontRow(name: "title3", regular: FTFonts.title3, semibold: FTFonts.title3Semibold, bold: FTFonts.title3Bold),
    FTFontRow(name: "headline", regular: FTFonts.headline, semibold: FTFonts.headlineSemibold, bold: FTFonts.headlineBold),
    FTFontRow(name: "subheadline", regular: FTFonts.subheadline, semibold: FTFonts.subheadlineSemibold, bold: FTFonts.subheadlineBold),
    FTFontRow(name: "body", regular: FTFonts.body, semibold: FTFonts.bodySemibold, bold: FTFonts.bodyBold),
    FTFontRow(name: "callout", regular: FTFonts.callout, semibold: FTFonts.calloutSemibold, bold: FTFonts.calloutBold),
    FTFontRow(name: "footnote", regular: FTFonts.footnote, semibold: FTFonts.footnoteSemibold, bold: FTFonts.footnoteBold),
    FTFontRow(name: "caption", regular: FTFonts.caption, semibold: FTFonts.captionSemibold, bold: FTFonts.captionBold),
    FTFontRow(name: "caption2", regular: FTFonts.caption2, semibold: FTFonts.caption2Semibold, bold: FTFonts.caption2Bold),
]

private struct FTFontsPreviewHost: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(ftFontRows) { row in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.name).font(row.regular)
                        Text("\(row.name)Semibold").font(row.semibold)
                        Text("\(row.name)Bold").font(row.bold)
                    }
                }
            }
            .foregroundStyle(FTColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(FTColors.background)
    }
}
#Preview("Light") {
    FTFontsPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    FTFontsPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
